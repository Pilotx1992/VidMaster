import '../entities/subtitle_settings.dart';

abstract class SubtitlePreferencesRepository {
  Future<SubtitleSettings> loadGlobalSettings();
  Future<void> saveGlobalSettings(SubtitleSettings settings);
  Future<SubtitleSettings?> loadVideoSettings(String videoPath);
  Future<void> saveVideoSettings(String videoPath, SubtitleSettings settings);
  Future<String?> loadExternalTrackPath(String videoPath);
  Future<void> saveExternalTrackPath(String videoPath, String? path);
}