# SoulNum AI Feature Flow

## Overview

Sơ đồ dưới đây mô tả luồng từ Flutter FE -> Supabase Edge Functions -> Gemini -> Database tables cho các chức năng AI chính:

- Reading AI
- Daily Cycle unlock + reading
- AI Chatbot

## Mermaid

```mermaid
flowchart LR
    subgraph FE["Flutter App"]
        HOME["Home / Feature Tiles"]
        RD["Reading Detail Page"]
        DC["Daily Cycle Page"]
        CHAT["AI Chat Page"]
    end

    subgraph EDGE["Supabase Edge Functions"]
        READFN["fn_get_or_generate_reading"]
        UNLOCKFN["fn_unlock_daily_biorhythm"]
        CHATFN["fn_chat_with_guide"]
    end

    subgraph AI["AI Layer"]
        GEM["Google Gemini API"]
    end

    subgraph DB["Supabase Database"]
        PROFILES["user_profiles"]
        PROMPTS["prompt_versions"]
        GCTX["global_context_blocks"]
        BASELINE["profile_numerology_baselines"]
        MEMORY["ai_context_memory"]
        READINGS["user_readings"]
        ARTIFACTS["ai_generated_contents"]
        ENT["subscription_entitlements"]
        UNLOCKS["daily_biorhythm_unlocks"]
        ADS["rewarded_ad_events"]
        CHATSESS["ai_chat_sessions"]
        CHATMSG["ai_chat_messages"]
        USAGE["ai_usage_ledger"]
    end

    HOME -->|"core_numbers / psych_matrix / birth_chart / energy_boost / four_peaks / four_challenges / forecast_* / compatibility"| RD
    RD -->|"profile_id, feature_key, target_date/period, secondary_profile_id?"| READFN

    HOME -->|"biorhythm_daily"| DC
    DC -->|"profile_id, unlock_date, ad_proof?"| UNLOCKFN
    UNLOCKFN --> PROFILES
    UNLOCKFN --> ENT
    UNLOCKFN --> UNLOCKS
    UNLOCKFN -->|"free user + rewarded ad"| ADS
    UNLOCKFN -->|"unlock ok"| READFN

    HOME -->|"chat_assistant"| CHAT
    CHAT -->|"profile_id, session_id?, message"| CHATFN

    READFN --> PROFILES
    READFN -->|"check existing reading first"| READINGS
    READFN -->|"if no reusable record"| BASELINE
    READFN --> PROMPTS
    READFN --> GCTX
    READFN --> MEMORY
    READFN -->|"recent readings"| READINGS
    READFN -->|"normalized input + prompt"| GEM
    GEM --> READFN
    READFN -->|"persist AI artifact"| ARTIFACTS
    READFN -->|"persist user-visible reading"| READINGS
    READFN -->|"extract memory_facts"| MEMORY
    READFN -->|"response: reading_id, result, from_cache, generated_at"| RD

    CHATFN --> PROFILES
    CHATFN --> ENT
    CHATFN --> USAGE
    CHATFN --> BASELINE
    CHATFN --> PROMPTS
    CHATFN --> GCTX
    CHATFN --> MEMORY
    CHATFN -->|"recent readings"| READINGS
    CHATFN --> CHATSESS
    CHATFN --> CHATMSG
    CHATFN -->|"build chat context"| GEM
    GEM --> CHATFN
    CHATFN -->|"store AI artifact"| ARTIFACTS
    CHATFN -->|"store user + assistant messages"| CHATMSG
    CHATFN -->|"upsert memory_facts"| MEMORY
    CHATFN -->|"consume monthly quota"| USAGE
    CHATFN -->|"response: session_id, reply, remaining_quota"| CHAT
```

## Reading Notes

- `user_readings` là bảng lookup đầu tiên cho Reading AI.
- Nếu đã có record phù hợp theo scope, backend trả luôn từ `user_readings`.
- Nếu chưa có, backend mới load baseline + prompt + context rồi gọi Gemini.
- `ai_generated_contents` lưu artifact AI gốc.
- `user_readings` lưu bản business record mà app sẽ fetch lại.
- `ai_context_memory` lưu các `memory_facts` rút gọn để dùng lại ở reading/chat sau.

## Daily Cycle Notes

- `biorhythm_daily` có 2 bước:
  1. unlock qua `fn_unlock_daily_biorhythm`
  2. reading qua `fn_get_or_generate_reading`
- VIP user: ghi `daily_biorhythm_unlocks` với `unlock_method = vip`
- Free user: ghi `rewarded_ad_events`, rồi ghi `daily_biorhythm_unlocks`

## Chat Notes

- Chat không ghi vào `user_readings`.
- Chat dùng:
  - `ai_chat_sessions`
  - `ai_chat_messages`
  - `ai_generated_contents`
  - `ai_context_memory`
  - `ai_usage_ledger`
- Baseline deterministic vẫn được dùng để chatbot trả lời có nền tảng numerology ổn định.
