import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/audio_track_entity.dart';
import '../entities/playlist_entity.dart';
import '../repositories/music_repository.dart';

// ═══════════════════════════════════════════════════════════════════════════
// LIBRARY
// ═══════════════════════════════════════════════════════════════════════════

/// Returns all audio tracks found on device storage.
final class GetAllTracks
    implements UseCase<List<AudioTrackEntity>, NoParams> {
  final MusicRepository _repository;
  const GetAllTracks(this._repository);

  @override
  Future<Either<Failure, List<AudioTrackEntity>>> call(NoParams params) =>
      _repository.getAllTracks();
}

// ─────────────────────────────────────────────────────────────────────────

/// Syncs the local device storage songs into the Isar database.
final class SyncMusicLibrary implements UseCase<void, NoParams> {
  final MusicRepository _repository;
  const SyncMusicLibrary(this._repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) =>
      _repository.syncLibrary();
}

// ─────────────────────────────────────────────────────────────────────────

/// Returns tracks filtered by album name.
final class GetTracksByAlbum
    implements UseCase<List<AudioTrackEntity>, GetTracksByAlbumParams> {
  final MusicRepository _repository;
  const GetTracksByAlbum(this._repository);

  @override
  Future<Either<Failure, List<AudioTrackEntity>>> call(
      GetTracksByAlbumParams params) =>
      _repository.getTracksByAlbum(params.album);
}

final class GetTracksByAlbumParams {
  final String album;
  const GetTracksByAlbumParams({required this.album});
}

// ─────────────────────────────────────────────────────────────────────────

/// Returns tracks filtered by artist name.
final class GetTracksByArtist
    implements UseCase<List<AudioTrackEntity>, GetTracksByArtistParams> {
  final MusicRepository _repository;
  const GetTracksByArtist(this._repository);

  @override
  Future<Either<Failure, List<AudioTrackEntity>>> call(
      GetTracksByArtistParams params) =>
      _repository.getTracksByArtist(params.artist);
}

final class GetTracksByArtistParams {
  final String artist;
  const GetTracksByArtistParams({required this.artist});
}

// ─────────────────────────────────────────────────────────────────────────

/// Searches tracks by partial title match (case-insensitive).
final class SearchTracks
    implements UseCase<List<AudioTrackEntity>, SearchTracksParams> {
  final MusicRepository _repository;
  const SearchTracks(this._repository);

  @override
  Future<Either<Failure, List<AudioTrackEntity>>> call(
      SearchTracksParams params) {
    if (params.query.trim().isEmpty) {
      return Future.value(const Right([]));
    }
    return _repository.searchTracks(params.query.trim());
  }
}

final class SearchTracksParams {
  final String query;
  const SearchTracksParams({required this.query});
}

// ─────────────────────────────────────────────────────────────────────────

/// Returns all unique album names.
final class GetAllAlbums implements UseCase<List<String>, NoParams> {
  final MusicRepository _repository;
  const GetAllAlbums(this._repository);

  @override
  Future<Either<Failure, List<String>>> call(NoParams params) =>
      _repository.getAllAlbums();
}

// ─────────────────────────────────────────────────────────────────────────

/// Returns all unique artist names.
final class GetAllArtists implements UseCase<List<String>, NoParams> {
  final MusicRepository _repository;
  const GetAllArtists(this._repository);

  @override
  Future<Either<Failure, List<String>>> call(NoParams params) =>
      _repository.getAllArtists();
}

// ═══════════════════════════════════════════════════════════════════════════
// PLAYBACK STATE
// ═══════════════════════════════════════════════════════════════════════════

/// Records a track play: increments play count + updates lastPlayedAt.
final class RecordMusicPlay
    implements UseCase<void, RecordMusicPlayParams> {
  final MusicRepository _repository;
  const RecordMusicPlay(this._repository);

  @override
  Future<Either<Failure, void>> call(RecordMusicPlayParams params) =>
      _repository.recordPlay(params.trackId);
}

final class RecordMusicPlayParams {
  final String trackId;
  const RecordMusicPlayParams({required this.trackId});
}

// ─────────────────────────────────────────────────────────────────────────

/// Returns recently played tracks, newest first.
final class GetRecentlyPlayedTracks
    implements UseCase<List<AudioTrackEntity>, GetRecentlyPlayedTracksParams> {
  final MusicRepository _repository;
  const GetRecentlyPlayedTracks(this._repository);

  @override
  Future<Either<Failure, List<AudioTrackEntity>>> call(
      GetRecentlyPlayedTracksParams params) =>
      _repository.getRecentlyPlayed(limit: params.limit);
}

final class GetRecentlyPlayedTracksParams {
  final int limit;
  const GetRecentlyPlayedTracksParams({this.limit = 20});
}

// ─────────────────────────────────────────────────────────────────────────

/// Returns most played tracks, highest count first.
final class GetMostPlayedTracks
    implements UseCase<List<AudioTrackEntity>, GetMostPlayedTracksParams> {
  final MusicRepository _repository;
  const GetMostPlayedTracks(this._repository);

  @override
  Future<Either<Failure, List<AudioTrackEntity>>> call(
      GetMostPlayedTracksParams params) =>
      _repository.getMostPlayed(limit: params.limit);
}

final class GetMostPlayedTracksParams {
  final int limit;
  const GetMostPlayedTracksParams({this.limit = 20});
}

// ═══════════════════════════════════════════════════════════════════════════
// FAVOURITES
// ═══════════════════════════════════════════════════════════════════════════

/// Toggles the favourite status for a track.
final class ToggleMusicFavourite
    implements UseCase<AudioTrackEntity, ToggleMusicFavouriteParams> {
  final MusicRepository _repository;
  const ToggleMusicFavourite(this._repository);

  @override
  Future<Either<Failure, AudioTrackEntity>> call(
      ToggleMusicFavouriteParams params) =>
      _repository.toggleFavourite(params.trackId);
}

final class ToggleMusicFavouriteParams {
  final String trackId;
  const ToggleMusicFavouriteParams({required this.trackId});
}

// ─────────────────────────────────────────────────────────────────────────

/// Returns all favourite tracks.
final class GetFavouriteTracks
    implements UseCase<List<AudioTrackEntity>, NoParams> {
  final MusicRepository _repository;
  const GetFavouriteTracks(this._repository);

  @override
  Future<Either<Failure, List<AudioTrackEntity>>> call(NoParams params) =>
      _repository.getFavouriteTracks();
}

// ═══════════════════════════════════════════════════════════════════════════
// PLAYLISTS
// ═══════════════════════════════════════════════════════════════════════════

/// Returns all user-created playlists.
final class GetAllPlaylists
    implements UseCase<List<PlaylistEntity>, NoParams> {
  final MusicRepository _repository;
  const GetAllPlaylists(this._repository);

  @override
  Future<Either<Failure, List<PlaylistEntity>>> call(NoParams params) =>
      _repository.getAllPlaylists();
}

// ─────────────────────────────────────────────────────────────────────────

/// Creates a new playlist with the given name.
final class CreatePlaylist
    implements UseCase<PlaylistEntity, CreatePlaylistParams> {
  final MusicRepository _repository;
  const CreatePlaylist(this._repository);

  @override
  Future<Either<Failure, PlaylistEntity>> call(
      CreatePlaylistParams params) {
    if (params.name.trim().isEmpty) {
      return Future.value(
        const Left(CacheFailure('Playlist name cannot be empty.')),
      );
    }
    return _repository.createPlaylist(params.name.trim());
  }
}

final class CreatePlaylistParams {
  final String name;
  const CreatePlaylistParams({required this.name});
}

// ─────────────────────────────────────────────────────────────────────────

/// Adds a track to a playlist.
final class AddTrackToPlaylist
    implements UseCase<PlaylistEntity, AddTrackToPlaylistParams> {
  final MusicRepository _repository;
  const AddTrackToPlaylist(this._repository);

  @override
  Future<Either<Failure, PlaylistEntity>> call(
      AddTrackToPlaylistParams params) =>
      _repository.addTrackToPlaylist(
        playlistId: params.playlistId,
        trackId: params.trackId,
      );
}

final class AddTrackToPlaylistParams {
  final String playlistId;
  final String trackId;
  const AddTrackToPlaylistParams({
    required this.playlistId,
    required this.trackId,
  });
}

// ─────────────────────────────────────────────────────────────────────────

/// Removes a track from a playlist.
final class RemoveTrackFromPlaylist
    implements UseCase<PlaylistEntity, RemoveTrackFromPlaylistParams> {
  final MusicRepository _repository;
  const RemoveTrackFromPlaylist(this._repository);

  @override
  Future<Either<Failure, PlaylistEntity>> call(
      RemoveTrackFromPlaylistParams params) =>
      _repository.removeTrackFromPlaylist(
        playlistId: params.playlistId,
        trackId: params.trackId,
      );
}

final class RemoveTrackFromPlaylistParams {
  final String playlistId;
  final String trackId;
  const RemoveTrackFromPlaylistParams({
    required this.playlistId,
    required this.trackId,
  });
}

// ─────────────────────────────────────────────────────────────────────────

/// Deletes a playlist permanently.
final class DeletePlaylist
    implements UseCase<void, DeletePlaylistParams> {
  final MusicRepository _repository;
  const DeletePlaylist(this._repository);

  @override
  Future<Either<Failure, void>> call(DeletePlaylistParams params) =>
      _repository.deletePlaylist(params.playlistId);
}

final class DeletePlaylistParams {
  final String playlistId;
  const DeletePlaylistParams({required this.playlistId});
}

// ─────────────────────────────────────────────────────────────────────────

/// Renames an existing playlist.
final class RenamePlaylist
    implements UseCase<PlaylistEntity, RenamePlaylistParams> {
  final MusicRepository _repository;
  const RenamePlaylist(this._repository);

  @override
  Future<Either<Failure, PlaylistEntity>> call(
      RenamePlaylistParams params) {
    if (params.newName.trim().isEmpty) {
      return Future.value(
        const Left(CacheFailure('Playlist name cannot be empty.')),
      );
    }
    return _repository.renamePlaylist(
      playlistId: params.playlistId,
      newName: params.newName.trim(),
    );
  }
}

final class RenamePlaylistParams {
  final String playlistId;
  final String newName;
  const RenamePlaylistParams({
    required this.playlistId,
    required this.newName,
  });
}

// ─────────────────────────────────────────────────────────────────────────

/// Returns all tracks inside a playlist, in order.
final class GetPlaylistTracks
    implements UseCase<List<AudioTrackEntity>, GetPlaylistTracksParams> {
  final MusicRepository _repository;
  const GetPlaylistTracks(this._repository);

  @override
  Future<Either<Failure, List<AudioTrackEntity>>> call(
      GetPlaylistTracksParams params) =>
      _repository.getPlaylistTracks(params.playlistId);
}

final class GetPlaylistTracksParams {
  final String playlistId;
  const GetPlaylistTracksParams({required this.playlistId});
}
