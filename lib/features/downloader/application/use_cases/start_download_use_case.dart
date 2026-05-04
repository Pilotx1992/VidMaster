import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/download_task_entity.dart';
import '../../domain/entities/download_url_info.dart';
import '../../domain/entities/extraction_result.dart';
import '../../domain/entities/media_format.dart';
import '../../domain/repositories/download_repository.dart';
import '../../domain/services/storage_service.dart';
import '../../core/downloader_constants.dart';

class StartDownloadUseCase {
  final DownloadRepository _repo;
  final StorageService     _storage;

  StartDownloadUseCase({
    required DownloadRepository repo,
    required StorageService     storage,
  })  : _repo    = repo,
        _storage = storage;

  Future<DownloadTaskEntity> call({
    required ExtractionResult result,
    required MediaFormat      format,
  }) async {
    // 1. Storage check
    final requiredSize = format.fileSizeBytes ?? 0;
    if (requiredSize > 0) {
      final multiplier = format.requiresMerge
          ? DownloaderConstants.storageBufferMultiplier
          : DownloaderConstants.storageBufferSingle;

      final hasSpace = await _storage.hasEnoughSpace(
        requiredSize, multiplier: multiplier,
      );
      if (!hasSpace) {
        throw Exception('Insufficient storage space. Need at least '
            '${(requiredSize * multiplier / 1024 / 1024).ceil()} MB.');
      }
    }

    // 2. Initialize task
    final taskId = const Uuid().v4();
    final isAudio = format.isAudioOnly;
    final subDir  = isAudio
        ? DownloaderConstants.audioSubDir
        : DownloaderConstants.videoSubDir;

    final safeTitle = result.title
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .substring(0, result.title.length.clamp(0, 100));

    final fileName = '$safeTitle.${format.extension}';
    final outputPath = await _storage.resolveOutputPath(subDir, fileName);
    final saveDirectory = outputPath.substring(0, outputPath.lastIndexOf('/'));

    final task = DownloadTaskEntity(
      taskId:        taskId,
      url:           result.originalUrl,
      fileName:      fileName,
      saveDirectory: saveDirectory,
      status:        DownloadStatus.running,
      createdAt:     DateTime.now(),
      engine:        format.requiresMerge ? DownloadEngineType.ffmpeg : DownloadEngineType.native,
      totalBytes:    format.fileSizeBytes,
    );

    // 3. Persist initial record to DB
    await _repo.save(task);

    // 4. Start native download
    if (format.requiresMerge) {
      final (videoNativeId, audioNativeId) = await _startDashDownload(taskId, result, format);
      
      // 5. Update record with native IDs
      if (videoNativeId != null && audioNativeId != null) {
        final updatedTask = task.copyWith(
          videoTaskId: videoNativeId,
          audioTaskId: audioNativeId,
        );
        await _repo.update(updatedTask);
        return updatedTask;
      }
    } else {
      final nativeId = await FlutterDownloader.enqueue(
        url:        format.url!,
        savedDir:   saveDirectory,
        fileName:   fileName,
        showNotification: true,
        openFileFromNotification: true,
      );
      
      if (nativeId != null) {
        final updatedTask = task.copyWith(taskId: nativeId);
        await _repo.save(updatedTask);
        await _repo.delete(taskId); // Cleanup the temp logical ID
        return updatedTask;
      }
    }

    return task;
  }

  Future<(String?, String?)> _startDashDownload(
    String logicalTaskId,
    ExtractionResult result,
    MediaFormat format,
  ) async {
    // For DASH: download video and audio to temp separately
    final videoTemp = await _storage.resolveTempPath('${logicalTaskId}_video.${format.extension}');
    await _storage.resolveTempPath('${logicalTaskId}_audio.m4a');
    final tempDir = videoTemp.substring(0, videoTemp.lastIndexOf('/'));

    // Video stream
    final videoId = await FlutterDownloader.enqueue(
      url:        format.videoUrl!,
      savedDir:   tempDir,
      fileName:   '${logicalTaskId}_video.${format.extension}',
      showNotification: false,
    );

    // Audio stream
    final audioId = await FlutterDownloader.enqueue(
      url:        format.audioUrl!,
      savedDir:   tempDir,
      fileName:   '${logicalTaskId}_audio.m4a',
      showNotification: false,
    );

    return (videoId, audioId);
  }
}
