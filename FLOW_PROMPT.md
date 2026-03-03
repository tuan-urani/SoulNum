Đúng trạng thái hiện tại, các chức năng dùng AI của SoulNum là:

| Feature key | Chức năng | Loại | Function backend |
|---|---|---|---|
| `core_numbers` | Con số cốt lõi | Reading AI | `fn_get_or_generate_reading` |
| `psych_matrix` | Ma trận tâm lý | Reading AI | `fn_get_or_generate_reading` |
| `birth_chart` | Biểu đồ ngày sinh | Reading AI | `fn_get_or_generate_reading` |
| `energy_boost` | Năng lượng gia tăng | Reading AI | `fn_get_or_generate_reading` |
| `four_peaks` | 4 đỉnh cao | Reading AI | `fn_get_or_generate_reading` |
| `four_challenges` | 4 thử thách | Reading AI | `fn_get_or_generate_reading` |
| `compatibility` | Chỉ số tương hợp | Reading AI | `fn_get_or_generate_reading` |
| `forecast_day` | Dự đoán ngày | Reading AI | `fn_get_or_generate_reading` |
| `forecast_month` | Dự đoán tháng | Reading AI | `fn_get_or_generate_reading` |
| `forecast_year` | Dự đoán năm | Reading AI | `fn_get_or_generate_reading` |
| `biorhythm_daily` | Chu kỳ sinh học theo ngày | Reading AI + gate | `fn_unlock_daily_biorhythm` rồi `fn_get_or_generate_reading` |
| `chat_assistant` | AI Chatbot | Chat AI | `fn_chat_with_guide` |

**Điều quan trọng trước**
Client không gửi thẳng `họ tên + ngày sinh` lên mỗi lần gọi AI.

Client hiện chỉ gửi:
- Reading:
```json
{
  "profile_id": "...",
  "feature_key": "...",
  "target_period": "...",
  "target_date": "YYYY-MM-DD",
  "secondary_profile_id": "...",
  "force_refresh": false
}
```
- Chat:
```json
{
  "profile_id": "...",
  "session_id": "...",
  "message": "..."
}
```

Tên, ngày sinh, giới tính được backend tự đọc từ `user_profiles`.

**Prompt + context dùng ra sao**
Mọi AI feature hiện tại đều theo công thức chung:

1. `prompt_versions`
- lấy prompt riêng theo `feature_key`
- ví dụ `core_numbers` có prompt riêng, `forecast_day` có prompt riêng

2. `global_context_blocks`
- lấy rule chung + context riêng cho feature
- ví dụ objective của `core_numbers` là giải thích các chỉ số cốt lõi
- objective của `compatibility` là so khớp 2 hồ sơ

3. `profile_numerology_baselines`
- lấy baseline deterministic từ `full_name + birth_date`
- đây là nền số học gốc

4. `ai_context_memory`
- lấy memory facts đã tích lũy của profile

5. `user_readings`
- lấy recent readings gần nhất làm context
- đồng thời check reuse trước khi generate mới

6. `ai_chat_messages`
- chỉ dùng cho `chat_assistant`
- đưa lịch sử chat gần nhất vào context

**Schema output AI hiện tại**
Các reading AI đang dùng chung một schema JSON strict kiểu:
```json
{
  "title": "string",
  "summary": "string",
  "insights": [{"label": "string", "value": "string"}],
  "actions": ["string"],
  "memory_facts": [
    {
      "type": "string",
      "key": "string",
      "value": {},
      "confidence": 0.0
    }
  ]
}
```

**1. Nhóm Reading AI cố định 1 lần**
Áp dụng cho:
- `core_numbers`
- `psych_matrix`
- `birth_chart`
- `energy_boost`
- `four_peaks`
- `four_challenges`

Prompt/context:
- prompt riêng theo feature
- global context riêng theo feature
- baseline của profile
- memory của profile
- recent readings gần nhất

Process:
1. Client gửi `profile_id + feature_key`
2. Backend đọc `user_profiles`
3. Backend check `user_readings` xem profile này đã có reading cho feature đó chưa
4. Nếu có rồi thì trả luôn
5. Nếu chưa có thì:
- lấy hoặc tính `profile_numerology_baselines`
- lấy `prompt_versions`
- lấy `global_context_blocks`
- lấy `ai_context_memory`
- lấy recent `user_readings`
- gọi Gemini
6. Sau khi Gemini trả về:
- lưu artifact vào `ai_generated_contents`
- lưu reading business vào `user_readings`
- rút `memory_facts` và upsert vào `ai_context_memory`

Client nhận:
```json
{
  "reading_id": "...",
  "feature_key": "core_numbers",
  "from_cache": true/false,
  "result": { ...JSON ở trên... },
  "generated_at": "...",
  "prompt_version": "v1.0.0",
  "context_version": "..."
}
```

Lưu DB:
- đọc: `user_profiles`, `user_readings`, `profile_numerology_baselines`, `prompt_versions`, `global_context_blocks`, `ai_context_memory`
- ghi khi miss:
  - `profile_numerology_baselines` nếu chưa có hoặc stale
  - `ai_generated_contents`
  - `user_readings`
  - `ai_context_memory`
- ghi khi hit:
  - chỉ update `ai_context_memory.last_used_at`

**2. `compatibility`**
Khác biệt:
- client phải gửi thêm `secondary_profile_id`
- backend đọc 2 hồ sơ
- backend tạo/lấy 2 baseline

Prompt/context:
- prompt `compatibility`
- global context `feature_compatibility`
- baseline profile chính
- baseline profile phụ
- memory của profile chính
- recent readings của profile chính

Process:
1. Client gửi `profile_id + secondary_profile_id + feature_key=compatibility`
2. Backend check cả 2 profile đều thuộc user
3. Backend yêu cầu cả 2 profile có `full_name + birth_date`
4. Check reuse trong `user_readings` theo cặp profile này
5. Nếu chưa có thì build payload với `profile.baseline` và `secondary_profile.baseline`
6. Gọi Gemini
7. Ghi DB giống reading thường

Client nhận:
- cùng contract reading thường

Lưu DB:
- đọc: giống reading thường nhưng thêm profile phụ
- ghi: `ai_generated_contents`, `user_readings`, `ai_context_memory`

**3. Nhóm Reading AI theo thời gian**
Áp dụng cho:
- `forecast_day`
- `forecast_month`
- `forecast_year`

Khác biệt chính:
- reuse theo scope thời gian, không phải chỉ 1 lần

Client gửi:
- `forecast_day`: `target_date`
- `forecast_month`: `target_period = YYYY-MM`
- `forecast_year`: `target_period = YYYY`

Nếu client không gửi:
- backend tự lấy ngày/tháng/năm hiện tại

Prompt/context:
- giống reading thường
- thêm `target_date` hoặc `target_period` vào payload Gemini

Process:
1. Client gửi request theo feature
2. Backend resolve scope:
- daily -> `target_date`
- monthly -> `period_key YYYY-MM`
- yearly -> `period_key YYYY`
3. Backend check `user_readings` theo scope đó
4. Nếu đã có record đúng scope thì trả lại
5. Nếu chưa có thì generate mới
6. Ghi DB như reading thường, nhưng `user_readings` có thêm:
- `target_date`
- hoặc `period_key`

Client nhận:
- cùng contract reading thường

Lưu DB:
- đọc: giống reading thường
- ghi:
  - `ai_generated_contents`
  - `user_readings.target_date` hoặc `user_readings.period_key`
  - `ai_context_memory`

**4. `biorhythm_daily`**
Đây là reading AI nhưng có thêm bước unlock trước.

Flow:
1. Client gọi `fn_unlock_daily_biorhythm`
2. Nếu unlock thành công mới gọi `fn_get_or_generate_reading` với `feature_key = biorhythm_daily`

Nếu user là VIP:
- backend ghi `daily_biorhythm_unlocks` với `unlock_method = vip`

Nếu user free xem ads:
- backend ghi `rewarded_ad_events`
- rồi ghi `daily_biorhythm_unlocks` với `unlock_method = rewarded_ad`

Sau đó phần AI processing:
- giống `forecast_day`
- reuse theo `target_date`

Prompt/context:
- prompt `biorhythm_daily`
- global context `feature_biorhythm_daily`
- baseline
- memory
- recent readings

Client nhận:
- unlock response trước:
```json
{
  "unlocked": true,
  "unlock_method": "vip | rewarded_ad",
  "unlock_date": "YYYY-MM-DD"
}
```
- rồi reading response như reading thường

Lưu DB:
- unlock step:
  - đọc: `subscription_entitlements`, `daily_biorhythm_unlocks`
  - ghi:
    - `daily_biorhythm_unlocks`
    - `rewarded_ad_events` nếu free user
- AI step:
  - ghi như reading thường:
    - `ai_generated_contents`
    - `user_readings`
    - `ai_context_memory`

**5. `chat_assistant`**
Đây là flow riêng, không dùng `user_readings` làm bảng kết quả chính.

Client gửi:
- `profile_id`
- `session_id` nếu đang chat tiếp
- `message`

Prompt/context:
- prompt `chat_assistant`
- global context `feature_chat_assistant`
- baseline của profile
- `ai_context_memory`
- recent `user_readings`
- recent `ai_chat_messages`

Process:
1. Backend check auth
2. Check profile ownership
3. Lấy hoặc tạo baseline
4. Check `subscription_entitlements` xem user có VIP Pro không
5. Check monthly quota trong `ai_usage_ledger`
6. Tạo `ai_chat_sessions` nếu chưa có session
7. Lưu message người dùng vào `ai_chat_messages`
8. Load recent messages + memory + recent readings
9. Gọi Gemini
10. Ghi artifact vào `ai_generated_contents`
11. Ghi message assistant vào `ai_chat_messages`
12. Upsert `memory_facts` vào `ai_context_memory`
13. Update quota ledger

Client nhận:
```json
{
  "session_id": "...",
  "reply": "text trả lời cuối cùng",
  "remaining_quota": 6,
  "quota_limit": 10,
  "quota_exhausted": false,
  "prompt_version": "v1.0.0",
  "context_version": "..."
}
```

Lưu ý:
- backend có thể lấy `reply` từ `output_json.reply`
- nếu không có thì fallback sang `output_json.summary`
- Flutter hiện chỉ dùng `reply` + quota fields

Lưu DB:
- đọc:
  - `user_profiles`
  - `profile_numerology_baselines`
  - `prompt_versions`
  - `global_context_blocks`
  - `ai_context_memory`
  - `user_readings`
  - `subscription_entitlements`
  - `ai_usage_ledger`
  - `ai_chat_sessions`
  - `ai_chat_messages`
- ghi:
  - `profile_numerology_baselines` nếu cần
  - `ai_chat_sessions` nếu session mới
  - `ai_chat_messages` cho user message
  - `ai_generated_contents`
  - `ai_chat_messages` cho assistant message
  - `ai_context_memory`
  - `ai_usage_ledger`

**Tóm tắt vai trò các bảng trong AI flow**
- `prompt_versions`: prompt runtime theo feature
- `global_context_blocks`: luật và objective theo domain/feature
- `profile_numerology_baselines`: nền số học deterministic của profile
- `ai_generated_contents`: artifact AI gốc
- `user_readings`: kết quả reading mà app reuse
- `ai_context_memory`: memory facts ngắn hạn/dài hạn cho cá nhân hóa
- `ai_chat_sessions`: phiên chat
- `ai_chat_messages`: lịch sử chat
- `ai_usage_ledger`: quota chat tháng
- `daily_biorhythm_unlocks`: unlock gate cho biorhythm
- `rewarded_ad_events`: bằng chứng rewarded ad

**Một điểm quan trọng**
Backend hiện trả `prompt_version` và `context_version` cho cả reading/chat, nhưng Flutter model hiện tại chưa map các field đó ở client reading/chat. Nghĩa là:
- backend có trả
- app hiện chưa dùng

Nguồn chính:
- [fn_get_or_generate_reading/index.ts](/Users/uranidev/Documents/GitHub/SoulNum/supabase/functions/fn_get_or_generate_reading/index.ts)
- [fn_chat_with_guide/index.ts](/Users/uranidev/Documents/GitHub/SoulNum/supabase/functions/fn_chat_with_guide/index.ts)
- [fn_unlock_daily_biorhythm/index.ts](/Users/uranidev/Documents/GitHub/SoulNum/supabase/functions/fn_unlock_daily_biorhythm/index.ts)
- [20260301102000_phase10_gemini_context_warehouse.sql](/Users/uranidev/Documents/GitHub/SoulNum/supabase/migrations/20260301102000_phase10_gemini_context_warehouse.sql)

Nếu bạn muốn, bước tiếp theo mình có thể làm 1 bảng đơn giản hơn nữa theo format:
- `Chức năng`
- `User bấm gì`
- `Server đọc bảng nào`
- `Server ghi bảng nào`
- `Client nhận gì`
để bạn dùng như tài liệu sản phẩm/nghiệp vụ.