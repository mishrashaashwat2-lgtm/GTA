-- GTA Cheat Codes Hub — Supabase starter schema
-- Run this in Supabase SQL Editor. Never expose a service-role key in browser code.
create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  nickname text not null default 'Player' check (char_length(nickname) between 1 and 32),
  role text not null default 'user' check (role in ('user','admin')),
  data jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create table if not exists public.submissions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null check (char_length(name) between 2 and 100),
  code text not null check (char_length(code) between 1 and 200),
  platform text not null check (platform in ('PlayStation','Xbox','PC')),
  description text not null default '' check (char_length(description) <= 500),
  status text not null default 'pending' check (status in ('pending','approved','rejected')),
  votes integer not null default 0,
  created_at timestamptz not null default now()
);
create table if not exists public.reports (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  submission_id uuid references public.submissions(id) on delete cascade,
  cheat_id text,
  reason text not null check (char_length(reason) between 5 and 500),
  status text not null default 'pending' check (status in ('pending','reviewed','dismissed')),
  created_at timestamptz not null default now(),
  check (submission_id is not null or cheat_id is not null)
);
create table if not exists public.notify_signups (
  id uuid primary key default gen_random_uuid(),
  email text not null unique check (char_length(email) <= 254),
  created_at timestamptz not null default now()
);
create table if not exists public.comments (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  submission_id uuid references public.submissions(id) on delete cascade,
  cheat_id text,
  body text not null check (char_length(body) between 1 and 1000),
  created_at timestamptz not null default now(),
  check (submission_id is not null or cheat_id is not null)
);
create table if not exists public.submission_votes (
  user_id uuid not null references auth.users(id) on delete cascade,
  submission_id uuid not null references public.submissions(id) on delete cascade,
  vote smallint not null check (vote in (-1,1)),
  created_at timestamptz not null default now(),
  primary key (user_id, submission_id)
);

alter table public.profiles enable row level security;
alter table public.submissions enable row level security;
alter table public.reports enable row level security;
alter table public.notify_signups enable row level security;
alter table public.comments enable row level security;
alter table public.submission_votes enable row level security;

create policy "Profiles readable by owner" on public.profiles for select to authenticated using (auth.uid() = id);
create policy "Profiles insertable by owner" on public.profiles for insert to authenticated with check (auth.uid() = id and role = 'user');
create policy "Profiles updateable by owner without role change" on public.profiles for update to authenticated using (auth.uid() = id) with check (auth.uid() = id and role = (select p.role from public.profiles p where p.id = auth.uid()));

create policy "Approved submissions are public" on public.submissions for select to anon, authenticated using (status = 'approved' or auth.uid() = user_id or exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'admin'));
create policy "Users submit pending codes" on public.submissions for insert to authenticated with check (auth.uid() = user_id and status = 'pending' and votes = 0);
create policy "Owners can edit pending submissions" on public.submissions for update to authenticated using (auth.uid() = user_id and status = 'pending') with check (auth.uid() = user_id and status = 'pending');
create policy "Admins moderate submissions" on public.submissions for update to authenticated using (exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'admin')) with check (exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'admin'));

create policy "Report authors and admins can read reports" on public.reports for select to authenticated using (auth.uid() = user_id or exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'admin'));
create policy "Authenticated users create reports" on public.reports for insert to authenticated with check (auth.uid() = user_id);
create policy "Admins manage reports" on public.reports for update to authenticated using (exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'admin')) with check (exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'admin'));

create policy "Anyone can subscribe" on public.notify_signups for insert to anon, authenticated with check (char_length(email) <= 254);
create policy "Only admins can view signups" on public.notify_signups for select to authenticated using (exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'admin'));

create policy "Comments on approved submissions or own" on public.comments for select to anon, authenticated using (submission_id is null or exists (select 1 from public.submissions s where s.id = submission_id and (s.status = 'approved' or s.user_id = auth.uid())));
create policy "Users add own comments" on public.comments for insert to authenticated with check (auth.uid() = user_id and char_length(body) between 1 and 1000);
create policy "Comment authors delete own comments" on public.comments for delete to authenticated using (auth.uid() = user_id);

create policy "Votes readable for approved submissions" on public.submission_votes for select to anon, authenticated using (exists (select 1 from public.submissions s where s.id = submission_id and s.status = 'approved') or auth.uid() = user_id);
create policy "Users cast own votes" on public.submission_votes for insert to authenticated with check (auth.uid() = user_id);
create policy "Users change own votes" on public.submission_votes for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "Users remove own votes" on public.submission_votes for delete to authenticated using (auth.uid() = user_id);

-- Create a profile after signup. New users can never self-assign admin through this trigger.
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public
as $$
begin
  insert into public.profiles (id, nickname)
  values (new.id, coalesce(nullif(left(new.raw_user_meta_data->>'nickname',32),''), 'Player'))
  on conflict (id) do nothing;
  return new;
end;
$$;
drop trigger if exists on_auth_user_created_profile on auth.users;
create trigger on_auth_user_created_profile after insert on auth.users
for each row execute procedure public.handle_new_user();

-- IMPORTANT: promote trusted administrators manually in SQL Editor after verifying their user ID:
-- update public.profiles set role = 'admin' where id = 'YOUR-AUTH-USER-UUID';
-- The browser demo currently does not use these community tables. Configure and test policies before launch.
