import '/flutter_flow/flutter_flow_util.dart';
import 'edit_bio_widget.dart' show EditBioWidget;
import 'package:flutter/material.dart';

class EditBioModel extends FlutterFlowModel<EditBioWidget> {
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
