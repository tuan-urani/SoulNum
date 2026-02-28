# PHASE 5 – USER FLOW DEFINITION

## Context
- Source PRD: `PRD - SoulNum (Vietnam, Numerology-first).md` (v1.2)
- Source UX research: `PHASE_4_UX_RESEARCH.md`
- Scope: Interaction logic and navigation flow only (no visual UI design)

## Entry Points Into Product
1. First app open after install.
2. Re-open app from home screen.
3. Push notification for daily biological cycle.
4. Internal CTA from any numerology analysis module.
5. Internal CTA when reaching profile limit (free tier).
6. Internal CTA when trying to access AI chatbot (VIP-only).

## User Goals Covered
1. Nhận insight cá nhân đầu tiên thật nhanh và tin cậy.
2. Quay lại mỗi ngày để xem chu kỳ sinh học với ma sát thấp.
3. Thêm hồ sơ người thân và xem chỉ số tương hợp.
4. Nâng cấp VIP Pro đúng thời điểm cần thiết.
5. Dùng AI chatbot để đào sâu bản thân trong quota tháng.
6. Kiểm soát dữ liệu cá nhân và xóa vĩnh viễn khi cần.

## Structured Output (JSON)

```json
{
  "user_flows": [
    {
      "flow_name": "F1_First_Time_Activation_To_First_Insight",
      "persona": "Lan - Self-discovery Seeker",
      "entry_point": "First app open after install",
      "goal": "Create first profile and view first personalized numerology result",
      "steps": [
        {
          "step": "Step 1",
          "user_action": "Open app for the first time",
          "system_response": "Load Vietnamese locale, initialize session, check if profile exists",
          "next_step": "If no profile -> Step 2; if profile exists -> Step 5"
        },
        {
          "step": "Step 2",
          "user_action": "Start profile creation and input full name + date of birth",
          "system_response": "Validate required fields and date format in real time",
          "next_step": "If valid -> Step 3; if invalid -> stay Step 2 with inline error"
        },
        {
          "step": "Step 3",
          "user_action": "Confirm profile creation",
          "system_response": "Persist profile and compute free core analyses",
          "next_step": "Step 4"
        },
        {
          "step": "Step 4",
          "user_action": "Open first analysis module (core number)",
          "system_response": "Display personalized result and expose next relevant modules",
          "next_step": "Step 5"
        },
        {
          "step": "Step 5",
          "user_action": "Navigate across other free analysis modules",
          "system_response": "Reuse active profile context without re-entry; keep navigation state",
          "next_step": "Flow ends"
        }
      ],
      "decision_points": [
        "Profile exists at app start?",
        "Name and date of birth valid?",
        "Computation successful or temporary failure?"
      ],
      "success_state": "User has at least one saved profile and has viewed at least one personalized numerology result",
      "failure_states": [
        "Invalid or missing profile fields block progress",
        "Calculation request fails and user cannot see first result",
        "User exits before completing first profile"
      ]
    },
    {
      "flow_name": "F2_Daily_Biological_Cycle_Access",
      "persona": "Tuan - Pragmatic Explorer",
      "entry_point": "Push notification or daily card tap from home",
      "goal": "View daily biological cycle with minimal friction",
      "steps": [
        {
          "step": "Step 1",
          "user_action": "Tap daily biological cycle entry",
          "system_response": "Load daily data context for active profile and current date",
          "next_step": "Step 2"
        },
        {
          "step": "Step 2",
          "user_action": "Proceed to view content",
          "system_response": "Check VIP entitlement and daily unlock status",
          "next_step": "If VIP or already unlocked today -> Step 5; else -> Step 3"
        },
        {
          "step": "Step 3",
          "user_action": "Free user chooses to watch rewarded ad",
          "system_response": "Load rewarded ad and prepare one-time daily unlock token",
          "next_step": "If ad loaded -> Step 4; if ad load fail -> Failure path"
        },
        {
          "step": "Step 4",
          "user_action": "Watch ad to completion",
          "system_response": "Grant daily access for that profile/date and record unlock",
          "next_step": "Step 5"
        },
        {
          "step": "Step 5",
          "user_action": "Read daily biological cycle",
          "system_response": "Display today prediction details and keep access active for the day",
          "next_step": "Flow ends"
        }
      ],
      "decision_points": [
        "Is user VIP Pro?",
        "Is daily content already unlocked today?",
        "Did ad load successfully?",
        "Did user complete ad or cancel?"
      ],
      "success_state": "User views daily biological cycle content successfully",
      "failure_states": [
        "Rewarded ad unavailable or failed to load",
        "User cancels ad before completion so content remains locked",
        "Daily data fetch fails due to connectivity/service issue"
      ]
    },
    {
      "flow_name": "F3_Multi_Profile_And_Compatibility_Check",
      "persona": "Minh - Family Interpreter",
      "entry_point": "Profile manager or compatibility CTA",
      "goal": "Add another profile and run compatibility between two valid profiles",
      "steps": [
        {
          "step": "Step 1",
          "user_action": "Open profile manager and tap add profile",
          "system_response": "Check profile count against entitlement (free: 2, VIP: unlimited)",
          "next_step": "If within limit -> Step 2; if limit reached -> Step 5"
        },
        {
          "step": "Step 2",
          "user_action": "Input second profile full name + date of birth",
          "system_response": "Validate required fields and save profile",
          "next_step": "Step 3"
        },
        {
          "step": "Step 3",
          "user_action": "Open compatibility feature and choose 2 profiles",
          "system_response": "Verify both selected profiles contain full name + date of birth",
          "next_step": "If valid -> Step 4; if invalid -> prompt completion and stay Step 3"
        },
        {
          "step": "Step 4",
          "user_action": "Run compatibility analysis",
          "system_response": "Compute and return compatibility score + interpretation",
          "next_step": "Flow ends"
        },
        {
          "step": "Step 5",
          "user_action": "When free limit reached, choose upgrade or manage existing profiles",
          "system_response": "Show VIP upgrade path and alternative manage/delete path",
          "next_step": "If upgrade -> F4; if manage/delete -> return Step 1"
        }
      ],
      "decision_points": [
        "Profile limit reached?",
        "Both profiles have complete required data?",
        "User upgrades now or keeps free tier?"
      ],
      "success_state": "User gets compatibility result for two complete profiles",
      "failure_states": [
        "Cannot add new profile because free limit reached and user does not upgrade",
        "Compatibility blocked due to incomplete profile data",
        "Calculation failure prevents result display"
      ]
    },
    {
      "flow_name": "F4_VIP_Pro_Subscription_Conversion",
      "persona": "Lan - Self-discovery Seeker",
      "entry_point": "VIP trigger from chatbot lock, profile limit lock, or VIP CTA",
      "goal": "Activate VIP Pro subscription and return user to interrupted task",
      "steps": [
        {
          "step": "Step 1",
          "user_action": "Tap upgrade when encountering VIP-required action",
          "system_response": "Open subscription options (monthly/yearly) with current user context",
          "next_step": "Step 2"
        },
        {
          "step": "Step 2",
          "user_action": "Select plan and confirm purchase",
          "system_response": "Launch store purchase flow and await transaction state",
          "next_step": "If success -> Step 3; if cancel/fail -> Failure path"
        },
        {
          "step": "Step 3",
          "user_action": "Complete transaction",
          "system_response": "Validate receipt, update VIP entitlement, and sync account status",
          "next_step": "Step 4"
        },
        {
          "step": "Step 4",
          "user_action": "Continue previous task",
          "system_response": "Auto-redirect user back to the interrupted feature (chatbot/add profile/daily)",
          "next_step": "Flow ends"
        }
      ],
      "decision_points": [
        "Monthly or yearly plan?",
        "Purchase success, pending, canceled, or failed?",
        "Receipt validation success or failure?"
      ],
      "success_state": "VIP Pro entitlement becomes active and user resumes original task without re-navigation",
      "failure_states": [
        "User cancels purchase",
        "Store transaction fails",
        "Receipt validation fails so entitlement is not granted",
        "Subscription remains pending and access is deferred"
      ]
    },
    {
      "flow_name": "F5_VIP_AI_Chatbot_With_Monthly_Hard_Limit",
      "persona": "Lan - Self-discovery Seeker",
      "entry_point": "Chatbot entry from analysis module or main navigation",
      "goal": "Receive deeper personalized guidance via AI chatbot within monthly quota",
      "steps": [
        {
          "step": "Step 1",
          "user_action": "Open AI chatbot",
          "system_response": "Check VIP entitlement and active profile presence",
          "next_step": "If not VIP -> F4; if no profile -> prompt create/select profile; else -> Step 2"
        },
        {
          "step": "Step 2",
          "user_action": "Start a question",
          "system_response": "Check remaining monthly chat quota (hard limit)",
          "next_step": "If quota > 0 -> Step 3; if quota = 0 -> Step 5"
        },
        {
          "step": "Step 3",
          "user_action": "Send message",
          "system_response": "Generate response using active profile context and decrement quota on successful reply",
          "next_step": "Step 4"
        },
        {
          "step": "Step 4",
          "user_action": "Continue conversation",
          "system_response": "Display response and updated remaining quota after each completed turn",
          "next_step": "Back to Step 2 until quota exhausted or user exits"
        },
        {
          "step": "Step 5",
          "user_action": "Reach quota limit",
          "system_response": "Lock new chat input until next monthly reset and show quota exhausted state",
          "next_step": "Flow ends"
        }
      ],
      "decision_points": [
        "Is user VIP Pro?",
        "Is there an active profile with required data?",
        "Is monthly quota remaining?",
        "Did AI response succeed or fail?"
      ],
      "success_state": "User receives one or more personalized chatbot responses while quota remains",
      "failure_states": [
        "Non-VIP user blocked from chat",
        "Quota exhausted (hard limit reached)",
        "AI service timeout/error prevents response",
        "Missing active profile blocks contextual response"
      ]
    },
    {
      "flow_name": "F6_Profile_Deletion_And_Data_Control",
      "persona": "Minh - Family Interpreter",
      "entry_point": "Profile detail/settings",
      "goal": "Permanently delete a profile and related data from app",
      "steps": [
        {
          "step": "Step 1",
          "user_action": "Open profile settings and choose delete profile",
          "system_response": "Show irreversible warning and data impact summary",
          "next_step": "Step 2"
        },
        {
          "step": "Step 2",
          "user_action": "Confirm permanent deletion",
          "system_response": "Execute deletion for profile and associated derived data",
          "next_step": "If deletion success -> Step 3; else -> Failure path"
        },
        {
          "step": "Step 3",
          "user_action": "Return to profile list",
          "system_response": "Refresh profile list and set next valid active profile or prompt create new profile",
          "next_step": "Flow ends"
        }
      ],
      "decision_points": [
        "User confirms or cancels irreversible deletion?",
        "Deletion request success or failure?",
        "Any profile remaining after deletion?"
      ],
      "success_state": "Selected profile and related data are permanently removed and user remains in a valid app state",
      "failure_states": [
        "User cancels deletion",
        "Deletion operation fails and profile remains",
        "State refresh fails and active profile cannot be resolved"
      ]
    }
  ]
}
```
