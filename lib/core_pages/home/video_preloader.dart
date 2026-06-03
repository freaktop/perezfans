import 'package:video_player/video_player.dart';

class VideoPreloader {
  static final VideoPreloader _instance = VideoPreloader._();
  factory VideoPreloader() => _instance;
  VideoPreloader._();

  final Set<String> _preloadingUrls = {};

  Future<void> preloadNext(List<String?> videoUrls, {int count = 2}) async {
    int loaded = 0;
    for (final url in videoUrls) {
      if (url == null || url.isEmpty) continue;
      if (loaded >= count) break;
      if (_preloadingUrls.contains(url)) continue;
      _preloadingUrls.add(url);
      try {
        final controller = VideoPlayerController.networkUrl(Uri.parse(url));
        await controller.initialize();
        controller.dispose();
      } catch (_) {}
      loaded++;
    }
  }

  void evict(String url) {
    _preloadingUrls.remove(url);
  }

  void clear() {
    _preloadingUrls.clear();
  }
}
