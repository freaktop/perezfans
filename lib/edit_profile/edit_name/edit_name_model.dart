import '/flutter_flow/flutter_flow_util.dart';
import 'edit_name_widget.dart' show EditNameWidget;
import 'package:flutter/material.dart';

class EditNameModel extends FlutterFlowModel<EditNameWidget> {
  ///  State fields for stateful widgets in this component.

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }
}
