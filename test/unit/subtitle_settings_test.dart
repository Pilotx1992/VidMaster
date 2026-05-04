import 'package:flutter_test/flutter_test.dart';
import 'package:vidmaster/features/video_player/domain/entities/subtitle_settings.dart';

void main() {
  group('SubtitleSettings', () {
    test('default settings are correct', () {
      const settings = SubtitleSettings.defaults;
      expect(settings.fontSize, 16.0);
      expect(settings.isVisible, true);
      expect(settings.syncOffset, Duration.zero);
    });

    test('copyWith updates fields correctly', () {
      const settings = SubtitleSettings.defaults;
      final updated = settings.copyWith(
        fontSize: 24.0,
        isVisible: false,
        syncOffset: const Duration(seconds: 1),
      );

      expect(updated.fontSize, 24.0);
      expect(updated.isVisible, false);
      expect(updated.syncOffset, const Duration(seconds: 1));
    });

    test('copyWith handles null values by keeping original', () {
      const settings = SubtitleSettings(fontSize: 20.0);
      final updated = settings.copyWith();
      expect(updated.fontSize, 20.0);
    });
  });
}
