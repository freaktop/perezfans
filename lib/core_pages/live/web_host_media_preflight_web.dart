import 'dart:html' as html;

import 'dart:developer' as developer;

/// Requests camera + microphone via browser [getUserMedia], then stops tracks.
/// Returns an error message if access fails; `null` on success.
Future<String?> preflightWebHostMedia() async {
  try {
    final md = html.window.navigator.mediaDevices;
    if (md == null) {
      return 'Camera or microphone is not supported in this browser.';
    }
    final stream = await md.getUserMedia({'video': true, 'audio': true});
    for (final t in stream.getTracks()) {
      t.stop();
    }
    return null;
  } catch (e, st) {
    developer.log(
      'preflightWebHostMedia failed',
      name: 'LiveHost',
      error: e,
      stackTrace: st,
    );
    return 'Camera or microphone access was denied. '
        'Please allow camera and microphone permissions and try again.';
  }
}
