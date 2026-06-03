import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class NotificationSettingsRecord extends FirestoreRecord {
  NotificationSettingsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "user" field.
  DocumentReference? _user;
  DocumentReference? get user => _user;
  bool hasUser() => _user != null;

  // "push_enabled" field.
  bool? _pushEnabled;
  bool get pushEnabled => _pushEnabled ?? false;
  bool hasPushEnabled() => _pushEnabled != null;

  // "likes" field.
  bool? _likes;
  bool get likes => _likes ?? false;
  bool hasLikes() => _likes != null;

  // "comments" field.
  bool? _comments;
  bool get comments => _comments ?? false;
  bool hasComments() => _comments != null;

  // "followers" field.
  bool? _followers;
  bool get followers => _followers ?? false;
  bool hasFollowers() => _followers != null;

  // "live_started" field.
  bool? _liveStarted;
  bool get liveStarted => _liveStarted ?? false;
  bool hasLiveStarted() => _liveStarted != null;

  // "direct_messages" field.
  bool? _directMessages;
  bool get directMessages => _directMessages ?? false;
  bool hasDirectMessages() => _directMessages != null;

  void _initializeFields() {
    _user = snapshotData['user'] as DocumentReference?;
    _pushEnabled = snapshotData['push_enabled'] as bool?;
    _likes = snapshotData['likes'] as bool?;
    _comments = snapshotData['comments'] as bool?;
    _followers = snapshotData['followers'] as bool?;
    _liveStarted = snapshotData['live_started'] as bool?;
    _directMessages = snapshotData['direct_messages'] as bool?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('notification_settings');

  static Stream<NotificationSettingsRecord> getDocument(
          DocumentReference ref) =>
      ref.snapshots().map((s) => NotificationSettingsRecord.fromSnapshot(s));

  static Future<NotificationSettingsRecord> getDocumentOnce(
          DocumentReference ref) =>
      ref.get().then((s) => NotificationSettingsRecord.fromSnapshot(s));

  static NotificationSettingsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      NotificationSettingsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static NotificationSettingsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      NotificationSettingsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'NotificationSettingsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is NotificationSettingsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createNotificationSettingsRecordData({
  DocumentReference? user,
  bool? pushEnabled,
  bool? likes,
  bool? comments,
  bool? followers,
  bool? liveStarted,
  bool? directMessages,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'user': user,
      'push_enabled': pushEnabled,
      'likes': likes,
      'comments': comments,
      'followers': followers,
      'live_started': liveStarted,
      'direct_messages': directMessages,
    }.withoutNulls,
  );

  return firestoreData;
}

class NotificationSettingsRecordDocumentEquality
    implements Equality<NotificationSettingsRecord> {
  const NotificationSettingsRecordDocumentEquality();

  @override
  bool equals(NotificationSettingsRecord? e1, NotificationSettingsRecord? e2) {
    return e1?.user == e2?.user &&
        e1?.pushEnabled == e2?.pushEnabled &&
        e1?.likes == e2?.likes &&
        e1?.comments == e2?.comments &&
        e1?.followers == e2?.followers &&
        e1?.liveStarted == e2?.liveStarted &&
        e1?.directMessages == e2?.directMessages;
  }

  @override
  int hash(NotificationSettingsRecord? e) => const ListEquality().hash([
        e?.user,
        e?.pushEnabled,
        e?.likes,
        e?.comments,
        e?.followers,
        e?.liveStarted,
        e?.directMessages,
      ]);

  @override
  bool isValidKey(Object? o) => o is NotificationSettingsRecord;
}
