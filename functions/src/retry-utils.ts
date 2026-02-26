import * as functions from 'firebase-functions';

/**
 * Configuration for retry behavior.
 */
export interface RetryConfig {
  /** Maximum number of retry attempts (default: 3) */
  maxRetries: number;
  /** Initial delay in ms before first retry (default: 1000) */
  initialDelayMs: number;
  /** Multiplier applied to delay after each retry (default: 2) */
  backoffMultiplier: number;
  /** Maximum delay in ms between retries (default: 10000) */
  maxDelayMs: number;
}

const DEFAULT_CONFIG: RetryConfig = {
  maxRetries: 3,
  initialDelayMs: 1000,
  backoffMultiplier: 2,
  maxDelayMs: 10000,
};

/**
 * Error codes that should NOT be retried because the request is fundamentally invalid.
 */
const NON_RETRYABLE_ERROR_CODES = new Set([
  // FCM: invalid/expired tokens
  'messaging/invalid-registration-token',
  'messaging/registration-token-not-registered',
  'messaging/invalid-argument',
  'messaging/invalid-recipient',
  // Stripe: client errors that won't change on retry
  'card_declined',
  'expired_card',
  'incorrect_cvc',
  'incorrect_number',
  'invalid_expiry_month',
  'invalid_expiry_year',
  'invalid_number',
  'authentication_required',
  // Firebase Auth
  'auth/user-not-found',
  'auth/invalid-argument',
]);

/**
 * Checks whether an error is retryable.
 */
export function isRetryableError(error: any): boolean {
  const code = error?.code || error?.errorInfo?.code || error?.raw?.code;
  if (code && NON_RETRYABLE_ERROR_CODES.has(code)) {
    return false;
  }
  return true;
}

/**
 * Executes an async function with exponential backoff retry.
 *
 * @param fn - The async function to execute
 * @param config - Optional retry configuration (uses defaults if omitted)
 * @returns The result of the function
 * @throws The last error if all retries are exhausted or error is non-retryable
 */
export async function withRetry<T>(
  fn: () => Promise<T>,
  config?: Partial<RetryConfig>,
): Promise<T> {
  const cfg: RetryConfig = { ...DEFAULT_CONFIG, ...config };
  let lastError: any;
  let delay = cfg.initialDelayMs;

  for (let attempt = 0; attempt <= cfg.maxRetries; attempt++) {
    try {
      return await fn();
    } catch (error: any) {
      lastError = error;

      // Don't retry non-retryable errors
      if (!isRetryableError(error)) {
        throw error;
      }

      // Don't retry if we've exhausted attempts
      if (attempt >= cfg.maxRetries) {
        break;
      }

      functions.logger.warn(
        `Retry attempt ${attempt + 1}/${cfg.maxRetries} after ${delay}ms`,
        { error: error.message || error.code },
      );

      // Add jitter (±25%) to prevent thundering herd when multiple
      // instances retry simultaneously after a shared dependency recovers.
      const jitter = delay * (0.75 + Math.random() * 0.5);
      await sleep(jitter);
      delay = Math.min(delay * cfg.backoffMultiplier, cfg.maxDelayMs);
    }
  }

  throw lastError;
}

function sleep(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}
