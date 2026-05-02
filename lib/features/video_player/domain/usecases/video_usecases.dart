import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/video_entity.dart';
import '../repositories/video_repository.dart';

// ═══════════════════════════════════════════════════════════════════════════
// LIBRARY
// ═══════════════════════════════════════════════════════════════════════════

/// Fetches the full video library from device storage.
///
/// Vault items are excluded automatically by the repository.
/// The list is returned in "last played first" order.
final class GetAllVideos implements UseCase<List<VideoEntity>, NoParams> {
  final VideoRepository _repository;
  const GetAllVideos(this._repository);

  @override
  Future<Either<Failure, List<VideoEntity>>> call(NoParams params) =>
      _repository.getAllVideos();
}

// ─────────────────────────────────────────────────────────────────────────

/// Scans device storage for video files and syncs them into the local DB.
final class SyncVideoLibrary implements UseCase<void, NoParams> {
  final VideoRepository _repository;
  const SyncVideoLibrary(this._repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) =>
      _repository.syncLibrary();
}

// ─────────────────────────────────────────────────────────────────────────

/// Fetches videos from a specific folder path.
final class GetVideosByFolder
    implements UseCase<List<VideoEntity>, GetVideosByFolderParams> {
  final VideoRepository _repository;
  const GetVideosByFolder(this._repository);

  @override
  Future<Either<Failure, List<VideoEntity>>> call(
      GetVideosByFolderParams params) =>
      _repository.getVideosByFolder(params.folderPath);
}

final class GetVideosByFolderParams {
  final String folderPath;
  const GetVideosByFolderParams({required this.folderPath});
}

// ─────────────────────────────────────────────────────────────────────────

/// Returns a list of all folder names that contain at least one video.
final class GetAllVideoFolders
    implements UseCase<List<String>, NoParams> {
  final VideoRepository _repository;
  const GetAllVideoFolders(this._repository);

  @override
  Future<Either<Failure, List<String>>> call(NoParams params) =>
      _repository.getAllVideoFolders();
}

// ─────────────────────────────────────────────────────────────────────────

/// Searches videos by partial title match (case-insensitive).
final class SearchVideos
    implements UseCase<List<VideoEntity>, SearchVideosParams> {
  final VideoRepository _repository;
  const SearchVideos(this._repository);

  @override
  Future<Either<Failure, List<VideoEntity>>> call(
      SearchVideosParams params) {
    if (params.query.trim().isEmpty) {
      // Avoid a pointless DB round-trip for empty queries.
      return Future.value(const Right([]));
    }
    return _repository.searchVideos(params.query.trim());
  }
}

final class SearchVideosParams {
  final String query;
  const SearchVideosParams({required this.query});
}

// ═══════════════════════════════════════════════════════════════════════════
// PLAYBACK STATE
// ═══════════════════════════════════════════════════════════════════════════

/// Saves the current playback position for a video.
///
/// Should be called:
///   - Every 5 seconds during active playback (via a periodic timer).
///   - Immediately when the player is paused or disposed.
final class SavePlaybackPosition
    implements UseCase<void, SavePlaybackPositionParams> {
  final VideoRepository _repository;
  const SavePlaybackPosition(this._repository);

  @override
  Future<Either<Failure, void>> call(SavePlaybackPositionParams params) {
    // Guard: don't save if position is at the very beginning (< 5 seconds).
    if (params.positionMs < 5000) {
      return Future.value(const Right(null));
    }
    return _repository.savePlaybackPosition(
        params.videoPath, params.positionMs);
  }
}

final class SavePlaybackPositionParams {
  final String videoPath;
  final int positionMs;
  const SavePlaybackPositionParams({
    required this.videoPath,
    required this.positionMs,
  });
}

// ─────────────────────────────────────────────────────────────────────────

/// Retrieves the last saved playback position for a video.
/// Returns 0 if the video has never been played.
final class GetPlaybackPosition
    implements UseCase<int, GetPlaybackPositionParams> {
  final VideoRepository _repository;
  const GetPlaybackPosition(this._repository);

  @override
  Future<Either<Failure, int>> call(GetPlaybackPositionParams params) =>
      _repository.getPlaybackPosition(params.videoPath);
}

final class GetPlaybackPositionParams {
  final String videoPath;
  const GetPlaybackPositionParams({required this.videoPath});
}

// ─────────────────────────────────────────────────────────────────────────

/// Clears the saved position (e.g. when video finishes or user resets).
final class ClearPlaybackPosition
    implements UseCase<void, ClearPlaybackPositionParams> {
  final VideoRepository _repository;
  const ClearPlaybackPosition(this._repository);

  @override
  Future<Either<Failure, void>> call(
      ClearPlaybackPositionParams params) =>
      _repository.clearPlaybackPosition(params.videoPath);
}

final class ClearPlaybackPositionParams {
  final String videoPath;
  const ClearPlaybackPositionParams({required this.videoPath});
}

// ═══════════════════════════════════════════════════════════════════════════
// THUMBNAILS
// ═══════════════════════════════════════════════════════════════════════════

/// Generates (or returns cached) thumbnail for a single video.
/// Returns the absolute path to the saved JPEG thumbnail.
final class GenerateThumbnail
    implements UseCase<String, GenerateThumbnailParams> {
  final VideoRepository _repository;
  const GenerateThumbnail(this._repository);

  @override
  Future<Either<Failure, String>> call(GenerateThumbnailParams params) =>
      _repository.generateThumbnail(params.videoPath);
}

final class GenerateThumbnailParams {
  final String videoPath;
  const GenerateThumbnailParams({required this.videoPath});
}

// ─────────────────────────────────────────────────────────────────────────

/// Generates thumbnails for multiple videos as a stream.
///
/// Emits one event per completed thumbnail so the UI can update
/// incrementally rather than waiting for the entire batch.
final class GenerateThumbnailsBatch
    implements StreamUseCase<String, GenerateThumbnailsBatchParams> {
  final VideoRepository _repository;
  const GenerateThumbnailsBatch(this._repository);

  @override
  Stream<Either<Failure, String>> call(
      GenerateThumbnailsBatchParams params) =>
      _repository.generateThumbnailsBatch(params.videoPaths);
}

final class GenerateThumbnailsBatchParams {
  final List<String> videoPaths;
  const GenerateThumbnailsBatchParams({required this.videoPaths});
}

// ═══════════════════════════════════════════════════════════════════════════
// USER ACTIONS
// ═══════════════════════════════════════════════════════════════════════════

/// Toggles the favourite status for a video.
/// Returns the updated [VideoEntity] with [isFavourite] flipped.
final class ToggleFavourite
    implements UseCase<VideoEntity, ToggleFavouriteParams> {
  final VideoRepository _repository;
  const ToggleFavourite(this._repository);

  @override
  Future<Either<Failure, VideoEntity>> call(
      ToggleFavouriteParams params) =>
      _repository.toggleFavourite(params.videoPath);
}

final class ToggleFavouriteParams {
  final String videoPath;
  const ToggleFavouriteParams({required this.videoPath});
}

// ─────────────────────────────────────────────────────────────────────────

/// Returns all videos the user has marked as favourite.
final class GetFavouriteVideos
    implements UseCase<List<VideoEntity>, NoParams> {
  final VideoRepository _repository;
  const GetFavouriteVideos(this._repository);

  @override
  Future<Either<Failure, List<VideoEntity>>> call(NoParams params) =>
      _repository.getFavouriteVideos();
}

// ─────────────────────────────────────────────────────────────────────────

/// Records a video play: increments play count + updates lastPlayedAt.
///
/// Call this once when playback has been ongoing for at least 10 seconds
/// to avoid counting accidental taps.
final class RecordVideoPlay
    implements UseCase<void, RecordVideoPlayParams> {
  final VideoRepository _repository;
  const RecordVideoPlay(this._repository);

  @override
  Future<Either<Failure, void>> call(RecordVideoPlayParams params) =>
      _repository.recordPlay(params.videoPath);
}

final class RecordVideoPlayParams {
  final String videoPath;
  const RecordVideoPlayParams({required this.videoPath});
}

// ─────────────────────────────────────────────────────────────────────────

/// Returns recently played videos, newest first.
final class GetRecentlyPlayed
    implements UseCase<List<VideoEntity>, GetRecentlyPlayedParams> {
  final VideoRepository _repository;
  const GetRecentlyPlayed(this._repository);

  @override
  Future<Either<Failure, List<VideoEntity>>> call(
      GetRecentlyPlayedParams params) =>
      _repository.getRecentlyPlayed(limit: params.limit);
}

final class GetRecentlyPlayedParams {
  final int limit;
  const GetRecentlyPlayedParams({this.limit = 20});
}
