import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/audio_track_entity.dart';
import 'package:on_audio_query/on_audio_query.dart' as audio_query;
import '../../domain/entities/playlist_entity.dart';
import '../../domain/repositories/music_repository.dart';
import '../datasources/music_local_data_source.dart';
import '../models/audio_track_model.dart';
import '../models/playlist_model.dart';

/// Production implementation of [MusicRepository].
///
/// Handles data access via [MusicLocalDataSource] (ObjectBox) and maps
/// models to Domain entities with strict error boundaries.
class MusicRepositoryImpl implements MusicRepository {
  final MusicLocalDataSource localDataSource;
  final audio_query.OnAudioQuery audioQuery;
  static const Set<String> _supportedCoverExtensions = {
    '.jpg',
    '.jpeg',
    '.png',
    '.webp',
  };

  MusicRepositoryImpl({
    required this.localDataSource,
    required this.audioQuery,
  });

  String _fileExtension(String path) {
    final fileName = path.split(RegExp(r'[\\/]')).last;
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex <= 0 || dotIndex == fileName.length - 1) {
      return '';
    }
    return fileName.substring(dotIndex);
  }

  Future<Directory> _getManagedCoversDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final coversDir = Directory(
      '${appDir.path}${Platform.pathSeparator}music_covers',
    );
    if (!await coversDir.exists()) {
      await coversDir.create(recursive: true);
    }
    return coversDir;
  }

  Future<void> _updatePlaylistTrackReferences({
    required AudioTrackEntity track,
    String? replacementTrackId,
  }) async {
    final playlists = await localDataSource.getAllPlaylists();
    for (final playlist in playlists) {
      var changed = false;
      final updatedIds = <String>[];

      for (final id in playlist.trackIds) {
        if (id == track.id || id == track.filePath) {
          changed = true;
          if (replacementTrackId != null &&
              !updatedIds.contains(replacementTrackId)) {
            updatedIds.add(replacementTrackId);
          }
          continue;
        }
        updatedIds.add(id);
      }

      if (!changed) {
        continue;
      }

      playlist.trackIds = updatedIds;
      playlist.updatedAt = DateTime.now();
      await localDataSource.savePlaylist(playlist);
    }
  }

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
      return Left(
          CacheFailure('Failed to fetch album tracks: ${e.toString()}'));
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
      return Left(
          CacheFailure('Failed to fetch artist tracks: ${e.toString()}'));
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
  Future<Either<Failure, AudioTrackEntity>> renameTrack({
    required String filePath,
    required String newName,
  }) async {
    try {
      final trimmedName = newName.trim();
      if (trimmedName.isEmpty) {
        return const Left(CacheFailure('Track name cannot be empty.'));
      }

      final model = await localDataSource.getTrackByFilePath(filePath);
      if (model == null) {
        return Left(FileNotFoundFailure(filePath));
      }

      final sourceFile = File(filePath);
      if (!await sourceFile.exists()) {
        return Left(FileNotFoundFailure(filePath));
      }

      final extension = _fileExtension(filePath);
      final targetPath =
          '${sourceFile.parent.path}${Platform.pathSeparator}$trimmedName$extension';

      if (targetPath == filePath) {
        return Right(model.toDomain());
      }

      if (await File(targetPath).exists()) {
        return const Left(
          CacheFailure('A file with that name already exists.'),
        );
      }

      await sourceFile.rename(targetPath);

      final oldTrack = model.toDomain();
      final updatedModel = AudioTrackModel(
        filePath: targetPath,
        title: trimmedName,
        artist: model.artist,
        album: model.album,
        durationMs: model.durationMs,
        fileSizeBytes: model.fileSizeBytes,
        albumArtPath: model.albumArtPath,
        trackNumber: model.trackNumber,
        year: model.year,
        lastPlayedAt: model.lastPlayedAt,
        playCount: model.playCount,
        isFavourite: model.isFavourite,
      );

      await localDataSource.deleteTrackByFilePath(filePath);
      await localDataSource.saveTrack(updatedModel);
      await _updatePlaylistTrackReferences(
        track: oldTrack,
        replacementTrackId: updatedModel.toDomain().id,
      );

      return Right(updatedModel.toDomain());
    } on FileSystemException catch (e, stackTrace) {
      return Left(
        FileSystemFailure(
          'Failed to rename track: ${e.message}',
          stackTrace: stackTrace,
        ),
      );
    } catch (e) {
      return Left(CacheFailure('Failed to rename track: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, AudioTrackEntity>> updateTrackCover({
    required String filePath,
    required String coverArtPath,
  }) async {
    try {
      final trimmedPath = coverArtPath.trim();
      if (trimmedPath.isEmpty) {
        return const Left(CacheFailure('Cover image path cannot be empty.'));
      }

      final model = await localDataSource.getTrackByFilePath(filePath);
      if (model == null) {
        return Left(FileNotFoundFailure(filePath));
      }

      final sourceFile = File(trimmedPath);
      if (!await sourceFile.exists()) {
        return Left(FileNotFoundFailure(trimmedPath));
      }

      final extension = _fileExtension(trimmedPath).toLowerCase();
      if (!_supportedCoverExtensions.contains(extension)) {
        return const Left(
          CacheFailure('Unsupported cover format. Use JPG, PNG, or WEBP.'),
        );
      }

      final coversDir = await _getManagedCoversDirectory();
      final targetFile = File(
        '${coversDir.path}${Platform.pathSeparator}track_${model.id}$extension',
      );

      if (sourceFile.absolute.path != targetFile.absolute.path) {
        await sourceFile.copy(targetFile.path);
      }

      final previousManagedPath = model.albumArtPath;
      model.albumArtPath = targetFile.path;
      await localDataSource.saveTrack(model);

      if (previousManagedPath != null &&
          previousManagedPath != targetFile.path &&
          previousManagedPath.startsWith(coversDir.path)) {
        try {
          final previousFile = File(previousManagedPath);
          if (await previousFile.exists()) {
            await previousFile.delete();
          }
        } catch (_) {
          // Keep the new cover even if the previous managed file cleanup fails.
        }
      }

      return Right(model.toDomain());
    } on FileSystemException catch (e, stackTrace) {
      return Left(
        FileSystemFailure(
          'Failed to store cover image: ${e.message}',
          stackTrace: stackTrace,
        ),
      );
    } catch (e) {
      return Left(CacheFailure('Failed to update cover: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTrack(String filePath) async {
    try {
      final model = await localDataSource.getTrackByFilePath(filePath);
      if (model == null) {
        return Left(FileNotFoundFailure(filePath));
      }

      final track = model.toDomain();
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }

      final deleted = await localDataSource.deleteTrackByFilePath(filePath);
      if (!deleted) {
        return Left(FileNotFoundFailure(filePath));
      }

      await _updatePlaylistTrackReferences(track: track);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to delete track: ${e.toString()}'));
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
      return Left(
          CacheFailure('Failed to fetch recent tracks: ${e.toString()}'));
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

  @override
  Future<Either<Failure, List<PlaylistEntity>>> getAllPlaylists() async {
    try {
      final models = await localDataSource.getAllPlaylists();
      return Right(models.map((m) => m.toDomain()).toList());
    } catch (e) {
      return Left(CacheFailure('Failed to fetch playlists: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, PlaylistEntity>> createPlaylist(String name) async {
    try {
      final now = DateTime.now();
      final model = PlaylistModel(
        playlistId: const Uuid().v4(),
        name: name.trim(),
        trackIds: const [],
        createdAt: now,
        updatedAt: now,
      );
      await localDataSource.savePlaylist(model);
      return Right(model.toDomain());
    } catch (e) {
      return Left(CacheFailure('Failed to create playlist: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, PlaylistEntity>> addTrackToPlaylist({
    required String playlistId,
    required String trackId,
  }) async {
    try {
      final playlist = await localDataSource.getPlaylistById(playlistId);
      if (playlist == null) return Left(FileNotFoundFailure(playlistId));

      if (!playlist.trackIds.contains(trackId)) {
        playlist.trackIds = [...playlist.trackIds, trackId];
        playlist.updatedAt = DateTime.now();
        await localDataSource.savePlaylist(playlist);
      }

      return Right(playlist.toDomain());
    } catch (e) {
      return Left(
          CacheFailure('Failed to add track to playlist: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, PlaylistEntity>> removeTrackFromPlaylist({
    required String playlistId,
    required String trackId,
  }) async {
    try {
      final playlist = await localDataSource.getPlaylistById(playlistId);
      if (playlist == null) return Left(FileNotFoundFailure(playlistId));

      playlist.trackIds =
          playlist.trackIds.where((id) => id != trackId).toList();
      playlist.updatedAt = DateTime.now();
      await localDataSource.savePlaylist(playlist);

      return Right(playlist.toDomain());
    } catch (e) {
      return Left(CacheFailure(
          'Failed to remove track from playlist: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deletePlaylist(String playlistId) async {
    try {
      final deleted = await localDataSource.deletePlaylist(playlistId);
      if (!deleted) return Left(FileNotFoundFailure(playlistId));
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to delete playlist: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, PlaylistEntity>> renamePlaylist({
    required String playlistId,
    required String newName,
  }) async {
    try {
      final playlist = await localDataSource.getPlaylistById(playlistId);
      if (playlist == null) return Left(FileNotFoundFailure(playlistId));

      playlist.name = newName.trim();
      playlist.updatedAt = DateTime.now();
      await localDataSource.savePlaylist(playlist);

      return Right(playlist.toDomain());
    } catch (e) {
      return Left(CacheFailure('Failed to rename playlist: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<AudioTrackEntity>>> getPlaylistTracks(
      String playlistId) async {
    try {
      final playlist = await localDataSource.getPlaylistById(playlistId);
      if (playlist == null) return Left(FileNotFoundFailure(playlistId));

      final allTracks = await localDataSource.getAllTracks();
      final byId = <String, AudioTrackEntity>{};
      for (final model in allTracks) {
        final entity = model.toDomain();
        byId[entity.id] = entity;
        byId[entity.filePath] = entity;
      }

      final tracks = <AudioTrackEntity>[];
      for (final id in playlist.trackIds) {
        final track = byId[id];
        if (track != null) tracks.add(track);
      }

      return Right(tracks);
    } catch (e) {
      return Left(
          CacheFailure('Failed to fetch playlist tracks: ${e.toString()}'));
    }
  }
}
