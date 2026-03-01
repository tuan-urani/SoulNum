-- SoulNum Phase 9 follow-up
-- Align auth metadata with phone + password sign-in mode.

alter table public.users
  add column if not exists phone_e164 text,
  add column if not exists auth_method text not null default 'phone_password';

comment on column public.users.phone_e164 is
  'Canonical phone copied from auth.users.phone for app-level ownership and auditing context.';
comment on column public.users.auth_method is
  'Primary auth mode used by the account (current: phone_password; fallback: unknown).';

-- Backfill existing app users from auth.users.
update public.users u
set phone_e164 = nullif(a.phone, ''),
    auth_method = case
      when coalesce(a.phone, '') <> '' then 'phone_password'
      else coalesce(u.auth_method, 'unknown')
    end,
    updated_at = now()
from auth.users a
where a.id = u.id
  and (
    u.phone_e164 is distinct from nullif(a.phone, '')
    or (coalesce(a.phone, '') <> '' and u.auth_method is distinct from 'phone_password')
  );

-- Recreate auth bootstrap to seed auth metadata for new users.
create or replace function public.handle_new_auth_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.users(id, phone_e164, auth_method)
  values (
    new.id,
    nullif(new.phone, ''),
    case when coalesce(new.phone, '') <> '' then 'phone_password' else 'unknown' end
  )
  on conflict (id)
  do update
  set phone_e164 = excluded.phone_e164,
      auth_method = excluded.auth_method,
      updated_at = now();

  insert into public.subscription_entitlements(
    user_id,
    is_vip_pro,
    profile_limit,
    chatbot_monthly_limit,
    ad_free_daily_cycle
  )
  values (
    new.id,
    false,
    2,
    0,
    false
  )
  on conflict (user_id) do nothing;

  return new;
end;
$$;

comment on function public.handle_new_auth_user is
  'Bootstrap app user metadata + default free-tier entitlements from auth.users.';

-- Keep phone metadata in sync when auth phone changes.
create or replace function public.handle_auth_user_updated()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.users
  set phone_e164 = nullif(new.phone, ''),
      auth_method = case
        when coalesce(new.phone, '') <> '' then 'phone_password'
        else auth_method
      end,
      updated_at = now()
  where id = new.id;

  return new;
end;
$$;

comment on function public.handle_auth_user_updated is
  'Sync app-level phone metadata when auth.users phone changes.';

drop trigger if exists on_auth_user_updated on auth.users;
create trigger on_auth_user_updated
after update of phone on auth.users
for each row
when (old.phone is distinct from new.phone)
execute function public.handle_auth_user_updated();
