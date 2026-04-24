import 'package:flutter_test/flutter_test.dart';
import 'package:vidmaster/features/video_player/domain/entities/video_entity.dart';

void main() {
  group('VideoEntity', () {
    test('should correctly compute resume progress', () {
      const video = VideoEntity(
        filePath: '/storage/emulated/0/Movies/test.mp4',
        title: 'test',
        folderName: 'Movies',
        fileSizeBytes: 1000,
        durationMs: 100000, // 100 seconds
        lastPositionMs: 50000, // 50 seconds
      );

      expect(video.resumeProgress, closeTo(0.5, 0.01));
    });

    test('should return formatted duration correctly', () {
      const video = VideoEntity(
        filePath: 'path',
        title: 'name',
        folderName: 'folder',
        fileSizeBytes: 0,
        durationMs: 3661000, // 1h 1m 1s
      );

      expect(video.formattedDuration, '1:01:01');
    });

    test('isWatched should be true if playCount > 0', () {
      const video = VideoEntity(
        filePath: 'path',
        title: 'name',
        folderName: 'folder',
        fileSizeBytes: 0,
        durationMs: 100000,
        playCount: 1,
      );

      expect(video.isWatched, isTrue);
    });
  });
}
