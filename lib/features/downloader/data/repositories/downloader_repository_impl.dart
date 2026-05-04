import 'package:dartz/dartz.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/download_task_entity.dart';
import '../../domain/entities/download_url_info.dart';
import '../../domain/repositories/downloader_repository.dart';
import '../datasources/downloader_local_data_source.dart';
import '../datasources/downloader_remote_data_source.dart';
import '../models/download_task_model.dart';
import 'package:uuid/uuid.dart';

/// Production implementation of [DownloaderRepository].
///
/// Coordinates [DownloaderLocalDataSource] (ObjectBox) and
/// [DownloaderRemoteDataSource] (Dio) to provide a unified download
/// management API that returns `Either<Failure, T>`.
class DownloaderRepositoryImpl implements DownloaderRepository {
  final DownloaderLocalDataSource _localDataSource;
  final DownloaderRemoteDataSource _remoteDataSource;

  DownloaderRepositoryImpl({
    required DownloaderLocalDataSource localDataSource,
    required DownloaderRemoteDataSource remoteDataSource,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource;

  // ─── URL Pre-flight ──────────────────────────────────────────────────

  @override
  Future<Either<Failure, DownloadUrlInfo>> validateDownloadUrl(
    String url,
  ) async {
    try {
      final info = await _remoteDataSource.validateUrl(url);
      return Right(info);
    } on ServerException catch (_) {
      return Left(InvalidUrlFailure(url));
    } catch (e, st) {
      return Left(NetworkFailure('URL validation failed: $e', stackTrace: st));
    }
  }

  // ─── Task Lifecycle ──────────────────────────────────────────────────

  @override
  Future<Either<Failure, DownloadTaskEntity>> startDownload({
    required String url,
    required String fileName,
    required String saveDirectory,
    DownloadEngineType? engine,
    bool wifiOnly = false,
  }) async {
    try {
      // 1. Pre-flight check (HEAD request)
      final urlInfo = await _remoteDataSource.validateUrl(url);

      // 2. Logic ID and Task Creation
      final logicalId = const Uuid().v4();
      final activeEngine = engine ?? urlInfo.engine;

      final task = DownloadTaskEntity(
        taskId:        logicalId,
        url:           url,
        fileName:      fileName,
        saveDirectory: saveDirectory,
        status:        DownloadStatus.running,
        createdAt:     DateTime.now(),
        engine:        activeEngine,
        totalBytes:    urlInfo.fileSizeBytes,
        wifiOnly:      wifiOnly,
      );

      // 3. Persist initial record
      await _localDataSource.putTask(DownloadTaskModel.fromDomain(task));

      String? videoNativeId;

      if (activeEngine == DownloadEngineType.ffmpeg) {
        // DASH Extraction Logic (Usually comes from social downloader, but if triggered here...)
        // This repo implementation is mainly for direct links. 
        // For DASH, we usually expect videoUrl and audioUrl to be set.
        // If they aren't, this falls back to native or fails.
        return const Left(NetworkFailure('Direct DASH download without metadata is not supported.'));
      } else {
        videoNativeId = await FlutterDownloader.enqueue(
          url: url,
          savedDir: saveDirectory,
          fileName: fileName,
          showNotification: true,
          openFileFromNotification: true,
          requiresStorageNotLow: true,
        );
      }

      if (videoNativeId == null) {
        return const Left(NetworkFailure('Failed to enqueue the task.'));
      }

      // 4. Update with native ID
      final finalTask = task.copyWith(taskId: videoNativeId);
      await _localDataSource.putTask(DownloadTaskModel.fromDomain(finalTask));
      await _localDataSource.deleteByTaskId(logicalId);

      return Right(finalTask);
    } catch (e, st) {
      return Left(NetworkFailure('Failed to start download: $e', stackTrace: st));
    }
  }

  @override
  Future<Either<Failure, void>> pauseDownload(String taskId) async {
    try {
      await FlutterDownloader.pause(taskId: taskId);
      return updateDownloadStatus(taskId, DownloadStatus.paused);
    } catch (e) {
      return Left(CacheFailure('Failed to pause download: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> resumeDownload(String taskId) async {
    try {
      final newTaskId = await FlutterDownloader.resume(taskId: taskId);
      if (newTaskId != null && newTaskId != taskId) {
        await _handleTaskIdChange(oldId: taskId, newId: newTaskId);
        return updateDownloadStatus(newTaskId, DownloadStatus.running);
      }
      return updateDownloadStatus(taskId, DownloadStatus.running);
    } catch (e) {
      return Left(CacheFailure('Failed to resume download: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> cancelDownload(String taskId) async {
    try {
      try {
        await FlutterDownloader.cancel(taskId: taskId);
      } catch (e) {
        // Ignore native error, still update local DB
      }
      return await updateDownloadStatus(taskId, DownloadStatus.cancelled);
    } catch (e) {
      return Left(CacheFailure('Failed to cancel download: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> retryDownload(String taskId) async {
    try {
      final newTaskId = await FlutterDownloader.retry(taskId: taskId);
      if (newTaskId != null && newTaskId != taskId) {
        await _handleTaskIdChange(oldId: taskId, newId: newTaskId);
        return updateDownloadStatus(newTaskId, DownloadStatus.queued);
      }
      return updateDownloadStatus(taskId, DownloadStatus.queued);
    } catch (e) {
      return Left(CacheFailure('Failed to retry download: $e'));
    }
  }

  Future<void> _handleTaskIdChange({required String oldId, required String newId}) async {
    final model = await _localDataSource.getTaskByTaskId(oldId);
    if (model != null) {
      await _localDataSource.deleteByTaskId(oldId);
      model.taskId = newId;
      await _localDataSource.putTask(model);
    }
  }

  @override
  Future<Either<Failure, void>> updateDownloadStatus(
    String taskId,
    DownloadStatus status,
  ) async {
    try {
      final model = await _localDataSource.getTaskByTaskId(taskId);
      if (model == null) {
        return Left(CacheFailure('Download task not found: $taskId'));
      }

      model.statusIndex = status.index;

      // Mark completion time if the task is finished.
      if (status == DownloadStatus.completed) {
        model.completedAt = DateTime.now();
      }

      await _localDataSource.putTask(model);
      return const Right(null);
    } on CacheException catch (e, st) {
      return Left(
          CacheFailure('Failed to update task status: ${e.message}',
              stackTrace: st));
    } catch (e, st) {
      return Left(CacheFailure('Unexpected error: $e', stackTrace: st));
    }
  }

  // ─── Queries ─────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<DownloadTaskEntity>>> getAllDownloads() async {
    try {
      final models = await _localDataSource.getAllTasks();
      return Right(models.map((m) => m.toDomain()).toList());
    } on CacheException catch (e, st) {
      return Left(CacheFailure('Failed to fetch downloads: ${e.message}',
          stackTrace: st));
    } catch (e, st) {
      return Left(CacheFailure('Unexpected error: $e', stackTrace: st));
    }
  }

  @override
  Future<Either<Failure, List<DownloadTaskEntity>>>
      getActiveDownloads() async {
    try {
      final models = await _localDataSource.getTasksByStatuses([
        DownloadStatus.queued,
        DownloadStatus.running,
      ]);
      return Right(models.map((m) => m.toDomain()).toList());
    } on CacheException catch (e, st) {
      return Left(CacheFailure('Failed to fetch active downloads: ${e.message}',
          stackTrace: st));
    } catch (e, st) {
      return Left(CacheFailure('Unexpected error: $e', stackTrace: st));
    }
  }

  @override
  Future<Either<Failure, List<DownloadTaskEntity>>>
      getCompletedDownloads() async {
    try {
      final models = await _localDataSource.getTasksByStatuses([
        DownloadStatus.completed,
      ]);
      return Right(models.map((m) => m.toDomain()).toList());
    } on CacheException catch (e, st) {
      return Left(
          CacheFailure('Failed to fetch completed downloads: ${e.message}',
              stackTrace: st));
    } catch (e, st) {
      return Left(CacheFailure('Unexpected error: $e', stackTrace: st));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDownloadRecord(
    String taskId, {
    bool deleteFile = false,
  }) async {
    try {
      // Remove from flutter_downloader.
      try {
        await FlutterDownloader.remove(taskId: taskId, shouldDeleteContent: deleteFile);
      } catch (e) {
        // Ignore native error, ensure Isar is cleaned up
      }

      // Also clean up local DB.
      await _localDataSource.deleteByTaskId(taskId);
      return const Right(null);
    } on CacheException catch (e, st) {
      return Left(CacheFailure('Failed to delete download: ${e.message}',
          stackTrace: st));
    } catch (e, st) {
      return Left(
          FileSystemFailure('Failed to delete file: $e', stackTrace: st));
    }
  }

  // ─── Live Updates ────────────────────────────────────────────────────

  @override
  Stream<Either<Failure, DownloadTaskEntity>> watchAllDownloads() {
    try {
      return _localDataSource.watchAllTasks().expand((models) {
        // Emit each model as a separate event so the UI can react per-task.
        return models.map<Either<Failure, DownloadTaskEntity>>(
          (m) => Right(m.toDomain()),
        );
      });
    } catch (e, st) {
      return Stream.value(
        Left(CacheFailure('Failed to watch downloads: $e', stackTrace: st)),
      );
    }
  }
}
