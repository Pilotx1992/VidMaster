import 'package:isar/isar.dart';
import '../models/video_model.dart';

/// Contract for local database operations related to Videos.
abstract interface class VideoLocalDataSource {
  Future<List<VideoModel>> getAllVideos();
  Future<List<VideoModel>> getVideosByFolder(String folderPath);
  Future<List<String>> getAllVideoFolders();
  Future<List<VideoModel>> searchVideos(String query);
  
  Future<VideoModel?> getVideoByPath(String filePath);
  Future<void> saveVideo(VideoModel video);
  
  Future<List<VideoModel>> getFavouriteVideos();
  Future<List<VideoModel>> getRecentlyPlayed({required int limit});
}

/// Isar implementation of the local data source.
class VideoLocalDataSourceImpl implements VideoLocalDataSource {
  final Isar isar;

  VideoLocalDataSourceImpl(this.isar);

  @override
  Future<List<VideoModel>> getAllVideos() async {
    return isar.videoModels.filter().isInVaultEqualTo(false).findAll();
  }

  @override
  Future<List<VideoModel>> getVideosByFolder(String folderPath) async {
    return isar.videoModels
        .filter()
        .folderNameEqualTo(folderPath)
        .and()
        .isInVaultEqualTo(false)
        .findAll();
  }

  @override
  Future<List<String>> getAllVideoFolders() async {
    final videos = await isar.videoModels.filter().isInVaultEqualTo(false).findAll();
    return videos.map((v) => v.folderName).toSet().toList();
  }

  @override
  Future<List<VideoModel>> searchVideos(String queryText) async {
    return isar.videoModels
        .filter()
        .fileNameContains(queryText, caseSensitive: false)
        .and()
        .isInVaultEqualTo(false)
        .findAll();
  }

  @override
  Future<VideoModel?> getVideoByPath(String filePath) async {
    return isar.videoModels.filter().filePathEqualTo(filePath).findFirst();
  }

  @override
  Future<void> saveVideo(VideoModel video) async {
    await isar.writeTxn(() async {
      await isar.videoModels.put(video);
    });
  }

  @override
  Future<List<VideoModel>> getFavouriteVideos() async {
    return isar.videoModels
        .filter()
        .isFavouriteEqualTo(true)
        .and()
        .isInVaultEqualTo(false)
        .sortByLastPlayedAtDesc()
        .findAll();
  }

  @override
  Future<List<VideoModel>> getRecentlyPlayed({required int limit}) async {
    return isar.videoModels
        .filter()
        .isInVaultEqualTo(false)
        .and()
        .lastPlayedAtIsNotNull()
        .sortByLastPlayedAtDesc()
        .limit(limit)
        .findAll();
  }
}
