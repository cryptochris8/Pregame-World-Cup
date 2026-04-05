Thank you for your detailed feedback. We have thoroughly addressed both issues identified in our review:

**Guideline 5.2.1 — Intellectual Property (FIFA)**

We conducted a comprehensive audit and removed all user-visible FIFA trademark references across 200+ files, including:
- All Dart source code and localization strings (4 languages)
- All JSON data files (194 files, 250+ edits) covering match summaries, player profiles, head-to-head records, and historical data
- App Store metadata, marketing materials, and website content

The only remaining "FIFA" reference is our legal disclaimer: "Pregame is an independent fan app and is not affiliated with, endorsed by, or sponsored by FIFA or any official tournament organization." This is intentionally retained to disclaim affiliation.

Verification: grep audits confirm zero unauthorized FIFA trademark usage in any user-facing content.

**Guideline 4 — Design: Minimum Legibility**

We audited all font sizes across the application and increased every instance below 11pt to meet a minimum of 11pt, ensuring comfortable readability on all device sizes including iPad. A total of 53 font size instances were updated across 27 files. Dynamic font calculations now enforce minimum sizes, and text contrast was improved on disclaimer screens.

**Guideline 1.2 — User-Generated Content**

We have implemented all five Apple-required UGC moderation precautions:

1. EULA/Terms of Service: A mandatory Terms Acceptance Screen is shown to every user after email verification and before app access. Users must scroll through the full terms (including zero-tolerance policy, community guidelines, and enforcement actions) before the "I Agree" button activates. Acceptance is stored with a server timestamp. Declining signs the user out.

2. Content Filtering: Automated ProfanityFilterService screens all user content — posts, comments, messages, and chat — with severity scoring, scam detection, and auto-rejection of objectionable content.

3. Reporting: ReportButton and ReportBottomSheet widgets are available on every UGC surface (activity feed posts, comments, watch party chat, match chat, direct messages, and user profiles) with 10 reason categories and optional details.

4. Blocking: Users can block others from profile screens. Blocking instantly removes the blocked user's content from the feed, removes any existing friendship, and notifies admin via Cloud Function.

5. Developer Response: The onReportCreated Cloud Function sends immediate push notifications to all admin users. Auto-moderation thresholds trigger automatically (5 reports = 24-hour mute, 10 reports = 7-day suspension). A scheduled function clears expired sanctions hourly.

A screen recording demonstrating the EULA acceptance, content reporting, and user blocking flows on a physical device is attached.

Demo account credentials are provided in App Store Connect review information.
