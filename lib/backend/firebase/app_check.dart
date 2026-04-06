import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';

import 'recaptcha_site_key.dart' show resolveWebRecaptchaSiteKey;

/// Call after Firebase.initializeApp().
///
/// **Web**
/// - App Check on web is **off by default** (`ENABLE_APP_CHECK_WEB` defaults to false)
///   so local `flutter run -d chrome` and builds without the flag behave like before
///   reCAPTCHA was wired (avoids `appCheck/recaptcha-error` breaking Auth/Firestore/live).
/// - Enable for production web: `--dart-define=ENABLE_APP_CHECK_WEB=true` plus a valid
///   `RECAPTCHA_SITE_KEY` / `pf-recaptcha-site-key` (see `firebase/deploy-web.sh`).
/// - Emergency skip everywhere: `--dart-define=DISABLE_APP_CHECK=true`
/// - Site key must match **Firebase Console → App Check → Web app** (reCAPTCHA Enterprise).
///
/// Web uses [ReCaptchaEnterpriseProvider] for Enterprise keys; [ReCaptchaV3Provider] with
/// an Enterprise key causes `exchangeRecaptchaV3Token` HTTP 400.
Future<void> initAppCheck() async {
  const disabled = bool.fromEnvironment(
    'DISABLE_APP_CHECK',
    defaultValue: false,
  );
  if (disabled) {
    debugPrint('App Check: disabled via DISABLE_APP_CHECK.');
    return;
  }

  if (kIsWeb) {
    const enableWeb = bool.fromEnvironment(
      'ENABLE_APP_CHECK_WEB',
      defaultValue: false,
    );
    if (!enableWeb) {
      debugPrint(
        'App Check (web): skipped (default). Set ENABLE_APP_CHECK_WEB=true + '
        'RECAPTCHA_SITE_KEY when App Check is configured for this origin.',
      );
      return;
    }

    const siteKeyEnv = String.fromEnvironment(
      'RECAPTCHA_SITE_KEY',
      defaultValue: '',
    );
    var normalized = siteKeyEnv.trim();
    if (normalized.isEmpty || _looksInvalidRecaptchaKey(normalized)) {
      normalized = resolveWebRecaptchaSiteKey().trim();
    }

    if (normalized.isEmpty || _looksInvalidRecaptchaKey(normalized)) {
      debugPrint(
        'App Check (web): ENABLE_APP_CHECK_WEB set but no valid reCAPTCHA site key. '
        'Use --dart-define=RECAPTCHA_SITE_KEY=... or meta pf-recaptcha-site-key.',
      );
      return;
    }

    try {
      await FirebaseAppCheck.instance.activate(
        webProvider: ReCaptchaEnterpriseProvider(normalized),
      );
      debugPrint('[PerezFans] App Check activated (web, reCAPTCHA Enterprise).');
    } catch (e) {
      debugPrint('[PerezFans] App Check web activation failed: $e');
    }
    return;
  }

  try {
    await FirebaseAppCheck.instance.activate(
      androidProvider:
          kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
      appleProvider:
          kDebugMode ? AppleProvider.debug : AppleProvider.appAttest,
    );
  } catch (e) {
    debugPrint('App Check (mobile) activation failed, continuing: $e');
  }
}

bool _looksInvalidRecaptchaKey(String s) {
  return s == 'your_site_key' || s.toLowerCase().contains('replace');
}
