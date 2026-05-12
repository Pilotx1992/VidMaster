import 'package:flutter_test/flutter_test.dart';
import 'package:vidmaster/features/video_player/domain/utils/video_mime_utils.dart';

void main() {
  group('VideoMimeUtils', () {
    test('normalizes extensions from Android and Windows paths', () {
      expect(
        VideoMimeUtils.extensionForPath(
            '/storage/emulated/0/Movies/Movie.WEBM'),
        'webm',
      );
      expect(VideoMimeUtils.extensionForPath(r'C:\Videos\clip.M4V'), 'm4v');
    });

    test('does not treat dotted folders or hidden names as extensions', () {
      expect(VideoMimeUtils.extensionForPath('/tmp/archive.videos/movie'), '');
      expect(VideoMimeUtils.extensionForPath('/tmp/.nomedia'), '');
    });

    test('maps likely Chromecast containers to MIME types', () {
      final mp4 = VideoMimeUtils.metadataForPath('/tmp/movie.mp4');
      final webm = VideoMimeUtils.metadataForPath('/tmp/movie.webm');
      final transportStream = VideoMimeUtils.metadataForPath('/tmp/movie.ts');

      expect(mp4.mimeType, 'video/mp4');
      expect(mp4.isLikelyChromecastCompatible, isTrue);
      expect(mp4.chromecastCompatibilityWarning, isNull);

      expect(webm.mimeType, 'video/webm');
      expect(webm.isLikelyChromecastCompatible, isTrue);

      expect(transportStream.mimeType, 'video/mp2t');
      expect(transportStream.isLikelyChromecastCompatible, isTrue);
    });

    test('returns fallback MIME and warning for unknown extensions', () {
      final metadata = VideoMimeUtils.metadataForPath('/tmp/movie.videoz');

      expect(metadata.extension, 'videoz');
      expect(metadata.mimeType, VideoMimeUtils.fallbackMimeType);
      expect(metadata.isLikelyChromecastCompatible, isFalse);
      expect(metadata.chromecastCompatibilityWarning, contains('unknown'));
    });
  });
}
