import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Firebase options for PerezFans. Use [currentPlatform] only on **web** and **Android**.
class DefaultFirebaseOptions {
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD7FWFvyb7VyvA4vf1kDFU7avHvuysz19U',
    authDomain: 'perezfans.firebaseapp.com',
    projectId: 'perezfans',
    storageBucket: 'perezfans.firebasestorage.app',
    messagingSenderId: '547851710384',
    appId: '1:547851710384:web:df4b5416d0698762acb075',
    measurementId: 'G-K27R216TE3',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDHroD1077L3L3nAki4is79GNkv-Ry6lsg',
    appId: '1:547851710384:android:5972ce4a27fe1dd6acb075',
    messagingSenderId: '547851710384',
    projectId: 'perezfans',
    storageBucket: 'perezfans.firebasestorage.app',
  );

  /// Web → [web]; Android → [android]. Not for iOS/desktop (use native init).
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    if (defaultTargetPlatform == TargetPlatform.android) return android;
    throw UnsupportedError(
      'DefaultFirebaseOptions.currentPlatform is only for web and Android.',
    );
  }
}
