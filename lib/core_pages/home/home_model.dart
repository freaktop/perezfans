import '/components/home_nav_bar/home_nav_bar_widget.dart';
import '/flutter_flow/flutter_flow_timer.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'home_widget.dart' show HomeWidget;
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:flutter/material.dart';

class HomeModel extends FlutterFlowModel<HomeWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for TimerFollowButton widget.
  final timerFollowButtonInitialTimeMs = 200;
  int timerFollowButtonMilliseconds = 200;
  String timerFollowButtonValue =
      StopWatchTimer.getDisplayTime(200, milliSecond: false);
  FlutterFlowTimerController timerFollowButtonController =
      FlutterFlowTimerController(StopWatchTimer(mode: StopWatchMode.countDown));

  // State field(s) for PageView widget.
  PageController? pageViewController;

  int get pageViewCurrentIndex => pageViewController != null &&
          pageViewController!.hasClients &&
          pageViewController!.page != null
      ? pageViewController!.page!.round()
      : 0;
  // Model for HomeNavBar component.
  late HomeNavBarModel homeNavBarModel;

  @override
  void initState(BuildContext context) {
    homeNavBarModel = createModel(context, () => HomeNavBarModel());
  }

  @override
  void dispose() {
    timerFollowButtonController.dispose();
    homeNavBarModel.dispose();
  }
}
