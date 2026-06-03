import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class TipsRecord extends FirestoreRecord {
  TipsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "sender" field.
  DocumentReference? _sender;
  DocumentReference? get sender => _sender;
  bool hasSender() => _sender != null;

  // "creator" field.
  DocumentReference? _creator;
  DocumentReference? get creator => _creator;
  bool hasCreator() => _creator != null;

  // "amount" field.
  double? _amount;
  double get amount => _amount ?? 0.0;
  bool hasAmount() => _amount != null;

  // "currency" field.
  String? _currency;
  String get currency => _currency ?? 'USD';
  bool hasCurrency() => _currency != null;

  // "message" field.
  String? _message;
  String? get message => _message;
  bool hasMessage() => _message != null;

  // "created_time" field.
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  // "stripe_payment_intent_id" field.
  String? _stripePaymentIntentId;
  String? get stripePaymentIntentId => _stripePaymentIntentId;
  bool hasStripePaymentIntentId() => _stripePaymentIntentId != null;

  // "status" field.
  String? _status;
  String get status => _status ?? 'completed';
  bool hasStatus() => _status != null;

  void _initializeFields() {
    _sender = snapshotData['sender'] as DocumentReference?;
    _creator = snapshotData['creator'] as DocumentReference?;
    _amount = snapshotData['amount'] as double?;
    _currency = snapshotData['currency'] as String?;
    _message = snapshotData['message'] as String?;
    _createdTime = snapshotData['created_time'] as DateTime?;
    _stripePaymentIntentId =
        snapshotData['stripe_payment_intent_id'] as String?;
    _status = snapshotData['status'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('tips');

  static Stream<TipsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => TipsRecord.fromSnapshot(s));

  static Future<TipsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => TipsRecord.fromSnapshot(s));

  static TipsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      TipsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static TipsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      TipsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'TipsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is TipsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createTipsRecordData({
  DocumentReference? sender,
  DocumentReference? creator,
  double? amount,
  String? currency,
  String? message,
  DateTime? createdTime,
  String? stripePaymentIntentId,
  String? status,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'sender': sender,
      'creator': creator,
      'amount': amount,
      'currency': currency,
      'message': message,
      'created_time': createdTime,
      'stripe_payment_intent_id': stripePaymentIntentId,
      'status': status,
    }.withoutNulls,
  );

  return firestoreData;
}

class TipsRecordDocumentEquality implements Equality<TipsRecord> {
  const TipsRecordDocumentEquality();

  @override
  bool equals(TipsRecord? e1, TipsRecord? e2) {
    return e1?.sender == e2?.sender &&
        e1?.creator == e2?.creator &&
        e1?.amount == e2?.amount &&
        e1?.currency == e2?.currency &&
        e1?.message == e2?.message &&
        e1?.createdTime == e2?.createdTime &&
        e1?.stripePaymentIntentId == e2?.stripePaymentIntentId &&
        e1?.status == e2?.status;
  }

  @override
  int hash(TipsRecord? e) => const ListEquality().hash([
        e?.sender,
        e?.creator,
        e?.amount,
        e?.currency,
        e?.message,
        e?.createdTime,
        e?.stripePaymentIntentId,
        e?.status,
      ]);

  @override
  bool isValidKey(Object? o) => o is TipsRecord;
}
