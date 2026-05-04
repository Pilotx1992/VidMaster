import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/return_code.dart';
import 'package:flutter/foundation.dart';

import '../../domain/services/merge_service.dart';

class FfmpegMergeService implements MergeService {
  @override
  Future<String> mergeVideoAudio({
    required String videoPath,
    required String audioPath,
    required String outputPath,
  }) async {
    final command =
        '-i "$videoPath" -i "$audioPath" '
        '-c copy '
        '-map 0:v:0 -map 1:a:0 '
        '-movflags +faststart '
        '"$outputPath"';

    debugPrint('[FFmpeg] Merging: $command');

    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();

    if (!ReturnCode.isSuccess(returnCode)) {
      throw MergeException(
        'Merge failed with code ${returnCode?.getValue()}',
        ffmpegReturnCode: returnCode?.getValue(),
      );
    }

    return outputPath;
  }

  @override
  Future<String> convertToMp3({
    required String inputPath,
    required String outputPath,
    int bitrate = 320,
  }) async {
    final command =
        '-i "$inputPath" -vn -acodec libmp3lame -ab ${bitrate}k -ar 44100 "$outputPath"';

    debugPrint('[FFmpeg] Converting to MP3: $command');

    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();

    if (!ReturnCode.isSuccess(returnCode)) {
      throw MergeException(
        'MP3 conversion failed',
        ffmpegReturnCode: returnCode?.getValue(),
      );
    }

    return outputPath;
  }
}
