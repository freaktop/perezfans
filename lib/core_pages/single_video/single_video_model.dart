import '/flutter_flow/flutter_flow_timer.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'single_video_widget.dart' show SingleVideoWidget;
import 'package:flutter/material.dart';

class SingleVideoModel extends FlutterFlowModel<SingleVideoWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for TimerFollowButton widget.
  final timerFollowButtonInitialTimeMs = 200;
  int timerFollowButtonMilliseconds = 200;
  String timerFollowButtonValue =
      StopWatchTimer.getDisplayTime(200, milliSecond: false);
  FlutterFlowTimerController timerFollowButtonController =
      FlutterFlowTimerController(StopWatchTimer(mode: StopWatchMode.countDown));

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    timerFollowButtonController.dispose();
  }
}
