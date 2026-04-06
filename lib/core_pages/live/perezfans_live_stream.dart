import '/core_pages/live/live_join_service.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:permission_handler/permission_handler.dart';

/// **Debug / harness only** — not a replacement for [LiveRoomWidget].
///
/// Loads `AGORA_APP_ID`, optional `AGORA_TEST_TOKEN`, optional `AGORA_TEST_RTC_UID`
/// from `assets/.env`, or `--dart-define=AGORA_TEST_TOKEN=...` etc.
/// The RTC **uid must match** the uid used when the token was minted (see
/// `createAgoraRtcToken` response). For production live, use the normal Go Live flow.
class PerezFansLiveStream extends StatefulWidget {
  const PerezFansLiveStream({super.key, this.webVariant = false});

  /// When true (typically [PerezFansLiveWeb]), uses a fixed 640×480 layout and
  /// a web-oriented title. Agora behavior is the same as the default harness.
  final bool webVariant;

  static const String routeName = 'PerezFansLiveStream';
  static const String routePath = 'agoraLiveTest';

  @override
  State<PerezFansLiveStream> createState() => _PerezFansLiveStreamState();
}

class _PerezFansLiveStreamState extends State<PerezFansLiveStream> {
  static const String kChannelName = 'perezfans_live';

  RtcEngine? _engine;
  bool _initializing = true;
  String? _initError;
  bool _isBroadcasting = false;
  int? _remoteUid;

  String _appId() =>
      (dotenv.env['AGORA_APP_ID'] ?? '').trim();

  String _token() {
    const fromDefine = String.fromEnvironment('AGORA_TEST_TOKEN', defaultValue: '');
    final fromEnv = (dotenv.env['AGORA_TEST_TOKEN'] ?? '').trim();
    return fromDefine.isNotEmpty ? fromDefine : fromEnv;
  }

  int _rtcUid() {
    const d = String.fromEnvironment('AGORA_TEST_RTC_UID', defaultValue: '');
    final fromDot = dotenv.env['AGORA_TEST_RTC_UID']?.trim() ?? '';
    final s = d.isNotEmpty ? d : fromDot;
    return int.tryParse(s) ?? 0;
  }

  @override
  void initState() {
    super.initState();
    _initAgora();
  }

  Future<void> _requestCapturePermission() async {
    if (kIsWeb) {
      final err = await LiveJoinService.ensureHostBroadcastPermissions();
      if (err != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      }
      return;
    }
    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      await [Permission.camera, Permission.microphone].request();
    }
  }

  Future<void> _initAgora() async {
    final appId = _appId();
    if (appId.isEmpty) {
      setState(() {
        _initializing = false;
        _initError = 'Set AGORA_APP_ID in assets/.env';
      });
      return;
    }

    try {
      await _requestCapturePermission();

      final engine = createAgoraRtcEngine();
      await engine.initialize(
        RtcEngineContext(
          appId: appId,
          channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        ),
      );

      engine.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (connection, elapsed) {
            debugPrint('PerezFansLiveStream: joined channel=${connection.channelId}');
          },
          onUserJoined: (connection, uid, elapsed) {
            debugPrint('PerezFansLiveStream: remote uid=$uid');
            if (mounted) setState(() => _remoteUid = uid);
          },
          onUserOffline: (connection, uid, reason) {
            debugPrint('PerezFansLiveStream: user offline uid=$uid');
            if (mounted && _remoteUid == uid) {
              setState(() => _remoteUid = null);
            }
          },
          onConnectionStateChanged: (connection, state, reason) {
            debugPrint('PerezFansLiveStream: connectionState=$state reason=$reason');
          },
        ),
      );

      await engine.enableVideo();
      await engine.enableAudio();

      if (!mounted) return;
      setState(() {
        _engine = engine;
        _initializing = false;
      });
    } catch (e, st) {
      debugPrint('PerezFansLiveStream init failed: $e\n$st');
      if (mounted) {
        setState(() {
          _initializing = false;
          _initError = e.toString();
        });
      }
    }
  }

  Future<void> _startBroadcast() async {
    final engine = _engine;
    if (engine == null) return;
    final token = _token();
    if (token.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Set AGORA_TEST_TOKEN in assets/.env (must match channel + rtcUid).',
            ),
          ),
        );
      }
      return;
    }
    final uid = _rtcUid();
    if (uid == 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Set AGORA_TEST_RTC_UID to the uid your token was generated for (see createAgoraRtcToken).',
            ),
          ),
        );
      }
      return;
    }

    await LiveJoinService.ensureHostBroadcastPermissions();

    await engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await engine.enableLocalVideo(true);
    await engine.enableLocalAudio(true);
    await engine.startPreview();

    await engine.joinChannel(
      token: token,
      channelId: kChannelName,
      uid: uid,
      options: ChannelMediaOptions(
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        publishCameraTrack: true,
        publishMicrophoneTrack: true,
        autoSubscribeAudio: true,
        autoSubscribeVideo: true,
      ),
    );

    if (mounted) setState(() => _isBroadcasting = true);
  }

  Future<void> _stopBroadcast() async {
    final engine = _engine;
    if (engine == null) return;
    await engine.leaveChannel();
    if (mounted) {
      setState(() {
        _isBroadcasting = false;
        _remoteUid = null;
      });
    }
  }

  Future<void> _joinAsAudience() async {
    if (_isBroadcasting) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Stop broadcast first, or open audience on another device/browser.'),
          ),
        );
      }
      return;
    }
    final engine = _engine;
    if (engine == null) return;
    final token = _token();
    if (token.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Set AGORA_TEST_TOKEN in assets/.env')),
        );
      }
      return;
    }
    final uid = _rtcUid();
    if (uid == 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Set AGORA_TEST_RTC_UID for the subscriber token you generated.'),
          ),
        );
      }
      return;
    }

    await engine.setClientRole(role: ClientRoleType.clientRoleAudience);
    await engine.joinChannel(
      token: token,
      channelId: kChannelName,
      uid: uid,
      options: ChannelMediaOptions(
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        clientRoleType: ClientRoleType.clientRoleAudience,
        publishCameraTrack: false,
        publishMicrophoneTrack: false,
        autoSubscribeAudio: true,
        autoSubscribeVideo: true,
      ),
    );
  }

  @override
  void dispose() {
    final engine = _engine;
    _engine = null;
    if (engine != null) {
      engine.leaveChannel().then((_) => engine.release()).catchError((_) {});
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.webVariant && kIsWeb
        ? 'PerezFans Live (Web HTML renderer)'
        : 'PerezFans Live (Agora test)';

    if (_initializing) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_initError != null) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(_initError!, textAlign: TextAlign.center),
          ),
        ),
      );
    }

    final engine = _engine!;

    final videoStack = Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: Colors.black),
        if (_isBroadcasting)
          AgoraVideoView(
            controller: VideoViewController(
              rtcEngine: engine,
              canvas: const VideoCanvas(
                uid: 0,
                sourceType: VideoSourceType.videoSourceCamera,
              ),
            ),
          ),
        if (_remoteUid != null)
          AgoraVideoView(
            controller: VideoViewController.remote(
              rtcEngine: engine,
              canvas: VideoCanvas(uid: _remoteUid!),
              connection: RtcConnection(channelId: kChannelName),
            ),
          ),
      ],
    );

    final controls = Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        spacing: 10,
        runSpacing: 8,
        children: [
          ElevatedButton(
            onPressed: _isBroadcasting ? null : _startBroadcast,
            child: const Text('Start broadcast'),
          ),
          ElevatedButton(
            onPressed: _isBroadcasting ? _stopBroadcast : null,
            child: const Text('Stop broadcast'),
          ),
          ElevatedButton(
            onPressed: _joinAsAudience,
            child: const Text('Join as audience'),
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.safePop(),
        ),
      ),
      body: widget.webVariant && kIsWeb
          ? SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Channel: $kChannelName · config via .env · '
                      'Use `flutter build web --web-renderer html` if CanvasKit/WebGL is unstable.',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (_isBroadcasting)
                    SizedBox(
                      width: 640,
                      height: 480,
                      child: ColoredBox(
                        color: Colors.black,
                        child: AgoraVideoView(
                          controller: VideoViewController(
                            rtcEngine: engine,
                            canvas: const VideoCanvas(
                              uid: 0,
                              sourceType: VideoSourceType.videoSourceCamera,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (_remoteUid != null)
                    Padding(
                      padding: EdgeInsets.only(top: _isBroadcasting ? 12.0 : 0),
                      child: SizedBox(
                        width: 640,
                        height: 480,
                        child: ColoredBox(
                          color: Colors.black,
                          child: AgoraVideoView(
                            controller: VideoViewController.remote(
                              rtcEngine: engine,
                              canvas: VideoCanvas(uid: _remoteUid!),
                              connection:
                                  RtcConnection(channelId: kChannelName),
                            ),
                          ),
                        ),
                      ),
                    ),
                  controls,
                ],
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Channel: $kChannelName · App ID from .env · Token/uid must match server.',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(child: videoStack),
                controls,
              ],
            ),
    );
  }
}
