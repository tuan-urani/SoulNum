begin;

comment on column public.ai_generated_contents.input_hash is
  'Legacy request identity field. In the simplified reading flow this stores a deterministic scope identity string (feature/profile/secondary/date/period), not the primary cache decision source.';

comment on table public.user_readings is
  'User-visible reading records. Feature: all numerology modules + compatibility + forecast history. AI role: primary lookup source for reusing existing readings before generating a new one.';

create index if not exists idx_user_readings_reuse_fixed_scope
on public.user_readings(user_id, profile_id, secondary_profile_id, feature_key, created_at desc)
where target_date is null and period_key is null;

create index if not exists idx_user_readings_reuse_target_date_scope
on public.user_readings(user_id, profile_id, secondary_profile_id, feature_key, target_date, created_at desc)
where target_date is not null;

create index if not exists idx_user_readings_reuse_period_scope
on public.user_readings(user_id, profile_id, secondary_profile_id, feature_key, period_key, created_at desc)
where period_key is not null;

commit;
