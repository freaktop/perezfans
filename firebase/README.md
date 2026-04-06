# Firebase setup for PerezFans

## Setup Firebase runtime config

This repository keeps runtime secrets and App Check keys out of source control.
Use `firebase/setup-firebase-config.sh` to configure Firebase Functions and local App Check support.

Example:

```bash
FIREBASE_PROJECT=perezfans \
STRIPE_SECRET=sk_test_... \
STRIPE_WEBHOOK_SECRET=whsec_... \
AGORA_APP_ID=xxxx \
AGORA_APP_CERTIFICATE=yyyy \
AGORA_RECORDING_SECRET=secret \
RECAPTCHA_SITE_KEY=6LeBRqIsAAAAAOWXICKGW5Lt0NTIDMlGHXWN2vS0 \
bash firebase/setup-firebase-config.sh
```

This does the following:

- sets `stripe.secret` and `stripe.webhook_secret`
- sets `agora.app_id`, `agora.app_certificate`, and `agora.recording_secret`
- optionally sets `recaptcha.site_key`
- writes `firebase/.recaptcha.env` for web App Check builds

## Deploy steps

1. Deploy Cloud Functions:

```bash
firebase --project perezfans deploy --only functions
```

2. Build and deploy web + Firestore rules:

```bash
bash firebase/deploy-web.sh
```

3. Verify config values:

```bash
firebase --project perezfans functions:config:get
```

## Notes

- Do not commit `firebase/.recaptcha.env`.
- If you use Stripe Accounts v2, set `STRIPE_ACCOUNTS_V2_API_VERSION`.
- If you want a marketplace platform fee, set `STRIPE_MARKETPLACE_APPLICATION_FEE_BPS`.
