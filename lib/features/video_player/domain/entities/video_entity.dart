/// Pure Dart domain entity representing a single video file.
///
/// This class lives in the Domain layer and has ZERO dependencies
/// on Flutter, Isar, or any third-party library.
/// The Data layer is responsible for mapping to/from this entity.
final class VideoEntity {
  /// Absolute file path on device storage.
  /// Example: `/storage/emulated/0/Movies/my_video.mp4`
  final String filePath;

  /// Display name (file name without extension).
  final String title;

  /// Parent folder name (used for folder-based grouping in the UI).
  final String folderName;

  /// Full path to the cached thumbnail image, or null if not yet generated.
  final String? thumbnailPath;

  /// Total duration in milliseconds. Null if metadata could not be read.
  final int? durationMs;

  /// Last saved playback position in milliseconds (for resume).
  /// Null means the video has never been played.
  final int? lastPositionMs;

  /// File size in bytes.
  final int fileSizeBytes;

  /// Video resolution string. Example: "1920x1080"
  final String? resolution;

  /// Timestamp of last playback. Used for "Recently Played" sorting.
  final DateTime? lastPlayedAt;

  /// Number of times this file has been played.
  final int playCount;

  /// Whether the user has marked this video as a favourite.
  final bool isFavourite;

  /// Whether this file has been moved into the encrypted vault.
  /// When true, the file is no longer accessible from the main library.
  final bool isInVault;

  const VideoEntity({
    required this.filePath,
    required this.title,
    required this.folderName,
    required this.fileSizeBytes,
    this.thumbnailPath,
    this.durationMs,
    this.lastPositionMs,
    this.resolution,
    this.lastPlayedAt,
    this.playCount = 0,
    this.isFavourite = false,
    this.isInVault = false,
  });

  // ─── Computed Properties ───────────────────────────────────────────────

  int get id => filePath.hashCode;
  String get fileName => title;
  bool get isFavorite => isFavourite;
  bool get isWatched => playCount > 0;

  /// File extension in lowercase. Example: `mkv`, `mp4`
  String get extension =>
      filePath.contains('.') ? filePath.split('.').last.toLowerCase() : '';

  /// Whether the video has a saved resume position to return to.
  bool get hasResumePosition =>
      lastPositionMs != null && lastPositionMs! > 5000;

  /// Resume progress as a 0.0–1.0 fraction.
  /// Returns 0.0 if duration or position is unknown.
  double get resumeProgress {
    if (durationMs == null || durationMs == 0 || lastPositionMs == null) {
      return 0.0;
    }
    return (lastPositionMs! / durationMs!).clamp(0.0, 1.0);
  }

  /// Human-readable file size. Example: "1.4 GB", "720 MB"
  String get formattedSize {
    const kb = 1024;
    const mb = kb * 1024;
    const gb = mb * 1024;
    if (fileSizeBytes >= gb) {
      return '${(fileSizeBytes / gb).toStringAsFixed(1)} GB';
    } else if (fileSizeBytes >= mb) {
      return '${(fileSizeBytes / mb).toStringAsFixed(0)} MB';
    } else {
      return '${(fileSizeBytes / kb).toStringAsFixed(0)} KB';
    }
  }

  /// Human-readable duration. Example: "1:23:45", "5:30"
  String get formattedDuration {
    if (durationMs == null) return '--:--';
    final totalSeconds = durationMs! ~/ 1000;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  // ─── Value Equality ───────────────────────────────────────────────────

  /// Two VideoEntity instances are equal if they point to the same file path.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoEntity &&
          runtimeType == other.runtimeType &&
          filePath == other.filePath;

  @override
  int get hashCode => filePath.hashCode;

  // ─── CopyWith ────────────────────────────────────────────────────────

  VideoEntity copyWith({
    String? filePath,
    String? title,
    String? folderName,
    int? fileSizeBytes,
    String? thumbnailPath,
    int? durationMs,
    int? lastPositionMs,
    String? resolution,
    DateTime? lastPlayedAt,
    int? playCount,
    bool? isFavourite,
    bool? isInVault,
  }) {
    return VideoEntity(
      filePath: filePath ?? this.filePath,
      title: title ?? this.title,
      folderName: folderName ?? this.folderName,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      durationMs: durationMs ?? this.durationMs,
      lastPositionMs: lastPositionMs ?? this.lastPositionMs,
      resolution: resolution ?? this.resolution,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      playCount: playCount ?? this.playCount,
      isFavourite: isFavourite ?? this.isFavourite,
      isInVault: isInVault ?? this.isInVault,
    );
  }

  @override
  String toString() =>
      'VideoEntity(title: $title, duration: ${durationMs}ms, path: $filePath)';
}
