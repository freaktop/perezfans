import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class BlocksRecord extends FirestoreRecord {
  BlocksRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "blocked_by" field.
  DocumentReference? _blockedBy;
  DocumentReference? get blockedBy => _blockedBy;
  bool hasBlockedBy() => _blockedBy != null;

  // "blocked_user" field.
  DocumentReference? _blockedUser;
  DocumentReference? get blockedUser => _blockedUser;
  bool hasBlockedUser() => _blockedUser != null;

  // "created_time" field.
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  void _initializeFields() {
    _blockedBy = snapshotData['blocked_by'] as DocumentReference?;
    _blockedUser = snapshotData['blocked_user'] as DocumentReference?;
    _createdTime = snapshotData['created_time'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('blocks');

  static Stream<BlocksRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => BlocksRecord.fromSnapshot(s));

  static Future<BlocksRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => BlocksRecord.fromSnapshot(s));

  static BlocksRecord fromSnapshot(DocumentSnapshot snapshot) =>
      BlocksRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static BlocksRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      BlocksRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'BlocksRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is BlocksRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createBlocksRecordData({
  DocumentReference? blockedBy,
  DocumentReference? blockedUser,
  DateTime? createdTime,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'blocked_by': blockedBy,
      'blocked_user': blockedUser,
      'created_time': createdTime,
    }.withoutNulls,
  );

  return firestoreData;
}

class BlocksRecordDocumentEquality implements Equality<BlocksRecord> {
  const BlocksRecordDocumentEquality();

  @override
  bool equals(BlocksRecord? e1, BlocksRecord? e2) {
    return e1?.blockedBy == e2?.blockedBy &&
        e1?.blockedUser == e2?.blockedUser &&
        e1?.createdTime == e2?.createdTime;
  }

  @override
  int hash(BlocksRecord? e) => const ListEquality().hash([
        e?.blockedBy,
        e?.blockedUser,
        e?.createdTime,
      ]);

  @override
  bool isValidKey(Object? o) => o is BlocksRecord;
}
