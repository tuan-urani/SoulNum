-- SoulNum Phase 9 follow-up
-- Normalize legacy auth metadata for users without phone.

alter table public.users
  alter column auth_method set default 'unknown';

update public.users
set auth_method = 'unknown',
    updated_at = now()
where coalesce(phone_e164, '') = ''
  and auth_method <> 'unknown';

comment on column public.users.auth_method is
  'Primary auth mode derived from auth.users (phone_password when phone exists, unknown otherwise).';

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
        else 'unknown'
      end,
      updated_at = now()
  where id = new.id;

  return new;
end;
$$;

comment on function public.handle_auth_user_updated is
  'Sync phone metadata and auth_method from auth.users after phone updates.';
