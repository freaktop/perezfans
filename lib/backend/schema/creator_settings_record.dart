import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class CreatorSettingsRecord extends FirestoreRecord {
  CreatorSettingsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "user" field.
  DocumentReference? _user;
  DocumentReference? get user => _user;
  bool hasUser() => _user != null;

  // "monthly_price" field.
  double? _monthlyPrice;
  double get monthlyPrice => _monthlyPrice ?? 0;
  bool hasMonthlyPrice() => _monthlyPrice != null;

  // "bronze_price" field.
  double? _bronzePrice;
  double get bronzePrice => _bronzePrice ?? 0;
  bool hasBronzePrice() => _bronzePrice != null;

  // "silver_price" field.
  double? _silverPrice;
  double get silverPrice => _silverPrice ?? 0;
  bool hasSilverPrice() => _silverPrice != null;

  // "gold_price" field.
  double? _goldPrice;
  double get goldPrice => _goldPrice ?? 0;
  bool hasGoldPrice() => _goldPrice != null;

  // "bronze_name" field.
  String? _bronzeName;
  String get bronzeName => _bronzeName ?? 'Bronze';
  bool hasBronzeName() => _bronzeName != null;

  // "silver_name" field.
  String? _silverName;
  String get silverName => _silverName ?? 'Silver';
  bool hasSilverName() => _silverName != null;

  // "gold_name" field.
  String? _goldName;
  String get goldName => _goldName ?? 'Gold';
  bool hasGoldName() => _goldName != null;

  // "currency" field.
  String? _currency;
  String get currency => _currency ?? 'usd';
  bool hasCurrency() => _currency != null;

  // "is_active" field.
  bool? _isActive;
  bool get isActive => _isActive ?? false;
  bool hasIsActive() => _isActive != null;

  // "stripe_account_id" field.
  String? _stripeAccountId;
  String get stripeAccountId => _stripeAccountId ?? '';
  bool hasStripeAccountId() => _stripeAccountId != null;

  // "stripe_onboarding_complete" field.
  bool? _stripeOnboardingComplete;
  bool get stripeOnboardingComplete => _stripeOnboardingComplete ?? false;
  bool hasStripeOnboardingComplete() => _stripeOnboardingComplete != null;

  // "subscriber_count" field.
  int? _subscriberCount;
  int get subscriberCount => _subscriberCount ?? 0;
  bool hasSubscriberCount() => _subscriberCount != null;

  // "created_time" field.
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  void _initializeFields() {
    _user = snapshotData['user'] as DocumentReference?;
    _monthlyPrice = castToType<double>(snapshotData['monthly_price']);
    _bronzePrice = castToType<double>(snapshotData['bronze_price']);
    _silverPrice = castToType<double>(snapshotData['silver_price']);
    _goldPrice = castToType<double>(snapshotData['gold_price']);
    _bronzeName = snapshotData['bronze_name'] as String?;
    _silverName = snapshotData['silver_name'] as String?;
    _goldName = snapshotData['gold_name'] as String?;
    _currency = snapshotData['currency'] as String?;
    _isActive = snapshotData['is_active'] as bool?;
    _stripeAccountId = snapshotData['stripe_account_id'] as String?;
    _stripeOnboardingComplete =
        snapshotData['stripe_onboarding_complete'] as bool?;
    _subscriberCount = castToType<int>(snapshotData['subscriber_count']);
    _createdTime = snapshotData['created_time'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('creator_settings');

  static Stream<CreatorSettingsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => CreatorSettingsRecord.fromSnapshot(s));

  static Future<CreatorSettingsRecord> getDocumentOnce(
          DocumentReference ref) =>
      ref.get().then((s) => CreatorSettingsRecord.fromSnapshot(s));

  static CreatorSettingsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      CreatorSettingsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static CreatorSettingsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      CreatorSettingsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'CreatorSettingsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is CreatorSettingsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createCreatorSettingsRecordData({
  DocumentReference? user,
  double? monthlyPrice,
  double? bronzePrice,
  double? silverPrice,
  double? goldPrice,
  String? bronzeName,
  String? silverName,
  String? goldName,
  String? currency,
  bool? isActive,
  String? stripeAccountId,
  bool? stripeOnboardingComplete,
  int? subscriberCount,
  DateTime? createdTime,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'user': user,
      'monthly_price': monthlyPrice,
      'bronze_price': bronzePrice,
      'silver_price': silverPrice,
      'gold_price': goldPrice,
      'bronze_name': bronzeName,
      'silver_name': silverName,
      'gold_name': goldName,
      'currency': currency,
      'is_active': isActive,
      'stripe_account_id': stripeAccountId,
      'stripe_onboarding_complete': stripeOnboardingComplete,
      'subscriber_count': subscriberCount,
      'created_time': createdTime,
    }.withoutNulls,
  );

  return firestoreData;
}

class CreatorSettingsRecordDocumentEquality
    implements Equality<CreatorSettingsRecord> {
  const CreatorSettingsRecordDocumentEquality();

  @override
  bool equals(CreatorSettingsRecord? e1, CreatorSettingsRecord? e2) {
    return e1?.user == e2?.user &&
        e1?.monthlyPrice == e2?.monthlyPrice &&
        e1?.bronzePrice == e2?.bronzePrice &&
        e1?.silverPrice == e2?.silverPrice &&
        e1?.goldPrice == e2?.goldPrice &&
        e1?.bronzeName == e2?.bronzeName &&
        e1?.silverName == e2?.silverName &&
        e1?.goldName == e2?.goldName &&
        e1?.currency == e2?.currency &&
        e1?.isActive == e2?.isActive &&
        e1?.stripeAccountId == e2?.stripeAccountId &&
        e1?.stripeOnboardingComplete == e2?.stripeOnboardingComplete &&
        e1?.subscriberCount == e2?.subscriberCount &&
        e1?.createdTime == e2?.createdTime;
  }

  @override
  int hash(CreatorSettingsRecord? e) => const ListEquality().hash([
        e?.user,
        e?.monthlyPrice,
        e?.bronzePrice,
        e?.silverPrice,
        e?.goldPrice,
        e?.bronzeName,
        e?.silverName,
        e?.goldName,
        e?.currency,
        e?.isActive,
        e?.stripeAccountId,
        e?.stripeOnboardingComplete,
        e?.subscriberCount,
        e?.createdTime,
      ]);

  @override
  bool isValidKey(Object? o) => o is CreatorSettingsRecord;
}
