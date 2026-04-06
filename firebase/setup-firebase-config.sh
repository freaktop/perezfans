#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

usage() {
  cat <<EOF
Usage:
  FIREBASE_PROJECT=perezfans \
  STRIPE_SECRET=\
  STRIPE_WEBHOOK_SECRET=whsec_Vmsl4oDkvlyBK5gDFCn8eD1W6AN8xhVl \
  AGORA_APP_ID=810d914de8bd4e8eabbbee0b180b3973\
  AGORA_APP_CERTIFICATE=f77b96147a5a4dbd90b33b819fff3e81\
  AGORA_RECORDING_SECRET=096c16536d214be89e57fd9ae5108bc4\
  [RECAPTCHA_SITE_KEY=6LeBRqIsAAAAAOWXICKGW5Lt0NTIDMlGHXWN2vS0] \
  [STRIPE_ACCOUNTS_V2_API_VERSION=<api_version>] \
  [STRIPE_MARKETPLACE_APPLICATION_FEE_BPS=<bps>] \
  bash "$SCRIPT_DIR/setup-firebase-config.sh"

This script sets the Firebase Functions runtime configuration for the PerezFans backend.
It also writes firebase/.recaptcha.env from RECAPTCHA_SITE_KEY if provided.

Examples:
  FIREBASE_PROJECT=perezfans \
  STRIPE_SECRET=sk_test_... \
  STRIPE_WEBHOOK_SECRET=whsec_... \
  AGORA_APP_ID=xxxx \
  AGORA_APP_CERTIFICATE=yyyy \
  AGORA_RECORDING_SECRET=secret \
  RECAPTCHA_SITE_KEY=6LeB... \
  bash "$SCRIPT_DIR/setup-firebase-config.sh"
EOF
}

required_vars=(FIREBASE_PROJECT STRIPE_SECRET STRIPE_WEBHOOK_SECRET AGORA_APP_ID AGORA_APP_CERTIFICATE AGORA_RECORDING_SECRET)
missing=()
for v in "${required_vars[@]}"; do
  if [[ -z "${!v:-}" ]]; then
    missing+=("$v")
  fi
done

if [[ ${#missing[@]} -gt 0 ]]; then
  echo "Error: missing required env var(s): ${missing[*]}" >&2
  echo
  usage
  exit 1
fi

if ! command -v firebase >/dev/null 2>&1; then
  echo "Error: firebase CLI not found. Install firebase-tools and log in before running this script." >&2
  exit 1
fi

cd "$ROOT"

cmd=(firebase --project "$FIREBASE_PROJECT" functions:config:set
  stripe.secret="$STRIPE_SECRET"
  stripe.webhook_secret="$STRIPE_WEBHOOK_SECRET"
  agora.app_id="$AGORA_APP_ID"
  agora.app_certificate="$AGORA_APP_CERTIFICATE"
  agora.recording_secret="$AGORA_RECORDING_SECRET"
)

if [[ -n "${STRIPE_ACCOUNTS_V2_API_VERSION:-}" ]]; then
  cmd+=(stripe.accounts_v2_api_version="$STRIPE_ACCOUNTS_V2_API_VERSION")
fi
if [[ -n "${STRIPE_MARKETPLACE_APPLICATION_FEE_BPS:-}" ]]; then
  cmd+=(stripe.marketplace_application_fee_bps="$STRIPE_MARKETPLACE_APPLICATION_FEE_BPS")
fi
if [[ -n "${RECAPTCHA_SITE_KEY:-}" ]]; then
  cmd+=(recaptcha.site_key="$RECAPTCHA_SITE_KEY")
fi

echo "Setting Firebase functions config for project '$FIREBASE_PROJECT'..."
"${cmd[@]}"

echo "Firebase functions config set successfully."

if [[ -n "${RECAPTCHA_SITE_KEY:-}" ]]; then
  cat >"$SCRIPT_DIR/.recaptcha.env" <<EOF
RECAPTCHA_SITE_KEY=${RECAPTCHA_SITE_KEY}
EOF
  echo "Saved App Check key to firebase/.recaptcha.env (ignored by git)."
else
  echo "RECAPTCHA_SITE_KEY was not provided. App Check will remain inactive unless set at build time."
fi

echo
cat <<EOF
Next steps:
  1) Deploy functions:
       firebase --project "$FIREBASE_PROJECT" deploy --only functions
  2) Build and deploy web + Firestore rules:
       bash firebase/deploy-web.sh
  3) Verify runtime config:
       firebase --project "$FIREBASE_PROJECT" functions:config:get

If you prefer, use the existing firebase/functions/set-functions-config.example.sh
as a reference for the config values.
EOF
