import 'package:isar/isar.dart';

part 'video_resume_isar.g.dart';

@collection
class VideoResumeIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String videoPathHash;

  late int positionMs;
}