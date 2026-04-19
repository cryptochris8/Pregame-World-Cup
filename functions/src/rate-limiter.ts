import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions';
import express from 'express';

/**
 * Lightweight Firestore-based rate limiter for HTTP Cloud Functions.
 *
 * Uses a rate_limits collection where each document represents a
 * request from a specific IP to a specific endpoint within a given
 * time window. Documents have a TTL field so Firestore TTL policy
 * can automatically clean them up (configure TTL on the expiresAt
 * field in the Firebase console).
 *
 * Design goals:
 *   - Single Firestore read (count query) per check -- minimal latency
 *   - Single Firestore write to record the request (fire-and-forget)
 *   - No in-memory state, works across multiple function instances
 */

interface RateLimitConfig {
  /** Maximum number of requests allowed within the window. */
  maxRequests: number;
  /** Time window in seconds. */
  windowSeconds: number;
}

/** Preset limits for different endpoint categories. */
export const RATE_LIMITS = {
  /** Venue discovery and photo proxy -- higher traffic expected. */
  VENUE: { maxRequests: 60, windowSeconds: 60 } as RateLimitConfig,
  /** Schedule update and test endpoints -- lower traffic, heavier operations. */
  SCHEDULE: { maxRequests: 10, windowSeconds: 60 } as RateLimitConfig,
  /** Payment checkout sessions -- prevent abuse (5 per 15 minutes per user). */
  PAYMENT_CHECKOUT: { maxRequests: 5, windowSeconds: 900 } as RateLimitConfig,
};

/**
 * Extract the client IP from the Cloud Functions request.
 * Prefers the X-Forwarded-For header (set by Google load balancer),
 * then falls back to the socket remote address.
 */
function getClientIp(request: express.Request): string {
  const forwarded = request.headers['x-forwarded-for'];
  if (forwarded) {
    const first = (Array.isArray(forwarded) ? forwarded[0] : forwarded).split(',')[0].trim();
    if (first) return first;
  }
  return request.ip || request.socket?.remoteAddress || 'unknown';
}

/**
 * Check whether the request should be rate-limited.
 *
 * Returns true if the request is ALLOWED, false if it should be rejected.
 * When rejected, the function also writes a 429 response on the provided
 * response object so the caller can simply return.
 */
export async function checkRateLimit(
  request: express.Request,
  response: express.Response,
  endpointName: string,
  config: RateLimitConfig
): Promise<boolean> {
  const db = admin.firestore();
  const ip = getClientIp(request);
  const now = Date.now();
  const windowStart = new Date(now - config.windowSeconds * 1000);
  const expiresAt = new Date(now + config.windowSeconds * 1000);

  try {
    // Count recent requests from this IP to this endpoint.
    const recentRequests = await db
      .collection('rate_limits')
      .where('ip', '==', ip)
      .where('endpoint', '==', endpointName)
      .where('timestamp', '>=', admin.firestore.Timestamp.fromDate(windowStart))
      .count()
      .get();

    const count = recentRequests.data().count;
    if (count >= config.maxRequests) {
      functions.logger.warn(
        `Rate limit exceeded for ${endpointName} from IP ${ip}: ${count}/${config.maxRequests} in ${config.windowSeconds}s`
      );
      response.status(429).json({
        error: 'Too Many Requests',
        message: `Rate limit exceeded. Maximum ${config.maxRequests} requests per ${config.windowSeconds} seconds.`,
        retryAfter: config.windowSeconds,
      });
      return false;
    }

    // Record this request (fire-and-forget -- do not await to avoid latency).
    db.collection('rate_limits')
      .add({
        ip,
        endpoint: endpointName,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        expiresAt: admin.firestore.Timestamp.fromDate(expiresAt),
      })
      .catch((err: any) => {
        functions.logger.error('Failed to record rate limit entry:', err.message);
      });

    return true;
  } catch (error: any) {
    // If the rate limiter itself fails, allow the request through so we
    // do not break functionality. Log the error for investigation.
    functions.logger.error('Rate limiter error (allowing request):', error.message);
    return true;
  }
}

/**
 * Options for the callable rate limiter.
 */
export interface CallableRateLimitOptions {
  /**
   * When true, a Firestore failure inside the limiter causes the request
   * to be rejected with HttpsError('resource-exhausted') rather than
   * letting it pass through. Use for revenue- or cost-sensitive endpoints
   * (payments, SMS) where a burst during a Firestore hiccup is worse than
   * a transient 429.
   *
   * Defaults to false (fail-open) to preserve backward compatibility for
   * low-risk endpoints.
   */
  failClosed?: boolean;
}

/**
 * Rate limit check for onCall Cloud Functions (authenticated users).
 *
 * Uses the authenticated user's UID as the key instead of IP address.
 * Throws an HttpsError with 'resource-exhausted' if the limit is exceeded
 * (or, when `options.failClosed` is true, if the limiter itself errors).
 */
export async function checkCallableRateLimit(
  userId: string,
  endpointName: string,
  config: RateLimitConfig,
  options: CallableRateLimitOptions = {}
): Promise<void> {
  const db = admin.firestore();
  const now = Date.now();
  const windowStart = new Date(now - config.windowSeconds * 1000);
  const expiresAt = new Date(now + config.windowSeconds * 1000);

  try {
    const recentRequests = await db
      .collection('rate_limits')
      .where('userId', '==', userId)
      .where('endpoint', '==', endpointName)
      .where('timestamp', '>=', admin.firestore.Timestamp.fromDate(windowStart))
      .count()
      .get();

    const count = recentRequests.data().count;
    if (count >= config.maxRequests) {
      functions.logger.warn(
        `Rate limit exceeded for ${endpointName} by user ${userId}: ${count}/${config.maxRequests} in ${config.windowSeconds}s`
      );
      throw new functions.https.HttpsError(
        'resource-exhausted',
        `Too many requests. Please try again later.`
      );
    }

    // Record this request (fire-and-forget).
    db.collection('rate_limits')
      .add({
        userId,
        endpoint: endpointName,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        expiresAt: admin.firestore.Timestamp.fromDate(expiresAt),
      })
      .catch((err: any) => {
        functions.logger.error('Failed to record rate limit entry:', err.message);
      });
  } catch (error: any) {
    // Re-throw HttpsError (rate limit exceeded)
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }
    // If the rate limiter itself fails, decide based on endpoint sensitivity.
    if (options.failClosed) {
      functions.logger.error(
        `Rate limiter error on fail-closed endpoint ${endpointName} (rejecting request):`,
        error.message
      );
      throw new functions.https.HttpsError(
        'resource-exhausted',
        'Service temporarily unavailable. Please try again later.'
      );
    }
    functions.logger.error('Rate limiter error (allowing request):', error.message);
  }
}

/**
 * Scheduled cleanup for expired rate limit documents.
 * Safety net in case Firestore TTL is not configured on the
 * expiresAt field. Run daily or as needed.
 */
export async function cleanupExpiredRateLimits(): Promise<number> {
  const db = admin.firestore();
  const now = admin.firestore.Timestamp.now();
  let totalDeleted = 0;

  let hasMore = true;
  while (hasMore) {
    const expired = await db
      .collection('rate_limits')
      .where('expiresAt', '<=', now)
      .limit(400)
      .get();

    if (expired.empty) {
      hasMore = false;
      break;
    }

    const batch = db.batch();
    expired.docs.forEach((doc) => batch.delete(doc.ref));
    await batch.commit();
    totalDeleted += expired.size;

    if (expired.size < 400) {
      hasMore = false;
    }
  }

  if (totalDeleted > 0) {
    functions.logger.info(`Cleaned up ${totalDeleted} expired rate limit documents`);
  }

  return totalDeleted;
}
