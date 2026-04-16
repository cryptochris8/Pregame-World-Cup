import * as functions from "firebase-functions";
import axios from "axios";

/**
 * Cloud Function that proxies Zapier workflow triggers.
 *
 * The Zapier MCP URL (with embedded credentials) is stored as the
 * ZAPIER_MCP_URL environment variable — never in client code.
 *
 * Only authenticated users may call this function.
 */
export const triggerZapierWorkflow = functions.https.onCall(
  async (data: any, context: any) => {
    // 1. Require authentication
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "Must be logged in to trigger workflows."
      );
    }

    // 2. Validate payload
    const { zapName, payload } = data;

    if (!zapName || typeof zapName !== "string") {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Missing or invalid 'zapName' field."
      );
    }

    if (!payload || typeof payload !== "object") {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Missing or invalid 'payload' field."
      );
    }

    // 3. Read the Zapier URL from environment — NOT hardcoded
    const zapierUrl = process.env.ZAPIER_MCP_URL;
    if (!zapierUrl) {
      functions.logger.error(
        "ZAPIER_MCP_URL environment variable is not configured."
      );
      throw new functions.https.HttpsError(
        "internal",
        "Workflow service is not configured."
      );
    }

    // 4. Forward to Zapier
    try {
      functions.logger.info(`Triggering Zapier workflow: ${zapName}`, {
        uid: context.auth.uid,
      });

      const response = await axios.post(
        zapierUrl,
        {
          zap_name: zapName,
          payload: {
            ...payload,
            triggered_by: context.auth.uid,
          },
        },
        {
          headers: {
            "Content-Type": "application/json",
            "User-Agent": "Pregame-CloudFunction/1.0.0",
          },
          timeout: 15000,
        }
      );

      const success =
        response.status === 200 || response.status === 201;

      if (success) {
        functions.logger.info(
          `Zapier workflow triggered successfully: ${zapName}`
        );
      } else {
        functions.logger.warn(
          `Zapier returned status ${response.status} for ${zapName}`
        );
      }

      return { success, statusCode: response.status };
    } catch (error: any) {
      functions.logger.error(
        `Zapier workflow failed: ${zapName} - ${error.message}`
      );
      // Don't expose internal details to the client
      throw new functions.https.HttpsError(
        "internal",
        "Failed to trigger workflow."
      );
    }
  }
);
