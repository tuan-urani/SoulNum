# PHASE 9 – SUPABASE BACKEND IMPLEMENTATION

## 1) Implementation Status
- Target Supabase project id: `aauidavuipscnbmdhale`
- Architecture source: [PHASE_8_TECH_ARCHITECTURE.md](/Users/uranidev/Documents/GitHub/SoulNum/PHASE_8_TECH_ARCHITECTURE.md)
- Execution mode: Supabase MCP (initial provisioning on February 28, 2026, auth-mode updates on March 1, 2026)
- Real implementation state:
  - Remote migrations applied:
    - `20260228142738_phase9_soulnum_backend_core`
    - `20260228163605_phase9_phone_password_auth_alignment`
    - `20260228163752_phase9_auth_method_normalization`
    - `20260301022503_phase9_email_password_auth_alignment`
    - `20260301022747_phase9_email_testing_auto_confirm_retry`
  - Remote tables created in `public` schema (15 tables)
  - Remote RLS + policies applied
  - Remote Edge Functions deployed
- Source artifacts in workspace:
  - `supabase/migrations/20260228211000_phase9_soulnum_backend.sql`
  - `supabase/migrations/20260228222000_phase9_phone_password_auth_alignment.sql`
  - `supabase/migrations/20260228223000_phase9_auth_method_normalization.sql`
  - `supabase/migrations/20260301022503_phase9_email_password_auth_alignment.sql`
  - `supabase/migrations/20260301022747_phase9_email_testing_auto_confirm_retry.sql`
  - `supabase/functions/*` (7 Edge Functions + shared modules)
  - `supabase/config.toml`
- Validation evidence from MCP:
  - `get_project_url` -> `https://aauidavuipscnbmdhale.supabase.co`
  - `list_migrations` includes:
    - `phase9_soulnum_backend_core`
    - `phase9_phone_password_auth_alignment`
    - `phase9_auth_method_normalization`
    - `phase9_email_password_auth_alignment`
    - `phase9_email_testing_auto_confirm_retry`
  - `list_tables` shows all expected `public` tables with `rls_enabled: true`
  - `list_edge_functions` shows all required SoulNum function slugs as `ACTIVE`

## 2) Created Database Schema (Implemented in Migration)
Migration file: [20260228211000_phase9_soulnum_backend.sql](/Users/uranidev/Documents/GitHub/SoulNum/supabase/migrations/20260228211000_phase9_soulnum_backend.sql)

### 2.1 Tables Created
1. `public.users`
2. `public.user_profiles`
3. `public.prompt_versions`
4. `public.ai_generated_contents`
5. `public.user_readings`
6. `public.ai_context_memory`
7. `public.ai_chat_sessions`
8. `public.ai_chat_messages`
9. `public.ai_usage_ledger`
10. `public.subscriptions`
11. `public.subscription_entitlements`
12. `public.subscription_events`
13. `public.rewarded_ad_events`
14. `public.daily_biorhythm_unlocks`
15. `public.profile_deletion_audits`

### 2.2 Relationship Highlights
- Ownership root:
  - `users.id` -> all user-owned tables (`user_id` / `owner_user_id`)
- Profile-scoped data:
  - `user_profiles.id` -> readings, memory, chat sessions, unlocks, ad events
- AI artifact chain:
  - `prompt_versions.id` -> `ai_generated_contents.prompt_version_id`
  - `ai_generated_contents.id` -> `user_readings.ai_content_id`, `ai_chat_messages.ai_content_id`
  - `user_readings.id` / `ai_generated_contents.id` -> `ai_context_memory.source_*`
- Monetization:
  - `subscriptions` + `subscription_events` + `subscription_entitlements`
- Daily ad gate:
  - `rewarded_ad_events.id` -> `daily_biorhythm_unlocks.ad_event_id`

### 2.3 AI Memory Persistence Coverage
- AI outputs stored in `ai_generated_contents`
- User-facing result history in `user_readings`
- Reusable cross-feature facts in `ai_context_memory`

### 2.4 Comments/Documentation in DB
- Every table includes `comment on table ...` describing:
  - table purpose
  - feature mapping
  - AI memory role
  - usage intention

### 2.5 Auth Metadata Alignment (Email + Password)
- `public.users` has been extended with:
  - `email text null`
  - `phone_e164 text null`
  - `auth_method text not null default 'unknown'`
- Existing rows are backfilled from `auth.users.email`.
- Legacy rows without email are normalized to `auth_method = 'unknown'`.
- `handle_new_auth_user()` now writes `email` + `auth_method` during auth bootstrap.
- Trigger `on_auth_user_updated` on `auth.users` now syncs from `email` changes.
- `phone_e164` is retained as legacy metadata to avoid destructive schema changes.

### 2.6 Testing Mode (No Email Confirmation)
- `handle_new_auth_user()` has test-mode logic to auto-set `auth.users.email_confirmed_at` for newly created email users.
- Existing unconfirmed email users are backfilled to `email_confirmed_at = now()` in migration.
- Result: testing signup/login can proceed without waiting for email confirmation flow.

## 3) RLS Rules Implemented

### 3.1 RLS Enabled On
- `users`
- `user_profiles`
- `prompt_versions`
- `ai_generated_contents`
- `user_readings`
- `ai_context_memory`
- `ai_chat_sessions`
- `ai_chat_messages`
- `ai_usage_ledger`
- `subscriptions`
- `subscription_entitlements`
- `subscription_events`
- `rewarded_ad_events`
- `daily_biorhythm_unlocks`
- `profile_deletion_audits`

### 3.2 Policy Strategy
- Authenticated users can access only their own records (`auth.uid()` ownership checks).
- `prompt_versions` is restricted to `service_role` policy.
- Sensitive writes (usage/quota/billing sync) are intended through Edge Functions (service role client).

### 3.3 Key Policy Groups Created
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
- `prompt_versions_service_only`

## 4) Indexing & Performance (Implemented)

### 4.1 User/Feature/Created-At Oriented Indexes
- `ai_generated_contents(user_id, feature_key, generated_at desc)`
- `user_readings(user_id, feature_key, created_at desc)`
- `user_readings(profile_id, feature_key, created_at desc)`
- `ai_context_memory(user_id, created_at desc)`
- `ai_chat_messages(user_id, created_at desc)`

### 4.2 Additional Retrieval/Integrity Indexes
- Cache lookup:
  - `ai_generated_contents(feature_key, prompt_version_id, input_hash)`
- Quota:
  - `ai_usage_ledger(user_id, usage_month desc)` + unique `(user_id, usage_month, usage_type)`
- Daily unlock idempotency:
  - unique `(user_id, profile_id, unlock_date)`
- Subscription lookup:
  - unique `(provider, provider_original_tx_id)`

## 5) SQL Functions/Triggers Implemented
- `tg_set_updated_at()` trigger helper
- `handle_new_auth_user()` auth bootstrap:
  - creates `public.users` row
  - stores auth metadata (`email`, `auth_method`)
  - seeds `subscription_entitlements` default free tier
  - auto-confirms email accounts in testing mode (`email_confirmed_at`)
- `handle_auth_user_updated()`:
  - syncs `public.users.email` from `auth.users.email` after updates
- `increment_ai_usage_if_available(...)`:
  - atomic quota increment
  - hard limit enforcement
  - blocked counter increment on exhaustion

## 6) Edge Functions Implemented

## 6.1 Shared Gateway Modules
- [http.ts](/Users/uranidev/Documents/GitHub/SoulNum/supabase/functions/_shared/http.ts)
- [supabase.ts](/Users/uranidev/Documents/GitHub/SoulNum/supabase/functions/_shared/supabase.ts)
- [gemini.ts](/Users/uranidev/Documents/GitHub/SoulNum/supabase/functions/_shared/gemini.ts)
- [prompt.ts](/Users/uranidev/Documents/GitHub/SoulNum/supabase/functions/_shared/prompt.ts)
- [memory.ts](/Users/uranidev/Documents/GitHub/SoulNum/supabase/functions/_shared/memory.ts)
- [domain.ts](/Users/uranidev/Documents/GitHub/SoulNum/supabase/functions/_shared/domain.ts)
- [hash.ts](/Users/uranidev/Documents/GitHub/SoulNum/supabase/functions/_shared/hash.ts)

### 6.2 Function List
1. [fn_get_or_generate_reading](/Users/uranidev/Documents/GitHub/SoulNum/supabase/functions/fn_get_or_generate_reading/index.ts)
2. [fn_chat_with_guide](/Users/uranidev/Documents/GitHub/SoulNum/supabase/functions/fn_chat_with_guide/index.ts)
3. [fn_unlock_daily_biorhythm](/Users/uranidev/Documents/GitHub/SoulNum/supabase/functions/fn_unlock_daily_biorhythm/index.ts)
4. [fn_sync_subscription](/Users/uranidev/Documents/GitHub/SoulNum/supabase/functions/fn_sync_subscription/index.ts)
5. [fn_delete_profile_permanently](/Users/uranidev/Documents/GitHub/SoulNum/supabase/functions/fn_delete_profile_permanently/index.ts)
6. [fn_get_history_feed](/Users/uranidev/Documents/GitHub/SoulNum/supabase/functions/fn_get_history_feed/index.ts)
7. [fn_compact_context_memory](/Users/uranidev/Documents/GitHub/SoulNum/supabase/functions/fn_compact_context_memory/index.ts)

### 6.3 AI Gateway Behavior
- Gemini is called only inside Edge Functions (`_shared/gemini.ts`)
- No Gemini API key exposure to Flutter client
- Prompt version is fetched from `prompt_versions`
- AI outputs are persisted before returning where applicable

### 6.4 AI Context Persistence Implementation
- `fn_get_or_generate_reading`:
  - writes `ai_generated_contents`
  - writes `user_readings`
  - extracts/upserts `ai_context_memory`
- `fn_chat_with_guide`:
  - writes `ai_generated_contents`
  - writes chat transcript
  - consumes hard quota via SQL function
  - upserts `ai_context_memory`

## 7) AI Execution Flow (Implemented)
1. Client calls Edge Function with Supabase JWT.
2. Function authenticates and resolves `user_id`.
3. Function loads owned profile + entitlement + memory context.
4. Function resolves active prompt version by feature.
5. Function builds payload and calls Gemini server-side.
6. Function normalizes response JSON.
7. Function persists AI artifact + reading/chat + memory facts.
8. Function returns structured response to mobile app.

## 8) Supabase Project Config
- [supabase/config.toml](/Users/uranidev/Documents/GitHub/SoulNum/supabase/config.toml)
  - project id set to `aauidavuipscnbmdhale`
  - JWT verification enabled for user-invoked functions
  - cron function (`fn_compact_context_memory`) with `verify_jwt = false`

## 9) Environment Variables Required for Deployment
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `SUPABASE_SERVICE_ROLE_KEY`
- `GEMINI_API_KEY`
- `VIP_CHATBOT_MONTHLY_LIMIT` (optional, default used when absent)
- `BILLING_VERIFY_URL` (optional; if absent, sync function runs in mock verification mode)
- `CRON_SECRET` (for scheduled memory compaction endpoint)

## 10) Deployment Notes
Deployment via Supabase MCP has been executed directly on project `aauidavuipscnbmdhale`.

Current deployed function slugs:
- `fn_get_or_generate_reading`
- `fn_chat_with_guide`
- `fn_unlock_daily_biorhythm`
- `fn_sync_subscription`
- `fn_delete_profile_permanently`
- `fn_get_history_feed`
- `fn_compact_context_memory`

Additional note:
- A temporary validation function `zz_path_test` was created to verify MCP path bundling before production deploys.
- It is unrelated to SoulNum business logic and can be removed manually from Supabase dashboard if you want a clean function list.
- Authentication mode on backend is aligned to email/password metadata.
- Testing mode currently bypasses email confirmation through DB-side auto-confirm logic in `handle_new_auth_user()`.
- For production hardening, remove this auto-confirm logic and re-enable email confirmation flow.

## 11) Backend Reasoning Summary
- The schema is AI-memory-first:
  - generated artifacts + user-visible readings + reusable memory facts are separate but linked.
- Monetization constraints are enforced server-side:
  - VIP entitlement checks
  - hard monthly chat quota
  - ad-gated daily unlock for free users
- Security posture:
  - RLS for user isolation
  - Gemini key server-side only
  - service-role only for privileged prompt and quota paths

---

## 12) Phase 10 Gemini Plan Execution Update (2026-03-01)

### 12.1 Migrations Applied to Project `aauidavuipscnbmdhale`
1. `phase10_context_baseline_tables`
   - created `public.global_context_blocks`
   - created `public.profile_numerology_baselines`
   - applied RLS + policies + indexes + updated_at triggers
2. `phase10_seed_prompt_and_context`
   - seeded global context blocks (`global + feature`)
   - seeded 12 active feature prompts in `public.prompt_versions`
   - all seeded prompts use strict JSON schema + `gemini-2.5-flash`

### 12.2 Remote Verification Snapshot
1. Prompt active count: exactly 1 active row for each of 12 features:
   - `core_numbers`, `psych_matrix`, `birth_chart`, `energy_boost`,
   - `four_peaks`, `four_challenges`,
   - `biorhythm_daily`,
   - `forecast_day`, `forecast_month`, `forecast_year`,
   - `compatibility`, `chat_assistant`.
2. Global context blocks active:
   - 1 global block
   - 12 feature blocks
3. New indexes present:
   - `idx_global_context_blocks_lookup`
   - `idx_global_context_blocks_updated_at`
   - `idx_profile_numerology_baselines_user_updated`
   - `idx_profile_numerology_baselines_profile_calc`

### 12.3 Edge Function Source Implemented (Repo State)
1. Updated:
   - [supabase/functions/_shared/gemini.ts](/Users/uranidev/Documents/GitHub/SoulNum/supabase/functions/_shared/gemini.ts)
   - [supabase/functions/_shared/prompt.ts](/Users/uranidev/Documents/GitHub/SoulNum/supabase/functions/_shared/prompt.ts)
   - [supabase/functions/_shared/memory.ts](/Users/uranidev/Documents/GitHub/SoulNum/supabase/functions/_shared/memory.ts)
   - [supabase/functions/fn_get_or_generate_reading/index.ts](/Users/uranidev/Documents/GitHub/SoulNum/supabase/functions/fn_get_or_generate_reading/index.ts)
   - [supabase/functions/fn_chat_with_guide/index.ts](/Users/uranidev/Documents/GitHub/SoulNum/supabase/functions/fn_chat_with_guide/index.ts)
2. Added:
   - [supabase/functions/_shared/context.ts](/Users/uranidev/Documents/GitHub/SoulNum/supabase/functions/_shared/context.ts)
   - [supabase/functions/_shared/baseline.ts](/Users/uranidev/Documents/GitHub/SoulNum/supabase/functions/_shared/baseline.ts)
   - [supabase/functions/_shared/numerology.ts](/Users/uranidev/Documents/GitHub/SoulNum/supabase/functions/_shared/numerology.ts)

### 12.4 Deployment Status Note (Important)
1. Supabase MCP deploy succeeds for new slugs with the updated bundle (validated via test slug `zz_full_compile`).
2. Supabase MCP currently returns `Function deploy failed due to an internal error` when attempting to update the two existing production slugs:
   - `fn_get_or_generate_reading`
   - `fn_chat_with_guide`
3. Therefore:
   - DB/migration state is fully applied on project.
   - Updated AI orchestration code is present in repository.
   - Direct in-place overwrite of the two old slugs is blocked by MCP deployment behavior at this time.

### 12.5 Temporary MCP Validation Functions Present
The following MCP validation slugs exist in project and are not part of business scope:
1. `zz_path_test`
2. `zz_compile_test`
3. `zz_compile_test2`
4. `zz_full_compile`

They can be deleted manually in Supabase dashboard after final production function rollout.
