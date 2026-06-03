import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class SubscriptionsRecord extends FirestoreRecord {
  SubscriptionsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "subscriber" field.
  DocumentReference? _subscriber;
  DocumentReference? get subscriber => _subscriber;
  bool hasSubscriber() => _subscriber != null;

  // "creator" field.
  DocumentReference? _creator;
  DocumentReference? get creator => _creator;
  bool hasCreator() => _creator != null;

  // "start_date" field.
  DateTime? _startDate;
  DateTime? get startDate => _startDate;
  bool hasStartDate() => _startDate != null;

  // "end_date" field.
  DateTime? _endDate;
  DateTime? get endDate => _endDate;
  bool hasEndDate() => _endDate != null;

  // "status" field.
  String? _status;
  String get status => _status ?? '';
  bool hasStatus() => _status != null;

  // "tier" field.
  String? _tier;
  String get tier => _tier ?? '';
  bool hasTier() => _tier != null;

  // "stripe_subscription_id" field.
  String? _stripeSubscriptionId;
  String get stripeSubscriptionId => _stripeSubscriptionId ?? '';
  bool hasStripeSubscriptionId() => _stripeSubscriptionId != null;

  // "auto_renew" field.
  bool? _autoRenew;
  bool get autoRenew => _autoRenew ?? true;
  bool hasAutoRenew() => _autoRenew != null;

  // "created_time" field.
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  void _initializeFields() {
    _subscriber = snapshotData['subscriber'] as DocumentReference?;
    _creator = snapshotData['creator'] as DocumentReference?;
    _startDate = snapshotData['start_date'] as DateTime?;
    _endDate = snapshotData['end_date'] as DateTime?;
    _status = snapshotData['status'] as String?;
    _tier = snapshotData['tier'] as String?;
    _stripeSubscriptionId = snapshotData['stripe_subscription_id'] as String?;
    _autoRenew = snapshotData['auto_renew'] as bool?;
    _createdTime = snapshotData['created_time'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('subscriptions');

  static Stream<SubscriptionsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => SubscriptionsRecord.fromSnapshot(s));

  static Future<SubscriptionsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => SubscriptionsRecord.fromSnapshot(s));

  static SubscriptionsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      SubscriptionsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static SubscriptionsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      SubscriptionsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'SubscriptionsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is SubscriptionsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createSubscriptionsRecordData({
  DocumentReference? subscriber,
  DocumentReference? creator,
  DateTime? startDate,
  DateTime? endDate,
  String? status,
  String? tier,
  String? stripeSubscriptionId,
  bool? autoRenew,
  DateTime? createdTime,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'subscriber': subscriber,
      'creator': creator,
      'start_date': startDate,
      'end_date': endDate,
      'status': status,
      'tier': tier,
      'stripe_subscription_id': stripeSubscriptionId,
      'auto_renew': autoRenew,
      'created_time': createdTime,
    }.withoutNulls,
  );

  return firestoreData;
}

class SubscriptionsRecordDocumentEquality
    implements Equality<SubscriptionsRecord> {
  const SubscriptionsRecordDocumentEquality();

  @override
  bool equals(SubscriptionsRecord? e1, SubscriptionsRecord? e2) {
    return e1?.subscriber == e2?.subscriber &&
        e1?.creator == e2?.creator &&
        e1?.startDate == e2?.startDate &&
        e1?.endDate == e2?.endDate &&
        e1?.status == e2?.status &&
        e1?.tier == e2?.tier &&
        e1?.stripeSubscriptionId == e2?.stripeSubscriptionId &&
        e1?.autoRenew == e2?.autoRenew &&
        e1?.createdTime == e2?.createdTime;
  }

  @override
  int hash(SubscriptionsRecord? e) => const ListEquality().hash([
        e?.subscriber,
        e?.creator,
        e?.startDate,
        e?.endDate,
        e?.status,
        e?.tier,
        e?.stripeSubscriptionId,
        e?.autoRenew,
        e?.createdTime,
      ]);

  @override
  bool isValidKey(Object? o) => o is SubscriptionsRecord;
}
