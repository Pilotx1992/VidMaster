import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/audio_track_entity.dart';
import '../entities/playlist_entity.dart';

/// Contract for all music library operations.
abstract interface class MusicRepository {
  // ─── Library ───────────────────────────────────────────────────────────

  Future<Either<Failure, void>> syncLibrary();
  Future<Either<Failure, List<AudioTrackEntity>>> getAllTracks();
  Future<Either<Failure, List<AudioTrackEntity>>> getTracksByAlbum(
      String album);
  Future<Either<Failure, List<AudioTrackEntity>>> getTracksByArtist(
      String artist);
  Future<Either<Failure, List<AudioTrackEntity>>> searchTracks(String query);
  Future<Either<Failure, List<String>>> getAllAlbums();
  Future<Either<Failure, List<String>>> getAllArtists();

  // ─── Playback State ────────────────────────────────────────────────────

  Future<Either<Failure, void>> recordPlay(String trackId);
  Future<Either<Failure, List<AudioTrackEntity>>> getRecentlyPlayed(
      {int limit = 20});
  Future<Either<Failure, List<AudioTrackEntity>>> getMostPlayed(
      {int limit = 20});

  // ─── Favourites ────────────────────────────────────────────────────────

  Future<Either<Failure, AudioTrackEntity>> toggleFavourite(String trackId);
  Future<Either<Failure, List<AudioTrackEntity>>> getFavouriteTracks();

  // ─── Playlists ─────────────────────────────────────────────────────────

  Future<Either<Failure, List<PlaylistEntity>>> getAllPlaylists();
  Future<Either<Failure, PlaylistEntity>> createPlaylist(String name);
  Future<Either<Failure, PlaylistEntity>> addTrackToPlaylist({
    required String playlistId,
    required String trackId,
  });
  Future<Either<Failure, PlaylistEntity>> removeTrackFromPlaylist({
    required String playlistId,
    required String trackId,
  });
  Future<Either<Failure, void>> deletePlaylist(String playlistId);
  Future<Either<Failure, PlaylistEntity>> renamePlaylist({
    required String playlistId,
    required String newName,
  });
  Future<Either<Failure, List<AudioTrackEntity>>> getPlaylistTracks(
      String playlistId);
}
