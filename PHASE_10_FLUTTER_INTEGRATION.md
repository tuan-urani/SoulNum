# PHASE 10 – FLUTTER UI & BACKEND IMPLEMENTATION

## 1) Scope
This document describes the real Flutter implementation for SoulNum Phase 10, based on:
- `PRD - SoulNum (Vietnam, Numerology-first).md`
- `PHASE_5_USER_FLOW_DEFINITION.md`
- `PHASE_7_UI_DESIGN.md`
- `PHASE_8_TECH_ARCHITECTURE.md`
- `PHASE_9_SUPABASE_IMPLEMENTATION.md`
- `.codex/rules/ui.md`

Constraints respected:
- No backend schema modification.
- No flow redesign.
- UI implementation follows existing rule system and app token usage.

## 2) Implementation Summary
Implemented in codebase:
1. Supabase runtime integration (`supabase_flutter`) with session bootstrap.
2. Data layer for secure table queries and Edge Function invocations.
3. Feature modules and real screen routes for core user journeys.
4. Localization expansion for Vietnamese-first MVP (`vi_VN`) with parity for `en_US`, `ja_JP`.
5. Verified static quality and tests.

## 3) Layered Architecture (Implemented)
### 3.1 Presentation Layer (`lib/src/ui`)
Responsibilities:
- Render screens and components.
- Receive user actions and dispatch to Cubits.
- Show state matrix: `loading`, `success`, `empty`, `failure`, `unauthorized`.

Key implemented modules:
- `ui/home`
- `ui/profile_manager`
- `ui/reading_detail`
- `ui/compatibility`
- `ui/daily_cycle`
- `ui/subscription`
- `ui/ai_chat`
- `ui/history`

### 3.2 Interactor/BLoC Layer
Responsibilities:
- Business orchestration and page-level state transitions.
- Validation before repository calls.
- Error state mapping for UI.

Implemented Cubits:
- `HomeCubit`
- `ProfileManagerCubit`
- `ReadingDetailCubit`
- `CompatibilityCubit`
- `DailyCycleCubit`
- `SubscriptionCubit`
- `AiChatCubit`
- `HistoryCubit`

### 3.3 Repository Layer (`lib/src/core/repository`)
Responsibilities:
- Use-case-oriented API for UI logic.
- Compose Supabase data sources and mappers.

Implemented repositories:
- `SessionRepository`
- `ProfileRepository`
- `ReadingRepository`
- `ChatRepository`
- `SubscriptionRepository`
- `HistoryRepository`
- `ProfileDeletionRepository`

### 3.4 Data Source Layer (`lib/src/api`)
Responsibilities:
- Low-level Supabase access.
- Edge Function invocation boundary.

Implemented data sources:
- `api/supabase/supabase_client_factory.dart`
- `api/supabase/supabase_auth_data_source.dart`
- `api/supabase/supabase_profile_data_source.dart`
- `api/supabase/supabase_ai_data_source.dart`
- `api/edge_functions/ai_gateway_api.dart`

### 3.5 Core Models and Mapping (`lib/src/core/model`, `lib/src/core/mapper`)
Implemented categories:
- Request DTOs: reading/chat/unlock/subscription/delete/history/profile upsert.
- Response DTOs: reading/chat/unlock/subscription/delete/history/profile/entitlement.
- Domain models: profile/entitlement/reading/chat/history/feature tile.
- Mapper: `core/mapper/soul_mapper.dart`.

## 4) Folder Structure Rationale
Implemented structure aligns with project architecture and `ui.md`:
- `lib/src/ui/<feature>/{binding,interactor,components,<feature>_page.dart}`
- `lib/src/core/model/request` and `lib/src/core/model/response`
- `lib/src/core/model` for UI/domain models
- `lib/src/core/repository` for orchestration
- `lib/src/api` for Supabase transport

Reasoning:
1. Prevents UI from calling backend directly.
2. Keeps feature ownership clear.
3. Enables maintainable testability and future scale.

## 5) Routing and Screen Coverage
Implemented route registry: `lib/src/utils/app_pages.dart`

Implemented screens:
1. Splash/session bootstrap
2. Home dashboard
3. Profile manager
4. Profile create form
5. Profile detail
6. Profile delete confirm
7. Reading detail (used by core numerology detail entries)
8. Compatibility
9. Daily cycle (locked/unlocked states)
10. VIP subscription
11. AI chat active
12. AI chat quota exhausted
13. History feed

This coverage maps to previously approved core/detail flow states from Phase 5 and Phase 7.

## 6) Supabase Integration Lifecycle
### 6.1 App Startup
- `environment_module.dart` loads `.env` and initializes Supabase.
- Required keys:
  - `SUPABASE_URL`
  - `SUPABASE_ANON_KEY` (publishable key used in current setup)

### 6.2 Session Handling
- `SplashPage` calls `SessionRepository.ensureSession()`.
- If no valid session exists, route to login.
- Auth target mode: email + password (anonymous sign-in is not a dependency).
- On successful sign-in: navigate to main/home.
- Backend trigger (`handle_new_auth_user`) initializes `public.users` + free entitlement snapshot.
- Backend trigger (`on_auth_user_updated`) syncs `public.users.email` when auth email changes.
- Testing mode note: backend auto-confirms new email users via `handle_new_auth_user` to skip confirmation during QA.

### 6.3 Secure Query Access
- Profile and entitlement reads use RLS-protected table queries.
- User-scoped ownership is enforced server-side by Supabase policies.

### 6.4 Edge Function Invocation
Implemented via `AiGatewayApi` + `SupabaseAiDataSource`:
- `fn_get_or_generate_reading`
- `fn_chat_with_guide`
- `fn_unlock_daily_biorhythm`
- `fn_sync_subscription`
- `fn_delete_profile_permanently`
- `fn_get_history_feed`

## 7) AI Invocation Lifecycle
1. UI event (example: open core reading, send chat message).
2. Cubit validates preconditions (profile selection, VIP gate, quota state).
3. Repository creates typed request DTO.
4. Data source calls Edge Function through Supabase Functions API.
5. Edge Function handles prompt/memory/generation/persistence server-side.
6. Response DTO is mapped to domain model.
7. Cubit emits next state (`success`, `failure`, `unauthorized`, or `empty`).

## 8) Monetization and Gating Behavior (Implemented)
1. Core numerology reading remains free (Edge reading function callable for valid profile).
2. VIP chatbot gate:
   - Chat page checks entitlement.
   - Non-VIP state routes user to upgrade path.
   - Quota exhaustion routes to `ai_chat_limit` screen.
3. Daily biorhythm gate:
   - Free users unlock with rewarded-ad proof payload.
   - VIP users are auto-unlocked.
4. Subscription sync:
   - Triggered from subscription screen through `fn_sync_subscription`.
   - Entitlement snapshot updated server-side.

## 9) Localization
Implemented:
- `vi_VN` added and set as default/fallback in `translation_manager.dart`.
- `en_US`, `ja_JP` updated for key parity.
- New keys added in `locale_key.dart` and consumed with `.tr`.

## 10) UI Rule Compliance Notes (`ui.md`)
Implemented alignment:
1. Shared App widgets used and extended (`AppButton`, `AppScreenScaffold`, `AppStatePlaceholder`).
2. Page-state rendering centralized with `AppBody` supporting `empty` and `unauthorized`.
3. No direct backend calls from widgets.
4. Request/response/domain model boundaries are explicit.

## 11) Performance and Reliability Strategy
Current implementation choices:
1. Reading and chat call server caching/memory logic through Edge Functions.
2. History uses cursor-based pagination (`next_cursor`).
3. State updates are immutable and scoped by feature Cubits.
4. Error states include retry paths in UI.

## 12) Security Notes
1. Gemini is never called from Flutter.
2. Only Supabase publishable/anon key is present in app config.
3. JWT/session handling is managed by Supabase auth client.
4. Sensitive entitlement/quota logic remains server-side.

## 13) Verification Results
Executed locally with FVM:
1. `fvm flutter pub get` -> success
2. `fvm flutter analyze` -> no issues found
3. `fvm flutter test` -> all tests passed

## 14) Next Implementation Extensions (Optional)
1. Replace mock purchase token flow with real StoreKit/Play Billing callback pipeline.
2. Add dedicated UI polish pass for strict 1:1 Figma spacing/text metrics if design QA requires pixel-level parity.
3. Add widget/integration tests for paywall, daily unlock, and quota transitions.
