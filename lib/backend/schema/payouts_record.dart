import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PayoutsRecord extends FirestoreRecord {
  PayoutsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  DocumentReference? _creator;
  DocumentReference? get creator => _creator;
  bool hasCreator() => _creator != null;

  double? _amount;
  double get amount => _amount ?? 0;
  bool hasAmount() => _amount != null;

  String? _currency;
  String get currency => _currency ?? 'usd';
  bool hasCurrency() => _currency != null;

  String? _status;
  String get status => _status ?? '';
  bool hasStatus() => _status != null;

  String? _stripePayoutId;
  String get stripePayoutId => _stripePayoutId ?? '';
  bool hasStripePayoutId() => _stripePayoutId != null;

  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  void _initializeFields() {
    _creator = snapshotData['creator'] as DocumentReference?;
    _amount = castToType<double>(snapshotData['amount']);
    _currency = snapshotData['currency'] as String?;
    _status = snapshotData['status'] as String?;
    _stripePayoutId = snapshotData['stripe_payout_id'] as String?;
    _createdTime = snapshotData['created_time'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('payouts');

  static Stream<PayoutsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => PayoutsRecord.fromSnapshot(s));

  static Future<PayoutsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => PayoutsRecord.fromSnapshot(s));

  static PayoutsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      PayoutsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static PayoutsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      PayoutsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'PayoutsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is PayoutsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createPayoutsRecordData({
  DocumentReference? creator,
  double? amount,
  String? currency,
  String? status,
  String? stripePayoutId,
  DateTime? createdTime,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'creator': creator,
      'amount': amount,
      'currency': currency,
      'status': status,
      'stripe_payout_id': stripePayoutId,
      'created_time': createdTime,
    }.withoutNulls,
  );

  return firestoreData;
}

class PayoutsRecordDocumentEquality implements Equality<PayoutsRecord> {
  const PayoutsRecordDocumentEquality();

  @override
  bool equals(PayoutsRecord? e1, PayoutsRecord? e2) {
    return e1?.creator == e2?.creator &&
        e1?.amount == e2?.amount &&
        e1?.currency == e2?.currency &&
        e1?.status == e2?.status &&
        e1?.stripePayoutId == e2?.stripePayoutId &&
        e1?.createdTime == e2?.createdTime;
  }

  @override
  int hash(PayoutsRecord? e) => const ListEquality().hash([
        e?.creator,
        e?.amount,
        e?.currency,
        e?.status,
        e?.stripePayoutId,
        e?.createdTime,
      ]);

  @override
  bool isValidKey(Object? o) => o is PayoutsRecord;
}
