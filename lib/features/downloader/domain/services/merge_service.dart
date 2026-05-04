abstract class MergeService {
  /// Merges [videoPath] and [audioPath] into [outputPath] using FFmpeg.
  /// Returns the final output path on success.
  Future<String> mergeVideoAudio({
    required String videoPath,
    required String audioPath,
    required String outputPath,
  });

  /// Converts [inputPath] (any format) to MP3 at [outputPath].
  Future<String> convertToMp3({
    required String inputPath,
    required String outputPath,
    int              bitrate = 320,
  });
}

class MergeException implements Exception {
  final String message;
  final int?   ffmpegReturnCode;
  const MergeException(this.message, {this.ffmpegReturnCode});
}
