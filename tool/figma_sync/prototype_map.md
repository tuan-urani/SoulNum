# SoulNum Prototype Map

## Synced frames
- Splash
- Login
- Register
- Home
- Profile Manager
- Profile Form
- Profile Detail
- Profile Delete Confirm
- Core Numbers
- Psych Matrix
- Birth Chart
- Energy Boost
- Four Peaks
- Four Challenges
- Compatibility
- Forecast Day
- Forecast Month
- Forecast Year
- Daily Cycle
- Daily Cycle Locked
- Subscription VIP
- AI Chat
- AI Chat Limit
- History

## Canonical Page 2 Order
1. Splash
2. Login
3. Register
4. Home
5. Profile Manager
6. Profile Form
7. Profile Detail
8. Profile Delete Confirm
9. Core Numbers
10. Psych Matrix
11. Birth Chart
12. Energy Boost
13. Four Peaks
14. Four Challenges
15. Compatibility
16. Forecast Day
17. Forecast Month
18. Forecast Year
19. Daily Cycle Locked
20. Daily Cycle
21. Subscription VIP
22. AI Chat Limit
23. AI Chat
24. History

## Prototype mapping
| Source Frame | Trigger | Interaction | Destination Frame | Transition | Notes |
|---|---|---|---|---|---|
| Splash | After delay 3s + has session | Navigate to | Home | Dissolve | Success path |
| Splash | After delay 3s + no valid session | Navigate to | Login | Dissolve | Auth fallback |
| Login | Tạo tài khoản mới | Navigate to | Register | Smart Animate / Instant | Auth forward |
| Login | Đăng nhập | Navigate to | Home | Smart Animate / Instant | Success path |
| Register | Đăng nhập ngay | Navigate to | Login | Smart Animate / Instant | Auth back |
| Register | Tạo tài khoản | Navigate to | Home | Smart Animate / Instant | Registration success |
| Home | Tóm tắt hồ sơ đang dùng | Navigate to | Profile Manager | Smart Animate / Instant | Current profile management entry |
| Home | Con số cốt lõi | Navigate to | Core Numbers | Smart Animate / Instant | Reading detail path |
| Home | Ma trận tâm lý | Navigate to | Psych Matrix | Smart Animate / Instant | Reading detail path |
| Home | Biểu đồ ngày sinh | Navigate to | Birth Chart | Smart Animate / Instant | Reading detail path |
| Home | Năng lượng gia tăng | Navigate to | Energy Boost | Smart Animate / Instant | Reading detail path |
| Home | 4 đỉnh cao | Navigate to | Four Peaks | Smart Animate / Instant | Reading detail path |
| Home | 4 thử thách | Navigate to | Four Challenges | Smart Animate / Instant | Reading detail path |
| Home | Chỉ số tương hợp | Navigate to | Compatibility | Smart Animate / Instant | Separate page flow |
| Home | Dự đoán ngày | Navigate to | Forecast Day | Smart Animate / Instant | Reading detail path |
| Home | Dự đoán tháng | Navigate to | Forecast Month | Smart Animate / Instant | Reading detail path |
| Home | Dự đoán năm | Navigate to | Forecast Year | Smart Animate / Instant | Reading detail path |
| Home | Chu kỳ sinh học | Navigate to | Daily Cycle | Smart Animate / Instant | Daily biorhythm route |
| Home | Chu kỳ sinh học | Navigate to | Daily Cycle Locked | Smart Animate / Instant | Alternate locked/ad-gate state for free user demo |
| Home | AI Chatbot VIP | Navigate to | AI Chat | Smart Animate / Instant | Chat assistant route |
| Profile Manager | Hồ sơ item | Navigate to | Profile Detail | Smart Animate / Instant | Open selected profile |
| Profile Manager | Tạo hồ sơ mới | Navigate to | Profile Form | Smart Animate / Instant | Create profile path |
| Profile Manager | Đăng xuất | Navigate to | Login | Dissolve | Sign-out path |
| Profile Form | Back | Navigate to | Profile Manager | Instant | Cancel create |
| Profile Form | Lưu | Navigate to | Profile Manager | Smart Animate / Instant | Standard save path |
| Profile Form | Lưu (force select active flow) | Navigate to | Home | Smart Animate / Instant | Alternate onboarding path |
| Profile Detail | Back | Navigate to | Profile Manager | Instant | Return to list |
| Profile Detail | Chọn làm hồ sơ đang dùng | Navigate to | Profile Manager | Smart Animate / Instant | Actual code pops previous screen |
| Profile Detail | Xóa vĩnh viễn hồ sơ | Navigate to | Profile Delete Confirm | Smart Animate / Instant | Destructive confirmation step |
| Profile Delete Confirm | Back | Navigate to | Profile Detail | Instant | Return without deleting |
| Profile Delete Confirm | Hủy | Navigate to | Profile Detail | Instant | Cancel delete |
| Profile Delete Confirm | Xác nhận xóa vĩnh viễn | Navigate to | Home | Dissolve | Runtime goes to root route after delete |
| Core Numbers | Back | Navigate to | Home | Instant | Return to entry screen |
| Psych Matrix | Back | Navigate to | Home | Instant | Return to entry screen |
| Birth Chart | Back | Navigate to | Home | Instant | Return to entry screen |
| Energy Boost | Back | Navigate to | Home | Instant | Return to entry screen |
| Four Peaks | Back | Navigate to | Home | Instant | Return to entry screen |
| Four Challenges | Back | Navigate to | Home | Instant | Return to entry screen |
| Compatibility | Back | Navigate to | Home | Instant | Return to entry screen |
| Compatibility | Chạy phân tích tương hợp | Stay on current frame | Compatibility | Instant | Same-screen state update; no navigation |
| Forecast Day | Back | Navigate to | Home | Instant | Return to entry screen |
| Forecast Month | Back | Navigate to | Home | Instant | Return to entry screen |
| Forecast Year | Back | Navigate to | Home | Instant | Return to entry screen |
| Daily Cycle | Back | Navigate to | Home | Instant | Return to entry screen |
| Daily Cycle Locked | Back | Navigate to | Home | Instant | Return to entry screen |
| Daily Cycle Locked | Xem quảng cáo để mở nội dung hôm nay | Navigate to | Daily Cycle | Smart Animate / Instant | Demo unlock path from locked state to unlocked state |
| Subscription VIP | Gói tháng | Stay on current frame | Subscription VIP | Instant | Same-screen status update |
| Subscription VIP | Gói năm | Stay on current frame | Subscription VIP | Instant | Same-screen status update |
| AI Chat | Back | Navigate to | Home | Instant | Return to entry screen |
| AI Chat Limit | Back | Navigate to | Home | Instant | Return to entry screen |
| AI Chat Limit | Kích hoạt VIP Pro | Navigate to | Subscription VIP | Smart Animate / Instant | Dedicated quota/paywall route |
| History | Back | Navigate to | Home | Instant | Return to entry screen |
| History | Xem thêm | Stay on current frame | History | Instant | Same-screen pagination state update |

## Manual notes
- Figma MCP currently synced frames only; prototype links must be wired manually in Figma.
- If you want a simpler public demo flow, you can wire `Profile Detail -> Chọn làm hồ sơ đang dùng` directly to `Home` instead of `Profile Manager`.
- Reading-to-reading next-step CTAs are not mapped because current Flutter UI has those buttons commented out.
- `Compatibility` currently uses a same-frame interaction for the main CTA because the result is rendered on the same page after selecting two profiles.
- `Subscription VIP` currently has no direct entry from the synced frames. In runtime, it is typically opened from unsynced paywall states like `AI Chat Limit` or in-chat upsell actions.
- `Daily Cycle` and `Daily Cycle Locked` are both synced. Use one or the other as the Home destination depending on whether you want the prototype to show the unlocked VIP state or the free-user ad-gate state.
- `AI Chat` is synced in the active conversation state. The current source also contains unauthorized/upsell handling inside the same page, but that state is not split into a separate synced frame.
- `AI Chat Limit` exists as a standalone paywall route in source, but it is not currently referenced by another synced screen. Keep it as an optional demo branch or manual prototype entry point.
- `History` is synced as a standalone screen. Current synced frames do not include its runtime entry trigger, so wire it manually only if you want a public-demo history branch.
