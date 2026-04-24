import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/download_task_entity.dart';
import '../entities/download_url_info.dart';
import '../repositories/downloader_repository.dart';

// ═══════════════════════════════════════════════════════════════════════════
// URL VALIDATION
// ═══════════════════════════════════════════════════════════════════════════

/// Validates a download URL and returns pre-flight info.
final class ValidateDownloadUrl
    implements UseCase<DownloadUrlInfo, ValidateDownloadUrlParams> {
  final DownloaderRepository _repository;
  const ValidateDownloadUrl(this._repository);

  @override
  Future<Either<Failure, DownloadUrlInfo>> call(
      ValidateDownloadUrlParams params) =>
      _repository.validateDownloadUrl(params.url);
}

final class ValidateDownloadUrlParams {
  final String url;
  const ValidateDownloadUrlParams({required this.url});
}

// ═══════════════════════════════════════════════════════════════════════════
// TASK LIFECYCLE
// ═══════════════════════════════════════════════════════════════════════════

/// Starts a new download task.
final class StartDownload
    implements UseCase<DownloadTaskEntity, StartDownloadParams> {
  final DownloaderRepository _repository;
  const StartDownload(this._repository);

  @override
  Future<Either<Failure, DownloadTaskEntity>> call(
      StartDownloadParams params) =>
      _repository.startDownload(
        url: params.url,
        fileName: params.fileName,
        saveDirectory: params.saveDirectory,
        wifiOnly: params.wifiOnly,
      );
}

final class StartDownloadParams {
  final String url;
  final String fileName;
  final String saveDirectory;
  final bool wifiOnly;
  const StartDownloadParams({
    required this.url,
    required this.fileName,
    required this.saveDirectory,
    this.wifiOnly = false,
  });
}

// ─────────────────────────────────────────────────────────────────────────

/// Shared params for pause / resume / cancel / retry operations.
final class TaskIdParams {
  final String taskId;
  const TaskIdParams({required this.taskId});
}

final class PauseDownload implements UseCase<void, TaskIdParams> {
  final DownloaderRepository _repository;
  const PauseDownload(this._repository);

  @override
  Future<Either<Failure, void>> call(TaskIdParams params) =>
      _repository.pauseDownload(params.taskId);
}

final class ResumeDownload implements UseCase<void, TaskIdParams> {
  final DownloaderRepository _repository;
  const ResumeDownload(this._repository);

  @override
  Future<Either<Failure, void>> call(TaskIdParams params) =>
      _repository.resumeDownload(params.taskId);
}

final class CancelDownload implements UseCase<void, TaskIdParams> {
  final DownloaderRepository _repository;
  const CancelDownload(this._repository);

  @override
  Future<Either<Failure, void>> call(TaskIdParams params) =>
      _repository.cancelDownload(params.taskId);
}

final class RetryDownload implements UseCase<void, TaskIdParams> {
  final DownloaderRepository _repository;
  const RetryDownload(this._repository);

  @override
  Future<Either<Failure, void>> call(TaskIdParams params) =>
      _repository.retryDownload(params.taskId);
}

// ═══════════════════════════════════════════════════════════════════════════
// QUERIES
// ═══════════════════════════════════════════════════════════════════════════

/// Returns all download tasks (active + completed + failed).
final class GetAllDownloads
    implements UseCase<List<DownloadTaskEntity>, NoParams> {
  final DownloaderRepository _repository;
  const GetAllDownloads(this._repository);

  @override
  Future<Either<Failure, List<DownloadTaskEntity>>> call(NoParams params) =>
      _repository.getAllDownloads();
}

// ─────────────────────────────────────────────────────────────────────────

/// Stream that emits download progress updates in real-time.
final class WatchAllDownloads
    implements StreamUseCase<DownloadTaskEntity, NoParams> {
  final DownloaderRepository _repository;
  const WatchAllDownloads(this._repository);

  @override
  Stream<Either<Failure, DownloadTaskEntity>> call(NoParams params) =>
      _repository.watchAllDownloads();
}

// ─────────────────────────────────────────────────────────────────────────

/// Deletes a download record (and optionally the downloaded file).
final class DeleteDownloadRecord
    implements UseCase<void, DeleteDownloadRecordParams> {
  final DownloaderRepository _repository;
  const DeleteDownloadRecord(this._repository);

  @override
  Future<Either<Failure, void>> call(DeleteDownloadRecordParams params) =>
      _repository.deleteDownloadRecord(
        params.taskId,
        deleteFile: params.deleteFile,
      );
}

final class DeleteDownloadRecordParams {
  final String taskId;
  final bool deleteFile;
  const DeleteDownloadRecordParams({
    required this.taskId,
    this.deleteFile = false,
  });
}
