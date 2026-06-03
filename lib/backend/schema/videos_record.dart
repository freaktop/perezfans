import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class VideosRecord extends FirestoreRecord {
  VideosRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "video_url" field.
  String? _videoUrl;
  String get videoUrl => _videoUrl ?? '';
  bool hasVideoUrl() => _videoUrl != null;

  // "video_user" field.
  DocumentReference? _videoUser;
  DocumentReference? get videoUser => _videoUser;
  bool hasVideoUser() => _videoUser != null;

  // "video_description" field.
  String? _videoDescription;
  String get videoDescription => _videoDescription ?? '';
  bool hasVideoDescription() => _videoDescription != null;

  // "video_likes" field.
  List<DocumentReference>? _videoLikes;
  List<DocumentReference> get videoLikes => _videoLikes ?? const [];
  bool hasVideoLikes() => _videoLikes != null;

  // "video_comment_num" field.
  int? _videoCommentNum;
  int get videoCommentNum => _videoCommentNum ?? 0;
  bool hasVideoCommentNum() => _videoCommentNum != null;

  // "video_bookmarks_num" field.
  int? _videoBookmarksNum;
  int get videoBookmarksNum => _videoBookmarksNum ?? 0;
  bool hasVideoBookmarksNum() => _videoBookmarksNum != null;

  // "video_shares_num" field.
  int? _videoSharesNum;
  int get videoSharesNum => _videoSharesNum ?? 0;
  bool hasVideoSharesNum() => _videoSharesNum != null;

  // "video_allow_comments" field.
  bool? _videoAllowComments;
  bool get videoAllowComments => _videoAllowComments ?? false;
  bool hasVideoAllowComments() => _videoAllowComments != null;

  // "video_posted_time" field.
  DateTime? _videoPostedTime;
  DateTime? get videoPostedTime => _videoPostedTime;
  bool hasVideoPostedTime() => _videoPostedTime != null;

  // "promotion_status" field.
  String? _promotionStatus;
  String get promotionStatus => _promotionStatus ?? '';
  bool hasPromotionStatus() => _promotionStatus != null;

  // "video_is_vault" field.
  bool? _videoIsVault;
  bool get videoIsVault => _videoIsVault ?? false;
  bool hasVideoIsVault() => _videoIsVault != null;

  // "video_is_adult" field.
  bool? _videoIsAdult;
  bool get videoIsAdult => _videoIsAdult ?? false;
  bool hasVideoIsAdult() => _videoIsAdult != null;

  // "video_niche" field.
  String? _videoNiche;
  String get videoNiche => _videoNiche ?? '';
  bool hasVideoNiche() => _videoNiche != null;

  // "video_is_repost" field.
  bool? _videoIsRepost;
  bool get videoIsRepost => _videoIsRepost ?? false;
  bool hasVideoIsRepost() => _videoIsRepost != null;

  // "video_repost_of" field.
  DocumentReference? _videoRepostOf;
  DocumentReference? get videoRepostOf => _videoRepostOf;
  bool hasVideoRepostOf() => _videoRepostOf != null;

  // "is_exclusive" field.
  bool? _isExclusive;
  bool get isExclusive => _isExclusive ?? false;
  bool hasIsExclusive() => _isExclusive != null;

  // "requires_subscription" field.
  bool? _requiresSubscription;
  bool get requiresSubscription => _requiresSubscription ?? false;
  bool hasRequiresSubscription() => _requiresSubscription != null;

  // "price" field.
  double? _price;
  double? get price => _price;
  bool hasPrice() => _price != null;

  // "is_live_stream" field.
  bool? _isLiveStream;
  bool get isLiveStream => _isLiveStream ?? false;
  bool hasIsLiveStream() => _isLiveStream != null;

  // "video_type" field.
  String? _videoType;
  String get videoType => _videoType ?? '';
  bool hasVideoType() => _videoType != null;

  // "views" field.
  int? _views;
  int get views => _views ?? 0;
  bool hasViews() => _views != null;

  // "video_sound" field.
  String? _videoSound;
  String get videoSound => _videoSound ?? '';
  bool hasVideoSound() => _videoSound != null;

  void _initializeFields() {
    _videoUrl = snapshotData['video_url'] as String?;
    _videoUser = snapshotData['video_user'] as DocumentReference?;
    _videoDescription = snapshotData['video_description'] as String?;
    _videoLikes = getDataList(snapshotData['video_likes']);
    _videoCommentNum = castToType<int>(snapshotData['video_comment_num']);
    _videoBookmarksNum = castToType<int>(snapshotData['video_bookmarks_num']);
    _videoSharesNum = castToType<int>(snapshotData['video_shares_num']);
    _videoAllowComments = snapshotData['video_allow_comments'] as bool?;
    _videoPostedTime = snapshotData['video_posted_time'] as DateTime?;
    _promotionStatus = snapshotData['promotion_status'] as String?;
    _videoIsVault = snapshotData['video_is_vault'] as bool?;
    _videoIsAdult = snapshotData['video_is_adult'] as bool?;
    _videoNiche = snapshotData['video_niche'] as String?;
    _videoIsRepost = snapshotData['video_is_repost'] as bool?;
    _videoRepostOf = snapshotData['video_repost_of'] as DocumentReference?;
    _isExclusive = snapshotData['is_exclusive'] as bool?;
    _requiresSubscription = snapshotData['requires_subscription'] as bool?;
    _price = castToType<double>(snapshotData['price']);
    _isLiveStream = snapshotData['is_live_stream'] as bool?;
    _videoType = snapshotData['video_type'] as String?;
    _views = castToType<int>(snapshotData['views']);
    _videoSound = snapshotData['video_sound'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('videos');

  static Stream<VideosRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => VideosRecord.fromSnapshot(s));

  static Future<VideosRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => VideosRecord.fromSnapshot(s));

  static VideosRecord fromSnapshot(DocumentSnapshot snapshot) => VideosRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static VideosRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      VideosRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'VideosRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is VideosRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createVideosRecordData({
  String? videoUrl,
  DocumentReference? videoUser,
  String? videoDescription,
  int? videoCommentNum,
  int? videoBookmarksNum,
  int? videoSharesNum,
  bool? videoAllowComments,
  DateTime? videoPostedTime,
  String? promotionStatus,
  bool? videoIsVault,
  bool? videoIsAdult,
  String? videoNiche,
  bool? videoIsRepost,
  DocumentReference? videoRepostOf,
  bool? isExclusive,
  bool? requiresSubscription,
  double? price,
  bool? isLiveStream,
  String? videoType,
  int? views,
  String? videoSound,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'video_url': videoUrl,
      'video_user': videoUser,
      'video_description': videoDescription,
      'video_comment_num': videoCommentNum,
      'video_bookmarks_num': videoBookmarksNum,
      'video_shares_num': videoSharesNum,
      'video_allow_comments': videoAllowComments,
      'video_posted_time': videoPostedTime,
      'promotion_status': promotionStatus,
      'video_is_vault': videoIsVault,
      'video_is_adult': videoIsAdult,
      'video_niche': videoNiche,
      'video_is_repost': videoIsRepost,
      'video_repost_of': videoRepostOf,
      'is_exclusive': isExclusive,
      'requires_subscription': requiresSubscription,
      'price': price,
      'is_live_stream': isLiveStream,
      'video_type': videoType,
      'views': views,
      'video_sound': videoSound,
    }.withoutNulls,
  );

  return firestoreData;
}

class VideosRecordDocumentEquality implements Equality<VideosRecord> {
  const VideosRecordDocumentEquality();

  @override
  bool equals(VideosRecord? e1, VideosRecord? e2) {
    const listEquality = ListEquality();
    return e1?.videoUrl == e2?.videoUrl &&
        e1?.videoUser == e2?.videoUser &&
        e1?.videoDescription == e2?.videoDescription &&
        listEquality.equals(e1?.videoLikes, e2?.videoLikes) &&
        e1?.videoCommentNum == e2?.videoCommentNum &&
        e1?.videoBookmarksNum == e2?.videoBookmarksNum &&
        e1?.videoSharesNum == e2?.videoSharesNum &&
        e1?.videoAllowComments == e2?.videoAllowComments &&
        e1?.videoPostedTime == e2?.videoPostedTime &&
        e1?.promotionStatus == e2?.promotionStatus &&
        e1?.videoIsVault == e2?.videoIsVault &&
        e1?.videoIsAdult == e2?.videoIsAdult &&
        e1?.videoNiche == e2?.videoNiche &&
        e1?.videoIsRepost == e2?.videoIsRepost &&
        e1?.videoRepostOf == e2?.videoRepostOf &&
        e1?.isExclusive == e2?.isExclusive &&
        e1?.requiresSubscription == e2?.requiresSubscription &&
        e1?.price == e2?.price &&
        e1?.isLiveStream == e2?.isLiveStream &&
        e1?.videoType == e2?.videoType &&
        e1?.views == e2?.views &&
        e1?.videoSound == e2?.videoSound;
  }

  @override
  int hash(VideosRecord? e) => const ListEquality().hash([
        e?.videoUrl,
        e?.videoUser,
        e?.videoDescription,
        e?.videoLikes,
        e?.videoCommentNum,
        e?.videoBookmarksNum,
        e?.videoSharesNum,
        e?.videoAllowComments,
        e?.videoPostedTime,
        e?.promotionStatus,
        e?.videoIsVault,
        e?.videoIsAdult,
        e?.videoNiche,
        e?.videoIsRepost,
        e?.videoRepostOf,
        e?.isExclusive,
        e?.requiresSubscription,
        e?.price,
        e?.isLiveStream,
        e?.videoType,
        e?.views,
        e?.videoSound,
      ]);

  @override
  bool isValidKey(Object? o) => o is VideosRecord;
}
