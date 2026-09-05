-- =========================================================
-- supabase.sql for next-chat-demo-master
-- Run this entire file once in Supabase SQL Editor.
-- =========================================================

-- USERS PROFILE TABLE
create table if not exists public.users (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null default 'User',
  avatar_url text not null default 'https://avatars.githubusercontent.com/u/0',
  created_at timestamptz not null default now()
);

-- CHAT MESSAGES TABLE
create table if not exists public.messages (
  id uuid primary key,
  text text not null,
  send_by uuid not null references public.users(id) on delete cascade,
  is_edit boolean not null default false,
  created_at timestamptz not null default now()
);

-- ChatInput inserts only text + id, so the sender is taken from
-- the currently authenticated Supabase user automatically.
alter table public.messages
  alter column send_by set default auth.uid();

-- Automatically create public.users when a new Auth user is created.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.users (id, display_name, avatar_url)
  values (
    new.id,
    coalesce(
      new.raw_user_meta_data ->> 'user_name',
      new.raw_user_meta_data ->> 'preferred_username',
      new.raw_user_meta_data ->> 'name',
      'User'
    ),
    coalesce(
      new.raw_user_meta_data ->> 'avatar_url',
      'https://avatars.githubusercontent.com/u/0'
    )
  )
  on conflict (id) do update
    set display_name = excluded.display_name,
        avatar_url = excluded.avatar_url;

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;

create trigger on_auth_user_created
after insert on auth.users
for each row
execute function public.handle_new_user();

-- Row Level Security
alter table public.users enable row level security;
alter table public.messages enable row level security;

-- Remove old copies if this SQL is run again.
drop policy if exists "Users can view profiles" on public.users;
drop policy if exists "Users can update own profile" on public.users;
drop policy if exists "Users can view messages" on public.messages;
drop policy if exists "Users can send messages" on public.messages;
drop policy if exists "Users can edit own messages" on public.messages;
drop policy if exists "Users can delete own messages" on public.messages;

-- USERS POLICIES
create policy "Users can view profiles"
on public.users
for select
to authenticated
using (true);

create policy "Users can update own profile"
on public.users
for update
to authenticated
using (auth.uid() = id)
with check (auth.uid() = id);

-- MESSAGE POLICIES
create policy "Users can view messages"
on public.messages
for select
to authenticated
using (true);

create policy "Users can send messages"
on public.messages
for insert
to authenticated
with check (auth.uid() = send_by);

create policy "Users can edit own messages"
on public.messages
for update
to authenticated
using (auth.uid() = send_by)
with check (auth.uid() = send_by);

create policy "Users can delete own messages"
on public.messages
for delete
to authenticated
using (auth.uid() = send_by);

-- Enable Realtime for messages without failing if it is already enabled.
do $$
begin
  alter publication supabase_realtime add table public.messages;
exception
  when duplicate_object then
    null;
end;
$$;

-- Useful for Realtime UPDATE/DELETE payloads.
alter table public.messages replica identity full;

-- =========================================================
-- END
-- =========================================================
