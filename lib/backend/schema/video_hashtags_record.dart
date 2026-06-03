import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class VideoHashtagsRecord extends FirestoreRecord {
  VideoHashtagsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "hashtag" field.
  String? _hashtag;
  String get hashtag => _hashtag ?? '';
  bool hasHashtag() => _hashtag != null;

  // "video_count" field.
  int? _videoCount;
  int get videoCount => _videoCount ?? 0;
  bool hasVideoCount() => _videoCount != null;

  // "last_used" field.
  DateTime? _lastUsed;
  DateTime? get lastUsed => _lastUsed;
  bool hasLastUsed() => _lastUsed != null;

  void _initializeFields() {
    _hashtag = snapshotData['hashtag'] as String?;
    _videoCount = castToType<int>(snapshotData['video_count']);
    _lastUsed = snapshotData['last_used'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('video_hashtags');

  static Stream<VideoHashtagsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => VideoHashtagsRecord.fromSnapshot(s));

  static Future<VideoHashtagsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => VideoHashtagsRecord.fromSnapshot(s));

  static VideoHashtagsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      VideoHashtagsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static VideoHashtagsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      VideoHashtagsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'VideoHashtagsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is VideoHashtagsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createVideoHashtagsRecordData({
  String? hashtag,
  int? videoCount,
  DateTime? lastUsed,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'hashtag': hashtag,
      'video_count': videoCount,
      'last_used': lastUsed,
    }.withoutNulls,
  );

  return firestoreData;
}

class VideoHashtagsRecordDocumentEquality
    implements Equality<VideoHashtagsRecord> {
  const VideoHashtagsRecordDocumentEquality();

  @override
  bool equals(VideoHashtagsRecord? e1, VideoHashtagsRecord? e2) {
    return e1?.hashtag == e2?.hashtag &&
        e1?.videoCount == e2?.videoCount &&
        e1?.lastUsed == e2?.lastUsed;
  }

  @override
  int hash(VideoHashtagsRecord? e) =>
      const ListEquality().hash([e?.hashtag, e?.videoCount, e?.lastUsed]);

  @override
  bool isValidKey(Object? o) => o is VideoHashtagsRecord;
}
