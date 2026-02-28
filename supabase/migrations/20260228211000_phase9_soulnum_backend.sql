-- SoulNum Phase 9 - Supabase backend implementation
-- Source of truth: PHASE_8_TECH_ARCHITECTURE.md
-- Notes:
-- 1) This migration implements schema + comments + indexes + RLS policies.
-- 2) Gemini integration is implemented in Edge Functions (server-side only).

create extension if not exists "pgcrypto";

-- -----------------------------------------------------------------------------
-- Utility functions
-- -----------------------------------------------------------------------------
create or replace function public.tg_set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

comment on function public.tg_set_updated_at is
  'Generic trigger function to keep updated_at timestamps current.';

-- -----------------------------------------------------------------------------
-- 1) users
-- -----------------------------------------------------------------------------
create table if not exists public.users (
  id uuid primary key references auth.users(id) on delete cascade,
  locale text not null default 'vi-VN',
  timezone text not null default 'Asia/Ho_Chi_Minh',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table public.users is
  'SoulNum app user metadata. Feature: authentication bootstrap + ownership root. AI role: anchors all user-scoped memory and generated artifacts.';
comment on column public.users.id is
  'FK to auth.users.id. Ownership root for all user-owned tables.';

drop trigger if exists trg_users_set_updated_at on public.users;
create trigger trg_users_set_updated_at
before update on public.users
for each row execute function public.tg_set_updated_at();

-- -----------------------------------------------------------------------------
-- 2) user_profiles
-- -----------------------------------------------------------------------------
create table if not exists public.user_profiles (
  id uuid primary key default gen_random_uuid(),
  owner_user_id uuid not null references public.users(id) on delete cascade,
  full_name text not null,
  birth_date date not null,
  gender text null,
  relation_label text null,
  is_active boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz null
);

comment on table public.user_profiles is
  'Numerology profiles owned by a user. Feature: multi-profile, compatibility, all numerology inputs. AI role: profile-scoped memory partition.';
comment on column public.user_profiles.owner_user_id is
  'User who owns this profile and all derived readings.';
comment on column public.user_profiles.full_name is
  'Required for numerology calculations.';
comment on column public.user_profiles.birth_date is
  'Required for numerology calculations.';

drop trigger if exists trg_user_profiles_set_updated_at on public.user_profiles;
create trigger trg_user_profiles_set_updated_at
before update on public.user_profiles
for each row execute function public.tg_set_updated_at();

create index if not exists idx_user_profiles_owner
on public.user_profiles(owner_user_id);
create index if not exists idx_user_profiles_owner_active
on public.user_profiles(owner_user_id, is_active)
where deleted_at is null;

-- -----------------------------------------------------------------------------
-- 3) prompt_versions
-- -----------------------------------------------------------------------------
create table if not exists public.prompt_versions (
  id bigserial primary key,
  feature_key text not null,
  version text not null,
  model_name text not null,
  prompt_template text not null,
  response_schema jsonb null,
  is_active boolean not null default false,
  created_by uuid null references public.users(id) on delete set null,
  created_at timestamptz not null default now(),
  unique(feature_key, version)
);

comment on table public.prompt_versions is
  'Versioned prompts used by Edge Functions. Feature: prompt orchestration. AI role: deterministic generation control and rollback support.';

create index if not exists idx_prompt_versions_feature_active
on public.prompt_versions(feature_key, is_active);

-- -----------------------------------------------------------------------------
-- 4) ai_generated_contents
-- -----------------------------------------------------------------------------
create table if not exists public.ai_generated_contents (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  profile_id uuid null references public.user_profiles(id) on delete cascade,
  feature_key text not null,
  prompt_version_id bigint not null references public.prompt_versions(id) on delete restrict,
  input_hash text not null,
  output_text text null,
  output_json jsonb not null,
  token_input integer null,
  token_output integer null,
  estimated_cost_usd numeric(12, 6) null,
  safety_labels jsonb null,
  generated_at timestamptz not null default now(),
  expires_at timestamptz null
);

comment on table public.ai_generated_contents is
  'Persisted Gemini outputs. Feature: numerology readings + chatbot responses + cache. AI role: artifact store for reuse, audit, and lifecycle continuity.';
comment on column public.ai_generated_contents.input_hash is
  'Deterministic hash of normalized inputs + prompt version used for cache lookup.';

create index if not exists idx_ai_generated_user_feature_generated_at
on public.ai_generated_contents(user_id, feature_key, generated_at desc);
create index if not exists idx_ai_generated_feature_prompt_hash
on public.ai_generated_contents(feature_key, prompt_version_id, input_hash);
create index if not exists idx_ai_generated_user_generated_at
on public.ai_generated_contents(user_id, generated_at desc);

-- -----------------------------------------------------------------------------
-- 5) user_readings
-- -----------------------------------------------------------------------------
create table if not exists public.user_readings (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  profile_id uuid not null references public.user_profiles(id) on delete cascade,
  secondary_profile_id uuid null references public.user_profiles(id) on delete set null,
  feature_key text not null,
  period_key text null,
  target_date date null,
  ai_content_id uuid null references public.ai_generated_contents(id) on delete set null,
  result_snapshot jsonb not null,
  source_type text not null default 'ai_orchestrated',
  created_at timestamptz not null default now()
);

comment on table public.user_readings is
  'User-visible reading history. Feature: all numerology modules + compatibility + forecast history. AI role: retrieval layer and memory extraction source.';

create index if not exists idx_user_readings_user_feature_created_at
on public.user_readings(user_id, feature_key, created_at desc);
create index if not exists idx_user_readings_profile_feature_created_at
on public.user_readings(profile_id, feature_key, created_at desc);
create index if not exists idx_user_readings_user_created_at
on public.user_readings(user_id, created_at desc);

-- -----------------------------------------------------------------------------
-- 6) ai_context_memory
-- -----------------------------------------------------------------------------
create table if not exists public.ai_context_memory (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  profile_id uuid null references public.user_profiles(id) on delete cascade,
  memory_type text not null,
  memory_key text not null,
  memory_value jsonb not null,
  confidence_score numeric(4, 3) not null default 0.500,
  source_content_id uuid null references public.ai_generated_contents(id) on delete set null,
  source_reading_id uuid null references public.user_readings(id) on delete set null,
  is_active boolean not null default true,
  last_used_at timestamptz null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(user_id, profile_id, memory_type, memory_key)
);

comment on table public.ai_context_memory is
  'Persistent AI memory facts reused across readings and chat. Feature: long-term personalization. AI role: user/profile memory graph.';

drop trigger if exists trg_ai_context_memory_set_updated_at on public.ai_context_memory;
create trigger trg_ai_context_memory_set_updated_at
before update on public.ai_context_memory
for each row execute function public.tg_set_updated_at();

create index if not exists idx_ai_context_memory_user_profile_active
on public.ai_context_memory(user_id, profile_id, is_active);
create index if not exists idx_ai_context_memory_user_last_used
on public.ai_context_memory(user_id, last_used_at desc nulls last);
create index if not exists idx_ai_context_memory_user_created
on public.ai_context_memory(user_id, created_at desc);

-- -----------------------------------------------------------------------------
-- 7) ai_chat_sessions
-- -----------------------------------------------------------------------------
create table if not exists public.ai_chat_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  profile_id uuid not null references public.user_profiles(id) on delete cascade,
  status text not null default 'active',
  started_at timestamptz not null default now(),
  ended_at timestamptz null
);

comment on table public.ai_chat_sessions is
  'Chat session container per user/profile. Feature: VIP Pro chatbot. AI role: scoped context windows for conversation continuity.';

create index if not exists idx_ai_chat_sessions_user_started
on public.ai_chat_sessions(user_id, started_at desc);
create index if not exists idx_ai_chat_sessions_profile_started
on public.ai_chat_sessions(profile_id, started_at desc);

-- -----------------------------------------------------------------------------
-- 8) ai_chat_messages
-- -----------------------------------------------------------------------------
create table if not exists public.ai_chat_messages (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references public.ai_chat_sessions(id) on delete cascade,
  user_id uuid not null references public.users(id) on delete cascade,
  role text not null,
  content text not null,
  ai_content_id uuid null references public.ai_generated_contents(id) on delete set null,
  token_input integer null,
  token_output integer null,
  created_at timestamptz not null default now()
);

comment on table public.ai_chat_messages is
  'Chat transcript rows. Feature: VIP chatbot transcript/history. AI role: conversational memory stream and compliance audit.';

create index if not exists idx_ai_chat_messages_session_created
on public.ai_chat_messages(session_id, created_at asc);
create index if not exists idx_ai_chat_messages_user_created
on public.ai_chat_messages(user_id, created_at desc);

-- -----------------------------------------------------------------------------
-- 9) ai_usage_ledger
-- -----------------------------------------------------------------------------
create table if not exists public.ai_usage_ledger (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  usage_month date not null,
  usage_type text not null,
  quota_limit integer not null,
  used_count integer not null default 0,
  blocked_count integer not null default 0,
  estimated_cost_usd numeric(12, 6) not null default 0,
  updated_at timestamptz not null default now(),
  unique(user_id, usage_month, usage_type)
);

comment on table public.ai_usage_ledger is
  'Monthly AI quota counters. Feature: VIP hard-limit chatbot + AI economics. AI role: cost/abuse control and hard-limit enforcement.';

drop trigger if exists trg_ai_usage_ledger_set_updated_at on public.ai_usage_ledger;
create trigger trg_ai_usage_ledger_set_updated_at
before update on public.ai_usage_ledger
for each row execute function public.tg_set_updated_at();

create index if not exists idx_ai_usage_ledger_user_month
on public.ai_usage_ledger(user_id, usage_month desc);

-- -----------------------------------------------------------------------------
-- 10) subscriptions
-- -----------------------------------------------------------------------------
create table if not exists public.subscriptions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  provider text not null,
  provider_original_tx_id text not null,
  plan_code text not null,
  status text not null,
  current_period_start timestamptz not null,
  current_period_end timestamptz not null,
  auto_renew boolean not null default true,
  last_verified_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(provider, provider_original_tx_id)
);

comment on table public.subscriptions is
  'Store subscription contracts. Feature: VIP Pro monthly/yearly billing lifecycle. AI role: entitlement source for chatbot and premium gates.';

drop trigger if exists trg_subscriptions_set_updated_at on public.subscriptions;
create trigger trg_subscriptions_set_updated_at
before update on public.subscriptions
for each row execute function public.tg_set_updated_at();

create index if not exists idx_subscriptions_user_status_period_end
on public.subscriptions(user_id, status, current_period_end desc);

-- -----------------------------------------------------------------------------
-- 11) subscription_entitlements
-- -----------------------------------------------------------------------------
create table if not exists public.subscription_entitlements (
  user_id uuid primary key references public.users(id) on delete cascade,
  is_vip_pro boolean not null default false,
  plan_code text null,
  entitle_start_at timestamptz null,
  entitle_end_at timestamptz null,
  profile_limit integer null,
  chatbot_monthly_limit integer not null default 0,
  ad_free_daily_cycle boolean not null default false,
  updated_at timestamptz not null default now()
);

comment on table public.subscription_entitlements is
  'Runtime entitlement snapshot. Feature: gating checks (VIP chat, profile limit, ad bypass). AI role: controls access cost for AI generation.';

drop trigger if exists trg_subscription_entitlements_set_updated_at on public.subscription_entitlements;
create trigger trg_subscription_entitlements_set_updated_at
before update on public.subscription_entitlements
for each row execute function public.tg_set_updated_at();

-- -----------------------------------------------------------------------------
-- 12) subscription_events
-- -----------------------------------------------------------------------------
create table if not exists public.subscription_events (
  id uuid primary key default gen_random_uuid(),
  subscription_id uuid null references public.subscriptions(id) on delete set null,
  user_id uuid not null references public.users(id) on delete cascade,
  provider text not null,
  event_type text not null,
  event_time timestamptz not null,
  raw_payload jsonb not null,
  created_at timestamptz not null default now()
);

comment on table public.subscription_events is
  'Immutable billing event log. Feature: subscription troubleshooting and compliance traceability. AI role: indirect (entitlement lifecycle audit).';

create index if not exists idx_subscription_events_user_event_time
on public.subscription_events(user_id, event_time desc);

-- -----------------------------------------------------------------------------
-- 13) rewarded_ad_events
-- -----------------------------------------------------------------------------
create table if not exists public.rewarded_ad_events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  profile_id uuid not null references public.user_profiles(id) on delete cascade,
  placement text not null,
  ad_network text not null,
  ad_unit_id text null,
  status text not null,
  provider_reward_id text null,
  occurred_at timestamptz not null default now(),
  metadata jsonb null
);

comment on table public.rewarded_ad_events is
  'Rewarded ad verification events. Feature: free-tier daily biorhythm gate. AI role: unlock control before AI/deterministic daily reading retrieval.';

create index if not exists idx_rewarded_ad_events_user_profile_occurred
on public.rewarded_ad_events(user_id, profile_id, occurred_at desc);

-- -----------------------------------------------------------------------------
-- 14) daily_biorhythm_unlocks
-- -----------------------------------------------------------------------------
create table if not exists public.daily_biorhythm_unlocks (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  profile_id uuid not null references public.user_profiles(id) on delete cascade,
  unlock_date date not null,
  unlock_method text not null,
  ad_event_id uuid null references public.rewarded_ad_events(id) on delete set null,
  created_at timestamptz not null default now(),
  unique(user_id, profile_id, unlock_date)
);

comment on table public.daily_biorhythm_unlocks is
  'One unlock record per user/profile/day. Feature: daily cycle access gate. AI role: determines if daily insight generation may proceed.';

create index if not exists idx_daily_biorhythm_unlocks_user_date
on public.daily_biorhythm_unlocks(user_id, unlock_date desc);

-- -----------------------------------------------------------------------------
-- 15) profile_deletion_audits
-- -----------------------------------------------------------------------------
create table if not exists public.profile_deletion_audits (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  deleted_profile_id uuid not null,
  deleted_at timestamptz not null default now(),
  reason text not null default 'user_requested'
);

comment on table public.profile_deletion_audits is
  'Non-PII deletion proof. Feature: in-app permanent profile deletion. AI role: confirms memory/readings cleanup lifecycle.';

create index if not exists idx_profile_deletion_audits_user_deleted
on public.profile_deletion_audits(user_id, deleted_at desc);

-- -----------------------------------------------------------------------------
-- Auth bootstrap trigger: create public.users row on auth.users insert
-- -----------------------------------------------------------------------------
create or replace function public.handle_new_auth_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.users(id)
  values (new.id)
  on conflict (id) do nothing;

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
  'Bootstrap app user and default free-tier entitlements for new auth users.';

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_auth_user();

-- -----------------------------------------------------------------------------
-- AI quota helper: atomic increment with hard limit enforcement
-- -----------------------------------------------------------------------------
create or replace function public.increment_ai_usage_if_available(
  p_user_id uuid,
  p_usage_month date,
  p_usage_type text,
  p_quota_limit integer
)
returns table (
  allowed boolean,
  used_count integer,
  blocked_count integer,
  quota_limit integer
)
language plpgsql
security definer
set search_path = public
as $$
declare
  updated_row public.ai_usage_ledger%rowtype;
begin
  insert into public.ai_usage_ledger(
    user_id,
    usage_month,
    usage_type,
    quota_limit,
    used_count,
    blocked_count,
    estimated_cost_usd
  )
  values (
    p_user_id,
    p_usage_month,
    p_usage_type,
    greatest(p_quota_limit, 0),
    0,
    0,
    0
  )
  on conflict (user_id, usage_month, usage_type)
  do update
  set quota_limit = greatest(excluded.quota_limit, public.ai_usage_ledger.quota_limit),
      updated_at = now();

  update public.ai_usage_ledger
  set used_count = used_count + 1,
      updated_at = now()
  where user_id = p_user_id
    and usage_month = p_usage_month
    and usage_type = p_usage_type
    and used_count < quota_limit
  returning * into updated_row;

  if found then
    return query
      select true, updated_row.used_count, updated_row.blocked_count, updated_row.quota_limit;
    return;
  end if;

  update public.ai_usage_ledger
  set blocked_count = blocked_count + 1,
      updated_at = now()
  where user_id = p_user_id
    and usage_month = p_usage_month
    and usage_type = p_usage_type
  returning * into updated_row;

  return query
    select false, updated_row.used_count, updated_row.blocked_count, updated_row.quota_limit;
end;
$$;

comment on function public.increment_ai_usage_if_available(uuid, date, text, integer) is
  'Atomically enforces hard usage limit and increments blocked_count when limit is exhausted.';

-- -----------------------------------------------------------------------------
-- RLS enablement
-- -----------------------------------------------------------------------------
alter table public.users enable row level security;
alter table public.user_profiles enable row level security;
alter table public.prompt_versions enable row level security;
alter table public.ai_generated_contents enable row level security;
alter table public.user_readings enable row level security;
alter table public.ai_context_memory enable row level security;
alter table public.ai_chat_sessions enable row level security;
alter table public.ai_chat_messages enable row level security;
alter table public.ai_usage_ledger enable row level security;
alter table public.subscriptions enable row level security;
alter table public.subscription_entitlements enable row level security;
alter table public.subscription_events enable row level security;
alter table public.rewarded_ad_events enable row level security;
alter table public.daily_biorhythm_unlocks enable row level security;
alter table public.profile_deletion_audits enable row level security;

-- -----------------------------------------------------------------------------
-- Policy cleanup for idempotent migration reruns
-- -----------------------------------------------------------------------------
drop policy if exists users_select_own on public.users;
drop policy if exists users_update_own on public.users;

drop policy if exists user_profiles_select_own on public.user_profiles;
drop policy if exists user_profiles_insert_own on public.user_profiles;
drop policy if exists user_profiles_update_own on public.user_profiles;
drop policy if exists user_profiles_delete_own on public.user_profiles;

drop policy if exists prompt_versions_service_only on public.prompt_versions;

drop policy if exists ai_generated_select_own on public.ai_generated_contents;
drop policy if exists ai_generated_insert_own on public.ai_generated_contents;
drop policy if exists ai_generated_update_own on public.ai_generated_contents;
drop policy if exists ai_generated_delete_own on public.ai_generated_contents;

drop policy if exists user_readings_select_own on public.user_readings;
drop policy if exists user_readings_insert_own on public.user_readings;
drop policy if exists user_readings_update_own on public.user_readings;
drop policy if exists user_readings_delete_own on public.user_readings;

drop policy if exists ai_memory_select_own on public.ai_context_memory;
drop policy if exists ai_memory_insert_own on public.ai_context_memory;
drop policy if exists ai_memory_update_own on public.ai_context_memory;
drop policy if exists ai_memory_delete_own on public.ai_context_memory;

drop policy if exists chat_sessions_select_own on public.ai_chat_sessions;
drop policy if exists chat_sessions_insert_own on public.ai_chat_sessions;
drop policy if exists chat_sessions_update_own on public.ai_chat_sessions;
drop policy if exists chat_sessions_delete_own on public.ai_chat_sessions;

drop policy if exists chat_messages_select_own on public.ai_chat_messages;
drop policy if exists chat_messages_insert_own on public.ai_chat_messages;
drop policy if exists chat_messages_update_own on public.ai_chat_messages;
drop policy if exists chat_messages_delete_own on public.ai_chat_messages;

drop policy if exists usage_ledger_select_own on public.ai_usage_ledger;

drop policy if exists subscriptions_select_own on public.subscriptions;
drop policy if exists entitlements_select_own on public.subscription_entitlements;
drop policy if exists subscription_events_select_own on public.subscription_events;

drop policy if exists rewarded_events_select_own on public.rewarded_ad_events;
drop policy if exists rewarded_events_insert_own on public.rewarded_ad_events;

drop policy if exists daily_unlocks_select_own on public.daily_biorhythm_unlocks;
drop policy if exists daily_unlocks_insert_own on public.daily_biorhythm_unlocks;
drop policy if exists daily_unlocks_update_own on public.daily_biorhythm_unlocks;
drop policy if exists daily_unlocks_delete_own on public.daily_biorhythm_unlocks;

drop policy if exists profile_delete_audit_select_own on public.profile_deletion_audits;

-- -----------------------------------------------------------------------------
-- RLS policies
-- -----------------------------------------------------------------------------
create policy users_select_own
on public.users
for select
to authenticated
using (id = auth.uid());

create policy users_update_own
on public.users
for update
to authenticated
using (id = auth.uid())
with check (id = auth.uid());

create policy user_profiles_select_own
on public.user_profiles
for select
to authenticated
using (owner_user_id = auth.uid());

create policy user_profiles_insert_own
on public.user_profiles
for insert
to authenticated
with check (owner_user_id = auth.uid());

create policy user_profiles_update_own
on public.user_profiles
for update
to authenticated
using (owner_user_id = auth.uid())
with check (owner_user_id = auth.uid());

create policy user_profiles_delete_own
on public.user_profiles
for delete
to authenticated
using (owner_user_id = auth.uid());

-- no public policy on prompt_versions (service role only)
create policy prompt_versions_service_only
on public.prompt_versions
for all
to service_role
using (true)
with check (true);

create policy ai_generated_select_own
on public.ai_generated_contents
for select
to authenticated
using (user_id = auth.uid());

create policy ai_generated_insert_own
on public.ai_generated_contents
for insert
to authenticated
with check (user_id = auth.uid());

create policy ai_generated_update_own
on public.ai_generated_contents
for update
to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

create policy ai_generated_delete_own
on public.ai_generated_contents
for delete
to authenticated
using (user_id = auth.uid());

create policy user_readings_select_own
on public.user_readings
for select
to authenticated
using (user_id = auth.uid());

create policy user_readings_insert_own
on public.user_readings
for insert
to authenticated
with check (user_id = auth.uid());

create policy user_readings_update_own
on public.user_readings
for update
to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

create policy user_readings_delete_own
on public.user_readings
for delete
to authenticated
using (user_id = auth.uid());

create policy ai_memory_select_own
on public.ai_context_memory
for select
to authenticated
using (user_id = auth.uid());

create policy ai_memory_insert_own
on public.ai_context_memory
for insert
to authenticated
with check (user_id = auth.uid());

create policy ai_memory_update_own
on public.ai_context_memory
for update
to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

create policy ai_memory_delete_own
on public.ai_context_memory
for delete
to authenticated
using (user_id = auth.uid());

create policy chat_sessions_select_own
on public.ai_chat_sessions
for select
to authenticated
using (user_id = auth.uid());

create policy chat_sessions_insert_own
on public.ai_chat_sessions
for insert
to authenticated
with check (user_id = auth.uid());

create policy chat_sessions_update_own
on public.ai_chat_sessions
for update
to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

create policy chat_sessions_delete_own
on public.ai_chat_sessions
for delete
to authenticated
using (user_id = auth.uid());

create policy chat_messages_select_own
on public.ai_chat_messages
for select
to authenticated
using (user_id = auth.uid());

create policy chat_messages_insert_own
on public.ai_chat_messages
for insert
to authenticated
with check (user_id = auth.uid());

create policy chat_messages_update_own
on public.ai_chat_messages
for update
to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

create policy chat_messages_delete_own
on public.ai_chat_messages
for delete
to authenticated
using (user_id = auth.uid());

create policy usage_ledger_select_own
on public.ai_usage_ledger
for select
to authenticated
using (user_id = auth.uid());

create policy subscriptions_select_own
on public.subscriptions
for select
to authenticated
using (user_id = auth.uid());

create policy entitlements_select_own
on public.subscription_entitlements
for select
to authenticated
using (user_id = auth.uid());

create policy subscription_events_select_own
on public.subscription_events
for select
to authenticated
using (user_id = auth.uid());

create policy rewarded_events_select_own
on public.rewarded_ad_events
for select
to authenticated
using (user_id = auth.uid());

create policy rewarded_events_insert_own
on public.rewarded_ad_events
for insert
to authenticated
with check (user_id = auth.uid());

create policy daily_unlocks_select_own
on public.daily_biorhythm_unlocks
for select
to authenticated
using (user_id = auth.uid());

create policy daily_unlocks_insert_own
on public.daily_biorhythm_unlocks
for insert
to authenticated
with check (user_id = auth.uid());

create policy daily_unlocks_update_own
on public.daily_biorhythm_unlocks
for update
to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

create policy daily_unlocks_delete_own
on public.daily_biorhythm_unlocks
for delete
to authenticated
using (user_id = auth.uid());

create policy profile_delete_audit_select_own
on public.profile_deletion_audits
for select
to authenticated
using (user_id = auth.uid());

-- -----------------------------------------------------------------------------
-- Helpful check constraints
-- -----------------------------------------------------------------------------
alter table public.ai_chat_messages
  add constraint chk_ai_chat_messages_role
  check (role in ('user', 'assistant', 'system'));

alter table public.ai_chat_sessions
  add constraint chk_ai_chat_sessions_status
  check (status in ('active', 'closed'));

alter table public.daily_biorhythm_unlocks
  add constraint chk_daily_unlock_method
  check (unlock_method in ('vip', 'rewarded_ad'));

alter table public.subscriptions
  add constraint chk_subscriptions_provider
  check (provider in ('apple', 'google'));

alter table public.subscriptions
  add constraint chk_subscriptions_plan
  check (plan_code in ('vip_pro_monthly', 'vip_pro_yearly'));

alter table public.ai_usage_ledger
  add constraint chk_ai_usage_non_negative
  check (used_count >= 0 and blocked_count >= 0 and quota_limit >= 0);
