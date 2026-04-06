// ignore_for_file: deprecated_member_use
import 'dart:html' as html;

/// Only non-empty `<meta name="pf-recaptcha-site-key" content="...">`.
///
/// Keys must match **Firebase Console → App Check → your Web app** (reCAPTCHA v3).
/// Guessing keys from GCP (e.g. `gcloud recaptcha keys list`) causes HTTP 400 on
/// `exchangeRecaptchaV3Token` if that key is not the one registered for App Check.
String resolveWebRecaptchaSiteKey() {
  final el = html.document.querySelector('meta[name="pf-recaptcha-site-key"]');
  return (el?.getAttribute('content') ?? '').trim();
}
