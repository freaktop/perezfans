import '/flutter_flow/flutter_flow_util.dart';
import 'app_tutorial_widget.dart' show AppTutorialWidget;
import 'package:flutter/material.dart';

class AppTutorialModel extends FlutterFlowModel<AppTutorialWidget> {
  int currentPage = 0;

  PageController? pageController;

  @override
  void initState(BuildContext context) {
    pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    pageController?.dispose();
  }
}
