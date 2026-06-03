import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UsersRecord extends FirestoreRecord {
  UsersRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "email" field.
  String? _email;
  String get email => _email ?? '';
  bool hasEmail() => _email != null;

  // "display_name" field.
  String? _displayName;
  String get displayName => _displayName ?? '';
  bool hasDisplayName() => _displayName != null;

  // "photo_url" field.
  String? _photoUrl;
  String get photoUrl => _photoUrl ?? '';
  bool hasPhotoUrl() => _photoUrl != null;

  // "uid" field.
  String? _uid;
  String get uid => _uid ?? '';
  bool hasUid() => _uid != null;

  // "created_time" field.
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  // "phone_number" field.
  String? _phoneNumber;
  String get phoneNumber => _phoneNumber ?? '';
  bool hasPhoneNumber() => _phoneNumber != null;

  // "user_bookmarks" field.
  List<DocumentReference>? _userBookmarks;
  List<DocumentReference> get userBookmarks => _userBookmarks ?? const [];
  bool hasUserBookmarks() => _userBookmarks != null;

  // "following" field.
  List<DocumentReference>? _following;
  List<DocumentReference> get following => _following ?? const [];
  bool hasFollowing() => _following != null;

  // "username" field.
  String? _username;
  String get username => _username ?? '';
  bool hasUsername() => _username != null;

  // "user_bio" field.
  String? _userBio;
  String get userBio => _userBio ?? '';
  bool hasUserBio() => _userBio != null;

  // "followers" field.
  List<DocumentReference>? _followers;
  List<DocumentReference> get followers => _followers ?? const [];
  bool hasFollowers() => _followers != null;

  // "total_likes" field.
  int? _totalLikes;
  int get totalLikes => _totalLikes ?? 0;
  bool hasTotalLikes() => _totalLikes != null;

  // "role" field.
  String? _role;
  String get role => _role ?? '';
  bool hasRole() => _role != null;

  // "referral_code" field.
  String? _referralCode;
  String get referralCode => _referralCode ?? '';
  bool hasReferralCode() => _referralCode != null;

  // "referred_by" field.
  DocumentReference? _referredBy;
  DocumentReference? get referredBy => _referredBy;
  bool hasReferredBy() => _referredBy != null;

  // "fcm_tokens" field.
  List<String>? _fcmTokens;
  List<String> get fcmTokens => _fcmTokens ?? const [];
  bool hasFcmTokens() => _fcmTokens != null;

  // "suspended" field.
  bool? _suspended;
  bool get suspended => _suspended ?? false;
  bool hasSuspended() => _suspended != null;

  // "suspension_reason" field.
  String? _suspensionReason;
  String get suspensionReason => _suspensionReason ?? '';
  bool hasSuspensionReason() => _suspensionReason != null;

  void _initializeFields() {
    _email = snapshotData['email'] as String?;
    _displayName = snapshotData['display_name'] as String?;
    _photoUrl = snapshotData['photo_url'] as String?;
    _uid = snapshotData['uid'] as String?;
    _createdTime = snapshotData['created_time'] as DateTime?;
    _phoneNumber = snapshotData['phone_number'] as String?;
    _userBookmarks = getDataList(snapshotData['user_bookmarks']);
    _following = getDataList(snapshotData['following']);
    _username = snapshotData['username'] as String?;
    _userBio = snapshotData['user_bio'] as String?;
    _followers = getDataList(snapshotData['followers']);
    _totalLikes = castToType<int>(snapshotData['total_likes']);
    _role = snapshotData['role'] as String?;
    _referralCode = snapshotData['referral_code'] as String?;
    _referredBy = snapshotData['referred_by'] as DocumentReference?;
    _fcmTokens = castToType<List<String>>(snapshotData['fcm_tokens']);
    _suspended = snapshotData['suspended'] as bool?;
    _suspensionReason = snapshotData['suspension_reason'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('users');

  static Stream<UsersRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => UsersRecord.fromSnapshot(s));

  static Future<UsersRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => UsersRecord.fromSnapshot(s));

  static UsersRecord fromSnapshot(DocumentSnapshot snapshot) => UsersRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static UsersRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      UsersRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'UsersRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is UsersRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createUsersRecordData({
  String? email,
  String? displayName,
  String? photoUrl,
  String? uid,
  DateTime? createdTime,
  String? phoneNumber,
  String? username,
  String? userBio,
  int? totalLikes,
  String? role,
  String? referralCode,
  DocumentReference? referredBy,
  List<String>? fcmTokens,
  bool? suspended,
  String? suspensionReason,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'email': email,
      'display_name': displayName,
      'photo_url': photoUrl,
      'uid': uid,
      'created_time': createdTime,
      'phone_number': phoneNumber,
      'username': username,
      'user_bio': userBio,
      'total_likes': totalLikes,
      'role': role,
      'referral_code': referralCode,
      'referred_by': referredBy,
      'fcm_tokens': fcmTokens,
      'suspended': suspended,
      'suspension_reason': suspensionReason,
    }.withoutNulls,
  );

  return firestoreData;
}

class UsersRecordDocumentEquality implements Equality<UsersRecord> {
  const UsersRecordDocumentEquality();

  @override
  bool equals(UsersRecord? e1, UsersRecord? e2) {
    const listEquality = ListEquality();
    return e1?.email == e2?.email &&
        e1?.displayName == e2?.displayName &&
        e1?.photoUrl == e2?.photoUrl &&
        e1?.uid == e2?.uid &&
        e1?.createdTime == e2?.createdTime &&
        e1?.phoneNumber == e2?.phoneNumber &&
        listEquality.equals(e1?.userBookmarks, e2?.userBookmarks) &&
        listEquality.equals(e1?.following, e2?.following) &&
        e1?.username == e2?.username &&
        e1?.userBio == e2?.userBio &&
        listEquality.equals(        e1?.followers, e2?.followers) &&
        e1?.totalLikes == e2?.totalLikes &&
        e1?.role == e2?.role &&
        e1?.referralCode == e2?.referralCode &&
        e1?.referredBy == e2?.referredBy &&
        const ListEquality().equals(e1?.fcmTokens, e2?.fcmTokens) &&
        e1?.suspended == e2?.suspended &&
        e1?.suspensionReason == e2?.suspensionReason;
  }

  @override
  int hash(UsersRecord? e) => const ListEquality().hash([
        e?.email,
        e?.displayName,
        e?.photoUrl,
        e?.uid,
        e?.createdTime,
        e?.phoneNumber,
        e?.userBookmarks,
        e?.following,
        e?.username,
        e?.userBio,
        e?.followers,
        e?.totalLikes,
        e?.role,
        e?.referralCode,
        e?.referredBy,
        e?.fcmTokens,
        e?.suspended,
        e?.suspensionReason,
      ]);

  @override
  bool isValidKey(Object? o) => o is UsersRecord;
}
