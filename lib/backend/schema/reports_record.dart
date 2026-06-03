import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ReportsRecord extends FirestoreRecord {
  ReportsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "reported_by" field.
  DocumentReference? _reportedBy;
  DocumentReference? get reportedBy => _reportedBy;
  bool hasReportedBy() => _reportedBy != null;

  // "reported_user" field.
  DocumentReference? _reportedUser;
  DocumentReference? get reportedUser => _reportedUser;
  bool hasReportedUser() => _reportedUser != null;

  // "reason" field.
  String? _reason;
  String get reason => _reason ?? '';
  bool hasReason() => _reason != null;

  // "details" field.
  String? _details;
  String get details => _details ?? '';
  bool hasDetails() => _details != null;

  // "created_time" field.
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  // "status" field.
  String? _status;
  String get status => _status ?? '';
  bool hasStatus() => _status != null;

  void _initializeFields() {
    _reportedBy = snapshotData['reported_by'] as DocumentReference?;
    _reportedUser = snapshotData['reported_user'] as DocumentReference?;
    _reason = snapshotData['reason'] as String?;
    _details = snapshotData['details'] as String?;
    _createdTime = snapshotData['created_time'] as DateTime?;
    _status = snapshotData['status'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('reports');

  static Stream<ReportsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => ReportsRecord.fromSnapshot(s));

  static Future<ReportsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => ReportsRecord.fromSnapshot(s));

  static ReportsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      ReportsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static ReportsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      ReportsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'ReportsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is ReportsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createReportsRecordData({
  DocumentReference? reportedBy,
  DocumentReference? reportedUser,
  String? reason,
  String? details,
  DateTime? createdTime,
  String? status,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'reported_by': reportedBy,
      'reported_user': reportedUser,
      'reason': reason,
      'details': details,
      'created_time': createdTime,
      'status': status,
    }.withoutNulls,
  );

  return firestoreData;
}

class ReportsRecordDocumentEquality implements Equality<ReportsRecord> {
  const ReportsRecordDocumentEquality();

  @override
  bool equals(ReportsRecord? e1, ReportsRecord? e2) {
    return e1?.reportedBy == e2?.reportedBy &&
        e1?.reportedUser == e2?.reportedUser &&
        e1?.reason == e2?.reason &&
        e1?.details == e2?.details &&
        e1?.createdTime == e2?.createdTime &&
        e1?.status == e2?.status;
  }

  @override
  int hash(ReportsRecord? e) => const ListEquality().hash([
        e?.reportedBy,
        e?.reportedUser,
        e?.reason,
        e?.details,
        e?.createdTime,
        e?.status,
      ]);

  @override
  bool isValidKey(Object? o) => o is ReportsRecord;
}
