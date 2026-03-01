-- PHASE 10: Gemini context warehouse + deterministic numerology baselines + prompt seeding
begin;

-- -----------------------------------------------------------------------------
-- 1) global_context_blocks (platform-owned context warehouse)
-- -----------------------------------------------------------------------------
create table if not exists public.global_context_blocks (
  id bigserial primary key,
  context_key text not null unique,
  scope text not null,
  feature_key text null,
  locale text not null default 'vi-VN',
  context_version text not null,
  priority integer not null default 100,
  content jsonb not null,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint chk_global_context_scope check (scope in ('global', 'feature')),
  constraint chk_global_context_scope_feature check (
    (scope = 'global' and feature_key is null) or
    (scope = 'feature' and feature_key is not null)
  )
);

comment on table public.global_context_blocks is
  'Platform-owned context warehouse. Feature: global + per-feature numerology guidance. AI role: reusable context layer before Gemini invocation.';
comment on column public.global_context_blocks.context_key is
  'Stable key for upsert and rollback-safe context management in migrations.';
comment on column public.global_context_blocks.content is
  'Structured context payload consumed by Edge Functions when constructing prompts.';

create index if not exists idx_global_context_blocks_lookup
on public.global_context_blocks(is_active, locale, scope, feature_key, priority);

create index if not exists idx_global_context_blocks_updated_at
on public.global_context_blocks(updated_at desc);

drop trigger if exists trg_global_context_blocks_set_updated_at on public.global_context_blocks;
create trigger trg_global_context_blocks_set_updated_at
before update on public.global_context_blocks
for each row execute function public.tg_set_updated_at();

-- -----------------------------------------------------------------------------
-- 2) profile_numerology_baselines (user-owned deterministic cache)
-- -----------------------------------------------------------------------------
create table if not exists public.profile_numerology_baselines (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  profile_id uuid not null references public.user_profiles(id) on delete cascade,
  calc_version text not null,
  context_version text not null,
  input_hash text not null,
  baseline_json jsonb not null,
  generated_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(user_id, profile_id, calc_version)
);

comment on table public.profile_numerology_baselines is
  'Deterministic numerology baseline cache by user/profile. Feature: all reading modules + chat personalization. AI role: stable numeric foundation before Gemini interpretation.';
comment on column public.profile_numerology_baselines.input_hash is
  'SHA-256 hash of normalized full_name + birth_date + calc_version for cache validation.';
comment on column public.profile_numerology_baselines.baseline_json is
  'Deterministic numerology output from local engine (non-LLM) reused across features.';

create index if not exists idx_profile_numerology_baselines_user_updated
on public.profile_numerology_baselines(user_id, updated_at desc);

create index if not exists idx_profile_numerology_baselines_profile_calc
on public.profile_numerology_baselines(profile_id, calc_version);

drop trigger if exists trg_profile_numerology_baselines_set_updated_at on public.profile_numerology_baselines;
create trigger trg_profile_numerology_baselines_set_updated_at
before update on public.profile_numerology_baselines
for each row execute function public.tg_set_updated_at();

-- -----------------------------------------------------------------------------
-- 3) RLS for new tables
-- -----------------------------------------------------------------------------
alter table public.global_context_blocks enable row level security;
alter table public.profile_numerology_baselines enable row level security;

drop policy if exists global_context_blocks_service_only on public.global_context_blocks;
drop policy if exists profile_baselines_select_own on public.profile_numerology_baselines;
drop policy if exists profile_baselines_insert_own on public.profile_numerology_baselines;
drop policy if exists profile_baselines_update_own on public.profile_numerology_baselines;
drop policy if exists profile_baselines_delete_own on public.profile_numerology_baselines;
drop policy if exists profile_baselines_service_only on public.profile_numerology_baselines;

create policy global_context_blocks_service_only
on public.global_context_blocks
for all
to service_role
using (true)
with check (true);

create policy profile_baselines_select_own
on public.profile_numerology_baselines
for select
to authenticated
using (user_id = auth.uid());

create policy profile_baselines_insert_own
on public.profile_numerology_baselines
for insert
to authenticated
with check (user_id = auth.uid());

create policy profile_baselines_update_own
on public.profile_numerology_baselines
for update
to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

create policy profile_baselines_delete_own
on public.profile_numerology_baselines
for delete
to authenticated
using (user_id = auth.uid());

create policy profile_baselines_service_only
on public.profile_numerology_baselines
for all
to service_role
using (true)
with check (true);

-- -----------------------------------------------------------------------------
-- 4) Seed global context warehouse (vi-VN)
-- -----------------------------------------------------------------------------
with seed_global as (
  select * from (
    values
      (
        'global_base_rules',
        'global',
        null,
        'vi-VN',
        'ctx_2026_03_v1',
        10,
        jsonb_build_object(
          'tone', 'calm_introspective_spiritual',
          'language', 'vi',
          'policy', jsonb_build_array(
            'Không đưa lời khẳng định tuyệt đối về tương lai.',
            'Diễn giải có trách nhiệm, mang tính tham khảo và phản tư.',
            'Không chẩn đoán y khoa, pháp lý, tài chính.'
          ),
          'style', jsonb_build_array(
            'Rõ ràng, dễ hiểu, tránh mơ hồ.',
            'Ưu tiên hành động cụ thể ngắn gọn.',
            'Giữ giọng điệu tích cực, không cực đoan.'
          )
        )
      ),
      ('feature_core_numbers', 'feature', 'core_numbers', 'vi-VN', 'ctx_2026_03_v1', 20, jsonb_build_object('objective', 'Diễn giải các chỉ số cốt lõi: đường đời, sứ mệnh, biểu đạt, linh hồn, nhân cách.', 'focus', jsonb_build_array('điểm mạnh tự nhiên', 'điểm mù cần cải thiện', 'cách ứng dụng trong công việc và quan hệ'))),
      ('feature_psych_matrix', 'feature', 'psych_matrix', 'vi-VN', 'ctx_2026_03_v1', 20, jsonb_build_object('objective', 'Diễn giải ma trận tâm lý từ tần suất chữ số ngày sinh.', 'focus', jsonb_build_array('năng lượng trội', 'năng lượng thiếu', 'gợi ý cân bằng thực tế'))),
      ('feature_birth_chart', 'feature', 'birth_chart', 'vi-VN', 'ctx_2026_03_v1', 20, jsonb_build_object('objective', 'Giải mã biểu đồ ngày sinh và tiềm năng phát triển.', 'focus', jsonb_build_array('năng lực bẩm sinh', 'khả năng học hỏi', 'định hướng phát triển'))),
      ('feature_energy_boost', 'feature', 'energy_boost', 'vi-VN', 'ctx_2026_03_v1', 20, jsonb_build_object('objective', 'Xác định vùng năng lượng gia tăng và điểm nghẽn năng lượng.', 'focus', jsonb_build_array('thói quen tăng năng lượng', 'thói quen gây hao tổn', 'nhịp sinh hoạt phù hợp'))),
      ('feature_four_peaks', 'feature', 'four_peaks', 'vi-VN', 'ctx_2026_03_v1', 20, jsonb_build_object('objective', 'Diễn giải 4 đỉnh cao cuộc đời theo giai đoạn.', 'focus', jsonb_build_array('cơ hội nổi bật theo giai đoạn', 'bài học chính', 'chiến lược chuẩn bị'))),
      ('feature_four_challenges', 'feature', 'four_challenges', 'vi-VN', 'ctx_2026_03_v1', 20, jsonb_build_object('objective', 'Diễn giải 4 thử thách cuộc đời và cách vượt qua.', 'focus', jsonb_build_array('mẫu khó khăn lặp lại', 'nguyên nhân cốt lõi', 'kế hoạch hành động ngắn hạn'))),
      ('feature_biorhythm_daily', 'feature', 'biorhythm_daily', 'vi-VN', 'ctx_2026_03_v1', 20, jsonb_build_object('objective', 'Đưa nhịp sinh học theo ngày với mức năng lượng dự kiến.', 'focus', jsonb_build_array('điểm thuận lợi hôm nay', 'điểm cần thận trọng', 'việc nên ưu tiên'))),
      ('feature_forecast_day', 'feature', 'forecast_day', 'vi-VN', 'ctx_2026_03_v1', 20, jsonb_build_object('objective', 'Xu hướng trong ngày dựa trên chu kỳ thần số học.', 'focus', jsonb_build_array('mở đầu ngày', 'công việc', 'quan hệ', 'tự chăm sóc'))),
      ('feature_forecast_month', 'feature', 'forecast_month', 'vi-VN', 'ctx_2026_03_v1', 20, jsonb_build_object('objective', 'Xu hướng trong tháng và chủ đề phát triển chính.', 'focus', jsonb_build_array('mục tiêu tháng', 'rủi ro tháng', 'điểm bứt phá'))),
      ('feature_forecast_year', 'feature', 'forecast_year', 'vi-VN', 'ctx_2026_03_v1', 20, jsonb_build_object('objective', 'Xu hướng năm và định hướng chiến lược cá nhân.', 'focus', jsonb_build_array('chủ đề năm', 'các mốc quan trọng', 'kế hoạch tăng trưởng'))),
      ('feature_compatibility', 'feature', 'compatibility', 'vi-VN', 'ctx_2026_03_v1', 20, jsonb_build_object('objective', 'Phân tích mức độ tương hợp giữa 2 hồ sơ.', 'focus', jsonb_build_array('điểm hòa hợp', 'điểm xung đột', 'nguyên tắc giao tiếp hiệu quả'))),
      ('feature_chat_assistant', 'feature', 'chat_assistant', 'vi-VN', 'ctx_2026_03_v1', 20, jsonb_build_object('objective', 'Tư vấn sâu theo ngữ cảnh cá nhân và lịch sử đọc trước đó.', 'focus', jsonb_build_array('trả lời trực diện câu hỏi', 'liên kết dữ liệu nền', 'đề xuất bước tiếp theo rõ ràng')))
  ) as t(context_key, scope, feature_key, locale, context_version, priority, content)
)
insert into public.global_context_blocks(
  context_key,
  scope,
  feature_key,
  locale,
  context_version,
  priority,
  content,
  is_active
)
select
  sg.context_key,
  sg.scope,
  sg.feature_key,
  sg.locale,
  sg.context_version,
  sg.priority,
  sg.content,
  true
from seed_global sg
on conflict (context_key)
do update set
  scope = excluded.scope,
  feature_key = excluded.feature_key,
  locale = excluded.locale,
  context_version = excluded.context_version,
  priority = excluded.priority,
  content = excluded.content,
  is_active = true,
  updated_at = now();

-- -----------------------------------------------------------------------------
-- 5) Seed active prompts (12 features) with strict response schema
-- -----------------------------------------------------------------------------
with common_schema as (
  select $schema$
  {
    "type": "object",
    "additionalProperties": false,
    "required": ["title", "summary", "insights", "actions", "memory_facts"],
    "properties": {
      "title": {"type": "string"},
      "summary": {"type": "string"},
      "insights": {
        "type": "array",
        "items": {
          "type": "object",
          "additionalProperties": false,
          "required": ["label", "value"],
          "properties": {
            "label": {"type": "string"},
            "value": {"type": "string"}
          }
        }
      },
      "actions": {
        "type": "array",
        "items": {"type": "string"}
      },
      "memory_facts": {
        "type": "array",
        "items": {
          "type": "object",
          "additionalProperties": false,
          "required": ["type", "key", "value", "confidence"],
          "properties": {
            "type": {"type": "string"},
            "key": {"type": "string"},
            "value": {"type": "object"},
            "confidence": {"type": "number"}
          }
        }
      }
    }
  }
  $schema$::jsonb as schema
),
seed_prompts as (
  select * from (
    values
      ('core_numbers', 'v1.0.0', 'gemini-2.5-flash', $prompt_core$
Bạn là chuyên gia thần số học cho SoulNum.
Nhiệm vụ: phân tích CON SỐ CỐT LÕI dựa trên payload JSON (họ tên, ngày sinh, baseline, memory, context).
Bắt buộc:
- Chỉ trả JSON hợp lệ theo response schema.
- Không markdown, không text ngoài JSON.
- insights: tối thiểu 4 mục; actions: 3-5 mục.
- memory_facts: 3-6 facts, type chỉ thuộc: trait, goal, pattern, preference, risk_note, compatibility, energy_state, decision_hint.
- Diễn giải ngắn gọn, thực tế, tiếng Việt.
$prompt_core$),
      ('psych_matrix', 'v1.0.0', 'gemini-2.5-flash', $prompt_psych$
Bạn là chuyên gia thần số học cho SoulNum.
Nhiệm vụ: phân tích MA TRẬN TÂM LÝ từ baseline và context.
Bắt buộc:
- Trả JSON đúng schema, không thêm chữ ngoài JSON.
- Nhấn mạnh năng lượng trội/thiếu và cách cân bằng.
- insights >= 4, actions 3-5, memory_facts 3-6.
- Ngôn ngữ tiếng Việt, giọng điệu bình tĩnh.
$prompt_psych$),
      ('birth_chart', 'v1.0.0', 'gemini-2.5-flash', $prompt_birth$
Bạn là chuyên gia thần số học cho SoulNum.
Nhiệm vụ: phân tích BIỂU ĐỒ NGÀY SINH và tiềm năng phát triển.
Bắt buộc:
- Chỉ trả JSON hợp lệ theo schema.
- Ưu tiên phân tích điểm mạnh, điểm cần rèn luyện và gợi ý phát triển.
- insights >= 4, actions 3-5, memory_facts 3-6.
$prompt_birth$),
      ('energy_boost', 'v1.0.0', 'gemini-2.5-flash', $prompt_energy$
Bạn là chuyên gia thần số học cho SoulNum.
Nhiệm vụ: phân tích NĂNG LƯỢNG GIA TĂNG, chỉ ra vùng tăng trưởng và hao hụt.
Bắt buộc:
- Output JSON theo schema, không văn bản ngoài JSON.
- insight mang tính ứng dụng theo thói quen hằng ngày.
- insights >= 4, actions 3-5, memory_facts 3-6.
$prompt_energy$),
      ('four_peaks', 'v1.0.0', 'gemini-2.5-flash', $prompt_peaks$
Bạn là chuyên gia thần số học cho SoulNum.
Nhiệm vụ: phân tích 4 ĐỈNH CAO cuộc đời theo dữ liệu baseline + context.
Bắt buộc:
- Chỉ trả JSON hợp lệ theo schema.
- Nêu cơ hội, bài học và gợi ý chuẩn bị theo giai đoạn.
- insights >= 4, actions 3-5, memory_facts 3-6.
$prompt_peaks$),
      ('four_challenges', 'v1.0.0', 'gemini-2.5-flash', $prompt_challenges$
Bạn là chuyên gia thần số học cho SoulNum.
Nhiệm vụ: phân tích 4 THỬ THÁCH cuộc đời và chiến lược vượt qua.
Bắt buộc:
- Trả JSON theo schema, không chữ ngoài JSON.
- Tập trung vào khó khăn cốt lõi và hành động khả thi.
- insights >= 4, actions 3-5, memory_facts 3-6.
$prompt_challenges$),
      ('biorhythm_daily', 'v1.0.0', 'gemini-2.5-flash', $prompt_bio$
Bạn là chuyên gia thần số học cho SoulNum.
Nhiệm vụ: phân tích CHU KỲ SINH HỌC THEO NGÀY.
Bắt buộc:
- Trả JSON đúng schema.
- Phản ánh xu hướng năng lượng trong ngày, tránh khẳng định tuyệt đối.
- insights >= 4, actions 3-5, memory_facts 3-6.
$prompt_bio$),
      ('forecast_day', 'v1.0.0', 'gemini-2.5-flash', $prompt_fday$
Bạn là chuyên gia thần số học cho SoulNum.
Nhiệm vụ: DỰ ĐOÁN NGÀY theo hướng tham khảo và phản tư.
Bắt buộc:
- JSON đúng schema.
- Diễn giải gắn với bối cảnh cá nhân từ baseline + memory.
- insights >= 4, actions 3-5, memory_facts 3-6.
$prompt_fday$),
      ('forecast_month', 'v1.0.0', 'gemini-2.5-flash', $prompt_fmonth$
Bạn là chuyên gia thần số học cho SoulNum.
Nhiệm vụ: DỰ ĐOÁN THÁNG theo xu hướng phát triển.
Bắt buộc:
- Chỉ trả JSON đúng schema.
- Nêu chủ đề trọng tâm của tháng và gợi ý hành động thực tế.
- insights >= 4, actions 3-5, memory_facts 3-6.
$prompt_fmonth$),
      ('forecast_year', 'v1.0.0', 'gemini-2.5-flash', $prompt_fyear$
Bạn là chuyên gia thần số học cho SoulNum.
Nhiệm vụ: DỰ ĐOÁN NĂM theo định hướng dài hạn.
Bắt buộc:
- Output JSON đúng schema, không text ngoài JSON.
- Tập trung vào chủ đề năm, điểm bứt phá, rủi ro cần quản trị.
- insights >= 4, actions 3-5, memory_facts 3-6.
$prompt_fyear$),
      ('compatibility', 'v1.0.0', 'gemini-2.5-flash', $prompt_compat$
Bạn là chuyên gia thần số học cho SoulNum.
Nhiệm vụ: phân tích CHỈ SỐ TƯƠNG HỢP giữa 2 hồ sơ.
Bắt buộc:
- Trả JSON đúng schema.
- Nêu điểm hòa hợp, điểm xung đột và nguyên tắc phối hợp.
- insights >= 4, actions 3-5, memory_facts 3-6.
$prompt_compat$),
      ('chat_assistant', 'v1.0.0', 'gemini-2.5-flash', $prompt_chat$
Bạn là trợ lý thần số học của SoulNum.
Nhiệm vụ: trả lời câu hỏi user_message dựa trên baseline, context warehouse, memory và lịch sử gần đây.
Bắt buộc:
- Trả JSON đúng schema.
- summary phải trả lời trực diện câu hỏi người dùng.
- insights >= 3, actions 2-5, memory_facts 2-5.
- Không phán quyết tuyệt đối; giữ giọng điệu hỗ trợ và cụ thể.
$prompt_chat$)
  ) as t(feature_key, version, model_name, prompt_template)
),
deactivated as (
  update public.prompt_versions p
  set is_active = false
  where p.feature_key in (select feature_key from seed_prompts)
  returning p.id
)
insert into public.prompt_versions(
  feature_key,
  version,
  model_name,
  prompt_template,
  response_schema,
  is_active,
  created_by
)
select
  sp.feature_key,
  sp.version,
  sp.model_name,
  sp.prompt_template,
  cs.schema,
  true,
  null
from seed_prompts sp
cross join common_schema cs
on conflict (feature_key, version)
do update set
  model_name = excluded.model_name,
  prompt_template = excluded.prompt_template,
  response_schema = excluded.response_schema,
  is_active = true;

commit;
