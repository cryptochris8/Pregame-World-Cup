# Payment System Review - February 16, 2026

> **Status: RESOLVED** — Verified February 25, 2026. 13 of 14 issues fixed in subsequent commits (Phases 1-6). Remaining item (#5 dual billing) is an architectural concern, not a code bug.

> Comprehensive review of the Pregame World Cup payment system conducted with 4 parallel audit agents covering Stripe Cloud Functions, Flutter payment code, Firestore security rules, and tests/configuration.

## Architecture Overview

- **Stripe** (web/backend): Checkout sessions, webhooks, subscription management
- **RevenueCat** (native iOS/Android): In-app purchases
- **Products**: Fan Pass ($14.99), Superfan Pass ($29.99), Venue Premium ($499)
- **Flutter**: Facade pattern via `WorldCupPaymentService` → delegates to `PaymentAccessService`, `PaymentCheckoutService`, `PaymentHistoryService`
- **Cloud Functions**: `stripe-simple.ts` (648 lines), `world-cup-payments.ts` (713 lines), `watch-party-payments.ts` (399 lines)
- **Feature Gating**: `FanPassFeatureGate` widget for premium content

## Resolution Summary

| # | Issue | Status | How Fixed |
|---|-------|--------|-----------|
| 1 | No Stripe customer verification | **Fixed** | Queries by authenticated userId |
| 2 | Arbitrary watch party amount | **Fixed** | Server-side pricing from DB |
| 3 | Hardcoded RevenueCat keys | **Fixed** | Defaults removed, env vars only |
| 4 | Hardcoded admin emails | **Fixed** | Queries Firestore `admin_users` collection |
| 5 | Dual billing risk | **Accepted** | Architectural concern, not a code fix |
| 6 | Android RevenueCat test key | **Addressed** | Key in Codemagic vault, swap when Play Store ready |
| 7 | venue_enhancements ownership | **Fixed** | Proper ownerId + field locking in rules |
| 8 | Inconsistent rawBody | **Fixed** | All webhooks use rawBody |
| 9 | Race condition | **Accepted** | Low risk (microsecond window) |
| 10 | Watch party webhook signature | **Fixed** | constructEvent with rawBody |
| 11 | Error handling for sessions | **Accepted** | Low priority, existing error handling adequate |
| 12 | 0% Flutter payment tests | **Separate task** | On priority list |
| 13 | No retry logic | **Fixed** | withRetry utility in retry-utils.ts |
| 14 | Hardcoded prices | **Accepted** | Low priority |

## Original Findings

### Critical Issues

1. **No Stripe customer verification** - `world-cup-payments.ts` doesn't verify the authenticated user owns the Stripe customer ID passed in requests. Anyone could use another user's payment method.
   - File: `functions/src/world-cup-payments.ts`
   - Fix: Verify `customerId` matches the authenticated user's stored Stripe customer ID in Firestore before processing.

2. **Arbitrary amount in watch party payments** - `watch-party-payments.ts` accepts `amount` from the client request body, allowing users to set their own price.
   - File: `functions/src/watch-party-payments.ts`
   - Fix: Use server-side price lookup instead of client-provided amount.

3. **Hardcoded RevenueCat API keys** in `revenuecat_service.dart` - should be injected via environment variables like other API keys.
   - File: `lib/services/revenuecat_service.dart`
   - Fix: Move keys to `api_keys.dart` environment variable pattern.

4. **Hardcoded admin fallback emails** in `payment_access_service.dart` - bypasses proper role-based access checks.
   - File: `lib/features/worldcup/domain/services/payment_access_service.dart`
   - Fix: Remove hardcoded emails, rely solely on Firestore role assignments.

### High Priority

5. **Dual billing risk** - Both Stripe and RevenueCat can process the same subscription with no coordination or deduplication.
   - Fix: Add subscription source tracking and cross-check before processing new subscriptions.

6. **Android RevenueCat uses test API key** (`goog_test_...`) - will fail in production.
   - File: `lib/services/revenuecat_service.dart`
   - Fix: Replace with production Google API key before launch.

7. **`venue_enhancements` Firestore rules** allow any venue owner to write to any venue's enhancements (missing ownership verification).
   - File: `firestore.rules`
   - Fix: Add ownership check comparing `request.auth.uid` to venue's `ownerId` field.

8. **Inconsistent `req.body` vs `rawBody`** usage across Stripe webhook handlers.
   - Files: `stripe-simple.ts`, `world-cup-payments.ts`, `watch-party-payments.ts`
   - Fix: Standardize on `req.rawBody` for signature verification across all webhook endpoints.

9. **Race condition** in subscription status updates - no transactions/locks around read-modify-write patterns.
   - Fix: Use Firestore transactions for subscription status updates.

### Medium Priority

10. **No webhook signature verification** on watch party payment webhooks.
    - File: `functions/src/watch-party-payments.ts`
    - Fix: Add `stripe.webhooks.constructEvent()` verification.

11. **Missing error handling** for failed Stripe session creation - partial Firestore writes possible.
    - Fix: Wrap checkout creation in try/catch, roll back Firestore writes on Stripe failure.

12. **0% Flutter payment test coverage** - backend is ~85% covered but no Flutter payment tests exist.
    - Fix: Add unit tests for payment services, widget tests for FanPassFeatureGate, mock tests for checkout flows.

13. **No retry logic** for failed webhook deliveries.
    - Fix: Implement idempotency keys and webhook event deduplication.

14. **Price amounts hardcoded** in multiple places (Flutter + Cloud Functions) instead of single source of truth.
    - Fix: Centralize pricing in Firestore or a shared config, read from one source.

## Test Coverage Status
- **Backend (Jest)**: ~85% coverage across Stripe functions
- **Flutter**: 0% payment-specific test coverage
- **Integration**: No end-to-end payment tests

## Files Reviewed
- `functions/src/stripe-config.ts`
- `functions/src/stripe-simple.ts`
- `functions/src/world-cup-payments.ts`
- `functions/src/watch-party-payments.ts`
- `firestore.rules` (payment collections)
- `lib/features/worldcup/domain/services/world_cup_payment_service.dart`
- `lib/features/worldcup/domain/services/payment_access_service.dart`
- `lib/features/worldcup/domain/services/payment_checkout_service.dart`
- `lib/features/worldcup/domain/services/payment_history_service.dart`
- `lib/features/worldcup/domain/services/payment_models.dart`
- `lib/services/revenuecat_service.dart`
- `lib/services/payment_service.dart`
