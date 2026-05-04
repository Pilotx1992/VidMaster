import 'package:flutter/foundation.dart';
import '../../domain/services/merge_service.dart';
import '../../domain/services/storage_service.dart';

/// Orchestrates the DASH merge pipeline after both streams complete.
class MergeStreamsUseCase {
  final MergeService   _merger;
  final StorageService _storage;

  MergeStreamsUseCase({
    required MergeService   merger,
    required StorageService storage,
  })  : _merger  = merger,
        _storage = storage;

  Future<String> call({
    required String videoTempPath,
    required String audioTempPath,
    required String title,
    required String extension,
  }) async {
    // 1. Sanitize filename
    final safeTitle = title
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .substring(0, title.length.clamp(0, 100));

    // 2. Resolve final output path
    final outputPath = await _storage.resolveOutputPath(
      'VidMaster/Videos',
      '$safeTitle.$extension',
    );

    try {
      // 3. Trigger FFmpeg merge
      final result = await _merger.mergeVideoAudio(
        videoPath:  videoTempPath,
        audioPath:  audioTempPath,
        outputPath: outputPath,
      );

      // 4. Cleanup temp files on success
      try {
        await _storage.deleteFile(videoTempPath);
        await _storage.deleteFile(audioTempPath);
        debugPrint('[MergeUseCase] Temp files deleted');
      } catch (e) {
        debugPrint('[MergeUseCase] Warning: Failed to cleanup temp files: $e');
      }

      return result;
    } on MergeException catch (e) {
      debugPrint('[MergeUseCase] Merge failed: ${e.message}');
      // Do not delete temp files on failure — allow retry
      rethrow;
    } catch (e) {
      debugPrint('[MergeUseCase] Unexpected error during merge: $e');
      rethrow;
    }
  }
}
