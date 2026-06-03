import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'new_post_widget.dart' show NewPostWidget;
import 'package:flutter/material.dart';

class NewPostModel extends FlutterFlowModel<NewPostWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for DescriptionInput widget.
  FocusNode? descriptionInputFocusNode;
  TextEditingController? descriptionInputTextController;
  String? Function(BuildContext, String?)?
      descriptionInputTextControllerValidator;
  // State field(s) for SwitchAllowComments widget.
  bool? switchAllowCommentsValue;
  // State field(s) for soundTextController widget.
  FocusNode? soundFocusNode;
  TextEditingController? soundTextController;
  String? Function(BuildContext, String?)?
      soundTextControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    descriptionInputFocusNode?.dispose();
    descriptionInputTextController?.dispose();
    soundFocusNode?.dispose();
    soundTextController?.dispose();
  }
}
