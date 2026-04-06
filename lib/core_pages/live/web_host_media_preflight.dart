import 'web_host_media_preflight_stub.dart'
    if (dart.library.html) 'web_host_media_preflight_web.dart' as impl;

Future<String?> preflightWebHostMedia() => impl.preflightWebHostMedia();
