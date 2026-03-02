# PHASE 9 – SUPABASE BACKEND IMPLEMENTATION

## 0) Document Metadata
- Last Updated: 2026-03-02
- Supabase Project ID: `aauidavuipscnbmdhale`
- Architecture reference: `PHASE_8_TECH_ARCHITECTURE.md`
- Verification basis for this document:
  - repository migrations under `supabase/migrations/*`
  - repository edge functions under `supabase/functions/*`
  - Supabase project config in `supabase/config.toml`
- Remote verification performed on 2026-03-02 against project `aauidavuipscnbmdhale` via Supabase MCP.

This document reflects the implemented backend state. Note: the repository migration file `20260302113000_phase10_reading_scope_reuse_simplification.sql` was applied to the remote project by MCP as migration version `20260302090500_phase10_reading_scope_reuse_simplification`.

---

## 1) Migration Ledger (Applied in Codebase)

1. `20260228211000_phase9_soulnum_backend.sql`
- Created core schema, constraints, indexes, RLS policies, triggers, and quota RPC.

2. `20260228222000_phase9_phone_password_auth_alignment.sql`
- Added `phone_e164`, `auth_method` and phone sync logic (legacy phase).

3. `20260228223000_phase9_auth_method_normalization.sql`
- Normalized `auth_method` defaults and update trigger behavior.

4. `20260301022503_phase9_email_password_auth_alignment.sql`
- Shifted auth metadata alignment to email/password (`email`, `auth_method`).

5. `20260301022747_phase9_email_testing_auto_confirm_retry.sql`
- Enabled testing-mode auto-confirm for email users.

6. `20260301102000_phase10_gemini_context_warehouse.sql`
- Added context warehouse + deterministic baseline tables.
- Seeded global context blocks and 12 active prompts.

7. `20260302113000_phase10_reading_scope_reuse_simplification.sql` (repo)
- Remote applied version: `20260302090500_phase10_reading_scope_reuse_simplification`
- Simplified reading reuse to be record-based by effective scope.
- Added scope lookup indexes on `user_readings`.
- Updated DB comments to reflect `user_readings` as the primary reuse source.

---

## 2) Database Provisioning State

## 2.1 Tables Implemented
1. `public.users`
2. `public.user_profiles`
3. `public.prompt_versions`
4. `public.global_context_blocks`
5. `public.profile_numerology_baselines`
6. `public.ai_generated_contents`
7. `public.user_readings`
8. `public.ai_context_memory`
9. `public.ai_chat_sessions`
10. `public.ai_chat_messages`
11. `public.ai_usage_ledger`
12. `public.subscriptions`
13. `public.subscription_entitlements`
14. `public.subscription_events`
15. `public.rewarded_ad_events`
16. `public.daily_biorhythm_unlocks`
17. `public.profile_deletion_audits`

## 2.2 Table Purpose Mapping
- User/Auth root: `users`
- Profile domain: `user_profiles`, `profile_deletion_audits`
- Prompt/context orchestration: `prompt_versions`, `global_context_blocks`, `profile_numerology_baselines`
- AI artifact/memory: `ai_generated_contents`, `user_readings`, `ai_context_memory`
- Chat domain: `ai_chat_sessions`, `ai_chat_messages`, `ai_usage_ledger`
- Monetization domain: `subscriptions`, `subscription_entitlements`, `subscription_events`
- Ad gate domain: `rewarded_ad_events`, `daily_biorhythm_unlocks`

## 2.3 Ownership Model
- User-owned data anchored to `users.id` and guarded by RLS.
- Platform-owned config data (`prompt_versions`, `global_context_blocks`) is service-role controlled.

## 2.4 Comments/Documentation in DB
- Core migration includes `comment on table` and key `comment on column` entries for intent.
- Newly added context tables also include purpose-oriented comments.

---

## 3) Relationships, Constraints, and Data Integrity

## 3.1 Key Foreign-Key Chains
1. `auth.users.id` -> `public.users.id`
2. `users.id` -> user-owned tables (`user_profiles`, `ai_generated_contents`, `user_readings`, etc.)
3. `prompt_versions.id` -> `ai_generated_contents.prompt_version_id`
4. `ai_generated_contents.id` -> `user_readings.ai_content_id`, `ai_chat_messages.ai_content_id`
5. `user_profiles.id` -> profile-scoped entities (`user_readings`, `ai_context_memory`, `daily_biorhythm_unlocks`, `profile_numerology_baselines`)

## 3.2 Integrity Constraints
- Artifact identity/index support:
  - `ai_generated_contents(feature_key, prompt_version_id, input_hash)` index
- Memory uniqueness:
  - `ai_context_memory unique(user_id, profile_id, memory_type, memory_key)`
- Daily unlock idempotency:
  - `daily_biorhythm_unlocks unique(user_id, profile_id, unlock_date)`
- Quota ledger uniqueness:
  - `ai_usage_ledger unique(user_id, usage_month, usage_type)`
- Billing uniqueness:
  - `subscriptions unique(provider, provider_original_tx_id)`
- Baseline cache uniqueness:
  - `profile_numerology_baselines unique(user_id, profile_id, calc_version)`

## 3.3 Domain Check Constraints
- `ai_chat_messages.role in ('user','assistant','system')`
- `ai_chat_sessions.status in ('active','closed','expired')`
- `global_context_blocks.scope in ('global','feature')`
- Conditional scope-feature consistency on `global_context_blocks`

---

## 4) RLS Implementation State

## 4.1 RLS Enabled
RLS is enabled on all 17 public tables.

## 4.2 User-Owned Policy Pattern
- `select/update/delete` policies typically enforce `user_id = auth.uid()`.
- `insert` policies enforce ownership with `with check` clauses.
- `user_profiles` uses `owner_user_id = auth.uid()`.

## 4.3 Service-Only Policy Pattern
- `prompt_versions_service_only`
- `global_context_blocks_service_only`
- `profile_baselines_service_only` (in addition to user policies)

## 4.4 Policy Groups (Implemented)
- `users_select_own`, `users_update_own`
- `user_profiles_*_own`
- `ai_generated_*_own`
- `user_readings_*_own`
- `ai_memory_*_own`
- `chat_sessions_*_own`
- `chat_messages_*_own`
- `usage_ledger_select_own`
- `subscriptions_select_own`
- `entitlements_select_own`
- `subscription_events_select_own`
- `rewarded_events_select_own`, `rewarded_events_insert_own`
- `daily_unlocks_*_own`
- `profile_delete_audit_select_own`
- `profile_baselines_*_own` + `profile_baselines_service_only`

---

## 5) Indexing & Performance State

## 5.1 Core Retrieval Indexes
- `idx_user_profiles_owner`
- `idx_user_profiles_owner_active`
- `idx_prompt_versions_feature_active`
- `idx_ai_generated_user_feature_generated_at`
- `idx_ai_generated_feature_prompt_hash`
- `idx_ai_generated_user_generated_at`
- `idx_user_readings_user_feature_created_at`
- `idx_user_readings_profile_feature_created_at`
- `idx_user_readings_user_created_at`
- `idx_user_readings_reuse_fixed_scope`
- `idx_user_readings_reuse_target_date_scope`
- `idx_user_readings_reuse_period_scope`
- `idx_ai_context_memory_user_profile_active`
- `idx_ai_context_memory_user_last_used`
- `idx_ai_context_memory_user_created`
- `idx_ai_chat_sessions_user_started`
- `idx_ai_chat_sessions_profile_started`
- `idx_ai_chat_messages_session_created`
- `idx_ai_chat_messages_user_created`
- `idx_ai_usage_ledger_user_month`
- `idx_subscriptions_user_status_period_end`
- `idx_subscription_events_user_event_time`
- `idx_rewarded_ad_events_user_profile_occurred`
- `idx_daily_biorhythm_unlocks_user_date`
- `idx_profile_deletion_audits_user_deleted`

## 5.2 Context-Warehouse Indexes
- `idx_global_context_blocks_lookup`
- `idx_global_context_blocks_updated_at`
- `idx_profile_numerology_baselines_user_updated`
- `idx_profile_numerology_baselines_profile_calc`

---

## 6) SQL Functions and Triggers

## 6.1 Trigger Utilities
- `public.tg_set_updated_at()` for `updated_at` consistency.

## 6.2 Auth Bootstrap and Sync
- `public.handle_new_auth_user()`:
  - ensures `public.users` row
  - seeds default free entitlement row
  - in current testing setup, auto-confirms email users
- `public.handle_auth_user_updated()`:
  - syncs `public.users.email` and `auth_method` from `auth.users.email`

## 6.3 Quota RPC
- `public.increment_ai_usage_if_available(...)`
- Behavior:
  - atomic usage increment under quota
  - increments blocked counter when exhausted
  - returns `(allowed, used_count, blocked_count, quota_limit)`

---

## 7) Edge Functions Implemented

## 7.1 Shared Modules
- `_shared/http.ts`
- `_shared/supabase.ts`
- `_shared/domain.ts`
- `_shared/hash.ts`
- `_shared/prompt.ts`
- `_shared/gemini.ts`
- `_shared/memory.ts`
- `_shared/context.ts`
- `_shared/baseline.ts`
- `_shared/numerology.ts`

## 7.2 Business Functions
1. `fn_get_or_generate_reading`
- Reading orchestration with direct existing-record lookup by effective scope, Gemini call on miss, schema validation, persistence, and memory upsert.

2. `fn_chat_with_guide`
- VIP-only chatbot, session handling, quota enforcement, persistence.

3. `fn_unlock_daily_biorhythm`
- VIP/ad-gated daily unlock handling.

4. `fn_sync_subscription`
- Billing verification + subscription/entitlement synchronization.

5. `fn_get_history_feed`
- Paginated reading history endpoint.

6. `fn_delete_profile_permanently`
- Hard-delete profile-related data and maintain audit trail.

7. `fn_compact_context_memory`
- Cron-protected cleanup of stale context memory.

## 7.3 JWT Verification Configuration
From `supabase/config.toml`:
- `verify_jwt = true` for all user-invoked business functions.
- `verify_jwt = false` only for `fn_compact_context_memory` (cron path), with `x-cron-secret` check.

---

## 8) AI Context Persistence and Reuse (Implemented)

1. Artifact persistence:
- `ai_generated_contents` stores raw and structured AI result + token metadata.

2. User-facing history:
- `user_readings` stores generated reading records and is now the first lookup source before any new reading generation.

3. Long-term memory:
- `ai_context_memory` stores normalized memory facts with confidence and activity status.

4. Deterministic baseline reuse:
- `profile_numerology_baselines` caches deterministic numerology outputs by profile.

5. Global context reuse:
- `global_context_blocks` supplies platform/feature-level guidance for prompt construction.

6. Reading reuse strategy:
- Fixed readings are reused once per profile snapshot.
- `forecast_day` and `biorhythm_daily` are reused per day.
- `forecast_month` is reused per month.
- `forecast_year` is reused per year.
- Existing reading reuse is invalidated when the relevant profile has been updated after the reading was created.

---

## 9) PromptOps and Seeded Runtime State

From migration `20260301102000_phase10_gemini_context_warehouse.sql`:
1. 1 global context block + 12 feature context blocks seeded (`vi-VN`).
2. 12 active prompts seeded for:
- `core_numbers`
- `psych_matrix`
- `birth_chart`
- `energy_boost`
- `four_peaks`
- `four_challenges`
- `biorhythm_daily`
- `forecast_day`
- `forecast_month`
- `forecast_year`
- `compatibility`
- `chat_assistant`
3. Seeded model is `gemini-2.5-flash` for all feature prompts.
4. `response_schema` is stored per prompt and validated server-side.

Note: Gemini API currently rejects some JSON Schema keywords (e.g., `additionalProperties`) at request level; `_shared/gemini.ts` sanitizes schema before sending while still enforcing strict server-side validation on response.

---

## 10) Auth Mode State (Current)

1. Auth flow is email/password.
2. `public.users` retains legacy `phone_e164` field for backward compatibility.
3. `auth_method` normalized for email mode (`email_password` or `unknown`).
4. Testing mode auto-confirm is enabled by migration logic.

---

## 11) Known Drift / Reconciliation Items

1. Flutter constants currently call:
- `fn_chat_with_guide_open`
- `fn_unlock_daily_biorhythm_open`
- `fn_sync_subscription_open`

2. Repository function source currently tracks canonical slugs without `_open`.

3. Reconciliation options:
- Option A: add `_open` function sources + config to repo and keep client unchanged.
- Option B: switch Flutter to canonical slugs and remove `_open` aliases from runtime.

4. Until reconciled, backend docs and runtime can diverge even when source-control docs are correct.

---

## 12) Implementation Notes

1. Gemini key remains server-side only via Supabase secrets.
2. AI generation requests are never sent directly from Flutter to Gemini.
3. Monetization gates (VIP, quota, ad unlock) are enforced in Edge Functions and DB/RPC logic.
4. For production hardening, disable testing auto-confirm and enforce full email verification.
