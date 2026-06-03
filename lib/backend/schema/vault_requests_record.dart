import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class VaultRequestsRecord extends FirestoreRecord {
  VaultRequestsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "requester" field.
  DocumentReference? _requester;
  DocumentReference? get requester => _requester;
  bool hasRequester() => _requester != null;

  // "creator" field.
  DocumentReference? _creator;
  DocumentReference? get creator => _creator;
  bool hasCreator() => _creator != null;

  // "title" field.
  String? _title;
  String get title => _title ?? '';
  bool hasTitle() => _title != null;

  // "description" field.
  String? _description;
  String get description => _description ?? '';
  bool hasDescription() => _description != null;

  // "requirements" field.
  String? _requirements;
  String? get requirements => _requirements;
  bool hasRequirements() => _requirements != null;

  // "budget_min" field.
  double? _budgetMin;
  double? get budgetMin => _budgetMin;
  bool hasBudgetMin() => _budgetMin != null;

  // "budget_max" field.
  double? _budgetMax;
  double? get budgetMax => _budgetMax;
  bool hasBudgetMax() => _budgetMax != null;

  // "status" field.
  String? _status;
  String get status => _status ?? 'pending';
  bool hasStatus() => _status != null;

  // "is_private" field.
  bool? _isPrivate;
  bool get isPrivate => _isPrivate ?? true;
  bool hasIsPrivate() => _isPrivate != null;

  // "created_time" field.
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  // "updated_time" field.
  DateTime? _updatedTime;
  DateTime? get updatedTime => _updatedTime;
  bool hasUpdatedTime() => _updatedTime != null;

  // "fulfilled_post_id" field.
  String? _fulfilledPostId;
  String? get fulfilledPostId => _fulfilledPostId;
  bool hasFulfilledPostId() => _fulfilledPostId != null;

  // "notes" field.
  String? _notes;
  String? get notes => _notes;
  bool hasNotes() => _notes != null;

  void _initializeFields() {
    _requester = snapshotData['requester'] as DocumentReference?;
    _creator = snapshotData['creator'] as DocumentReference?;
    _title = snapshotData['title'] as String?;
    _description = snapshotData['description'] as String?;
    _requirements = snapshotData['requirements'] as String?;
    _budgetMin = castToType<double>(snapshotData['budget_min']);
    _budgetMax = castToType<double>(snapshotData['budget_max']);
    _status = snapshotData['status'] as String?;
    _isPrivate = snapshotData['is_private'] as bool?;
    _createdTime = snapshotData['created_time'] as DateTime?;
    _updatedTime = snapshotData['updated_time'] as DateTime?;
    _fulfilledPostId = snapshotData['fulfilled_post_id'] as String?;
    _notes = snapshotData['notes'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('vault_requests');

  static Stream<VaultRequestsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => VaultRequestsRecord.fromSnapshot(s));

  static Future<VaultRequestsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => VaultRequestsRecord.fromSnapshot(s));

  static VaultRequestsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      VaultRequestsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static VaultRequestsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      VaultRequestsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'VaultRequestsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is VaultRequestsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createVaultRequestsRecordData({
  DocumentReference? requester,
  DocumentReference? creator,
  String? title,
  String? description,
  String? requirements,
  double? budgetMin,
  double? budgetMax,
  String? status,
  bool? isPrivate,
  DateTime? createdTime,
  DateTime? updatedTime,
  String? fulfilledPostId,
  String? notes,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'requester': requester,
      'creator': creator,
      'title': title,
      'description': description,
      'requirements': requirements,
      'budget_min': budgetMin,
      'budget_max': budgetMax,
      'status': status,
      'is_private': isPrivate,
      'created_time': createdTime,
      'updated_time': updatedTime,
      'fulfilled_post_id': fulfilledPostId,
      'notes': notes,
    }.withoutNulls,
  );

  return firestoreData;
}

class VaultRequestsRecordDocumentEquality
    implements Equality<VaultRequestsRecord> {
  const VaultRequestsRecordDocumentEquality();

  @override
  bool equals(VaultRequestsRecord? e1, VaultRequestsRecord? e2) {
    return e1?.requester == e2?.requester &&
        e1?.creator == e2?.creator &&
        e1?.title == e2?.title &&
        e1?.description == e2?.description &&
        e1?.requirements == e2?.requirements &&
        e1?.budgetMin == e2?.budgetMin &&
        e1?.budgetMax == e2?.budgetMax &&
        e1?.status == e2?.status &&
        e1?.isPrivate == e2?.isPrivate &&
        e1?.createdTime == e2?.createdTime &&
        e1?.updatedTime == e2?.updatedTime &&
        e1?.fulfilledPostId == e2?.fulfilledPostId &&
        e1?.notes == e2?.notes;
  }

  @override
  int hash(VaultRequestsRecord? e) => const ListEquality().hash([
        e?.requester,
        e?.creator,
        e?.title,
        e?.description,
        e?.requirements,
        e?.budgetMin,
        e?.budgetMax,
        e?.status,
        e?.isPrivate,
        e?.createdTime,
        e?.updatedTime,
        e?.fulfilledPostId,
        e?.notes,
      ]);

  @override
  bool isValidKey(Object? o) => o is VaultRequestsRecord;
}
