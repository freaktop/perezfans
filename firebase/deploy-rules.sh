#!/usr/bin/env bash
# From repo root:  bash firebase/deploy-rules.sh
# Requires Firebase CLI: npm i -g firebase-tools && firebase login
set -euo pipefail
cd "$(dirname "$0")"
firebase deploy --only firestore:rules,firestore:indexes,storage
