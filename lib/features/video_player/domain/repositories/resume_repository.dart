abstract class ResumeRepository {
  Future<Duration?> loadPosition(String videoPath);
  Future<void> savePosition(String videoPath, Duration position);
}