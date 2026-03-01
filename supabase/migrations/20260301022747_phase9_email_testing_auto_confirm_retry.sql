-- SoulNum Phase 9 testing mode
-- Auto-confirm email users to avoid confirmation-step friction in test environments.

-- Backfill: mark existing email users as confirmed if not already confirmed.
update auth.users
set email_confirmed_at = coalesce(email_confirmed_at, now()),
    updated_at = now()
where coalesce(email, '') <> ''
  and email_confirmed_at is null;

-- Update bootstrap function to auto-confirm newly inserted email users.
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

  -- Testing mode: bypass email confirmation for quicker QA loops.
  if coalesce(new.email, '') <> '' and new.email_confirmed_at is null then
    update auth.users
    set email_confirmed_at = coalesce(email_confirmed_at, now()),
        updated_at = now()
    where id = new.id;
  end if;

  return new;
end;
$$;

comment on function public.handle_new_auth_user is
  'Bootstrap app user metadata + default free-tier entitlements from auth.users (email-based, testing mode auto-confirm enabled).';
