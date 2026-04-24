import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/video_entity.dart';
import '../../domain/repositories/video_repository.dart';
import '../datasources/video_local_data_source.dart';


/// Production implementation of [VideoRepository].
///
/// Orchestrates data fetching from the [VideoLocalDataSource] (ObjectBox)
/// and handles mapping to Domain Entities and exception catching.
class VideoRepositoryImpl implements VideoRepository {
  final VideoLocalDataSource localDataSource;

  VideoRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<VideoEntity>>> getAllVideos() async {
    try {
      final models = await localDataSource.getAllVideos();
      final entities = models.map((m) => m.toDomain()).toList();
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
      final entities = models.map((m) => m.toDomain()).toList();
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
      final entities = models.map((m) => m.toDomain()).toList();
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
    // Note: Thumbnail generation requires a hardware-specific service.
    // In Clean Architecture, this should be delegated to a Device file service.
    // Returning a failure here to indicate it's not implemented purely in DB layer.
    return Left(ThumbnailFailure(videoPath));
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
      final entities = models.map((m) => m.toDomain()).toList();
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
      final entities = models.map((m) => m.toDomain()).toList();
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Failed to fetch recent: ${e.toString()}'));
    }
  }
}
