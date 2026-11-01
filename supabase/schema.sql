-- Personal Finance Manager: private single-user cloud storage
-- IMPORTANT: Replace YOUR_EMAIL@gmail.com with the exact Google/email address
-- that is allowed to use this private application before running this SQL.

create table if not exists public.finance_data (
  user_id uuid primary key references auth.users(id) on delete cascade,
  data jsonb not null default '{
    "version": 1,
    "profile": {"name": "My Finance"},
    "transactions": [],
    "people": [],
    "banks": [],
    "budgets": {},
    "bills": [],
    "goals": [],
    "settings": {"currency": "INR", "theme": "light"}
  }'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.finance_data enable row level security;

drop policy if exists "Only the configured owner can read finance data" on public.finance_data;
drop policy if exists "Only the configured owner can insert finance data" on public.finance_data;
drop policy if exists "Only the configured owner can update finance data" on public.finance_data;
drop policy if exists "Only the configured owner can delete finance data" on public.finance_data;

create policy "Only the configured owner can read finance data"
on public.finance_data for select
to authenticated
using (
  user_id = (select auth.uid())
  and lower(coalesce(auth.jwt() ->> 'email', '')) = lower('YOUR_EMAIL@gmail.com')
);

create policy "Only the configured owner can insert finance data"
on public.finance_data for insert
to authenticated
with check (
  user_id = (select auth.uid())
  and lower(coalesce(auth.jwt() ->> 'email', '')) = lower('YOUR_EMAIL@gmail.com')
);

create policy "Only the configured owner can update finance data"
on public.finance_data for update
to authenticated
using (
  user_id = (select auth.uid())
  and lower(coalesce(auth.jwt() ->> 'email', '')) = lower('YOUR_EMAIL@gmail.com')
)
with check (
  user_id = (select auth.uid())
  and lower(coalesce(auth.jwt() ->> 'email', '')) = lower('YOUR_EMAIL@gmail.com')
);

create policy "Only the configured owner can delete finance data"
on public.finance_data for delete
to authenticated
using (
  user_id = (select auth.uid())
  and lower(coalesce(auth.jwt() ->> 'email', '')) = lower('YOUR_EMAIL@gmail.com')
);

grant select, insert, update, delete on public.finance_data to authenticated;

