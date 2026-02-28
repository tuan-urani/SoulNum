# PHASE 6 – WIREFRAME CREATION

## Context
- Figma file: https://www.figma.com/design/VIdpz2GpnsB841njLyqMxX/SoulNum
- Inputs used:
  - PRD v1.2
  - Phase 4 UX Research
  - Phase 5 User Flow Definition
- Constraint applied: low-fidelity only (layout + structure, no color system, no icon assets, no images, no visual polish)

## Execution Summary
1. Created a local low-fidelity wireframe page for SoulNum flow coverage at:
   - `wireframes/phase6_soulnum_wireframes.html`
2. Injected Figma MCP capture script into the HTML page.
3. Started a local server and captured the page into the provided Figma file using `outputMode: existingFile`.
4. Polled capture status until completion.
5. Verified imported structure via Figma metadata.
6. Updated all wireframe labels/content to Vietnamese and re-captured into the same Figma file.

## Figma Result
- Imported frame name: `SoulNum Phase 6 Wireframes`
- Metadata node id (top frame): `4:2`
- Direct node link: https://www.figma.com/design/VIdpz2GpnsB841njLyqMxX/SoulNum?node-id=4-2
- Vietnamese updated frame name: `SoulNum - Wireframe Giai đoạn 6`
- Metadata node id (Vietnamese frame): `7:2`
- Direct node link (Vietnamese frame): https://www.figma.com/design/VIdpz2GpnsB841njLyqMxX/SoulNum?node-id=7-2

## Wireframes Created
1. S1 - First Open / Profile Setup (F1)
2. S2 - Home / Free Analysis Hub (F1)
3. S3 - Analysis Detail (F1)
4. S4 - Daily Cycle Locked (Free, F2)
5. S5 - Daily Cycle Unlocked (F2)
6. S6 - Profile Manager (F3)
7. S7 - Add Profile Form (F3)
8. S8 - Compatibility Flow (F3)
9. S9 - VIP Upgrade (F4)
10. S10 - AI Chatbot Active (F5)
11. S11 - AI Chatbot Quota Exhausted (F5)
12. S12 - Delete Profile Confirmation (F6)

## Flow Coverage
- F1 Activation to First Insight: Covered by S1-S3
- F2 Daily Biological Cycle + Ad Gate: Covered by S4-S5
- F3 Multi-profile + Compatibility: Covered by S6-S8
- F4 VIP Pro Conversion: Covered by S9
- F5 VIP Chatbot + Hard Limit: Covered by S10-S11
- F6 Profile Deletion + Data Control: Covered by S12

## Structured Output (JSON)

```json
{
  "figma_page_created": true,
  "wireframes_created": [
    "S1 - First Open / Profile Setup (F1)",
    "S2 - Home / Free Analysis Hub (F1)",
    "S3 - Analysis Detail (F1)",
    "S4 - Daily Cycle Locked (Free, F2)",
    "S5 - Daily Cycle Unlocked (F2)",
    "S6 - Profile Manager (F3)",
    "S7 - Add Profile Form (F3)",
    "S8 - Compatibility Flow (F3)",
    "S9 - VIP Upgrade (F4)",
    "S10 - AI Chatbot Active (F5)",
    "S11 - AI Chatbot Quota Exhausted (F5)",
    "S12 - Delete Profile Confirmation (F6)"
  ],
  "screens_count": "12",
  "flow_coverage": "F1-F6 (100% high-level flow coverage)",
  "notes": "Wireframes were captured into the provided Figma file. A Vietnamese-updated version is available as frame 'SoulNum - Wireframe Giai đoạn 6' (node 7:2). The Figma capture script remains in wireframes/phase6_soulnum_wireframes.html per MCP guidance for optional re-capture."
}
```
