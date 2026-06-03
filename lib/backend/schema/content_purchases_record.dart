import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ContentPurchasesRecord extends FirestoreRecord {
  ContentPurchasesRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "user" field.
  DocumentReference? _user;
  DocumentReference? get user => _user;
  bool hasUser() => _user != null;

  // "content_id" field.
  String? _contentId;
  String get contentId => _contentId ?? '';
  bool hasContentId() => _contentId != null;

  // "content_type" field.
  String? _contentType;
  String get contentType => _contentType ?? '';
  bool hasContentType() => _contentType != null;

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
  String get currency => _currency ?? 'usd';
  bool hasCurrency() => _currency != null;

  // "purchased_time" field.
  DateTime? _purchasedTime;
  DateTime? get purchasedTime => _purchasedTime;
  bool hasPurchasedTime() => _purchasedTime != null;

  // "stripe_payment_id" field.
  String? _stripePaymentId;
  String? get stripePaymentId => _stripePaymentId;
  bool hasStripePaymentId() => _stripePaymentId != null;

  void _initializeFields() {
    _user = snapshotData['user'] as DocumentReference?;
    _contentId = snapshotData['content_id'] as String?;
    _contentType = snapshotData['content_type'] as String?;
    _creator = snapshotData['creator'] as DocumentReference?;
    _amount = castToType<double>(snapshotData['amount']);
    _currency = snapshotData['currency'] as String?;
    _purchasedTime = snapshotData['purchased_time'] as DateTime?;
    _stripePaymentId = snapshotData['stripe_payment_id'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('content_purchases');

  static Stream<ContentPurchasesRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => ContentPurchasesRecord.fromSnapshot(s));

  static Future<ContentPurchasesRecord> getDocumentOnce(
          DocumentReference ref) =>
      ref.get().then((s) => ContentPurchasesRecord.fromSnapshot(s));

  static ContentPurchasesRecord fromSnapshot(DocumentSnapshot snapshot) =>
      ContentPurchasesRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static ContentPurchasesRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      ContentPurchasesRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'ContentPurchasesRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is ContentPurchasesRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createContentPurchasesRecordData({
  DocumentReference? user,
  String? contentId,
  String? contentType,
  DocumentReference? creator,
  double? amount,
  String? currency,
  DateTime? purchasedTime,
  String? stripePaymentId,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'user': user,
      'content_id': contentId,
      'content_type': contentType,
      'creator': creator,
      'amount': amount,
      'currency': currency,
      'purchased_time': purchasedTime,
      'stripe_payment_id': stripePaymentId,
    }.withoutNulls,
  );

  return firestoreData;
}

class ContentPurchasesRecordDocumentEquality
    implements Equality<ContentPurchasesRecord> {
  const ContentPurchasesRecordDocumentEquality();

  @override
  bool equals(ContentPurchasesRecord? e1, ContentPurchasesRecord? e2) {
    return e1?.user == e2?.user &&
        e1?.contentId == e2?.contentId &&
        e1?.contentType == e2?.contentType &&
        e1?.creator == e2?.creator &&
        e1?.amount == e2?.amount &&
        e1?.currency == e2?.currency &&
        e1?.purchasedTime == e2?.purchasedTime &&
        e1?.stripePaymentId == e2?.stripePaymentId;
  }

  @override
  int hash(ContentPurchasesRecord? e) => const ListEquality().hash([
        e?.user,
        e?.contentId,
        e?.contentType,
        e?.creator,
        e?.amount,
        e?.currency,
        e?.purchasedTime,
        e?.stripePaymentId
      ]);

  @override
  bool isValidKey(Object? o) => o is ContentPurchasesRecord;
}
