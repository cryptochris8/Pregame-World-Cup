# Payment System Review - February 16, 2026

> Comprehensive review of the Pregame World Cup payment system conducted with 4 parallel audit agents covering Stripe Cloud Functions, Flutter payment code, Firestore security rules, and tests/configuration.

## Architecture Overview

- **Stripe** (web/backend): Checkout sessions, webhooks, subscription management
- **RevenueCat** (native iOS/Android): In-app purchases
- **Products**: Fan Pass ($14.99), Superfan Pass ($29.99), Venue Premium ($99)
- **Flutter**: Facade pattern via `WorldCupPaymentService` → delegates to `PaymentAccessService`, `PaymentCheckoutService`, `PaymentHistoryService`
- **Cloud Functions**: `stripe-simple.ts` (648 lines), `world-cup-payments.ts` (713 lines), `watch-party-payments.ts` (399 lines)
- **Feature Gating**: `FanPassFeatureGate` widget for premium content

## Findings

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

## Proposed Fix Plan

### Phase 1: Security Blockers (7 items)
| # | Issue | Files |
|---|-------|-------|
| 1 | Add Stripe customer verification | `world-cup-payments.ts` |
| 2 | Server-side amount validation for watch parties | `watch-party-payments.ts` |
| 3 | Move RevenueCat keys to env vars | `revenuecat_service.dart`, `api_keys.dart` |
| 4 | Remove hardcoded admin emails | `payment_access_service.dart` |
| 7 | Fix venue_enhancements ownership rule | `firestore.rules` |
| 8 | Standardize rawBody for webhook verification | All 3 Stripe function files |
| 10 | Add webhook signature verification to watch party | `watch-party-payments.ts` |

### Phase 2: Reliability Improvements (7 items)
| # | Issue | Files |
|---|-------|-------|
| 5 | Dual billing coordination (Stripe + RevenueCat) | Payment services |
| 6 | Fix Android RevenueCat production key | `revenuecat_service.dart` |
| 9 | Add Firestore transactions for status updates | Stripe function files |
| 11 | Error handling for failed session creation | `world-cup-payments.ts` |
| 13 | Webhook retry/idempotency logic | All webhook handlers |
| 14 | Centralize pricing configuration | Multiple files |

### Phase 3: Testing (5 items)
| # | Item | Scope |
|---|------|-------|
| 1 | Flutter payment service unit tests | `payment_*_service.dart` |
| 2 | FanPassFeatureGate widget tests | Feature gate widget |
| 3 | Webhook simulation tests | Cloud Functions |
| 4 | RevenueCat mock tests | `revenuecat_service.dart` |
| 5 | End-to-end payment flow test | Full stack |

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
