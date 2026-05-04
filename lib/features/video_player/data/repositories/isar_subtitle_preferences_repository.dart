import 'package:isar/isar.dart';
import '../../domain/entities/subtitle_settings.dart';
import '../../domain/repositories/subtitle_preferences_repository.dart';

part 'isar_subtitle_preferences_repository.g.dart';

@collection
class IsarSubtitleSettingsRecord {
  Id id = Isar.autoIncrement;
  @Index(unique: true)
  String? videoPath; // null means global
  
  double fontSize = 16.0;
  bool isVisible = true;
  int syncOffsetMs = 0;

  IsarSubtitleSettingsRecord();

  factory IsarSubtitleSettingsRecord.fromEntity(SubtitleSettings entity, {String? videoPath}) {
    return IsarSubtitleSettingsRecord()
      ..videoPath = videoPath
      ..fontSize = entity.fontSize
      ..isVisible = entity.isVisible
      ..syncOffsetMs = entity.syncOffset.inMilliseconds;
  }

  SubtitleSettings toEntity() {
    return SubtitleSettings(
      fontSize: fontSize,
      isVisible: isVisible,
      syncOffset: Duration(milliseconds: syncOffsetMs),
    );
  }
}

@collection
class IsarExternalSubtitleRecord {
  Id id = Isar.autoIncrement;
  @Index(unique: true)
  late String videoPath;
  late String subtitlePath;
}

class IsarSubtitlePreferencesRepository implements SubtitlePreferencesRepository {
  final Isar _isar;

  IsarSubtitlePreferencesRepository(this._isar);

  @override
  Future<SubtitleSettings> loadGlobalSettings() async {
    final settings = await _isar.isarSubtitleSettingsRecords.filter().videoPathIsNull().findFirst();
    return settings?.toEntity() ?? SubtitleSettings.defaults;
  }

  @override
  Future<void> saveGlobalSettings(SubtitleSettings settings) async {
    await _isar.writeTxn(() async {
      final existing = await _isar.isarSubtitleSettingsRecords.filter().videoPathIsNull().findFirst();
      final record = IsarSubtitleSettingsRecord.fromEntity(settings, videoPath: null);
      if (existing != null) record.id = existing.id;
      await _isar.isarSubtitleSettingsRecords.put(record);
    });
  }

  @override
  Future<SubtitleSettings?> loadVideoSettings(String videoPath) async {
    final settings = await _isar.isarSubtitleSettingsRecords.filter().videoPathEqualTo(videoPath).findFirst();
    return settings?.toEntity();
  }

  @override
  Future<void> saveVideoSettings(String videoPath, SubtitleSettings settings) async {
    await _isar.writeTxn(() async {
      final existing = await _isar.isarSubtitleSettingsRecords.filter().videoPathEqualTo(videoPath).findFirst();
      final record = IsarSubtitleSettingsRecord.fromEntity(settings, videoPath: videoPath);
      if (existing != null) record.id = existing.id;
      await _isar.isarSubtitleSettingsRecords.put(record);
    });
  }

  @override
  Future<String?> loadExternalTrackPath(String videoPath) async {
    final record = await _isar.isarExternalSubtitleRecords.filter().videoPathEqualTo(videoPath).findFirst();
    return record?.subtitlePath;
  }

  @override
  Future<void> saveExternalTrackPath(String videoPath, String? path) async {
    await _isar.writeTxn(() async {
      final existing = await _isar.isarExternalSubtitleRecords.filter().videoPathEqualTo(videoPath).findFirst();
      if (path == null) {
        if (existing != null) await _isar.isarExternalSubtitleRecords.delete(existing.id);
      } else {
        final record = (existing ?? IsarExternalSubtitleRecord())
          ..videoPath = videoPath
          ..subtitlePath = path;
        await _isar.isarExternalSubtitleRecords.put(record);
      }
    });
  }
}