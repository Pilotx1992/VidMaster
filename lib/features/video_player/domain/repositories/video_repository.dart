import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/video_entity.dart';

/// Contract for all video library operations in the Domain layer.
///
/// The implementation lives in the Data layer and may combine:
///   - Android MediaStore (via a platform channel or `on_audio_query`)
///   - Local DB (for cached metadata: thumbnails, resume positions, favourites)
///
/// All methods return [Either<Failure, T>] so callers handle errors
/// explicitly without try/catch blocks.
abstract interface class VideoRepository {
  // ─── Library Queries ──────────────────────────────────────────────────

  /// Returns every video file found on device storage, excluding vault items.
  ///
  /// Implementation notes:
  ///   1. Query MediaStore for all video MIME types.
  ///   2. Enrich each result with cached data (thumbnail, lastPosition).
  ///   3. Filter out files whose path starts with the vault directory.
  Future<Either<Failure, List<VideoEntity>>> getAllVideos();

  /// Returns all videos inside a specific folder path.
  ///
  /// [folderPath] — absolute path, e.g. `/storage/emulated/0/Movies`
  Future<Either<Failure, List<VideoEntity>>> getVideosByFolder(
      String folderPath);

  /// Returns a deduplicated list of all folder names that contain videos.
  /// Used to populate the folder-browser screen.
  Future<Either<Failure, List<String>>> getAllVideoFolders();

  /// Full-text search across video titles.
  ///
  /// Matches partial, case-insensitive strings.
  /// Searches both the MediaStore display name and cached metadata.
  Future<Either<Failure, List<VideoEntity>>> searchVideos(String query);

  // ─── Playback State ───────────────────────────────────────────────────

  /// Persists the current playback position so the video can be resumed later.
  ///
  /// [videoPath]  — the absolute file path (used as the unique key)
  /// [positionMs] — position in milliseconds
  ///
  /// Called every 5 seconds during active playback and on player dispose.
  Future<Either<Failure, void>> savePlaybackPosition(
      String videoPath, int positionMs);

  /// Retrieves the last saved position for a given video path.
  /// Returns 0 if the video has never been played or position was cleared.
  Future<Either<Failure, int>> getPlaybackPosition(String videoPath);

  /// Clears the saved position (e.g. when the user finishes the video).
  Future<Either<Failure, void>> clearPlaybackPosition(String videoPath);

  // ─── Metadata & Thumbnails ────────────────────────────────────────────

  /// Generates a thumbnail for the given video and returns its cached path.
  ///
  /// Implementation notes:
  ///   - Uses `video_thumbnail` package to capture a frame at 20% of duration.
  ///   - Saves the JPEG thumbnail to app cache directory.
  ///   - Subsequent calls for the same path return the cached thumbnail
  ///     without re-generating.
  ///
  /// Returns [ThumbnailFailure] if the file is corrupt or unreadable.
  Future<Either<Failure, String>> generateThumbnail(String videoPath);

  /// Generates thumbnails for a batch of videos in the background.
  ///
  /// Used during library scan to pre-warm the cache.
  /// Progress is reported via the returned stream: each event is the
  /// thumbnail path of the most recently completed video.
  Stream<Either<Failure, String>> generateThumbnailsBatch(
      List<String> videoPaths);

  // ─── User Actions ─────────────────────────────────────────────────────

  /// Toggles the favourite status of a video and returns the updated entity.
  Future<Either<Failure, VideoEntity>> toggleFavourite(String videoPath);

  /// Returns all videos marked as favourite, ordered by last played date.
  Future<Either<Failure, List<VideoEntity>>> getFavouriteVideos();

  /// Increments the play count and updates [lastPlayedAt] for the given video.
  ///
  /// Call this once when a video starts playing (after first 10 seconds).
  Future<Either<Failure, void>> recordPlay(String videoPath);

  /// Returns the last [limit] played videos, ordered by [lastPlayedAt] desc.
  Future<Either<Failure, List<VideoEntity>>> getRecentlyPlayed(
      {int limit = 20});
}
