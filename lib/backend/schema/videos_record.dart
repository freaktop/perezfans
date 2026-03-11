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
        e1?.videoPostedTime == e2?.videoPostedTime;
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
        e?.videoPostedTime
      ]);

  @override
  bool isValidKey(Object? o) => o is VideosRecord;
}
