import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_util.dart';
import 'perezfans_live_stream.dart';

/// Flutter **web** debug layout for the Agora harness (fixed 640×480 panels).
///
/// Same behavior as [PerezFansLiveStream]: `.env` / dart-define for app id,
/// token, and rtc uid — not hardcoded `YOUR_AGORA_APP_ID` / `uid: 0`.
class PerezFansLiveWeb extends StatelessWidget {
  const PerezFansLiveWeb({super.key});

  static const String routeName = 'PerezFansLiveWeb';
  static const String routePath = 'agoraLiveWeb';

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('PerezFans Live (Web)'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.safePop(),
          ),
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Text(
              'This route is for Flutter web. Run on Chrome or deploy a web build.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }
    return const PerezFansLiveStream(webVariant: true);
  }
}
