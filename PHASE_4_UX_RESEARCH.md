# PHASE 4 – UX RESEARCH

## Context
- Product: SoulNum (Vietnam, Numerology-first)
- Input source: Approved PRD v1.2
- Scope: User behavior understanding only (no UI design, no database design)

## 1) Primary User Personas

### Persona 1: "Lan" - Self-discovery Seeker (Primary)
- Age range: 22-30
- Context: Đang ở giai đoạn chuyển việc/tình cảm, có nhiều quyết định cá nhân.
- Motivation: Muốn hiểu bản thân để giảm mơ hồ khi ra quyết định.
- Behavior:
  - Dùng mobile nhiều, chủ yếu buổi tối.
  - Sẵn sàng thử app free trước, chỉ trả phí khi thấy "đúng" và "hữu ích".
  - Quay lại theo nhịp hằng ngày nếu có lý do rõ ràng.
- Sensitivity:
  - Nhạy cảm với nội dung chung chung.
  - Dễ bỏ app nếu ad gây gián đoạn hoặc kết quả thiếu nhất quán.

### Persona 2: "Minh" - Family Interpreter (Primary)
- Age range: 29-40
- Context: Muốn xem cho bản thân, người yêu/vợ chồng, con cái, người thân.
- Motivation: Tìm góc nhìn để cải thiện quan hệ và cách giao tiếp.
- Behavior:
  - Tạo nhiều hồ sơ để so sánh/tương hợp.
  - Quan tâm chỉ số tương hợp và dự đoán chu kỳ.
  - Có xu hướng cân nhắc VIP khi chạm giới hạn 2 hồ sơ free.
- Sensitivity:
  - Cần trải nghiệm rõ ràng khi chuyển đổi giữa nhiều hồ sơ.
  - Không muốn nhập lại dữ liệu nhiều lần.

### Persona 3: "Tuấn" - Pragmatic Explorer (Secondary)
- Age range: 18-27
- Context: Tò mò numerology, chưa chắc niềm tin cao.
- Motivation: Tìm insight nhanh, giải trí có định hướng.
- Behavior:
  - Vào app theo phiên ngắn.
  - Sử dụng daily prediction/biological cycle như thói quen check nhanh.
  - Chỉ cân nhắc trả phí nếu chatbot cho câu trả lời sâu và cá nhân.
- Sensitivity:
  - Rất nhạy với paywall sớm.
  - Dễ rời bỏ nếu giá trị trả phí không khác biệt rõ.

## 2) User Journey Map

| Stage | User Goal | Key Actions | Emotional State | Decision Friction |
|---|---|---|---|---|
| 1. Trigger | Tìm hiểu bản thân/quan hệ | Tải app, mở app lần đầu | Tò mò, kỳ vọng | Nghi ngờ độ chính xác và độ tin cậy |
| 2. Setup Profile | Nhận kết quả cá nhân hóa | Nhập họ tên + ngày sinh | Tập trung, hy vọng | Lo ngại nhập sai dữ liệu làm sai kết quả |
| 3. First Value | Xác thực "app có đúng mình không" | Xem con số cốt lõi, biểu đồ ngày sinh, ma trận tâm lý | Hào hứng nếu thấy đúng; thất vọng nếu chung chung | Nội dung dày đặc, khó tiêu hóa nếu quá nhiều khái niệm |
| 4. Exploration | Mở rộng insight | Xem 4 đỉnh cao, 4 thử thách, dự đoán ngày/tháng/năm | Quan tâm, muốn đào sâu | Khó phân biệt insight nào nên ưu tiên hành động |
| 5. Habit Loop | Có lý do quay lại mỗi ngày | Mở chu kỳ sinh học theo ngày | Ổn định, tạo thói quen | Free user phải xem rewarded ad, có thể drop nếu ad không tải/chờ lâu |
| 6. Social/Family Usage | So sánh với người khác | Tạo thêm hồ sơ, xem chỉ số tương hợp | Gắn kết, tò mò | Chạm trần 2 hồ sơ free tạo ma sát nâng cấp |
| 7. Monetization Decision | Quyết định trả phí | Cân nhắc VIP Pro để mở chatbot và không giới hạn hồ sơ | Cân nhắc giá trị/chi phí | Hoài nghi chatbot có đủ sâu; lo hard limit không đủ dùng |
| 8. VIP Usage | Đào sâu bản thân | Chat AI theo hồ sơ cá nhân | Được hỗ trợ, tự tin hơn | Bị ngắt khi chạm hard limit gây hụt cảm xúc |
| 9. Retention/Trust | Duy trì giá trị dài hạn | Quay lại daily, kiểm chứng dự đoán theo thời gian | Tin tưởng dần hoặc chán dần | Nếu insight lặp lại, perceived value giảm và churn tăng |

## 3) Pain Points In Current Experience

1. Niềm tin thấp vào độ chính xác do thị trường có nhiều nội dung numerology chung chung.
2. Cognitive overload: nhiều chỉ số/khái niệm, người mới khó hiểu nhanh "nó giúp gì cho mình".
3. Thiếu ưu tiên hành động: người dùng đọc nhiều nhưng khó quyết định nên làm gì tiếp theo.
4. Daily unlock friction: Free user có thể khó chịu nếu rewarded ad thất bại, tải chậm, hoặc tần suất cảm nhận quá dày.
5. Upgrade friction tại giới hạn hồ sơ: nếu lý do nâng cấp không đủ rõ, người dùng sẽ dừng thay vì trả phí.
6. Perceived unfairness với hard limit chatbot: người dùng VIP có thể cảm thấy bị giới hạn khi nhu cầu tăng đột biến.
7. Data sensitivity anxiety: người dùng e ngại lưu họ tên + ngày sinh nếu không thấy kiểm soát dữ liệu rõ ràng.
8. Inconsistency risk: nếu nội dung giữa các module (cốt lõi, chu kỳ, dự đoán) mâu thuẫn, trust giảm nhanh.

## 4) Behavioral Insights

1. "Proof-before-pay" behavior: đa số người dùng chỉ trả phí sau khi free experience chứng minh độ đúng và tính hữu ích cá nhân.
2. Daily intent is lightweight: hành vi quay lại mỗi ngày thường là check nhanh; bất kỳ ma sát nào > vài giây đều làm rơi phiên.
3. Relationship-driven expansion: nhu cầu xem cho người thân là động lực mạnh để tạo nhiều hồ sơ và tăng tần suất dùng.
4. Trust compounds over sessions: giá trị cảm nhận tăng khi insight nhất quán qua nhiều lần kiểm chứng, không phải chỉ ở phiên đầu.
5. Pay decision is event-based: xác suất nâng cấp cao nhất khi chạm "moment of need" (chạm trần hồ sơ, cần đào sâu qua chatbot).
6. Hard limit tolerance depends on transparency: người dùng chấp nhận giới hạn nếu biết trước quota và cảm thấy công bằng.
7. Emotional oscillation pattern:
   - Early journey: tò mò -> kỳ vọng
   - First results: xác nhận bản thân hoặc nghi ngờ
   - Daily usage: tiện lợi -> thói quen
   - Paywall moment: cân nhắc -> do dự
   - VIP deep use: được hỗ trợ -> hụt hẫng khi hết quota
8. Decision friction concentrates at 3 points:
   - Sau lần đọc đầu: "kết quả có đủ đúng để tin không?"
   - Tại daily ad gate: "xem tiếp có đáng công xem ads không?"
   - Tại VIP upgrade: "chatbot + unlimited hồ sơ có đáng tiền không?"

## Structured Output (JSON)

```json
{
  "personas": [
    {
      "name": "Lan - Self-discovery Seeker",
      "segment": "Primary",
      "age_range": "22-30",
      "goals": [
        "Hiểu bản thân để ra quyết định cá nhân rõ hơn",
        "Tìm insight đủ sâu nhưng dễ hiểu"
      ],
      "behaviors": [
        "Mobile-first, dùng nhiều buổi tối",
        "Dùng free trước rồi mới cân nhắc trả phí",
        "Quay lại hằng ngày nếu có giá trị rõ"
      ],
      "sensitivity": [
        "Nội dung chung chung làm giảm niềm tin",
        "Ad gián đoạn làm giảm retention"
      ]
    },
    {
      "name": "Minh - Family Interpreter",
      "segment": "Primary",
      "age_range": "29-40",
      "goals": [
        "Xem cho bản thân và người thân",
        "Cải thiện sự hòa hợp trong quan hệ"
      ],
      "behaviors": [
        "Tạo nhiều hồ sơ để so sánh",
        "Quan tâm mạnh tới chỉ số tương hợp",
        "Có động lực nâng cấp khi chạm trần hồ sơ"
      ],
      "sensitivity": [
        "Không muốn thao tác nhập liệu lặp lại",
        "Cần chuyển đổi hồ sơ nhanh và rõ"
      ]
    },
    {
      "name": "Tuấn - Pragmatic Explorer",
      "segment": "Secondary",
      "age_range": "18-27",
      "goals": [
        "Nhận insight nhanh, thực dụng",
        "Khám phá numerology theo hướng thử nghiệm"
      ],
      "behaviors": [
        "Phiên dùng ngắn, check nhanh hằng ngày",
        "Nhạy với paywall sớm",
        "Chỉ trả phí nếu chatbot khác biệt rõ"
      ],
      "sensitivity": [
        "Giá trị trả phí không rõ sẽ không nâng cấp",
        "Khó chịu nếu quota chatbot hết nhanh"
      ]
    }
  ],
  "user_journey_map": [
    {
      "stage": "Trigger",
      "goal": "Tìm hiểu bản thân/quan hệ",
      "emotional_state": "Tò mò, kỳ vọng",
      "decision_friction": "Nghi ngờ độ chính xác"
    },
    {
      "stage": "Setup Profile",
      "goal": "Nhận kết quả cá nhân hóa",
      "emotional_state": "Hy vọng",
      "decision_friction": "Lo ngại nhập sai dữ liệu"
    },
    {
      "stage": "First Value",
      "goal": "Xác thực độ đúng",
      "emotional_state": "Hào hứng hoặc thất vọng",
      "decision_friction": "Thông tin nhiều, khó hiểu nhanh"
    },
    {
      "stage": "Exploration",
      "goal": "Đào sâu insight",
      "emotional_state": "Quan tâm",
      "decision_friction": "Không rõ ưu tiên hành động"
    },
    {
      "stage": "Habit Loop",
      "goal": "Duy trì quay lại mỗi ngày",
      "emotional_state": "Ổn định",
      "decision_friction": "Ma sát từ rewarded ad"
    },
    {
      "stage": "Social/Family Usage",
      "goal": "Xem cho người thân",
      "emotional_state": "Tò mò, gắn kết",
      "decision_friction": "Giới hạn 2 hồ sơ free"
    },
    {
      "stage": "Monetization Decision",
      "goal": "Quyết định nâng cấp VIP",
      "emotional_state": "Cân nhắc, do dự",
      "decision_friction": "Chưa chắc chatbot/hồ sơ unlimited đáng giá"
    },
    {
      "stage": "VIP Usage",
      "goal": "Hiểu sâu qua AI",
      "emotional_state": "Được hỗ trợ",
      "decision_friction": "Hard limit tạo hụt cảm xúc khi hết quota"
    },
    {
      "stage": "Retention",
      "goal": "Duy trì giá trị lâu dài",
      "emotional_state": "Tin tưởng dần hoặc chán dần",
      "decision_friction": "Insight lặp lại làm giảm perceived value"
    }
  ],
  "pain_points": [
    "Niềm tin thấp do nội dung thị trường thường chung chung",
    "Quá tải thông tin với người mới",
    "Thiếu định hướng hành động sau khi đọc phân tích",
    "Ma sát khi mở nội dung daily bằng rewarded ad",
    "Ma sát chuyển đổi khi chạm giới hạn 2 hồ sơ free",
    "Cảm giác bị bó khi chatbot VIP có hard limit",
    "Lo ngại quyền riêng tư với dữ liệu họ tên + ngày sinh",
    "Rủi ro mâu thuẫn nội dung giữa các module"
  ],
  "behavioral_insights": [
    "User Việt có xu hướng proof-before-pay: cần thấy đúng rồi mới trả phí",
    "Daily usage là hành vi nhanh; ma sát nhỏ cũng làm drop phiên",
    "Use case gia đình/bạn bè là động lực tăng hồ sơ và tần suất dùng",
    "Niềm tin được tích lũy qua nhiều phiên, không chỉ phiên đầu",
    "Điểm ra quyết định trả phí tập trung ở moment of need",
    "Hard limit được chấp nhận tốt hơn nếu minh bạch quota từ đầu"
  ]
}
```
