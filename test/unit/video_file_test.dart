import 'package:flutter_test/flutter_test.dart';
import 'package:vidmaster/features/video_player/domain/entities/video_file.dart';

void main() {
  group('VideoFile', () {
    test('equality is based on path', () {
      const first = VideoFile(path: '/tmp/sample.mp4', name: 'sample', duration: Duration(minutes: 3));
      const second = VideoFile(path: '/tmp/sample.mp4', name: 'sample-copy', duration: Duration(minutes: 3));
      const other = VideoFile(path: '/tmp/other.mp4', name: 'other', duration: Duration(minutes: 3));

      expect(first, equals(second));
      expect(first.hashCode, equals(second.hashCode));
      expect(first, isNot(equals(other)));
    });
  });
}
