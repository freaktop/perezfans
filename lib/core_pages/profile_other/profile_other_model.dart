import '/flutter_flow/flutter_flow_timer.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'profile_other_widget.dart' show ProfileOtherWidget;
import 'package:flutter/material.dart';

class ProfileOtherModel extends FlutterFlowModel<ProfileOtherWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for TimerFollowButton widget.
  final timerFollowButtonInitialTimeMs = 200;
  int timerFollowButtonMilliseconds = 200;
  String timerFollowButtonValue =
      StopWatchTimer.getDisplayTime(200, milliSecond: false);
  FlutterFlowTimerController timerFollowButtonController =
      FlutterFlowTimerController(StopWatchTimer(mode: StopWatchMode.countDown));

  // State field(s) for TabBar widget.
  TabController? tabBarController;
  int get tabBarCurrentIndex =>
      tabBarController != null ? tabBarController!.index : 0;
  int get tabBarPreviousIndex =>
      tabBarController != null ? tabBarController!.previousIndex : 0;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    timerFollowButtonController.dispose();
    tabBarController?.dispose();
  }
}
