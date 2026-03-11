import '/flutter_flow/flutter_flow_util.dart';
import 'comments_widget.dart' show CommentsWidget;
import 'package:flutter/material.dart';

class CommentsModel extends FlutterFlowModel<CommentsWidget> {
  ///  State fields for stateful widgets in this component.

  final formKey = GlobalKey<FormState>();
  // State field(s) for CommentInput widget.
  FocusNode? commentInputFocusNode;
  TextEditingController? commentInputTextController;
  String? Function(BuildContext, String?)? commentInputTextControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    commentInputFocusNode?.dispose();
    commentInputTextController?.dispose();
  }
}
