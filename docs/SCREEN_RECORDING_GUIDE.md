# App Store Screen Recording Guide

**Purpose:** Apple Guideline 1.2 requires a screen recording demonstrating UGC moderation features.
**Device:** iPad Air (Apple reviewed on iPad Air 11-inch M3) or any physical iOS device
**Duration:** Keep under 2-3 minutes
**Narration:** None needed — just clear, deliberate taps
**Attach to:** App Review Information > Notes field in App Store Connect

---

## Scene 1: EULA/Terms Acceptance Flow (~45 seconds)

1. Open the app (start logged out)
2. Create a new account OR log in with existing account
3. Complete email verification
4. **The Terms of Service screen appears automatically**
5. Slowly scroll through the terms — show key sections:
   - "Zero Tolerance Policy" (prohibited content list)
   - "Content Moderation" (24-hour review)
   - "Enforcement" (mute, suspend, ban)
6. Notice the button says "Scroll down to review all terms" and is disabled
7. Scroll to the bottom — button changes to **"I Agree to the Terms of Service"** and becomes active
8. Tap "I Agree"
9. Show that the main app loads (World Cup home screen)

---

## Scene 2: Flagging/Reporting Objectionable Content (~45 seconds)

### Option A: Report from Activity Feed
1. Navigate to the **Activity Feed** tab (tab index 1)
2. Find a post from another user
3. Tap the **three-dot menu** (PopupMenuButton) on their post
4. Show that **"Report"** option appears
5. Tap Report
6. Show the **Report Bottom Sheet** with reason categories:
   - Spam, Harassment, Hate Speech, Violence, Sexual Content, Misinformation, Impersonation, Scam, Inappropriate, Other
7. Select a reason (e.g., "Inappropriate Content")
8. Optionally type additional details
9. Tap Submit
10. Show the success confirmation

### Option B: Report from Chat (optional, reinforces coverage)
1. Open a chat conversation (Messages tab)
2. Long-press on a message from another user
3. Show **"Report Message"** option in the bottom sheet
4. Tap it to show the Report Bottom Sheet appears

---

## Scene 3: Blocking Abusive Users (~45 seconds)

### Show the block action:
1. Navigate to another user's **profile** (via Friends tab or Activity Feed)
2. Show the **flag/report icon** in the app bar (top right)
3. OR: Open a chat → long-press a message → tap **"Block User"**
4. Confirm the block action

### Show content removal (this is what Apple specifically checks):
5. **Before blocking:** Show the user's posts visible in your Activity Feed
6. **Block the user**
7. **After blocking:** Navigate back to Activity Feed
8. **Show that the blocked user's posts have disappeared** from your feed
9. This demonstrates "remove it from the user's feed instantly"

---

## Recording Tips

- Use iOS built-in screen recording (Settings > Control Center > Screen Recording)
- Tap deliberately and pause briefly on each important UI element
- If something loads slowly, wait for it — don't rush
- Make sure the device is on Wi-Fi with good connectivity
- Test the full flow once before recording the final version
- No need to show the email verification step if using an existing account that hasn't accepted terms yet (any user without `termsAcceptedAt` in their profile will see the terms screen)

---

## Pre-Recording Checklist

- [ ] Physical iOS device (preferably iPad Air)
- [ ] App installed with latest build (version with all V2 fixes)
- [ ] Test account that has NOT yet accepted terms (or create a new account)
- [ ] At least one other test account with posts in the Activity Feed
- [ ] Screen recording enabled in Control Center
- [ ] Device on Wi-Fi
- [ ] Do Not Disturb enabled (avoid notification interruptions)
- [ ] Run through the flow once as practice before recording
