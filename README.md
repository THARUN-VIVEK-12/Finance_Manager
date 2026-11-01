# Personal Finance Manager — Vercel + Supabase

This is the upgraded version of the supplied Personal Finance Manager HTML app.
It keeps the original dashboard, transactions, income, expenses, people/loans,
banks, budgets, bills, reports, settings, and JSON import/export. It adds Google
OAuth, email/password authentication, Supabase cloud persistence, a local cache,
and first-login migration from the old browser data.

## Important privacy model

This build is configured for ONE personal email address. The same address must
be entered in `config.js` and in the four owner policies in `supabase/schema.sql`.
The database policies enforce the email restriction server-side and also require
`user_id = auth.uid()`. Do not remove RLS or replace the anon key with a service-role
key. Never put a Supabase service-role key in browser code.

The app stores the full finance data object in one JSONB row per owner. This keeps
the existing app data model intact and makes migration straightforward. It is
appropriate for a personal finance tracker with moderate data volume. The browser
cache is a convenience/offline fallback, not a substitute for cloud backups.

## 1. Create the Supabase project

1. Open https://supabase.com/ and create a Free project.
2. Choose a strong database password and save it somewhere private.
3. Wait for the database to finish provisioning.
4. Open **Project Settings → API** (or **API Keys**) and copy:
   - Project URL
   - `anon` / publishable browser key
5. Open **SQL Editor → New query**.
6. Open `supabase/schema.sql` in this project.
7. Replace every occurrence of `YOUR_EMAIL@gmail.com` with your exact personal
   Google/email address. Keep the quotes around the email.
8. Run the complete SQL script. Confirm that `public.finance_data` exists and
   Row Level Security is enabled.

## 2. Configure the application

1. Open `config.js`.
2. Replace `https://YOUR_PROJECT_REF.supabase.co` with your Supabase Project URL.
3. Replace `YOUR_SUPABASE_ANON_OR_PUBLISHABLE_KEY` with the anon/publishable key.
4. Replace `YOUR_EMAIL@gmail.com` with the same personal email used in the SQL.
5. Save the file.

The Supabase anon/publishable key is a public browser key. The security boundary
is RLS, not hiding this key. NEVER use the `service_role` / secret key here.

## 3. Enable Email authentication

1. In Supabase open **Authentication → Providers → Email**.
2. Enable Email provider.
3. For a personal app, keep email confirmation enabled if you want confirmation
   before email/password accounts can sign in.
4. Email/password users must use the same allowed email address configured above.

## 4. Enable Google login

1. Open Google Cloud Console: https://console.cloud.google.com/
2. Create/select a project and configure the Google Auth Platform consent screen.
3. Create an OAuth Client ID with application type **Web application**.
4. In Google OAuth client settings, add your deployed Vercel origin under
   **Authorized JavaScript origins** (for example `https://your-app.vercel.app`).
5. In Google OAuth client settings, add this exact redirect URI under
   **Authorized redirect URIs**:
   `https://YOUR_PROJECT_REF.supabase.co/auth/v1/callback`
6. Copy the Google Client ID and Client Secret.
7. In Supabase open **Authentication → Providers → Google**, enable Google,
   paste the Client ID and Client Secret, and save.
8. In Supabase open **Authentication → URL Configuration**:
   - Set Site URL to your Vercel URL, e.g. `https://your-app.vercel.app`
   - Add `https://your-app.vercel.app/**` to Redirect URLs
   - For local testing also add `http://localhost:5500/**` if using that port.

Supabase's Google provider setup guide:
https://supabase.com/docs/guides/auth/social-login/auth-google

## 5. Deploy to GitHub and Vercel

1. Create a new GitHub repository, e.g. `personal-finance-manager`.
2. Upload the project contents:
   - `index.html`
   - `config.js`
   - `vercel.json`
   - `supabase/schema.sql`
   - `README.md`
3. In Vercel choose **Add New → Project**, import the GitHub repository.
4. Framework Preset: **Other**.
5. Build Command: leave blank.
6. Output Directory: `.` (project root).
7. Deploy.
8. Copy the production URL and add it to Supabase Auth URL Configuration and
   Google OAuth Authorized JavaScript origins as described above.

This is a static site: no Node server, build step, or paid backend is required.
Pushing later changes to the connected GitHub production branch triggers a new
Vercel deployment.

## 6. First login and migrate your old browser data

1. BEFORE switching to the new Vercel URL, open your old Personal Finance
   Manager in the browser where its records currently exist.
2. Open **Settings & Backup → Export JSON** and save the backup file. This is
   the safest migration method because browser storage is isolated by website
   origin; a new Vercel domain cannot normally read localStorage from an old
   `file://` page or a different website URL.
3. Deploy and configure the new app, then open the Vercel URL.
4. Sign in with the configured Google account, or create/sign in with the same
   email using the email form.
5. If Supabase has no finance row yet, the app automatically migrates any
   localStorage/IndexedDB data that is accessible on that same origin.
6. For the guaranteed cross-origin migration, open **Settings & Backup →
   JSON Restore**, choose the backup exported in step 2, and keep **Replace
   existing data** selected. The imported data is saved to Supabase.
7. Wait for **Synced to Supabase**, then open Dashboard, Transactions, Banks,
   People, Budgets and Reports and verify the records.
8. Export a fresh JSON backup from Settings or Reports and keep it somewhere
   safe.

If a cloud row already exists, the cloud copy takes precedence during sign-in.
Import your old JSON backup afterward if you need to merge/replace it. Do not
delete the old browser storage or backup until you have verified the cloud data.

## 7. Local testing

Use VS Code Live Server or another local static server. For example:
- Open the project folder in VS Code.
- Right-click `index.html`.
- Choose **Open with Live Server**.
- Add the exact local origin (e.g. `http://127.0.0.1:5500`) to Supabase Auth
  Redirect URLs and Google Authorized JavaScript origins if testing Google login.

Opening the file directly as `file://` is not recommended for OAuth.

## Data and security notes

- Each account can read/write only its own row, and the SQL additionally restricts
  access to the one configured email.
- The finance payload includes transaction descriptions/comments, account names,
  last four account digits, loans, budgets and bills. Do not store full bank account
  numbers, card numbers, PINs, CVVs, passwords, or UPI PINs.
- This app is a manual personal finance tracker, not a bank connection service.
  It does not connect to banks or fetch balances automatically.
- LocalStorage/IndexedDB are used as a local cache and migration source. Cloud
  synchronization requires an internet connection.
- If cloud sync fails, the UI shows an error and the browser cache remains. Export
  a JSON backup and resolve the cloud issue before relying on another device.
- Free-plan quotas, inactivity pausing, email limits, and provider policies can
  change. Check the current Supabase and Vercel plan limits before relying on
  them for long-term storage.
