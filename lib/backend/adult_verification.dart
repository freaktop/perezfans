import 'package:cloud_functions/cloud_functions.dart';

/// Confirms 18+ attestation via Cloud Function (updates [is_adult_verified] server-side).
Future<void> confirmAdultAgeAttestation() async {
  final functions = FirebaseFunctions.instanceFor(region: 'us-central1');
  final callable = functions.httpsCallable('confirmAdultAgeAttestation');
  await callable.call(<String, dynamic>{'acknowledged': true});
}
