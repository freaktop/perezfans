import '/flutter_flow/flutter_flow_util.dart';
import 'tip_widget.dart' show TipWidget;
import 'package:flutter/material.dart';

class TipModel extends FlutterFlowModel<TipWidget> {
  FocusNode? customAmountFocusNode;
  TextEditingController? customAmountTextController;
  String? Function(BuildContext, String?)? customAmountTextControllerValidator;

  FocusNode? messageFocusNode;
  TextEditingController? messageTextController;
  String? Function(BuildContext, String?)? messageTextControllerValidator;

  int? selectedPresetCents;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    customAmountFocusNode?.dispose();
    customAmountTextController?.dispose();
    messageFocusNode?.dispose();
    messageTextController?.dispose();
  }
}
