import '/backend/backend.dart';

class TrendingService {
  /// Extracts hashtags from a description and returns the description without them.
  static String extractHashtags(String description) {
    final regex = RegExp(r'#\w+');
    return description.replaceAll(regex, '').trim();
  }

  /// Parses hashtags from a description, returning them as lowercase strings.
  static List<String> parseHashtags(String description) {
    final regex = RegExp(r'#(\w+)');
    final matches = regex.allMatches(description);
    return matches.map((m) => m.group(1)!.toLowerCase()).toList();
  }

  /// Updates the video_hashtags collection for the given list of hashtag strings.
  static Future<void> indexHashtags(List<String> tags) async {
    final batch = FirebaseFirestore.instance.batch();
    final now = DateTime.now();

    for (final tag in tags) {
      final ref =
          VideoHashtagsRecord.collection.doc(tag);
      final existing = await ref.get();
      if (existing.exists) {
        final currentCount =
            (existing.data() as Map<String, dynamic>?)?['video_count'] as int? ??
                0;
        batch.update(ref, {
          'video_count': currentCount + 1,
          'last_used': now,
        });
      } else {
        batch.set(ref, {
          'hashtag': tag,
          'video_count': 1,
          'last_used': now,
        });
      }
    }

    await batch.commit();
  }
}
