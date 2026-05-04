import 'package:crypto/crypto.dart';
import 'package:isar/isar.dart';

import '../../domain/repositories/resume_repository.dart';
import '../models/video_resume_isar.dart';

class IsarResumeRepository implements ResumeRepository {
  final Isar _isar;

  IsarResumeRepository(this._isar);

  @override
  Future<Duration?> loadPosition(String videoPath) async {
    final hash = _hashPath(videoPath);
    final resume = await _isar.videoResumeIsars.where().videoPathHashEqualTo(hash).findFirst();
    return resume != null ? Duration(milliseconds: resume.positionMs) : null;
  }

  @override
  Future<void> savePosition(String videoPath, Duration position) async {
    final hash = _hashPath(videoPath);
    await _isar.writeTxn(() async {
      final existing = await _isar.videoResumeIsars.where().videoPathHashEqualTo(hash).findFirst();
      if (existing != null) {
        existing.positionMs = position.inMilliseconds;
        await _isar.videoResumeIsars.put(existing);
      } else {
        final resume = VideoResumeIsar()
          ..videoPathHash = hash
          ..positionMs = position.inMilliseconds;
        await _isar.videoResumeIsars.put(resume);
      }
    });
  }

  String _hashPath(String path) {
    return sha256.convert(path.codeUnits).toString();
  }
}