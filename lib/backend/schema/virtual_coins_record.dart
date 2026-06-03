import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VirtualCoinsRecord extends FirestoreRecord {
  VirtualCoinsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  DocumentReference? _user;
  DocumentReference? get user => _user;
  bool hasUser() => _user != null;

  int? _balance;
  int get balance => _balance ?? 0;
  bool hasBalance() => _balance != null;

  DateTime? _lastUpdated;
  DateTime? get lastUpdated => _lastUpdated;
  bool hasLastUpdated() => _lastUpdated != null;

  void _initializeFields() {
    _user = snapshotData['user'] as DocumentReference?;
    _balance = castToType<int>(snapshotData['balance']);
    _lastUpdated = snapshotData['last_updated'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('virtual_coins');

  static Stream<VirtualCoinsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => VirtualCoinsRecord.fromSnapshot(s));

  static Future<VirtualCoinsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => VirtualCoinsRecord.fromSnapshot(s));

  static VirtualCoinsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      VirtualCoinsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static VirtualCoinsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      VirtualCoinsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'VirtualCoinsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is VirtualCoinsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createVirtualCoinsRecordData({
  DocumentReference? user,
  int? balance,
  DateTime? lastUpdated,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'user': user,
      'balance': balance,
      'last_updated': lastUpdated,
    }.withoutNulls,
  );
  return firestoreData;
}

class VirtualCoinsRecordDocumentEquality
    implements Equality<VirtualCoinsRecord> {
  const VirtualCoinsRecordDocumentEquality();

  @override
  bool equals(VirtualCoinsRecord? e1, VirtualCoinsRecord? e2) {
    return e1?.user == e2?.user &&
        e1?.balance == e2?.balance &&
        e1?.lastUpdated == e2?.lastUpdated;
  }

  @override
  int hash(VirtualCoinsRecord? e) => const ListEquality().hash([
        e?.user,
        e?.balance,
        e?.lastUpdated,
      ]);

  @override
  bool isValidKey(Object? o) => o is VirtualCoinsRecord;
}
