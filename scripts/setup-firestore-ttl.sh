#!/bin/bash
# Setup Firestore TTL policies for automatic document expiration.
#
# Prerequisites:
#   - gcloud CLI installed and authenticated
#   - Firebase project selected: gcloud config set project <PROJECT_ID>
#
# Collections with TTL:
#   - rate_limits: Temporary rate-limiting records (expiresAt field)
#   - processed_webhook_events: Deduplication records for webhooks (expiresAt field)
#
# The backup Cloud Function (scheduledCleanup) runs daily but TTL is the
# primary expiration mechanism. TTL may take up to 72 hours to delete
# expired documents.
#
# Usage:
#   chmod +x scripts/setup-firestore-ttl.sh
#   ./scripts/setup-firestore-ttl.sh

set -euo pipefail

PROJECT_ID=$(gcloud config get-value project 2>/dev/null)

if [ -z "$PROJECT_ID" ]; then
  echo "Error: No Firebase project set. Run: gcloud config set project <PROJECT_ID>"
  exit 1
fi

echo "Setting up Firestore TTL policies for project: $PROJECT_ID"
echo ""

echo "1/2 Configuring TTL on rate_limits.expiresAt..."
gcloud firestore fields ttls update expiresAt \
  --collection-group=rate_limits \
  --project="$PROJECT_ID"

echo ""
echo "2/2 Configuring TTL on processed_webhook_events.expiresAt..."
gcloud firestore fields ttls update expiresAt \
  --collection-group=processed_webhook_events \
  --project="$PROJECT_ID"

echo ""
echo "TTL policies configured successfully."
echo "Note: It may take up to 72 hours for Firestore to begin deleting expired documents."
