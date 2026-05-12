import 'package:dartz/dartz.dart';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/video_entity.dart';
import '../../domain/repositories/video_repository.dart';
import '../datasources/video_local_data_source.dart';
import '../models/video_model.dart';

/// Production implementation of [VideoRepository].
///
/// Uses [PhotoManager] (MediaStore API) to discover videos on the device,
/// the same reliable mechanism that powers the Music library via `on_audio_query`.
class VideoRepositoryImpl implements VideoRepository {
  final VideoLocalDataSource localDataSource;

  VideoRepositoryImpl({required this.localDataSource});

  // ─── Library Sync ─────────────────────────────────────────────────────

  @override
  Future<Either<Failure, void>> syncLibrary() async {
    try {
      // 1. Request storage permission via PhotoManager
      final permissionState = await PhotoManager.requestPermissionExtend();
      if (!permissionState.isAuth && permissionState != PermissionState.limited) {
        return const Left(StoragePermissionFailure());
      }

      // 2. Query all video albums/folders from MediaStore
      final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.video,
        hasAll: true,
      );

      // 3. Iterate through each album and save videos to local DB
      for (final album in albums) {
        final int assetCount = await album.assetCountAsync;
        if (assetCount == 0) continue;

        // Load assets in pages of 100 for memory efficiency
        int page = 0;
        const int pageSize = 100;

        while (page * pageSize < assetCount) {
          final List<AssetEntity> assets = await album.getAssetListPaged(
            page: page,
            size: pageSize,
          );

          for (final asset in assets) {
            // Get the actual file
            final file = await asset.file;
            if (file == null) continue;

            final path = file.path;

            // Skip if already in DB
            final existing = await localDataSource.getVideoByPath(path);
            if (existing != null) continue;

            // Extract folder name from path
            final pathParts = path.split('/');
            final folderName = pathParts.length >= 2
                ? pathParts[pathParts.length - 2]
                : 'Unknown';

            final fileName = asset.title ?? pathParts.last;

            final newVideo = VideoModel(
              filePath: path,
              fileName: fileName,
              folderName: folderName,
              fileSizeBytes: await file.length(),
              durationMs: asset.duration * 1000, // asset.duration is in seconds
              resolution: '${asset.width}x${asset.height}',
            );

            await localDataSource.saveVideo(newVideo);
          }

          page++;
        }
      }

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to sync video library: ${e.toString()}'));
    }
  }

  // ─── Library Queries ──────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<VideoEntity>>> getAllVideos() async {
    try {
      final models = await localDataSource.getAllVideos();
      final entities = models.map((m) => _withDeviceDateFallback(m.toDomain())).toList();
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Failed to fetch videos: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<VideoEntity>>> getVideosByFolder(
      String folderPath) async {
    try {
      final models = await localDataSource.getVideosByFolder(folderPath);
      final entities = models.map((m) => _withDeviceDateFallback(m.toDomain())).toList();
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Failed to fetch folder: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getAllVideoFolders() async {
    try {
      final folders = await localDataSource.getAllVideoFolders();
      return Right(folders);
    } catch (e) {
      return Left(CacheFailure('Failed to fetch folders: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<VideoEntity>>> searchVideos(String query) async {
    try {
      final models = await localDataSource.searchVideos(query);
      final entities = models.map((m) => _withDeviceDateFallback(m.toDomain())).toList();
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Failed to search videos: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> savePlaybackPosition(
      String videoPath, int positionMs) async {
    try {
      final model = await localDataSource.getVideoByPath(videoPath);
      if (model != null) {
        model.lastPositionMs = positionMs;
        model.lastPlayedAt = DateTime.now();
        await localDataSource.saveVideo(model);
      } else {
        return Left(FileNotFoundFailure(videoPath));
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to save position: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, int>> getPlaybackPosition(String videoPath) async {
    try {
      final model = await localDataSource.getVideoByPath(videoPath);
      return Right(model?.lastPositionMs ?? 0);
    } catch (e) {
      return Left(CacheFailure('Failed to get position: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> clearPlaybackPosition(String videoPath) async {
    try {
      final model = await localDataSource.getVideoByPath(videoPath);
      if (model != null) {
        model.lastPositionMs = null;
        await localDataSource.saveVideo(model);
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to clear position: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> generateThumbnail(String videoPath) async {
    try {
      final model = await localDataSource.getVideoByPath(videoPath);
      if (model == null) return Left(FileNotFoundFailure(videoPath));

      // If cached thumbnail exists on disk, return it.
      final existing = model.thumbnailPath;
      if (existing != null && await File(existing).exists()) {
        return Right(existing);
      }

      final cacheDir = await getTemporaryDirectory();
      final thumbsDir = Directory('${cacheDir.path}/vidmaster_thumbs');
      if (!await thumbsDir.exists()) {
        await thumbsDir.create(recursive: true);
      }

      final key = sha1.convert(utf8.encode(videoPath)).toString();
      final outPath = '${thumbsDir.path}/$key.jpg';

      // Generate a single frame thumbnail (fast + good enough).
      final generated = await VideoThumbnail.thumbnailFile(
        video: videoPath,
        thumbnailPath: thumbsDir.path,
        imageFormat: ImageFormat.JPEG,
        quality: 75,
        // Keep it light; grid cards don't need huge images.
        maxWidth: 512,
      );

      final finalPath = generated ?? (await File(outPath).exists() ? outPath : null);
      if (finalPath == null) return Left(ThumbnailFailure(videoPath));

      model.thumbnailPath = finalPath;
      await localDataSource.saveVideo(model);
      return Right(finalPath);
    } catch (e) {
      return Left(CacheFailure('Failed to generate thumbnail: ${e.toString()}'));
    }
  }

  @override
  Stream<Either<Failure, String>> generateThumbnailsBatch(
      List<String> videoPaths) async* {
    yield const Left(CacheFailure('Batch thumbnail generation not implemented'));
  }

  @override
  Future<Either<Failure, VideoEntity>> toggleFavourite(String videoPath) async {
    try {
      final model = await localDataSource.getVideoByPath(videoPath);
      if (model != null) {
        model.isFavourite = !model.isFavourite;
        await localDataSource.saveVideo(model);
        return Right(model.toDomain());
      } else {
        return Left(FileNotFoundFailure(videoPath));
      }
    } catch (e) {
      return Left(CacheFailure('Failed to toggle favourite: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<VideoEntity>>> getFavouriteVideos() async {
    try {
      final models = await localDataSource.getFavouriteVideos();
      final entities = models.map((m) => _withDeviceDateFallback(m.toDomain())).toList();
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Failed to fetch favourites: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> recordPlay(String videoPath) async {
    try {
      final model = await localDataSource.getVideoByPath(videoPath);
      if (model != null) {
        model.playCount += 1;
        model.lastPlayedAt = DateTime.now();
        await localDataSource.saveVideo(model);
      } else {
        return Left(FileNotFoundFailure(videoPath));
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to record play: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<VideoEntity>>> getRecentlyPlayed({
    int limit = 20,
  }) async {
    try {
      final models = await localDataSource.getRecentlyPlayed(limit: limit);
      final entities = models.map((m) => _withDeviceDateFallback(m.toDomain())).toList();
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Failed to fetch recent: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteVideo(String filePath) async {
    try {
      // 1. File first. If this throws (permission, missing file, scoped-
      //    storage rejection on Android 11+), we abort and keep the DB row
      //    so the library still reflects what's actually on disk.
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
      // 2. DB row. Best-effort; if Isar fails here the file is already gone
      //    so the next syncLibrary() will eventually clean it up.
      await localDataSource.deleteVideoByPath(filePath);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to delete video: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> clearRecentlyPlayed() async {
    try {
      await localDataSource.clearRecentlyPlayed();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to clear recent: ${e.toString()}'));
    }
  }

  VideoEntity _withDeviceDateFallback(VideoEntity e) {
    // ALWAYS populate `fileModifiedAt` from disk when it's missing — this is
    // the canonical "date added/modified on device" key the UI Date sort uses.
    //
    // Critical: the previous version short-circuited on `lastPlayedAt != null`.
    // Because `VideoModel` (Isar) does NOT persist `fileModifiedAt`, ANY video
    // that had ever been played came back from the DB with
    // `fileModifiedAt = null` AND `lastPlayedAt != null`. That made the old
    // guard skip the disk-stat fallback, leaving `fileModifiedAt = null`, which
    // collapsed to `DateTime(0)` (epoch) in the Date comparator — so every
    // played video sank to the bottom of the list the instant it was opened.
    // That's the "order changes based on playback" bug the user reported.
    if (e.fileModifiedAt != null) return e;
    try {
      final dt = File(e.filePath).lastModifiedSync();
      return e.copyWith(fileModifiedAt: dt);
    } catch (_) {
      return e;
    }
  }
}
