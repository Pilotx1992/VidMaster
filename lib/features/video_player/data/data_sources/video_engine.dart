// lib/data/data_sources/video_engine.dart
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class VideoEngine {
  final Player _player = Player(
    configuration: const PlayerConfiguration(
      // 🔥 Performance: Hardware acceleration is critical for 4K
      bufferSize: 32 * 1024 * 1024, // 32MB buffer for high-bitrate files
    ),
  );
  
  late final VideoController controller = VideoController(_player);

  Player get player => _player;

  VideoEngine() {
    // 🔥 Stability: Enable hardware decoding for 4K/60fps files
    try {
      (_player.platform as dynamic).setProperty('hwdec', 'auto');
    } catch (_) {}
  }

  Future<void> open(Media media)           async => _player.open(media);
  Future<void> play()                      async => _player.play();
  Future<void> pause()                     async => _player.pause();
  Future<void> seek(Duration position)     async => _player.seek(position);
  Future<void> setVolume(double v)         async => _player.setVolume(v * 100);
  Future<void> setPlaybackSpeed(double s)  async => _player.setRate(s);
  Future<void> setSubtitleTrack(SubtitleTrack t) async => _player.setSubtitleTrack(t);
  
  Future<void> setSubtitleDelay(Duration delay) async {
    try {
      // ignore: avoid_dynamic_calls
      await (player.platform as dynamic).setProperty('sub-delay', (delay.inMilliseconds / 1000.0).toStringAsFixed(3));
    } catch (_) {}
  }

  void dispose() => _player.dispose();
}