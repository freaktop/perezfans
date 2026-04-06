import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';

/// Creates a new feed item for the current user pointing at the same media as [source].
Future<void> createRepostForVideo(
  BuildContext context, {
  required VideosRecord source,
}) async {
  if (currentUserReference == null) return;
  if (source.videoUser?.path == currentUserReference!.path) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('You can’t repost your own video.')),
    );
    return;
  }
  if (source.videoIsVault) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Vault content can’t be reposted.')),
    );
    return;
  }
  if (source.videoUrl.isEmpty) return;

  final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Repost this video?'),
          content: const Text(
            'Your followers will see it in the For You feed with your name.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Repost'),
            ),
          ],
        ),
      ) ??
      false;
  if (!ok || !context.mounted) return;

  try {
    await VideosRecord.collection.doc().set(
          createVideosRecordData(
            videoUrl: source.videoUrl,
            videoUser: currentUserReference,
            videoDescription: source.videoDescription,
            videoCommentNum: 0,
            videoBookmarksNum: 0,
            videoSharesNum: 0,
            videoAllowComments: source.videoAllowComments,
            videoPostedTime: getCurrentTimestamp,
            videoIsAdult: source.videoIsAdult,
            videoIsVault: false,
            videoNiche: source.videoNiche.isNotEmpty ? source.videoNiche : null,
            videoIsRepost: true,
            videoRepostOf: source.reference,
          ),
        );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reposted — it will appear in the feed.')),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not repost: $e')),
      );
    }
  }
}
