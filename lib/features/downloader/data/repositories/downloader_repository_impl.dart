import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/download_task_entity.dart';
import '../../domain/entities/download_url_info.dart';
import '../../domain/repositories/downloader_repository.dart';
import '../datasources/downloader_local_data_source.dart';
import '../datasources/downloader_remote_data_source.dart';
import '../models/download_task_model.dart';

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
    bool wifiOnly = false,
  }) async {
    try {
      // 1. Validate the URL first via HEAD request.
      final urlInfo = await _remoteDataSource.validateUrl(url);

      // 2. Ensure the save directory exists.
      final dir = Directory(saveDirectory);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      // 3. Generate a unique task ID for the download engine.
      final taskId =
          'task_${DateTime.now().millisecondsSinceEpoch}_${url.hashCode.abs()}';

      // 4. Create and persist the task model.
      final model = DownloadTaskModel(
        taskId: taskId,
        url: url,
        fileName: fileName,
        saveDirectory: saveDirectory,
        statusIndex: DownloadStatus.queued.index,
        createdAt: DateTime.now(),
        totalBytes: urlInfo.fileSizeBytes,
        wifiOnly: wifiOnly,
      );
      _localDataSource.putTask(model);

      return Right(model.toDomain());
    } on ServerException catch (_) {
      return Left(InvalidUrlFailure(url));
    } on CacheException catch (e, st) {
      return Left(CacheFailure('Failed to persist download: ${e.message}',
          stackTrace: st));
    } catch (e, st) {
      return Left(
          NetworkFailure('Failed to start download: $e', stackTrace: st));
    }
  }

  @override
  Future<Either<Failure, void>> pauseDownload(String taskId) async {
    return _updateTaskStatus(taskId, DownloadStatus.paused);
  }

  @override
  Future<Either<Failure, void>> resumeDownload(String taskId) async {
    return _updateTaskStatus(taskId, DownloadStatus.running);
  }

  @override
  Future<Either<Failure, void>> cancelDownload(String taskId) async {
    return _updateTaskStatus(taskId, DownloadStatus.cancelled);
  }

  @override
  Future<Either<Failure, void>> retryDownload(String taskId) async {
    return _updateTaskStatus(taskId, DownloadStatus.queued);
  }

  /// Shared helper: find a task by [taskId], update its status, and persist.
  Future<Either<Failure, void>> _updateTaskStatus(
    String taskId,
    DownloadStatus status,
  ) async {
    try {
      final model = _localDataSource.getTaskByTaskId(taskId);
      if (model == null) {
        return Left(CacheFailure('Download task not found: $taskId'));
      }

      model.statusIndex = status.index;

      // Mark completion time if the task is finished.
      if (status == DownloadStatus.completed) {
        model.completedAt = DateTime.now();
      }

      _localDataSource.putTask(model);
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
      final models = _localDataSource.getAllTasks();
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
      final models = _localDataSource.getTasksByStatuses([
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
      final models = _localDataSource.getTasksByStatuses([
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
      // Optionally delete the downloaded file from disk.
      if (deleteFile) {
        final model = _localDataSource.getTaskByTaskId(taskId);
        if (model != null) {
          final file = File('${model.saveDirectory}/${model.fileName}');
          if (await file.exists()) {
            await file.delete();
          }
        }
      }

      _localDataSource.deleteByTaskId(taskId);
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
