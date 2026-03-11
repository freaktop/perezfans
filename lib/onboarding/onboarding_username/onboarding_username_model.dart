import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'onboarding_username_widget.dart' show OnboardingUsernameWidget;
import 'package:flutter/material.dart';

class OnboardingUsernameModel
    extends FlutterFlowModel<OnboardingUsernameWidget> {
  ///  State fields for stateful widgets in this page.

  final formKey = GlobalKey<FormState>();
  // State field(s) for usernameInput widget.
  FocusNode? usernameInputFocusNode;
  TextEditingController? usernameInputTextController;
  String? Function(BuildContext, String?)? usernameInputTextControllerValidator;
  String? _usernameInputTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Field is required';
    }

    if (!RegExp(kTextValidatorUsernameRegex).hasMatch(val)) {
      return 'Must start with a letter and can only contain letters, digits and - or _.';
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
