import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '/auth/firebase_auth/auth_util.dart';

class FcmService {
  static final FcmService _instance = FcmService._internal();
  factory FcmService() => _instance;
  FcmService._internal();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    final messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) return;

    final token = await messaging.getToken(
      vapidKey: 'YWo4Bk5Ae5jKjm22FJcKJRuyAnJOwUHHRaQtDVK0jgY',
    );

    if (token != null) {
      await _saveToken(token);
    }

    messaging.onTokenRefresh.listen(_saveToken);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        // Foreground messages are handled here
        // Could show a local notification or in-app banner
      }
    });
  }

  Future<void> _saveToken(String token) async {
    if (currentUserReference == null) return;
    await currentUserReference!.set({
      'fcm_tokens': FieldValue.arrayUnion([token]),
    }, SetOptions(merge: true));
  }

  Future<void> removeToken(String token) async {
    if (currentUserReference == null) return;
    await currentUserReference!.update({
      'fcm_tokens': FieldValue.arrayRemove([token]),
    });
  }
}
