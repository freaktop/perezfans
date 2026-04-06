import '/backend/firebase_storage/storage.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/upload_data.dart';
import '/index.dart';
import 'package:flutter/material.dart';

/// Pick a video, upload to Storage, set [FFAppState.newVideo], then open [NewPostWidget].
Future<void> pickUploadVideoAndOpenNewPost(BuildContext context) async {
  final selectedMedia = await selectMediaWithSourceBottomSheet(
    context: context,
    allowPhoto: false,
    allowVideo: true,
  );
  if (selectedMedia == null ||
      !selectedMedia.every((m) => validateFileFormat(m.storagePath, context))) {
    return;
  }

  showUploadMessage(context, 'Uploading video...', showLoading: true);
  try {
    final downloadUrls = (await Future.wait(
      selectedMedia.map((m) async => await uploadData(m.storagePath, m.bytes)),
    ))
        .where((u) => u != null)
        .map((u) => u!)
        .toList();

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    if (downloadUrls.length != selectedMedia.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Upload failed. Please try again.')),
      );
      return;
    }

    FFAppState().newVideo = downloadUrls.first;
    FFAppState().update(() {});

    if (context.mounted) {
      context.pushNamed(NewPostWidget.routeName);
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    }
  }
}
