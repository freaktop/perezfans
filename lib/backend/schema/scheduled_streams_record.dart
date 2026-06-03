import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ScheduledStreamsRecord extends FirestoreRecord {
  ScheduledStreamsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "creator" field.
  DocumentReference? _creator;
  DocumentReference? get creator => _creator;
  bool hasCreator() => _creator != null;

  // "title" field.
  String? _title;
  String get title => _title ?? '';
  bool hasTitle() => _title != null;

  // "description" field.
  String? _description;
  String get description => _description ?? '';
  bool hasDescription() => _description != null;

  // "scheduled_time" field.
  DateTime? _scheduledTime;
  DateTime? get scheduledTime => _scheduledTime;
  bool hasScheduledTime() => _scheduledTime != null;

  // "duration_minutes" field.
  int? _durationMinutes;
  int get durationMinutes => _durationMinutes ?? 0;
  bool hasDurationMinutes() => _durationMinutes != null;

  // "thumbnail_url" field.
  String? _thumbnailUrl;
  String get thumbnailUrl => _thumbnailUrl ?? '';
  bool hasThumbnailUrl() => _thumbnailUrl != null;

  // "is_cancelled" field.
  bool? _isCancelled;
  bool get isCancelled => _isCancelled ?? false;
  bool hasIsCancelled() => _isCancelled != null;

  // "created_time" field.
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  // "is_exclusive" field.
  bool? _isExclusive;
  bool get isExclusive => _isExclusive ?? false;
  bool hasIsExclusive() => _isExclusive != null;

  // "notification_sent" field.
  bool? _notificationSent;
  bool get notificationSent => _notificationSent ?? false;
  bool hasNotificationSent() => _notificationSent != null;

  void _initializeFields() {
    _creator = snapshotData['creator'] as DocumentReference?;
    _title = snapshotData['title'] as String?;
    _description = snapshotData['description'] as String?;
    _scheduledTime = snapshotData['scheduled_time'] as DateTime?;
    _durationMinutes = castToType<int>(snapshotData['duration_minutes']);
    _thumbnailUrl = snapshotData['thumbnail_url'] as String?;
    _isCancelled = snapshotData['is_cancelled'] as bool?;
    _createdTime = snapshotData['created_time'] as DateTime?;
    _isExclusive = snapshotData['is_exclusive'] as bool?;
    _notificationSent = snapshotData['notification_sent'] as bool?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('scheduled_streams');

  static Stream<ScheduledStreamsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => ScheduledStreamsRecord.fromSnapshot(s));

  static Future<ScheduledStreamsRecord> getDocumentOnce(
          DocumentReference ref) =>
      ref.get().then((s) => ScheduledStreamsRecord.fromSnapshot(s));

  static ScheduledStreamsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      ScheduledStreamsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static ScheduledStreamsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      ScheduledStreamsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'ScheduledStreamsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is ScheduledStreamsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createScheduledStreamsRecordData({
  DocumentReference? creator,
  String? title,
  String? description,
  DateTime? scheduledTime,
  int? durationMinutes,
  String? thumbnailUrl,
  bool? isCancelled,
  DateTime? createdTime,
  bool? isExclusive,
  bool? notificationSent,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'creator': creator,
      'title': title,
      'description': description,
      'scheduled_time': scheduledTime,
      'duration_minutes': durationMinutes,
      'thumbnail_url': thumbnailUrl,
      'is_cancelled': isCancelled,
      'created_time': createdTime,
      'is_exclusive': isExclusive,
      'notification_sent': notificationSent,
    }.withoutNulls,
  );

  return firestoreData;
}

class ScheduledStreamsRecordDocumentEquality
    implements Equality<ScheduledStreamsRecord> {
  const ScheduledStreamsRecordDocumentEquality();

  @override
  bool equals(ScheduledStreamsRecord? e1, ScheduledStreamsRecord? e2) {
    return e1?.creator == e2?.creator &&
        e1?.title == e2?.title &&
        e1?.description == e2?.description &&
        e1?.scheduledTime == e2?.scheduledTime &&
        e1?.durationMinutes == e2?.durationMinutes &&
        e1?.thumbnailUrl == e2?.thumbnailUrl &&
        e1?.isCancelled == e2?.isCancelled &&
        e1?.createdTime == e2?.createdTime &&
        e1?.isExclusive == e2?.isExclusive &&
        e1?.notificationSent == e2?.notificationSent;
  }

  @override
  int hash(ScheduledStreamsRecord? e) => const ListEquality().hash([
        e?.creator,
        e?.title,
        e?.description,
        e?.scheduledTime,
        e?.durationMinutes,
        e?.thumbnailUrl,
        e?.isCancelled,
        e?.createdTime,
        e?.isExclusive,
        e?.notificationSent,
      ]);

  @override
  bool isValidKey(Object? o) => o is ScheduledStreamsRecord;
}
