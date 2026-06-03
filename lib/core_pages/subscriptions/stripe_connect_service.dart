import 'package:cloud_functions/cloud_functions.dart';

class StripeConnectService {
  static final StripeConnectService _instance = StripeConnectService._();
  factory StripeConnectService() => _instance;
  StripeConnectService._();

  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<String> createStripeConnectAccount({String? email}) async {
    final result = await _functions.httpsCallable('createStripeConnectAccount')
        .call(<String, dynamic>{'email': email ?? ''});
    return result.data['url'] as String;
  }

  Future<String> createStripeAccountLink(String accountId) async {
    final result = await _functions.httpsCallable('createStripeAccountLink')
        .call(<String, dynamic>{'accountId': accountId});
    return result.data['url'] as String;
  }

  Future<String> createSubscriptionCheckout({
    required String creatorId,
    required int priceInCents,
  }) async {
    final result =
        await _functions.httpsCallable('createSubscriptionCheckout').call(
              <String, dynamic>{
                'creatorId': creatorId,
                'priceInCents': priceInCents,
              },
            );
    return result.data['url'] as String;
  }

  Future<String> createTipCheckout({
    required String creatorId,
    required int amountInCents,
    String currency = 'usd',
  }) async {
    final result = await _functions.httpsCallable('createTipCheckout').call(
      <String, dynamic>{
        'creatorId': creatorId,
        'amountInCents': amountInCents,
        'currency': currency,
      },
    );
    return result.data['url'] as String;
  }

  Future<String> createTipPaymentIntent({
    required String creatorId,
    required int amountInCents,
    String currency = 'usd',
  }) async {
    final result =
        await _functions.httpsCallable('createTipPaymentIntent').call(
              <String, dynamic>{
                'creatorId': creatorId,
                'amountInCents': amountInCents,
                'currency': currency,
              },
            );
    return result.data['clientSecret'] as String;
  }

  Future<Map<String, dynamic>> checkStripeAccountStatus(
      String accountId) async {
    final result =
        await _functions.httpsCallable('checkStripeAccountStatus').call(
              <String, dynamic>{'accountId': accountId},
            );
    return result.data as Map<String, dynamic>;
  }
}
