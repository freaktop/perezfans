import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

import '/backend/payments/stripe_checkout_urls.dart';

/// Starts Stripe Checkout for video promotion (callable: createPromotionCheckoutSession).
Future<String> startPromotionCheckout({
  required String videoId,
  String tier = 'basic',
}) async {
  if (videoId.trim().isEmpty) {
    throw Exception('Video ID is missing. Try again from your video or Creator tools.');
  }

  final urlIssue = StripeCheckoutUrls.validatePromotionUrlsForStripe();
  if (urlIssue != null) {
    throw Exception(urlIssue);
  }

  final successUrl = StripeCheckoutUrls.promotionSuccessUri().toString();
  final cancelUrl = StripeCheckoutUrls.promotionCancelUri().toString();

  final functions = FirebaseFunctions.instanceFor(region: 'us-central1');
  final callable = functions.httpsCallable('createPromotionCheckoutSession');

  try {
    final response = await callable.call({
      'videoId': videoId,
      'tier': tier,
      'successUrl': successUrl,
      'cancelUrl': cancelUrl,
    });

    final data = response.data;
    if (data is! Map || data['checkoutUrl'] == null) {
      throw Exception(
        'Checkout did not return a URL. Check Stripe configuration and network.',
      );
    }
    final checkoutUrl = data['checkoutUrl'] as String;
    if (checkoutUrl.isEmpty) {
      throw Exception('Checkout URL was empty.');
    }

    final uri = Uri.parse(checkoutUrl);
    final opened = await launchUrl(
      uri,
      mode: kIsWeb ? LaunchMode.platformDefault : LaunchMode.externalApplication,
      webOnlyWindowName: '_self',
    );
    if (!opened) {
      throw Exception('Could not open checkout. Allow pop-ups or try another device.');
    }
    return checkoutUrl;
  } on FirebaseFunctionsException catch (e) {
    final code = e.code;
    final message = e.message ?? 'Cloud Function error';
    throw Exception(
      code == 'unauthenticated'
          ? 'Sign in again, then retry checkout.'
          : (code == 'permission-denied'
              ? 'You are not allowed to promote this video.'
              : '$message (${e.details ?? code})'),
    );
  }
}

String promotionStatusLabel(String status) {
  switch (status) {
    case 'active':
      return 'Promotion active';
    case 'pending_payment':
      return 'Payment pending';
    default:
      return kDebugMode ? 'Not promoted' : 'Not promoted';
  }
}
