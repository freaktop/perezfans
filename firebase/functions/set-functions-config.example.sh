#!/usr/bin/env bash
# Firebase Functions (Gen-1) runtime config — set these keys, not repo files.
# Run from firebase/:  bash functions/set-functions-config.example.sh
# Use your real values once; never commit them. Copy this script if you prefer.
set -euo pipefail
cd "$(dirname "$0")/.."

firebase functions:config:set \
  stripe.secret="YOUR_STRIPE_SECRET_KEY" \
  stripe.webhook_secret="YOUR_STRIPE_WEBHOOK_SIGNING_SECRET"

# Accounts v2 (Connect marketplace) — copy preview version from Stripe docs / API version selector:
#   firebase functions:config:set stripe.accounts_v2_api_version="2025-04-30.preview"
# Optional platform fee on marketplace checkouts (basis points, 1000 = 10%):
#   firebase functions:config:set stripe.marketplace_application_fee_bps="1000"

firebase functions:config:set \
  agora.app_id="YOUR_AGORA_APP_ID" \
  agora.app_certificate="YOUR_AGORA_PRIMARY_CERTIFICATE" \
  agora.recording_secret="YOUR_RANDOM_SECRET_FOR_CALLBACK_HEADER"

# reCAPTCHA Enterprise — must match the site key used in web/index.html / App Check (public key):
#   firebase functions:config:set recaptcha.site_key="6LeBRqIsAAAAAOWXICKGW5Lt0NTIDMlGHXWN2vS0"
# Enable API once: gcloud services enable recaptchaenterprise.googleapis.com --project=perezfans

# Verify (values may be redacted in output):
#   firebase functions:config:get
# Deploy:
#   firebase deploy --only functions
# Stripe return pages (success/cancel) live under firebase/public/promote/ — deploy hosting:
#   firebase deploy --only hosting

# Keys read by functions/index.js:
#   stripe.secret              → Stripe API (checkout + webhook verification input)
#   stripe.webhook_secret      → Stripe webhook signing secret (whsec_...)
#   stripe.accounts_v2_api_version → Required for createSellerConnectedAccount / onboarding (Accounts v2)
#   stripe.marketplace_application_fee_bps → Optional; default 1000 if unset
#   agora.app_id               → Agora RTC app id (also returned to clients)
#   agora.app_certificate      → Agora primary certificate (token generation)
#   agora.recording_secret     → Shared secret; send as header x-recording-secret to agoraRecordingCallback
#
# Optional Agora REST API key (for Cloud Recording REST) is not used by index.js yet;
# if you add that flow later, use e.g. agora.restful_api_key and read functions.config().agora.restful_api_key.
