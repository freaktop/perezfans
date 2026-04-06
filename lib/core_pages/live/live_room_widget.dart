import 'dart:async';
import 'dart:developer' as developer;

import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/core/firestore_listener_manager.dart';
import '/core_pages/live/live_join_service.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LiveRoomWidget extends StatefulWidget {
  const LiveRoomWidget({
    super.key,
    this.streamRef,
    this.streamId,
    this.asHost = false,
  });

  final DocumentReference? streamRef;
  final String? streamId;
  final bool asHost;

  static String routeName = 'LiveRoom';
  static String routePath = 'liveRoom';

  @override
  State<LiveRoomWidget> createState() => _LiveRoomWidgetState();
}

class _LiveRoomWidgetState extends State<LiveRoomWidget> {
  final _functions =
      FirebaseFunctions.instanceFor(region: 'us-central1');

  RtcEngine? _engine;
  bool _joined = false;
  int? _remoteUid;
  String _channelName = '';
  bool _loading = true;
  String _status = 'Connecting...';
  final _chatController = TextEditingController();
  final _replayUrlController = TextEditingController();

  /// Selected duration in minutes, or `null` = off.
  int? _autoEndMinutes;
  Timer? _autoEndTimer;

  bool _joinBusy = false;

  /// Publisher role is derived from Firestore `host_user` vs signed-in user (must match token).
  bool _isBroadcasting = false;

  /// Host per Firestore (for End Live / retry) — not cleared on Agora failure.
  bool _isHostUser = false;

  /// True after join timeout or recoverable publish failure (shows Retry / Back).
  bool _connectFailure = false;

  Timer? _connectTimer;

  String? _liveRoomMessagesBindKey;

  DocumentReference? get _streamRef => LiveJoinService.resolveStreamReference(
        streamRef: widget.streamRef,
        streamId: widget.streamId,
      );
  CollectionReference? get _messagesRef => _streamRef?.collection('messages');

  void _logLive(String message, [Object? err, StackTrace? st]) {
    developer.log(
      message,
      name: 'LiveRoom',
      error: err,
      stackTrace: st,
    );
    LiveJoinService.log(message, err, st);
  }

  void _cancelConnectTimer() {
    _connectTimer?.cancel();
    _connectTimer = null;
  }

  void _armConnectTimeoutAfterJoinRequest() {
    _cancelConnectTimer();
    _connectTimer = Timer(const Duration(seconds: 10), () {
      if (!mounted || _joined) return;
      _logLive('livehost: timeout reached');
      unawaited(_handleJoinTimeout());
    });
  }

  Future<void> _handleJoinTimeout() async {
    _cancelConnectTimer();
    final eng = _engine;
    _engine = null;
    if (eng != null) {
      try {
        await eng.leaveChannel();
        await eng.release();
      } catch (e, st) {
        _logLive('livehost: timeout engine cleanup', e, st);
      }
    }
    if (mounted) {
      setState(() {
        _loading = false;
        _connectFailure = true;
        _status =
            "Couldn't start your live stream. Check camera/mic permissions or try again.";
        _joined = false;
        _isBroadcasting = false;
      });
    }
  }

  Future<void> _retryHostJoin() async {
    _logLive('livehost: retry tapped');
    _cancelConnectTimer();
    if (!mounted) return;
    setState(() {
      _connectFailure = false;
      _loading = true;
      _status = 'Connecting...';
      _joined = false;
      _engine = null;
      _remoteUid = null;
    });
    await joinLiveStreamSafely();
  }

  void _backFromFailedHost() {
    _logLive('livehost: back tapped (failed connect)');
    if (context.mounted) {
      context.safePop();
    }
  }

  Future<void> _sendMessage() async {
    final text = _chatController.text.trim();
    final messagesRef = _messagesRef;
    final sender = currentUserReference;
    if (text.isEmpty) return;
    if (messagesRef == null) return;
    if (sender == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign in to send messages.')),
        );
      }
      return;
    }
    _chatController.clear();
    await messagesRef.add({
      'sender': sender,
      'text': text,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  /// Validates prerequisites, loads stream doc, token, then initializes Agora.
  Future<void> joinLiveStreamSafely() async {
    if (!mounted || _joinBusy) {
      _logLive('join skipped mounted=$mounted joinBusy=$_joinBusy');
      return;
    }
    _joinBusy = true;
    _logLive(
      'joinLiveStreamSafely start: streamId=${widget.streamId ?? "null"} '
      'ref=${widget.streamRef?.path ?? "null"} asHost=${widget.asHost}',
    );

    Future<void> failUi(String message) async {
      _cancelConnectTimer();
      if (mounted) {
        setState(() {
          _loading = false;
          _status = message;
          _isBroadcasting = false;
          if (_isHostUser) {
            _connectFailure = true;
          }
        });
      }
    }

    try {
      final validation = await LiveJoinService.validateLiveJoinRequirements(
        streamRefParam: widget.streamRef,
        streamIdArg: widget.streamId,
      );
      validation.log('validateLiveJoinRequirements');

      if (!validation.ok) {
        await failUi(
          validation.userMessage ?? 'Cannot join this stream.',
        );
        return;
      }

      final streamRef = validation.streamRef;
      if (streamRef == null) {
        await failUi('Internal error: missing stream reference.');
        return;
      }

      final paramId = widget.streamId?.trim();
      if (paramId != null &&
          paramId.isNotEmpty &&
          paramId != streamRef.id) {
        _logLive(
          'runtime warning: streamId param="$paramId" != streamRef.id="${streamRef.id}" '
          '(using document ref for token + join)',
        );
      }

      final docRead = await LiveJoinService.readLiveStreamDocument(streamRef);
      _logLive(
        'firestore live_streams/${streamRef.id} exists=${docRead.exists} '
        'status=${docRead.status ?? ""} channelSet=${docRead.channelName != null} '
        'hostRef=${docRead.hostUserRef?.path ?? "null"}',
      );

      if (docRead.permissionDenied) {
        await failUi(
          'No permission to open this stream. For 18+ live, verify your age in profile first.',
        );
        return;
      }
      if (!docRead.exists) {
        await failUi('This live stream no longer exists.');
        return;
      }
      if (docRead.status != 'live') {
        await failUi(
          'This stream is not live — it may have ended or not started yet.',
        );
        return;
      }

      final channelName = docRead.channelName ?? '';
      if (channelName.isEmpty) {
        await failUi('Channel is not configured for this stream.');
        return;
      }

      final me = currentUserReference;
      final hostRef = docRead.hostUserRef;
      final broadcasting = me != null &&
          hostRef != null &&
          me.path == hostRef.path;
      if (widget.asHost != broadcasting) {
        _logLive(
          'route asHost=${widget.asHost} vs Firestore host match=$broadcasting '
          '(using Firestore + token for publisher/audience).',
        );
      }
      if (hostRef == null) {
        await failUi('This stream is missing host information.');
        return;
      }
      if (mounted) {
        setState(() => _isHostUser = broadcasting);
      }
      if (broadcasting) {
        _logLive('livehost: host media pre-check (camera/mic)');
        final permErr = await LiveJoinService.ensureHostBroadcastPermissions();
        if (permErr != null) {
          _logLive('livehost: camera/mic denied/failure in room: $permErr');
          await failUi(permErr);
          return;
        }
        _logLive('livehost: camera/mic granted in room');
      }
      if (mounted) {
        setState(() => _isBroadcasting = broadcasting);
      }

      final callable = _functions.httpsCallable('createAgoraRtcToken');
      AgoraTokenPayload? payload;
      try {
        payload = await LiveJoinService.fetchAgoraToken(
          callable: callable,
          streamId: streamRef.id,
        );
      } catch (e, st) {
        _logLive('createAgoraRtcToken failed', e, st);
        await failUi(_mapJoinExceptionToMessage(e));
        return;
      }

      if (payload == null) {
        await failUi(
          'Could not get a video token. Check connection and try again.',
        );
        return;
      }

      final effectiveChannel = LiveJoinService.effectiveJoinChannelName(
        firestoreChannel: channelName,
        payload: payload,
      );
      if (effectiveChannel == null || effectiveChannel.isEmpty) {
        await failUi('Channel name missing from server response.');
        return;
      }
      _channelName = effectiveChannel;

      _logLive(
        'token ok role=${broadcasting ? "publisher" : "subscriber"} '
        'rtcUid=${payload.rtcUid} joinChannelId=$_channelName',
      );

      RtcEngine? engine;
      try {
        _logLive('livehost: host media init started');
        engine = createAgoraRtcEngine();
        await engine.initialize(
          RtcEngineContext(
            appId: payload.appId,
            channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
          ),
        );
      } catch (e, st) {
        _logLive('RtcEngine.initialize failed', e, st);
        try {
          await engine?.release();
        } catch (_) {}
        await failUi(
          'Could not start the video engine. Try again or restart the app.',
        );
        return;
      }

      await engine.enableVideo();
      await engine.enableAudio();
      await engine.setAudioProfile(
        profile: AudioProfileType.audioProfileDefault,
        scenario: AudioScenarioType.audioScenarioGameStreaming,
      );
      await engine.setClientRole(
        role: broadcasting
            ? ClientRoleType.clientRoleBroadcaster
            : ClientRoleType.clientRoleAudience,
      );
      if (broadcasting) {
        await engine.enableLocalVideo(true);
        await engine.enableLocalAudio(true);
        try {
          await engine.startPreview();
          _logLive('livehost: host local preview ready (startPreview)');
        } catch (e, st) {
          _logLive('livehost: startPreview failed', e, st);
          rethrow;
        }
      }

      _engine = engine;
      if (mounted) setState(() {});

      engine.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (connection, elapsed) async {
            _cancelConnectTimer();
            _logLive(
              'onJoinChannelSuccess elapsed=$elapsed '
              'connChannel=${connection.channelId}',
            );
            _logLive('livehost: publish success');
            if (mounted) {
              setState(() {
                _joined = true;
                _status = 'Live';
                _loading = false;
                _connectFailure = false;
              });
            }
          },
          onUserJoined: (connection, remoteUid, elapsed) {
            _logLive('onUserJoined remoteUid=$remoteUid elapsed=$elapsed');
            if (mounted) {
              setState(() => _remoteUid = remoteUid);
            }
          },
          onUserOffline: (connection, remoteUid, reason) {
            _logLive('onUserOffline remoteUid=$remoteUid reason=$reason');
            if (mounted && _remoteUid == remoteUid) {
              setState(() => _remoteUid = null);
            }
          },
          onError: (err, msg) {
            _logLive('livehost: publish failed err=$err msg=$msg');
            _logLive('Agora onError err=$err msg=$msg');
            _cancelConnectTimer();
            if (mounted) {
              setState(() {
                _status = 'Agora error: $msg (code: $err)';
                _loading = false;
                _isBroadcasting = false;
                if (_isHostUser) {
                  _connectFailure = true;
                }
              });
            }
          },
          onConnectionStateChanged: (connection, state, reason) {
            _logLive('onConnectionStateChanged state=$state reason=$reason channel=${connection.channelId}');
          },
        ),
      );

      _logLive('livehost: publish started (joinChannel)');
      _logLive('joinChannel uid=${payload.rtcUid} channel=$_channelName tokenLength=${payload.token.length}');
      try {
        await engine.joinChannel(
          token: payload.token,
          channelId: _channelName,
          uid: payload.rtcUid,
          options: ChannelMediaOptions(
            channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
            clientRoleType: broadcasting
                ? ClientRoleType.clientRoleBroadcaster
                : ClientRoleType.clientRoleAudience,
            publishCameraTrack: broadcasting,
            publishMicrophoneTrack: broadcasting,
            autoSubscribeAudio: true,
            autoSubscribeVideo: true,
          ),
        );
        _logLive('joinChannel call completed successfully');
      } catch (e, st) {
        _logLive('joinChannel threw exception', e, st);
        await failUi('Failed to join video channel: $e');
        return;
      }

      _logLive('joinChannel await completed');
      _armConnectTimeoutAfterJoinRequest();
      if (mounted) setState(() {});
    } catch (e, st) {
      _logLive('livehost: publish failed (join fatal)', e, st);
      _logLive('joinLiveStreamSafely fatal', e, st);
      try {
        await _engine?.leaveChannel();
        await _engine?.release();
      } catch (e2, st2) {
        _logLive('engine cleanup after error', e2, st2);
      }
      _engine = null;
      if (mounted) {
        setState(() {
          _loading = false;
          _status = _mapJoinExceptionToMessage(e);
          _isBroadcasting = false;
          _joined = false;
          _remoteUid = null;
          if (_isHostUser) {
            _connectFailure = true;
          }
        });
      }
    } finally {
      _joinBusy = false;
    }
  }

  String _mapJoinExceptionToMessage(Object e) {
    if (e is FirebaseFunctionsException) {
      final code = e.code;
      final details = e.message ?? '';
      switch (code) {
        case 'unauthenticated':
          return 'Sign in again, then rejoin the live stream.';
        case 'permission-denied':
          return details.isNotEmpty
              ? details
              : 'You are not allowed to join this stream.';
        case 'failed-precondition':
          return details.isNotEmpty ? details : 'Stream is not ready to join.';
        case 'not-found':
          return 'This live stream was not found.';
        default:
          return details.isNotEmpty ? details : 'Join failed ($code).';
      }
    }
    final s = e.toString();
    if (s.contains('Null check operator')) {
      return 'Join failed due to incomplete data. Update the app and try again.';
    }
    return 'Failed to join stream: $s';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _logLive(
        'livehost: host room opened asHost=${widget.asHost} '
        'streamId=${widget.streamId ?? widget.streamRef?.id}',
      );
      await joinLiveStreamSafely();
    });
  }

  Future<void> _endLiveCore({String replayUrl = ''}) async {
    _autoEndTimer?.cancel();
    _autoEndTimer = null;
    final sid = _streamRef?.id;
    if (sid == null || sid.isEmpty) {
      _logLive('endLiveCore: missing stream id');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not end live — stream id is missing.'),
          ),
        );
        context.safePop();
      }
      return;
    }
    try {
      await _functions.httpsCallable('endLiveStream').call({
        'streamId': sid,
        'replayUrl': replayUrl,
      });
    } catch (e, st) {
      _logLive('endLiveStream callable failed', e, st);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not end live: $e')),
        );
      }
      return;
    }
    if (context.mounted) {
      context.safePop();
    }
  }

  Future<void> _endLiveDialog() async {
    _logLive('livehost: end stream tapped');
    final shouldEnd = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('End live stream'),
        content: TextFormField(
          controller: _replayUrlController,
          decoration: const InputDecoration(
            labelText: 'Replay URL (optional) — save to your grid',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('End Live'),
          ),
        ],
      ),
    );
    if (shouldEnd != true) return;
    final replayUrl = _replayUrlController.text.trim();
    await _endLiveCore(replayUrl: replayUrl);
  }

  void _scheduleAutoEnd(int? minutes) {
    _autoEndTimer?.cancel();
    _autoEndTimer = null;
    _autoEndMinutes = minutes;
    if (minutes != null) {
      _autoEndTimer = Timer(Duration(minutes: minutes), () async {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Scheduled time reached — ending live. '
              'Add a replay URL from your profile if you still need to post it.',
            ),
          ),
        );
        await _endLiveCore();
      });
    }
    if (mounted) setState(() {});
  }

  Widget _autoEndChip(int? minutes, String label) {
    final selected = _autoEndMinutes == minutes;
    return Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: FilterChip(
        label: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12.0,
            color: selected ? Colors.white : Colors.white70,
          ),
        ),
        selected: selected,
        onSelected: (_) => _scheduleAutoEnd(minutes),
        selectedColor: FlutterFlowTheme.of(context).primary,
        checkmarkColor: Colors.white,
        backgroundColor: Colors.white12,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  @override
  void dispose() {
    _cancelConnectTimer();
    if (_liveRoomMessagesBindKey != null) {
      FirestoreListenerManager.instance.cancel(_liveRoomMessagesBindKey!);
    }
    _autoEndTimer?.cancel();
    _chatController.dispose();
    _replayUrlController.dispose();
    final eng = _engine;
    _engine = null;
    if (eng != null) {
      eng.leaveChannel().then((_) => eng.release()).catchError(
        (Object e, StackTrace st) {
          developer.log(
            'Agora dispose cleanup failed',
            name: 'LiveRoom',
            error: e,
            stackTrace: st,
          );
        },
      );
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.black54,
          foregroundColor: Colors.white,
          title: Text(
            widget.asHost ? 'Live' : 'Live',
            style: FlutterFlowTheme.of(context).titleMedium.override(
                  font: GoogleFonts.poppins(color: Colors.white),
                  letterSpacing: 0.0,
                ),
          ),
          actions: [
            if (_isHostUser)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: TextButton.icon(
                  onPressed: _endLiveDialog,
                  icon: Icon(Icons.stop_circle_outlined, color: Colors.white),
                  label: Text(
                    'End',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: Colors.black),
            Positioned.fill(
              child: () {
                final engine = _engine;
                if (engine == null) {
                  return Center(
                    child: _loading
                        ? const CircularProgressIndicator()
                        : Text(
                            _status,
                            textAlign: TextAlign.center,
                            style:
                                GoogleFonts.poppins(color: Colors.white70),
                          ),
                  );
                }
                if (_isBroadcasting) {
                  return AgoraVideoView(
                    controller: VideoViewController(
                      rtcEngine: engine,
                      canvas: const VideoCanvas(
                        uid: 0,
                        sourceType: VideoSourceType.videoSourceCamera,
                      ),
                    ),
                  );
                }
                final remote = _remoteUid;
                if (remote != null) {
                  return AgoraVideoView(
                    controller: VideoViewController.remote(
                      rtcEngine: engine,
                      canvas: VideoCanvas(uid: remote),
                      connection: RtcConnection(
                        channelId: _channelName,
                      ),
                    ),
                  );
                }
                return Center(
                  child: Text(
                    'Waiting for host…',
                    style: GoogleFonts.poppins(color: Colors.white70),
                  ),
                );
              }(),
            ),
            if (_loading && _engine != null)
              const Positioned.fill(
                child: IgnorePointer(
                  child: Center(
                    child: SizedBox(
                      width: 36,
                      height: 36,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
              ),
            if (_connectFailure && _isHostUser)
              Positioned.fill(
                child: ColoredBox(
                  color: Colors.black87,
                  child: SafeArea(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Couldn't start your live stream.",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 18.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Check camera/mic permissions or try again.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 14.0,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                TextButton(
                                  onPressed: _retryHostJoin,
                                  child: Text(
                                    'Retry',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: _backFromFailedHost,
                                  child: Text(
                                    'Back',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white70,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: _endLiveDialog,
                                  child: Text(
                                    'End stream',
                                    style: GoogleFonts.poppins(
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            Positioned(
              left: 12.0,
              top: MediaQuery.paddingOf(context).top + kToolbarHeight + 8.0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: Text(
                  _joined ? 'LIVE' : _status,
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                        font: GoogleFonts.poppins(),
                        color: Colors.white,
                        letterSpacing: 0.0,
                      ),
                ),
              ),
            ),
            if (_isHostUser)
              Positioned(
                left: 8.0,
                right: 8.0,
                top: MediaQuery.paddingOf(context).top + kToolbarHeight + 40.0,
                child: Material(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(8.0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 6.0,
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Text(
                            'Auto-stop:',
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 12.0,
                            ),
                          ),
                          const SizedBox(width: 6.0),
                          _autoEndChip(null, 'Off'),
                          _autoEndChip(10, '10m'),
                          _autoEndChip(20, '20m'),
                          _autoEndChip(30, '30m'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 220),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.85),
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: () {
                          final messagesRef = _messagesRef;
                          if (messagesRef == null) {
                            return const SizedBox.shrink();
                          }
                          final bindKey =
                              'live_room_messages_${messagesRef.path}';
                          if (_liveRoomMessagesBindKey != bindKey) {
                            if (_liveRoomMessagesBindKey != null) {
                              FirestoreListenerManager.instance
                                  .cancel(_liveRoomMessagesBindKey!);
                            }
                            _liveRoomMessagesBindKey = bindKey;
                          }
                          return StreamBuilder<QuerySnapshot>(
                                stream: FirestoreListenerManager.instance
                                    .bindStream(
                                  bindKey,
                                  () => messagesRef
                                      .orderBy('created_at', descending: true)
                                      .limit(40)
                                      .snapshots(),
                                ),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return const SizedBox.shrink();
                                  }
                                  final docs = snapshot.data?.docs ?? [];
                                  return ListView.builder(
                                    shrinkWrap: true,
                                    reverse: true,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12.0,
                                    ),
                                    itemCount: docs.length,
                                    itemBuilder: (context, i) {
                                      final data = docs[i].data()
                                          as Map<String, dynamic>;
                                      final text =
                                          (data['text'] ?? '').toString();
                                      final sender = data['sender']
                                          as DocumentReference?;
                                      final mine =
                                          sender == currentUserReference;
                                      return Align(
                                        alignment: mine
                                            ? Alignment.centerRight
                                            : Alignment.centerLeft,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 4.0,
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10.0,
                                              vertical: 6.0,
                                            ),
                                            decoration: BoxDecoration(
                                              color: mine
                                                  ? FlutterFlowTheme.of(context)
                                                      .primary
                                                  : Colors.white24,
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                            child: Text(
                                              text,
                                              style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontSize: 13.0,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              );
                        }(),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          12.0, 8.0, 12.0, 12.0,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _chatController,
                                style: GoogleFonts.poppins(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: 'Comment…',
                                  hintStyle: TextStyle(
                                    color: Colors.white54,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white12,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24.0),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 10.0,
                                  ),
                                ),
                                onFieldSubmitted: (_) => _sendMessage(),
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            IconButton.filled(
                              onPressed: _messagesRef == null
                                  ? null
                                  : _sendMessage,
                              icon: const Icon(Icons.send_rounded),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
