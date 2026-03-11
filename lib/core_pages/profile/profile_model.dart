import '/components/profile_nav_bar/profile_nav_bar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'profile_widget.dart' show ProfileWidget;
import 'package:flutter/material.dart';

class ProfileModel extends FlutterFlowModel<ProfileWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for TabBar widget.
  TabController? tabBarController;
  int get tabBarCurrentIndex =>
      tabBarController != null ? tabBarController!.index : 0;
  int get tabBarPreviousIndex =>
      tabBarController != null ? tabBarController!.previousIndex : 0;

  // Model for ProfileNavBar component.
  late ProfileNavBarModel profileNavBarModel;

  @override
  void initState(BuildContext context) {
    profileNavBarModel = createModel(context, () => ProfileNavBarModel());
  }

  @override
  void dispose() {
    tabBarController?.dispose();
    profileNavBarModel.dispose();
  }
}
