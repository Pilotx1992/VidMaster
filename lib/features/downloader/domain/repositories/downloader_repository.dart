import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/download_task_entity.dart';
import '../entities/download_url_info.dart';

/// Contract for all download manager operations.
abstract interface class DownloaderRepository {
  // ─── Task Lifecycle ────────────────────────────────────────────────────

  /// Validates [url], checks storage, enqueues a Foreground Service download.
  ///
  /// Sends a HEAD request first to:
  ///   - Confirm the URL is reachable (returns [InvalidUrlFailure] if not)
  ///   - Read Content-Length (check vs available storage)
  ///   - Suggest a filename from Content-Disposition / URL path
  ///
  /// Returns the created [DownloadTaskEntity] with status = [queued].
  Future<Either<Failure, DownloadTaskEntity>> startDownload({
    required String url,
    required String fileName,
    required String saveDirectory,
    bool wifiOnly = false,
  });

  Future<Either<Failure, void>> pauseDownload(String taskId);
  Future<Either<Failure, void>> resumeDownload(String taskId);
  Future<Either<Failure, void>> cancelDownload(String taskId);
  Future<Either<Failure, void>> retryDownload(String taskId);

  // ─── Queries ───────────────────────────────────────────────────────────

  Future<Either<Failure, List<DownloadTaskEntity>>> getAllDownloads();
  Future<Either<Failure, List<DownloadTaskEntity>>> getActiveDownloads();
  Future<Either<Failure, List<DownloadTaskEntity>>> getCompletedDownloads();
  Future<Either<Failure, void>> deleteDownloadRecord(String taskId,
      {bool deleteFile = false});

  // ─── URL Pre-flight ────────────────────────────────────────────────────

  /// Validates a URL before showing the download dialog.
  /// Returns a [DownloadUrlInfo] with the suggested name and size.
  Future<Either<Failure, DownloadUrlInfo>> validateDownloadUrl(String url);

  // ─── Live Updates ──────────────────────────────────────────────────────

  /// Stream that emits an updated [DownloadTaskEntity] whenever any task's
  /// progress, status, or speed changes.
  Stream<Either<Failure, DownloadTaskEntity>> watchAllDownloads();
}
