import 'package:isar/isar.dart';

part 'subtitle_settings_isar.g.dart';

@collection
class SubtitleSettingsIsar {
  Id id = Isar.autoIncrement;

  late int fontSizeIndex;
  late int textColorValue;
  late int backgroundColorValue;
  late double backgroundOpacity;
  late int fontStyleIndex;
  String? externalTrackPath;
}