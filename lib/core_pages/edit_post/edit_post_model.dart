import '/flutter_flow/flutter_flow_util.dart';
import 'edit_post_widget.dart' show EditPostWidget;
import 'package:flutter/material.dart';

class EditPostModel extends FlutterFlowModel<EditPostWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for DescriptionInput widget.
  FocusNode? descriptionInputFocusNode;
  TextEditingController? descriptionInputTextController;
  String? Function(BuildContext, String?)?
      descriptionInputTextControllerValidator;
  // State field(s) for SwitchAllowComments widget.
  bool? switchAllowCommentsValue;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    descriptionInputFocusNode?.dispose();
    descriptionInputTextController?.dispose();
  }
}
