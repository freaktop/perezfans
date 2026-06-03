import '/flutter_flow/flutter_flow_util.dart';
import 'subscription_settings_widget.dart' show SubscriptionSettingsWidget;
import 'package:flutter/material.dart';

class SubscriptionSettingsModel
    extends FlutterFlowModel<SubscriptionSettingsWidget> {
  FocusNode? bronzePriceFocusNode;
  TextEditingController? bronzePriceTextController;
  String? Function(BuildContext, String?)?
      bronzePriceTextControllerValidator;

  FocusNode? bronzeNameFocusNode;
  TextEditingController? bronzeNameTextController;
  String? Function(BuildContext, String?)?
      bronzeNameTextControllerValidator;

  FocusNode? silverPriceFocusNode;
  TextEditingController? silverPriceTextController;
  String? Function(BuildContext, String?)?
      silverPriceTextControllerValidator;

  FocusNode? silverNameFocusNode;
  TextEditingController? silverNameTextController;
  String? Function(BuildContext, String?)?
      silverNameTextControllerValidator;

  FocusNode? goldPriceFocusNode;
  TextEditingController? goldPriceTextController;
  String? Function(BuildContext, String?)?
      goldPriceTextControllerValidator;

  FocusNode? goldNameFocusNode;
  TextEditingController? goldNameTextController;
  String? Function(BuildContext, String?)?
      goldNameTextControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    bronzePriceFocusNode?.dispose();
    bronzePriceTextController?.dispose();
    bronzeNameFocusNode?.dispose();
    bronzeNameTextController?.dispose();
    silverPriceFocusNode?.dispose();
    silverPriceTextController?.dispose();
    silverNameFocusNode?.dispose();
    silverNameTextController?.dispose();
    goldPriceFocusNode?.dispose();
    goldPriceTextController?.dispose();
    goldNameFocusNode?.dispose();
    goldNameTextController?.dispose();
  }
}
