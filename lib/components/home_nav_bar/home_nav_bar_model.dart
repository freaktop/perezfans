import '/flutter_flow/flutter_flow_util.dart';
import 'home_nav_bar_widget.dart' show HomeNavBarWidget;
import 'package:flutter/material.dart';

class HomeNavBarModel extends FlutterFlowModel<HomeNavBarWidget> {
  ///  State fields for stateful widgets in this component.

  bool isDataUploading_uploadMediaOlu = false;
  FFUploadedFile uploadedLocalFile_uploadMediaOlu =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');
  String uploadedFileUrl_uploadMediaOlu = '';

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
