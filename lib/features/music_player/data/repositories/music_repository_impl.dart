import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/audio_track_entity.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../../domain/entities/playlist_entity.dart';
import '../../domain/repositories/music_repository.dart';
import '../datasources/music_local_data_source.dart';
import '../models/audio_track_model.dart';

/// Production implementation of [MusicRepository].
///
/// Handles data access via [MusicLocalDataSource] (ObjectBox) and maps
/// models to Domain entities with strict error boundaries.
class MusicRepositoryImpl implements MusicRepository {
  final MusicLocalDataSource localDataSource;
  final OnAudioQuery audioQuery;

  MusicRepositoryImpl({
    required this.localDataSource,
    required this.audioQuery,
  });

  @override
  Future<Either<Failure, void>> syncLibrary() async {
    try {
      final hasPermission = await audioQuery.checkAndRequest(
        retryRequest: true,
      );

      if (!hasPermission) {
        return const Left(CacheFailure('Storage permission denied.'));
      }

      final songs = await audioQuery.querySongs(
        ignoreCase: true,
      );

      for (final song in songs) {
        if (song.isMusic != true) continue;
        
        // Skip if already exists (avoids overwriting playCount, etc.)
        final existing = await localDataSource.searchTracks(song.title);
        if (existing.any((t) => t.filePath == song.data)) continue;

        final newTrack = AudioTrackModel(
          filePath: song.data,
          title: song.title,
          artist: song.artist ?? 'Unknown',
          album: song.album ?? 'Unknown',
          durationMs: song.duration ?? 0,
          fileSizeBytes: song.size,
          trackNumber: song.track,
        );
        await localDataSource.saveTrack(newTrack);
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to sync library: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<AudioTrackEntity>>> getAllTracks() async {
    try {
      final models = await localDataSource.getAllTracks();
      final entities = models.map((m) => m.toDomain()).toList();
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Failed to fetch tracks: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<AudioTrackEntity>>> getTracksByAlbum(
      String album) async {
    try {
      final models = await localDataSource.getTracksByAlbum(album);
      final entities = models.map((m) => m.toDomain()).toList();
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Failed to fetch album tracks: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<AudioTrackEntity>>> getTracksByArtist(
      String artist) async {
    try {
      final models = await localDataSource.getTracksByArtist(artist);
      final entities = models.map((m) => m.toDomain()).toList();
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Failed to fetch artist tracks: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<AudioTrackEntity>>> searchTracks(
      String query) async {
    try {
      final models = await localDataSource.searchTracks(query);
      final entities = models.map((m) => m.toDomain()).toList();
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Failed to search tracks: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getAllAlbums() async {
    try {
      final albums = await localDataSource.getAllAlbums();
      return Right(albums);
    } catch (e) {
      return Left(CacheFailure('Failed to fetch albums: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getAllArtists() async {
    try {
      final artists = await localDataSource.getAllArtists();
      return Right(artists);
    } catch (e) {
      return Left(CacheFailure('Failed to fetch artists: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> recordPlay(String trackId) async {
    try {
      final model = await localDataSource.getTrackById(trackId);
      if (model != null) {
        model.playCount += 1;
        model.lastPlayedAt = DateTime.now();
        await localDataSource.saveTrack(model);
        return const Right(null);
      } else {
        return Left(FileNotFoundFailure(trackId));
      }
    } catch (e) {
      return Left(CacheFailure('Failed to record play: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<AudioTrackEntity>>> getRecentlyPlayed({
    int limit = 20,
  }) async {
    try {
      final models = await localDataSource.getRecentlyPlayed(limit: limit);
      final entities = models.map((m) => m.toDomain()).toList();
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Failed to fetch recent tracks: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<AudioTrackEntity>>> getMostPlayed({
    int limit = 20,
  }) async {
    try {
      final models = await localDataSource.getMostPlayed(limit: limit);
      final entities = models.map((m) => m.toDomain()).toList();
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Failed to fetch most played: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, AudioTrackEntity>> toggleFavourite(
      String trackId) async {
    try {
      final model = await localDataSource.getTrackById(trackId);
      if (model != null) {
        model.isFavourite = !model.isFavourite;
        await localDataSource.saveTrack(model);
        return Right(model.toDomain());
      } else {
        return Left(FileNotFoundFailure(trackId));
      }
    } catch (e) {
      return Left(CacheFailure('Failed to toggle favourite: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<AudioTrackEntity>>> getFavouriteTracks() async {
    try {
      final models = await localDataSource.getFavouriteTracks();
      final entities = models.map((m) => m.toDomain()).toList();
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Failed to fetch favourites: ${e.toString()}'));
    }
  }

  // ─── Playlists ─────────────────────────────────────────────────────────
  // Note: PlaylistModel was not requested in the DB setup constraint, so 
  // these methods return an unimplemented CacheFailure for now.

  @override
  Future<Either<Failure, List<PlaylistEntity>>> getAllPlaylists() async {
    return const Left(CacheFailure('Playlists not implemented in local DB yet'));
  }

  @override
  Future<Either<Failure, PlaylistEntity>> createPlaylist(String name) async {
    return const Left(CacheFailure('Playlists not implemented in local DB yet'));
  }

  @override
  Future<Either<Failure, PlaylistEntity>> addTrackToPlaylist({
    required String playlistId,
    required String trackId,
  }) async {
    return const Left(CacheFailure('Playlists not implemented in local DB yet'));
  }

  @override
  Future<Either<Failure, PlaylistEntity>> removeTrackFromPlaylist({
    required String playlistId,
    required String trackId,
  }) async {
    return const Left(CacheFailure('Playlists not implemented in local DB yet'));
  }

  @override
  Future<Either<Failure, void>> deletePlaylist(String playlistId) async {
    return const Left(CacheFailure('Playlists not implemented in local DB yet'));
  }

  @override
  Future<Either<Failure, PlaylistEntity>> renamePlaylist({
    required String playlistId,
    required String newName,
  }) async {
    return const Left(CacheFailure('Playlists not implemented in local DB yet'));
  }

  @override
  Future<Either<Failure, List<AudioTrackEntity>>> getPlaylistTracks(
      String playlistId) async {
    return const Left(CacheFailure('Playlists not implemented in local DB yet'));
  }
}
