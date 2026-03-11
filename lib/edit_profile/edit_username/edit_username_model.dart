import '/flutter_flow/flutter_flow_util.dart';
import 'edit_username_widget.dart' show EditUsernameWidget;
import 'package:flutter/material.dart';

class EditUsernameModel extends FlutterFlowModel<EditUsernameWidget> {
  ///  State fields for stateful widgets in this component.

  final formKey = GlobalKey<FormState>();
  // State field(s) for UsernameInput widget.
  FocusNode? usernameInputFocusNode;
  TextEditingController? usernameInputTextController;
  String? Function(BuildContext, String?)? usernameInputTextControllerValidator;
  String? _usernameInputTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Field is required';
    }

    return null;
  }

  @override
  void initState(BuildContext context) {
    usernameInputTextControllerValidator =
        _usernameInputTextControllerValidator;
  }

  @override
  void dispose() {
    usernameInputFocusNode?.dispose();
    usernameInputTextController?.dispose();
  }
}
