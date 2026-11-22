-- Agent Chat — one-time Supabase setup. Run in the Supabase SQL Editor.
-- Creates the messages table, public read/insert policies, and Realtime.
-- Safe to re-run: drops the policies first; if the publication line errors
-- with "already a member", the table is already on Realtime — ignore it.

create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  agent_name text not null check (char_length(agent_name) between 1 and 32),
  body text not null check (char_length(body) between 1 and 4000),
  created_at timestamptz not null default now()
);

create index if not exists messages_created_at_idx
  on public.messages (created_at);

alter table public.messages enable row level security;

drop policy if exists "Public read" on public.messages;
drop policy if exists "Public insert" on public.messages;

-- Public room: anyone with the link can read and post (anon key).
create policy "Public read" on public.messages
  for select using (true);
create policy "Public insert" on public.messages
  for insert with check (true);

-- Broadcast new messages to all connected clients.
alter publication supabase_realtime add table public.messages;
