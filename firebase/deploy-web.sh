#!/usr/bin/env bash
# Firebase CLI requires hosting files under this directory (not ../build/web).
# Run from repo root or firebase/: syncs Flutter web build then deploys.
#
# App Check (web, reCAPTCHA v3): create firebase/.recaptcha.env with:
#   RECAPTCHA_SITE_KEY=<key from Firebase Console → Build → App Check → Web app>
# Or export RECAPTCHA_SITE_KEY before running this script.
# The key is injected into hosting/index.html and passed as --dart-define for Flutter.
#
# CanvasKit/Skwasm use WebGL; a white screen + CONTEXT_LOST in the console is usually GPU/browser.
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

BUILD_ARGS=()
if [[ -n "${RECAPTCHA_SITE_KEY:-}" ]]; then
  BUILD_ARGS+=("--dart-define=RECAPTCHA_SITE_KEY=${RECAPTCHA_SITE_KEY}")
  BUILD_ARGS+=("--dart-define=ENABLE_APP_CHECK_WEB=true")
else
  echo "deploy-web.sh: RECAPTCHA_SITE_KEY is not set (optional file: firebase/.recaptcha.env)." >&2
  echo "  Without it, App Check stays inactive unless you use --dart-define at build time." >&2
  echo "  If Firestore/App Check enforcement is ON in Firebase Console, add the key from:" >&2
  echo "  Firebase Console → Build → App Check → your Web app → reCAPTCHA v3 site key" >&2
fi

flutter build web "${BUILD_ARGS[@]}"
rm -rf "$ROOT/firebase/hosting"
mkdir -p "$ROOT/firebase/hosting"
cp -a "$ROOT/build/web/." "$ROOT/firebase/hosting/"

# Static pages (Agora test harness, Stripe / promote return URLs, etc.)
if [[ -d "$ROOT/firebase/public" ]]; then
  cp -a "$ROOT/firebase/public/." "$ROOT/firebase/hosting/"
fi

RECAPTCHA_SITE_KEY="${RECAPTCHA_SITE_KEY:-}" python3 "$SCRIPT_DIR/inject_recaptcha_meta.py" "$ROOT/firebase/hosting/index.html"

cd "$ROOT/firebase"
firebase deploy --only hosting,firestore:rules "$@"
