import 'package:flutter/foundation.dart' show kDebugMode;

import '/app_state.dart';

/// Builds promotion checkout return URLs from [FFAppState.websiteURL].
/// Configure the real production hostname in app settings (not hard-coded here).
class StripeCheckoutUrls {
  StripeCheckoutUrls._();

  static String _baseNoSlash() {
    final raw = FFAppState().websiteURL.trim();
    if (raw.isEmpty) {
      return 'https://perezfans.web.app';
    }
    return raw.replaceAll(RegExp(r'/+$'), '');
  }

  static Uri promotionSuccessUri() =>
      Uri.parse('${_baseNoSlash()}/promote/success.html');

  static Uri promotionCancelUri() =>
      Uri.parse('${_baseNoSlash()}/promote/cancel.html');

  /// Validates that URLs are absolute https (Stripe live / default).
  /// In debug mode, HTTP is allowed for local testing only.
  static String? validatePromotionUrlsForStripe() {
    final s = promotionSuccessUri();
    final c = promotionCancelUri();
    if (!s.hasScheme || !c.hasScheme) {
      return 'Promotion success/cancel URLs must include a scheme (https://).';
    }
    if (!kDebugMode && (s.scheme != 'https' || c.scheme != 'https')) {
      return 'Production builds require HTTPS success/cancel URLs (got $s / $c).';
    }
    if (s.host.isEmpty || c.host.isEmpty) {
      return 'Promotion URLs are missing a hostname. Set website URL in app settings.';
    }
    return null;
  }
}
