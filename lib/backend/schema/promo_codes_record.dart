import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PromoCodesRecord extends FirestoreRecord {
  PromoCodesRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  String? _code;
  String get code => _code ?? '';
  bool hasCode() => _code != null;

  int? _discountPercent;
  int get discountPercent => _discountPercent ?? 0;
  bool hasDiscountPercent() => _discountPercent != null;

  int? _maxUses;
  int get maxUses => _maxUses ?? 0;
  bool hasMaxUses() => _maxUses != null;

  int? _currentUses;
  int get currentUses => _currentUses ?? 0;
  bool hasCurrentUses() => _currentUses != null;

  bool? _isActive;
  bool get isActive => _isActive ?? false;
  bool hasIsActive() => _isActive != null;

  DateTime? _expiresAt;
  DateTime? get expiresAt => _expiresAt;
  bool hasExpiresAt() => _expiresAt != null;

  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  void _initializeFields() {
    _code = snapshotData['code'] as String?;
    _discountPercent = castToType<int>(snapshotData['discount_percent']);
    _maxUses = castToType<int>(snapshotData['max_uses']);
    _currentUses = castToType<int>(snapshotData['current_uses']);
    _isActive = snapshotData['is_active'] as bool?;
    _expiresAt = snapshotData['expires_at'] as DateTime?;
    _createdTime = snapshotData['created_time'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('promo_codes');

  static Stream<PromoCodesRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => PromoCodesRecord.fromSnapshot(s));

  static Future<PromoCodesRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => PromoCodesRecord.fromSnapshot(s));

  static PromoCodesRecord fromSnapshot(DocumentSnapshot snapshot) =>
      PromoCodesRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static PromoCodesRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      PromoCodesRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'PromoCodesRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is PromoCodesRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createPromoCodesRecordData({
  String? code,
  int? discountPercent,
  int? maxUses,
  int? currentUses,
  bool? isActive,
  DateTime? expiresAt,
  DateTime? createdTime,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'code': code,
      'discount_percent': discountPercent,
      'max_uses': maxUses,
      'current_uses': currentUses,
      'is_active': isActive,
      'expires_at': expiresAt,
      'created_time': createdTime,
    }.withoutNulls,
  );
  return firestoreData;
}

class PromoCodesRecordDocumentEquality
    implements Equality<PromoCodesRecord> {
  const PromoCodesRecordDocumentEquality();

  @override
  bool equals(PromoCodesRecord? e1, PromoCodesRecord? e2) {
    return e1?.code == e2?.code &&
        e1?.discountPercent == e2?.discountPercent &&
        e1?.maxUses == e2?.maxUses &&
        e1?.currentUses == e2?.currentUses &&
        e1?.isActive == e2?.isActive &&
        e1?.expiresAt == e2?.expiresAt &&
        e1?.createdTime == e2?.createdTime;
  }

  @override
  int hash(PromoCodesRecord? e) => const ListEquality().hash([
        e?.code,
        e?.discountPercent,
        e?.maxUses,
        e?.currentUses,
        e?.isActive,
        e?.expiresAt,
        e?.createdTime,
      ]);

  @override
  bool isValidKey(Object? o) => o is PromoCodesRecord;
}
