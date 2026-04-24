/// Status of a download task, mirroring flutter_downloader's DownloadTaskStatus
/// but decoupled from the package so Domain stays pure.
enum DownloadStatus {
  /// Task has been queued but not started.
  queued,

  /// Currently downloading.
  running,

  /// Manually paused by the user.
  paused,

  /// Successfully completed.
  completed,

  /// Failed due to network/storage error.
  failed,

  /// Cancelled by the user.
  cancelled,
}

/// Represents a single download task in the Domain layer.
final class DownloadTaskEntity {
  /// Internal task ID from flutter_downloader (opaque string).
  final String taskId;

  /// The source URL being downloaded.
  final String url;

  /// User-facing file name (with extension). Example: `movie.mp4`
  final String fileName;

  /// Absolute path to the directory where the file will be saved.
  final String saveDirectory;

  /// Current download status.
  final DownloadStatus status;

  /// Download progress: 0–100.
  final int progressPercent;

  /// Total file size in bytes from Content-Length header.
  /// Null if the server did not provide Content-Length.
  final int? totalBytes;

  /// Number of bytes downloaded so far.
  final int downloadedBytes;

  /// Current download speed in bytes per second.
  /// Null if not yet calculated (< 1 second of data).
  final int? speedBytesPerSec;

  /// When the task was created.
  final DateTime createdAt;

  /// When the download completed. Null if not finished.
  final DateTime? completedAt;

  /// Error message if status is [DownloadStatus.failed].
  final String? errorMessage;

  /// Whether this download should only run on Wi-Fi.
  final bool wifiOnly;

  const DownloadTaskEntity({
    required this.taskId,
    required this.url,
    required this.fileName,
    required this.saveDirectory,
    required this.status,
    required this.createdAt,
    this.progressPercent = 0,
    this.totalBytes,
    this.downloadedBytes = 0,
    this.speedBytesPerSec,
    this.completedAt,
    this.errorMessage,
    this.wifiOnly = false,
  });

  // ─── Computed Properties ───────────────────────────────────────────────

  String get absoluteFilePath => '$saveDirectory/$fileName';

  bool get isActive =>
      status == DownloadStatus.running || status == DownloadStatus.queued;

  bool get isFinished =>
      status == DownloadStatus.completed ||
      status == DownloadStatus.cancelled ||
      status == DownloadStatus.failed;

  /// Estimated seconds remaining. Null if speed is unknown.
  int? get etaSeconds {
    if (speedBytesPerSec == null || speedBytesPerSec == 0) return null;
    if (totalBytes == null) return null;
    final remaining = totalBytes! - downloadedBytes;
    return (remaining / speedBytesPerSec!).ceil();
  }

  String get formattedSpeed {
    if (speedBytesPerSec == null) return '-- KB/s';
    const kb = 1024;
    const mb = kb * 1024;
    if (speedBytesPerSec! >= mb) {
      return '${(speedBytesPerSec! / mb).toStringAsFixed(1)} MB/s';
    }
    return '${(speedBytesPerSec! / kb).toStringAsFixed(0)} KB/s';
  }

  DownloadTaskEntity copyWith({
    DownloadStatus? status,
    int? progressPercent,
    int? downloadedBytes,
    int? speedBytesPerSec,
    int? totalBytes,
    DateTime? completedAt,
    String? errorMessage,
  }) {
    return DownloadTaskEntity(
      taskId: taskId,
      url: url,
      fileName: fileName,
      saveDirectory: saveDirectory,
      status: status ?? this.status,
      createdAt: createdAt,
      progressPercent: progressPercent ?? this.progressPercent,
      totalBytes: totalBytes ?? this.totalBytes,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      speedBytesPerSec: speedBytesPerSec ?? this.speedBytesPerSec,
      completedAt: completedAt ?? this.completedAt,
      errorMessage: errorMessage ?? this.errorMessage,
      wifiOnly: wifiOnly,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DownloadTaskEntity &&
          runtimeType == other.runtimeType &&
          taskId == other.taskId;

  @override
  int get hashCode => taskId.hashCode;
}
