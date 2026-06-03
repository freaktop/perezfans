import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ActivitiesRecord extends FirestoreRecord {
  ActivitiesRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  DocumentReference? _actor;
  DocumentReference? get actor => _actor;
  bool hasActor() => _actor != null;

  String? _type;
  String get type => _type ?? '';
  bool hasType() => _type != null;

  DocumentReference? _targetUser;
  DocumentReference? get targetUser => _targetUser;
  bool hasTargetUser() => _targetUser != null;

  DocumentReference? _targetVideo;
  DocumentReference? get targetVideo => _targetVideo;
  bool hasTargetVideo() => _targetVideo != null;

  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  void _initializeFields() {
    _actor = snapshotData['actor'] as DocumentReference?;
    _type = snapshotData['type'] as String?;
    _targetUser = snapshotData['target_user'] as DocumentReference?;
    _targetVideo = snapshotData['target_video'] as DocumentReference?;
    _createdTime = snapshotData['created_time'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('activities');

  static Stream<ActivitiesRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => ActivitiesRecord.fromSnapshot(s));

  static Future<ActivitiesRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => ActivitiesRecord.fromSnapshot(s));

  static ActivitiesRecord fromSnapshot(DocumentSnapshot snapshot) =>
      ActivitiesRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static ActivitiesRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      ActivitiesRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'ActivitiesRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is ActivitiesRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createActivitiesRecordData({
  DocumentReference? actor,
  String? type,
  DocumentReference? targetUser,
  DocumentReference? targetVideo,
  DateTime? createdTime,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'actor': actor,
      'type': type,
      'target_user': targetUser,
      'target_video': targetVideo,
      'created_time': createdTime,
    }.withoutNulls,
  );
  return firestoreData;
}

class ActivitiesRecordDocumentEquality
    implements Equality<ActivitiesRecord> {
  const ActivitiesRecordDocumentEquality();

  @override
  bool equals(ActivitiesRecord? e1, ActivitiesRecord? e2) {
    return e1?.actor == e2?.actor &&
        e1?.type == e2?.type &&
        e1?.targetUser == e2?.targetUser &&
        e1?.targetVideo == e2?.targetVideo &&
        e1?.createdTime == e2?.createdTime;
  }

  @override
  int hash(ActivitiesRecord? e) => const ListEquality().hash([
        e?.actor,
        e?.type,
        e?.targetUser,
        e?.targetVideo,
        e?.createdTime,
      ]);

  @override
  bool isValidKey(Object? o) => o is ActivitiesRecord;
}
