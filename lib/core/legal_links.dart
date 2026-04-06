import 'package:flutter/foundation.dart';

import '/app_state.dart';

/// Same-origin legal pages on web; on mobile uses [FFAppState] public site URL.
String perezFansPublicPageUrl(String path) {
  assert(path.startsWith('/'));
  if (kIsWeb) {
    final b = Uri.base;
    final port = b.hasPort && b.port != 80 && b.port != 443 ? ':${b.port}' : '';
    return '${b.scheme}://${b.host}$port$path';
  }
  final base = FFAppState().websiteURL.replaceAll(RegExp(r'/$'), '');
  return '$base$path';
}

String termsOfServiceUrl() => perezFansPublicPageUrl('/terms');

String privacyPolicyUrl() => perezFansPublicPageUrl('/privacy');
