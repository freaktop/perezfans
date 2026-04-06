# PerezFans — web launch and store submission

Use this as a practical checklist. Keep secrets and store/console settings production-ready; have counsel review legal pages if your model or regions change.

## 1. Web app (Firebase Hosting)

1. **Authorized domains** (Firebase Console → Authentication → Settings): add your Hosting domain (e.g. `perezfans.web.app`, custom domain).
2. **App Check (web)**: Create reCAPTCHA v3 site key, register in Firebase App Check, then build with  
   `RECAPTCHA_SITE_KEY=...` (see `firebase/deploy_web.sh` and `lib/backend/firebase/app_check.dart`).
3. **Build and deploy** from repo root:
   ```bash
   bash firebase/deploy_web.sh
   ```
   This runs `flutter build web` and `firebase deploy --only hosting`. Hosting serves `build/web` (see `firebase/firebase.json`).
4. **SPA routing**: Deep links use client-side routes; Hosting rewrites fall through to `index.html` when no static file matches.
5. **Legal URLs**: Counsel should review `web/terms.html` and `web/privacy.html` (served at **/terms** and **/privacy** on Hosting; old `.html` URLs redirect). Settings → Terms / Privacy opens these (same origin on web).
6. **SEO**: When you want indexing, remove or adjust `<meta name="robots" content="noindex" />` in `web/index.html`.

## 2. Stripe (web and mobile)

1. Webhooks point to your **`stripeWebhook`** HTTPS function URL.
2. Set `stripe.accounts_v2_api_version` if using Accounts v2 Connect flows.
3. Return URLs for Checkout use `https://perezfans.web.app/...` (or your custom domain) — ensure those paths exist under `web/` and are deployed.

## 3. Android (Google Play)

1. **Play Console**: Create app, content questionnaire (UGC, adult if applicable), Data safety form (match `privacy.html` / actual behavior).
2. **Signing**: Upload key / app signing by Google Play.
3. **Release**: `flutter build appbundle --release` (fix any Proguard/R8 if enabled later).
4. **Deep links**: `android/app/src/main/AndroidManifest.xml` intent-filters; add **App Links** host verification if using HTTPS links.
5. **App Check**: Release uses Play Integrity (see `app_check.dart`).

## 4. iOS (App Store)

1. **Apple Developer**: App ID, provisioning, App Store Connect listing.
2. **Privacy nutrition labels** and **age rating** aligned with adult/UGC features.
3. **Release**: `flutter build ipa` / Xcode archive.
4. **Associated domains** if using universal links.
5. **App Check**: App Attest in release.

## 5. Operational

1. **Support email** and **account deletion** path (Firebase Auth delete + Firestore user doc — verify `onUserDeleted` behavior).
2. **Moderation**: Reporting, blocking, escalation — required for many UGC policies.
3. **Monitoring**: Firebase Crashlytics (optional), Functions logs, Stripe dashboard.

## 6. After launch

1. Rotate any test keys; use **live** Stripe keys only in production config.
2. Monitor webhook failures and App Check enforcement errors.
