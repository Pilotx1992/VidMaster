import 'package:flutter_test/flutter_test.dart';
import 'package:vidmaster/features/video_player/domain/entities/video_file.dart';

void main() {
  group('VideoFile', () {
    test('equality is based on path', () {
      const first = VideoFile(
          path: '/tmp/sample.mp4',
          name: 'sample',
          duration: Duration(minutes: 3));
      const second = VideoFile(
          path: '/tmp/sample.mp4',
          name: 'sample-copy',
          duration: Duration(minutes: 3));
      const other = VideoFile(
          path: '/tmp/other.mp4',
          name: 'other',
          duration: Duration(minutes: 3));

      expect(first, equals(second));
      expect(first.hashCode, equals(second.hashCode));
      expect(first, isNot(equals(other)));
    });

    test('derives cast metadata from the file path', () {
      const video = VideoFile(path: r'C:\Videos\Sample.MP4', name: 'Sample');

      expect(video.extension, 'mp4');
      expect(video.mimeType, 'video/mp4');
      expect(video.isLikelyChromecastCompatible, isTrue);
      expect(video.chromecastCompatibilityWarning, isNull);
    });

    test('surfaces warning for recognized unsupported containers', () {
      const video = VideoFile(
          path: '/storage/emulated/0/Movies/sample.mkv', name: 'sample');

      expect(video.extension, 'mkv');
      expect(video.mimeType, 'video/x-matroska');
      expect(video.isLikelyChromecastCompatible, isFalse);
      expect(
        video.chromecastCompatibilityWarning,
        contains('Chromecast Default Media Receiver is unlikely to play .mkv'),
      );
    });
  });
}
