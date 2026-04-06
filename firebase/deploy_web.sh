#!/usr/bin/env bash
# Build Flutter web and deploy to Firebase Hosting (copies build/web → firebase/hosting).
# Prefer firebase/deploy-web.sh for hosting + Firestore rules + App Check inject.
# Optional: firebase/.recaptcha.env with RECAPTCHA_SITE_KEY (see .recaptcha.env.example).
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT"

if [[ -f "$SCRIPT_DIR/.recaptcha.env" ]]; then
  set -a
  # shellcheck disable=SC1091
  source "$SCRIPT_DIR/.recaptcha.env"
  set +a
fi

BUILD_ARGS=(--release)
if [[ -n "${DISABLE_APP_CHECK:-}" && "${DISABLE_APP_CHECK}" == "true" ]]; then
  BUILD_ARGS+=(--dart-define=DISABLE_APP_CHECK=true)
elif [[ -n "${RECAPTCHA_SITE_KEY:-}" ]]; then
  BUILD_ARGS+=(--dart-define="RECAPTCHA_SITE_KEY=${RECAPTCHA_SITE_KEY}")
  BUILD_ARGS+=(--dart-define=ENABLE_APP_CHECK_WEB=true)
else
  echo "Note: RECAPTCHA_SITE_KEY not set — add firebase/.recaptcha.env or export RECAPTCHA_SITE_KEY for App Check."
fi

flutter build web "${BUILD_ARGS[@]}"

rm -rf "${ROOT}/firebase/hosting"
mkdir -p "${ROOT}/firebase/hosting"
cp -a "${ROOT}/build/web/." "${ROOT}/firebase/hosting/"

if [[ -d "${ROOT}/firebase/public" ]]; then
  cp -a "${ROOT}/firebase/public/." "${ROOT}/firebase/hosting/"
fi

RECAPTCHA_SITE_KEY="${RECAPTCHA_SITE_KEY:-}" python3 "$SCRIPT_DIR/inject_recaptcha_meta.py" "$ROOT/firebase/hosting/index.html"

cd "${ROOT}/firebase"
if command -v firebase >/dev/null 2>&1; then
  firebase deploy --only hosting "$@"
else
  npx --yes firebase-tools deploy --only hosting "$@"
fi
