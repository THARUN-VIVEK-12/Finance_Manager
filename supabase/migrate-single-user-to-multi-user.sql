-- Run this ONCE in Supabase SQL Editor to convert an existing single-user setup.
-- Existing finance_data rows remain associated with their original auth.users.id.

alter table public.finance_data enable row level security;

drop policy if exists "Only the configured owner can read finance data" on public.finance_data;
drop policy if exists "Only the configured owner can insert finance data" on public.finance_data;
drop policy if exists "Only the configured owner can update finance data" on public.finance_data;
drop policy if exists "Only the configured owner can delete finance data" on public.finance_data;
drop policy if exists "Users can read their own finance data" on public.finance_data;
drop policy if exists "Users can insert their own finance data" on public.finance_data;
drop policy if exists "Users can update their own finance data" on public.finance_data;
drop policy if exists "Users can delete their own finance data" on public.finance_data;

create policy "Users can read their own finance data" on public.finance_data
for select to authenticated using (user_id = (select auth.uid()));
create policy "Users can insert their own finance data" on public.finance_data
for insert to authenticated with check (user_id = (select auth.uid()));
create policy "Users can update their own finance data" on public.finance_data
for update to authenticated using (user_id = (select auth.uid()))
with check (user_id = (select auth.uid()));
create policy "Users can delete their own finance data" on public.finance_data
for delete to authenticated using (user_id = (select auth.uid()));

grant select, insert, update, delete on public.finance_data to authenticated;
