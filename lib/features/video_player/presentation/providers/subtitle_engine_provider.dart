import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/subtitle_settings.dart';

class SubtitleEngineNotifier extends StateNotifier<SubtitleSettings> {
  SubtitleEngineNotifier() : super(const SubtitleSettings());

  void updateSettings(SubtitleSettings settings) {
    state = settings;
  }

  void reset() => state = const SubtitleSettings();
}

final subtitleEngineProvider = StateNotifierProvider<SubtitleEngineNotifier, SubtitleSettings>((ref) {
  return SubtitleEngineNotifier();
});
