import 'dart:developer' as developer;
import 'dart:io' show Platform;

import '/auth/firebase_auth/auth_util.dart';
import '/core_pages/live/web_host_media_preflight.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:permission_handler/permission_handler.dart';

/// Central validation before any Agora / token work.
class LiveJoinValidation {
  const LiveJoinValidation._({
    required this.ok,
    this.userMessage,
    this.streamRef,
  });

  final bool ok;
  final String? userMessage;
  final DocumentReference? streamRef;

  factory LiveJoinValidation.success(DocumentReference ref) =>
      LiveJoinValidation._(ok: true, streamRef: ref);

  factory LiveJoinValidation.fail(String message) =>
      LiveJoinValidation._(ok: false, userMessage: message);

  void log(String context) {
    LiveJoinService.log(
      '${context}: ok=$ok ref=${streamRef?.path} msg=${userMessage ?? ""}',
    );
  }
}

class LiveStreamDocRead {
  const LiveStreamDocRead({
    required this.exists,
    this.channelName,
    this.status,
    this.hostUserRef,
    this.permissionDenied = false,
  });

  final bool exists;
  final String? channelName;
  final String? status;
  /// Firestore `host_user` — used to align client role with token (publisher vs subscriber).
  final DocumentReference? hostUserRef;
  final bool permissionDenied;
}

class AgoraTokenPayload {
  const AgoraTokenPayload({
    required this.appId,
    required this.token,
    required this.rtcUid,
    this.channelName,
  });

  final String appId;
  final String token;
  final int rtcUid;

  /// Channel the token was minted for ([createAgoraRtcToken]); join MUST use this.
  final String? channelName;
}

/// Shared live-room join logic (validation + Firestore + callable parsing).
class LiveJoinService {
  LiveJoinService._();

  static void log(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(message, name: 'LiveJoin', error: error, stackTrace: stackTrace);
  }

  static DocumentReference? resolveStreamReference({
    DocumentReference? streamRef,
    String? streamId,
  }) {
    if (streamRef != null) return streamRef;
    final id = streamId?.trim();
    if (id == null || id.isEmpty) return null;
    return FirebaseFirestore.instance.collection('live_streams').doc(id);
  }

  /// Validates auth and stream route params (camera/mic checked separately once host is known).
  static Future<LiveJoinValidation> validateLiveJoinRequirements({
    required DocumentReference? streamRefParam,
    required String? streamIdArg,
  }) async {
    final resolved =
        resolveStreamReference(streamRef: streamRefParam, streamId: streamIdArg);

    if (resolved == null) {
      return LiveJoinValidation.fail(
        'No live stream selected. Go back and open a stream from the Live list.',
      );
    }

    final fbUser = firebase_auth.FirebaseAuth.instance.currentUser;
    if (fbUser == null) {
      return LiveJoinValidation.fail('Sign in to watch or host live streams.');
    }

    final appUid = currentUserUid;
    if (appUid.isNotEmpty && appUid != fbUser.uid) {
      log(
        'Auth uid mismatch (app="$appUid" firebase="${fbUser.uid}") — using Firebase user for token.',
      );
    }

    return LiveJoinValidation.success(resolved);
  }

  /// Resolves [host_user] from Firestore (reference, path string, or uid string).
  static DocumentReference? parseHostUserField(dynamic raw) {
    if (raw == null) return null;
    if (raw is DocumentReference) return raw;
    if (raw is String) {
      final s = raw.trim();
      if (s.isEmpty) return null;
      if (s.contains('/')) {
        return FirebaseFirestore.instance.doc(s);
      }
      return FirebaseFirestore.instance.collection('users').doc(s);
    }
    return null;
  }

  /// Camera + mic before publishing (web + native). Web must prompt or Agora fails silently.
  static Future<String?> ensureHostBroadcastPermissions() async {
    try {
      if (kIsWeb) {
        log('livehost: requesting camera/mic (web getUserMedia)');
        final err = await preflightWebHostMedia();
        if (err != null) {
          log('livehost: camera/mic denied or failure: $err');
          return err;
        }
        log('livehost: camera/mic granted');
        return null;
      }
      if (!Platform.isAndroid && !Platform.isIOS) return null;
      final cam = await Permission.camera.request();
      final mic = await Permission.microphone.request();
      if (!cam.isGranted || !mic.isGranted) {
        return 'Camera and microphone permission are required to go live. '
            'Enable them in system settings and try again.';
      }
    } catch (e, st) {
      log('host capture permission failed', e, st);
      return 'Could not access camera/microphone. Check browser or system permissions.';
    }
    return null;
  }

  static Future<LiveStreamDocRead> readLiveStreamDocument(
    DocumentReference ref,
  ) async {
    try {
      final snap = await ref.get();
      if (!snap.exists) {
        return const LiveStreamDocRead(exists: false);
      }
      final raw = snap.data();
      if (raw is! Map<String, dynamic>) {
        return const LiveStreamDocRead(exists: false);
      }
      final channel = (raw['channel_name'] ?? '').toString();
      final status = (raw['status'] ?? '').toString();
      final hostUserRef = parseHostUserField(raw['host_user']);
      if (hostUserRef == null) {
        log('host_user missing or unparsable type=${raw['host_user']?.runtimeType}');
      }
      return LiveStreamDocRead(
        exists: true,
        channelName: channel.isEmpty ? null : channel,
        status: status.isEmpty ? null : status,
        hostUserRef: hostUserRef,
      );
    } on FirebaseException catch (e, st) {
      log(
        'readLiveStreamDocument failed code=${e.code} message=${e.message}',
        e,
        st,
      );
      if (e.code == 'permission-denied') {
        return LiveStreamDocRead(
          exists: false,
          permissionDenied: true,
        );
      }
      rethrow;
    }
  }

  static AgoraTokenPayload? parseTokenResponse(dynamic rawData) {
    if (rawData == null || rawData is! Map) {
      log('token payload wrong type=${rawData.runtimeType}');
      return null;
    }
    final map = Map<String, dynamic>.from(
      rawData.map((k, v) => MapEntry(k.toString(), v)),
    );
    final appId = (map['appId'] ?? '').toString();
    final token = (map['token'] ?? '').toString();
    final rtcUid = map['rtcUid'] is int
        ? map['rtcUid'] as int
        : int.tryParse(map['rtcUid']?.toString() ?? '') ?? 0;
    final chRaw = (map['channelName'] ?? map['channel_name'] ?? '').toString();
    final channelName = chRaw.trim().isEmpty ? null : chRaw.trim();

    if (appId.isEmpty || token.isEmpty) {
      log('token payload missing appId or token');
      return null;
    }
    if (rtcUid <= 0) {
      log('token payload invalid rtcUid=$rtcUid');
      return null;
    }
    return AgoraTokenPayload(
      appId: appId,
      token: token,
      rtcUid: rtcUid,
      channelName: channelName,
    );
  }

  /// Prefer [AgoraTokenPayload.channelName] so [joinChannel] matches token minting.
  static String? effectiveJoinChannelName({
    required String firestoreChannel,
    required AgoraTokenPayload payload,
  }) {
    final fromToken = payload.channelName?.trim();
    final fromDoc = firestoreChannel.trim();
    if (fromToken != null && fromToken.isNotEmpty) {
      if (fromDoc.isNotEmpty && fromToken != fromDoc) {
        log(
          'channel mismatch firestore="$fromDoc" token="$fromToken" '
          '(join uses token — must match RtcTokenBuilder input)',
        );
      }
      return fromToken;
    }
    if (fromDoc.isEmpty) return null;
    log('token response had no channelName; using firestore channel');
    return fromDoc;
  }

  static Future<AgoraTokenPayload?> fetchAgoraToken({
    required HttpsCallable callable,
    required String streamId,
  }) async {
    final resp = await callable.call({'streamId': streamId});
    final payload = parseTokenResponse(resp.data);
    if (payload != null) {
      log(
        'token ok streamId=$streamId rtcUid=${payload.rtcUid} '
        'tokenLen=${payload.token.length} '
        'appIdPrefix=${payload.appId.length >= 6 ? payload.appId.substring(0, 6) : payload.appId} '
        'channel=${payload.channelName ?? "(from FS only)"}',
      );
    }
    return payload;
  }
}
