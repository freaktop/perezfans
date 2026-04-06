// PerezFans Stripe Connect — product default (2026):
// - Fan pays creator via DESTINATION CHARGES: platform Checkout, funds transferred to the
//   creator’s connected account minus [createMarketplacePaymentCheckout] application fee.
// - Creators onboard with Accounts v2 profile `marketplace` (see [createSellerConnectedAccount]).
// - Direct charges ([startDirectChargeCheckout]) and per-creator Stripe Product catalogs are
//   intentionally deferred until a future feature needs merchant-of-record-on-seller behavior.
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:url_launcher/url_launcher.dart';

final _functions = FirebaseFunctions.instanceFor(region: 'us-central1');

/// Stripe Checkout return pages under [web/stripe/]. On Flutter web, use the
/// current origin so localhost and production both return to the correct host.
String? _defaultMarketplaceSuccessUrl() {
  if (!kIsWeb) return null;
  return '${Uri.base.origin}/stripe/marketplace-success.html';
}

String? _defaultMarketplaceCancelUrl() {
  if (!kIsWeb) return null;
  return '${Uri.base.origin}/stripe/marketplace-cancel.html';
}

enum StripeConnectAccountProfile { marketplace, subscriptionsEmbedded }

String _functionsErrorMessage(FirebaseFunctionsException e) {
  final msg = e.message ?? 'Request failed';
  switch (e.code) {
    case 'unauthenticated':
      return 'Sign in again, then retry.';
    case 'permission-denied':
      return 'You do not have permission for this action.';
    case 'failed-precondition':
      return msg;
    case 'unavailable':
      return 'Stripe service is temporarily unavailable. Try again shortly.';
    default:
      return '$msg (${e.code})';
  }
}

/// Account profiles:
/// - [marketplace] — Express, platform liability (default PerezFans flow).
/// - [subscriptionsEmbedded] — full dashboard, Stripe liability, merchant+customer
///   (Subscriptions + embedded payments blueprint).
/// Creates a Stripe Accounts v2 connected account for the signed-in seller.
Future<Map<String, dynamic>> createSellerConnectedAccount({
  String country = 'us',
  String? displayName,
  String? contactEmail,
  bool simulateAcceptTosObo = false,
  StripeConnectAccountProfile accountProfile =
      StripeConnectAccountProfile.marketplace,
  String? businessPhone,
}) async {
  try {
    final callable = _functions.httpsCallable('createSellerConnectedAccount');
    final res = await callable.call(<String, dynamic>{
      'country': country,
      if (displayName != null) 'displayName': displayName,
      if (contactEmail != null) 'contactEmail': contactEmail,
      if (kDebugMode) 'simulateAcceptTosObo': simulateAcceptTosObo,
      'accountProfile': accountProfile == StripeConnectAccountProfile.marketplace
          ? 'marketplace'
          : 'subscriptions_embedded',
      if (businessPhone != null) 'businessPhone': businessPhone,
    });
    final data = res.data;
    if (data is! Map) {
      throw Exception('Invalid response from createSellerConnectedAccount');
    }
    return Map<String, dynamic>.from(
      data.map((k, v) => MapEntry(k.toString(), v)),
    );
  } on FirebaseFunctionsException catch (e) {
    throw Exception(_functionsErrorMessage(e));
  }
}

/// Stripe-hosted onboarding (KYC). Configurations default from account profile
/// (recipient+merchant vs merchant+customer).
Future<String> createSellerOnboardingLink({
  String? refreshUrl,
  String? returnUrl,
  List<String>? onboardingConfigurations,
}) async {
  try {
    final callable = _functions.httpsCallable('createSellerOnboardingLink');
    final res = await callable.call(<String, dynamic>{
      if (refreshUrl != null) 'refreshUrl': refreshUrl,
      if (returnUrl != null) 'returnUrl': returnUrl,
      if (onboardingConfigurations != null)
        'onboardingConfigurations': onboardingConfigurations,
    });
    final data = res.data;
    if (data is! Map || data['url'] == null) {
      throw Exception('Onboarding URL was not returned. Check Stripe Connect setup.');
    }
    return data['url'] as String;
  } on FirebaseFunctionsException catch (e) {
    throw Exception(_functionsErrorMessage(e));
  }
}

Future<Map<String, dynamic>> refreshSellerStripeStatus() async {
  try {
    final callable = _functions.httpsCallable('refreshSellerStripeStatus');
    final response = await callable.call();
    final data = response.data;
    if (data is! Map) {
      throw Exception('Invalid response from refreshSellerStripeStatus');
    }
    return Map<String, dynamic>.from(
      data.map((k, v) => MapEntry(k.toString(), v)),
    );
  } on FirebaseFunctionsException catch (e) {
    throw Exception(_functionsErrorMessage(e));
  }
}

/// **Primary PerezFans purchase flow:** platform-hosted Checkout, then Stripe sends the
/// net amount to the seller’s connected account ([payment_intent_data.transfer_data.destination])
/// and keeps a platform fee ([application_fee_amount]). Use this for tips, unlocks, and
/// generic “support this creator” payments.
Future<String> startMarketplaceCheckout({
  required String sellerUid,
  required int amountCents,
  String currency = 'usd',
  String productName = 'PerezFans support',
  String? successUrl,
  String? cancelUrl,
}) async {
  if (sellerUid.isEmpty) {
    throw Exception('Seller is not valid.');
  }
  if (amountCents < 50) {
    throw Exception('Amount is too small for checkout.');
  }
  try {
    final resolvedSuccess = successUrl ?? _defaultMarketplaceSuccessUrl();
    final resolvedCancel = cancelUrl ?? _defaultMarketplaceCancelUrl();
    final callable =
        _functions.httpsCallable('createMarketplacePaymentCheckout');
    final response = await callable.call(<String, dynamic>{
      'sellerUid': sellerUid,
      'amountCents': amountCents,
      'currency': currency,
      'productName': productName,
      if (resolvedSuccess != null) 'successUrl': resolvedSuccess,
      if (resolvedCancel != null) 'cancelUrl': resolvedCancel,
    });
    final data = response.data;
    if (data is! Map || data['checkoutUrl'] == null) {
      throw Exception('Checkout URL was not returned.');
    }
    final checkoutUrl = data['checkoutUrl'] as String;
    final uri = Uri.parse(checkoutUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not open checkout.');
    }
    return checkoutUrl;
  } on FirebaseFunctionsException catch (e) {
    throw Exception(_functionsErrorMessage(e));
  }
}

/// **Deferred / alternate model:** Checkout session created in the connected account’s context
/// (seller = merchant of record). Not wired into main PerezFans UI; prefer
/// [startMarketplaceCheckout] unless you explicitly need direct charges later.
Future<String> startDirectChargeCheckout({
  required String sellerUid,
  required int amountCents,
  String currency = 'usd',
  String productName = 'PerezFans support',
  String? successUrl,
  String? cancelUrl,
}) async {
  if (sellerUid.isEmpty) {
    throw Exception('Seller is not valid.');
  }
  if (amountCents < 50) {
    throw Exception('Amount is too small for checkout.');
  }
  try {
    final resolvedSuccess = successUrl ?? _defaultMarketplaceSuccessUrl();
    final resolvedCancel = cancelUrl ?? _defaultMarketplaceCancelUrl();
    final callable =
        _functions.httpsCallable('createDirectChargeCheckoutSession');
    final response = await callable.call(<String, dynamic>{
      'sellerUid': sellerUid,
      'amountCents': amountCents,
      'currency': currency,
      'productName': productName,
      if (resolvedSuccess != null) 'successUrl': resolvedSuccess,
      if (resolvedCancel != null) 'cancelUrl': resolvedCancel,
    });
    final data = response.data;
    if (data is! Map || data['checkoutUrl'] == null) {
      throw Exception('Checkout URL was not returned.');
    }
    final checkoutUrl = data['checkoutUrl'] as String;
    final uri = Uri.parse(checkoutUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not open checkout.');
    }
    return checkoutUrl;
  } on FirebaseFunctionsException catch (e) {
    throw Exception(_functionsErrorMessage(e));
  }
}
