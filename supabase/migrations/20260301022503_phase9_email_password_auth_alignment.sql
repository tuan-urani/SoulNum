-- SoulNum Phase 9 follow-up
-- Align app auth metadata and triggers with email + password authentication.

alter table public.users
  add column if not exists email text;

comment on column public.users.email is
  'Canonical email copied from auth.users.email for app-level ownership and auth context.';
comment on column public.users.phone_e164 is
  'Legacy phone metadata retained for backward compatibility; not used by current email_password auth flow.';
comment on column public.users.auth_method is
  'Primary auth mode derived from auth.users (email_password when email exists, unknown otherwise).';

-- Backfill app users from auth.users email.
update public.users u
set email = nullif(lower(a.email), ''),
    auth_method = case
      when coalesce(a.email, '') <> '' then 'email_password'
      else 'unknown'
    end,
    updated_at = now()
from auth.users a
where a.id = u.id
  and (
    u.email is distinct from nullif(lower(a.email), '')
    or (
      coalesce(a.email, '') <> '' and u.auth_method is distinct from 'email_password'
    )
    or (
      coalesce(a.email, '') = '' and u.auth_method is distinct from 'unknown'
    )
  );

-- Bootstrap auth metadata for new auth users.
create or replace function public.handle_new_auth_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.users(id, email, auth_method)
  values (
    new.id,
    nullif(lower(new.email), ''),
    case
      when coalesce(new.email, '') <> '' then 'email_password'
      else 'unknown'
    end
  )
  on conflict (id)
  do update
  set email = excluded.email,
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
  'Bootstrap app user metadata + default free-tier entitlements from auth.users (email-based).';

-- Sync app metadata when auth email changes.
create or replace function public.handle_auth_user_updated()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.users
  set email = nullif(lower(new.email), ''),
      auth_method = case
        when coalesce(new.email, '') <> '' then 'email_password'
        else 'unknown'
      end,
      updated_at = now()
  where id = new.id;

  return new;
end;
$$;

comment on function public.handle_auth_user_updated is
  'Sync app-level email metadata and auth_method from auth.users after email updates.';

drop trigger if exists on_auth_user_updated on auth.users;
create trigger on_auth_user_updated
after update of email on auth.users
for each row
when (old.email is distinct from new.email)
execute function public.handle_auth_user_updated();
