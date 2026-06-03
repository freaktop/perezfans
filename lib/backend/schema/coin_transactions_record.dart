import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CoinTransactionsRecord extends FirestoreRecord {
  CoinTransactionsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  DocumentReference? _user;
  DocumentReference? get user => _user;
  bool hasUser() => _user != null;

  DocumentReference? _recipient;
  DocumentReference? get recipient => _recipient;
  bool hasRecipient() => _recipient != null;

  int? _amount;
  int get amount => _amount ?? 0;
  bool hasAmount() => _amount != null;

  String? _type;
  String get type => _type ?? '';
  bool hasType() => _type != null;

  String? _description;
  String get description => _description ?? '';
  bool hasDescription() => _description != null;

  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  void _initializeFields() {
    _user = snapshotData['user'] as DocumentReference?;
    _recipient = snapshotData['recipient'] as DocumentReference?;
    _amount = castToType<int>(snapshotData['amount']);
    _type = snapshotData['type'] as String?;
    _description = snapshotData['description'] as String?;
    _createdTime = snapshotData['created_time'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('coin_transactions');

  static Stream<CoinTransactionsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => CoinTransactionsRecord.fromSnapshot(s));

  static Future<CoinTransactionsRecord> getDocumentOnce(
          DocumentReference ref) =>
      ref.get().then((s) => CoinTransactionsRecord.fromSnapshot(s));

  static CoinTransactionsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      CoinTransactionsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static CoinTransactionsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      CoinTransactionsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'CoinTransactionsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is CoinTransactionsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createCoinTransactionsRecordData({
  DocumentReference? user,
  DocumentReference? recipient,
  int? amount,
  String? type,
  String? description,
  DateTime? createdTime,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'user': user,
      'recipient': recipient,
      'amount': amount,
      'type': type,
      'description': description,
      'created_time': createdTime,
    }.withoutNulls,
  );
  return firestoreData;
}

class CoinTransactionsRecordDocumentEquality
    implements Equality<CoinTransactionsRecord> {
  const CoinTransactionsRecordDocumentEquality();

  @override
  bool equals(CoinTransactionsRecord? e1, CoinTransactionsRecord? e2) {
    return e1?.user == e2?.user &&
        e1?.recipient == e2?.recipient &&
        e1?.amount == e2?.amount &&
        e1?.type == e2?.type &&
        e1?.description == e2?.description &&
        e1?.createdTime == e2?.createdTime;
  }

  @override
  int hash(CoinTransactionsRecord? e) => const ListEquality().hash([
        e?.user,
        e?.recipient,
        e?.amount,
        e?.type,
        e?.description,
        e?.createdTime,
      ]);

  @override
  bool isValidKey(Object? o) => o is CoinTransactionsRecord;
}
