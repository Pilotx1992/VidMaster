import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../di.dart';
import '../../domain/entities/video_entity.dart';
import '../../domain/usecases/video_usecases.dart';

// ── State ──────────────────────────────────────────────────────────────────

enum VideoLibraryStatus { initial, loading, loaded, error }

enum VideoSortOrder { name, date, size, duration }

class VideoLibraryState {
  final VideoLibraryStatus status;
  final List<VideoEntity> videos;
  final List<String> folders;
  final List<VideoEntity> recentlyPlayed;
  final List<VideoEntity> favorites;
  final String? errorMessage;
  final String searchQuery;
  final VideoSortOrder sortOrder;
  final bool isGridView;

  const VideoLibraryState({
    this.status = VideoLibraryStatus.initial,
    this.videos = const [],
    this.folders = const [],
    this.recentlyPlayed = const [],
    this.favorites = const [],
    this.errorMessage,
    this.searchQuery = '',
    this.sortOrder = VideoSortOrder.name,
    this.isGridView = true,
  });

  List<VideoEntity> get displayVideos {
    var list = searchQuery.isEmpty
        ? videos
        : videos
            .where((v) =>
                v.fileName.toLowerCase().contains(searchQuery.toLowerCase()))
            .toList();

    return switch (sortOrder) {
      VideoSortOrder.name => list..sort((a, b) => a.fileName.compareTo(b.fileName)),
      VideoSortOrder.date => list..sort((a, b) => (b.lastPlayedAt ?? DateTime(0)).compareTo(a.lastPlayedAt ?? DateTime(0))),
      VideoSortOrder.size => list..sort((a, b) => b.fileSizeBytes.compareTo(a.fileSizeBytes)),
      VideoSortOrder.duration => list..sort((a, b) => (b.durationMs ?? 0).compareTo(a.durationMs ?? 0)),
    };
  }

  bool get hasVideos => videos.isNotEmpty;
  bool get isSearching => searchQuery.isNotEmpty;

  VideoLibraryState copyWith({
    VideoLibraryStatus? status,
    List<VideoEntity>? videos,
    List<String>? folders,
    List<VideoEntity>? recentlyPlayed,
    List<VideoEntity>? favorites,
    String? errorMessage,
    String? searchQuery,
    VideoSortOrder? sortOrder,
    bool? isGridView,
  }) =>
      VideoLibraryState(
        status: status ?? this.status,
        videos: videos ?? this.videos,
        folders: folders ?? this.folders,
        recentlyPlayed: recentlyPlayed ?? this.recentlyPlayed,
        favorites: favorites ?? this.favorites,
        errorMessage: errorMessage ?? this.errorMessage,
        searchQuery: searchQuery ?? this.searchQuery,
        sortOrder: sortOrder ?? this.sortOrder,
        isGridView: isGridView ?? this.isGridView,
      );
}

// ── Notifier ───────────────────────────────────────────────────────────────

class VideoLibraryNotifier extends StateNotifier<VideoLibraryState> {
  final SyncVideoLibrary _syncVideoLibrary;
  final GetAllVideos _getAllVideos;
  final GetAllVideoFolders _getAllFolders;
  final GetRecentlyPlayed _getRecentlyPlayed;
  final GetFavouriteVideos _getFavorites;
  final ToggleFavourite _toggleFavorite;
  final RecordVideoPlay _markAsPlayed;
  final SavePlaybackPosition _savePosition;
  final GenerateThumbnail _generateThumbnail;

  VideoLibraryNotifier({
    required SyncVideoLibrary syncVideoLibrary,
    required GetAllVideos getAllVideos,
    required GetAllVideoFolders getAllFolders,
    required GetRecentlyPlayed getRecentlyPlayed,
    required GetFavouriteVideos getFavorites,
    required ToggleFavourite toggleFavorite,
    required RecordVideoPlay markAsPlayed,
    required SavePlaybackPosition savePosition,
    required GenerateThumbnail generateThumbnail,
  })  : _syncVideoLibrary = syncVideoLibrary,
        _getAllVideos = getAllVideos,
        _getAllFolders = getAllFolders,
        _getRecentlyPlayed = getRecentlyPlayed,
        _getFavorites = getFavorites,
        _toggleFavorite = toggleFavorite,
        _markAsPlayed = markAsPlayed,
        _savePosition = savePosition,
        _generateThumbnail = generateThumbnail,
        super(const VideoLibraryState());

  Future<void> loadLibrary({bool forceSync = false}) async {
    state = state.copyWith(status: VideoLibraryStatus.loading);

    // Check if DB has data; if not, trigger a sync from device storage
    bool shouldSync = forceSync;
    if (!shouldSync) {
      final initialVideos = await _getAllVideos(const NoParams());
      final hasLocalData = initialVideos.fold((_) => false, (l) => l.isNotEmpty);
      if (!hasLocalData) {
        shouldSync = true;
      }
    }

    if (shouldSync) {
      final syncResult = await _syncVideoLibrary(const NoParams());
      syncResult.fold(
        (failure) {
          state = state.copyWith(
            status: VideoLibraryStatus.error,
            errorMessage: failure.message,
          );
        },
        (_) {},
      );
      // If sync errored with permission denial, stop here
      if (state.status == VideoLibraryStatus.error) return;
    }

    final results = await Future.wait([
      _getAllVideos(const NoParams()),
      _getAllFolders(const NoParams()),
      _getRecentlyPlayed(const GetRecentlyPlayedParams()),
      _getFavorites(const NoParams()),
    ]);

    final videosResult = results[0] as Either<Failure, List<VideoEntity>>;
    final foldersResult = results[1] as Either<Failure, List<String>>;
    final recentResult = results[2] as Either<Failure, List<VideoEntity>>;
    final favResult = results[3] as Either<Failure, List<VideoEntity>>;

    // Surface first error found (storage permission is most common).
    Failure? firstError;
    for (final r in [videosResult, foldersResult, recentResult, favResult]) {
      r.fold((l) => firstError ??= l, (_) {});
    }

    if (firstError != null) {
      state = state.copyWith(
        status: VideoLibraryStatus.error,
        errorMessage: firstError!.message,
      );
      return;
    }

    state = state.copyWith(
      status: VideoLibraryStatus.loaded,
      videos: videosResult.fold((_) => [], (r) => r),
      folders: foldersResult.fold((_) => [], (r) => r),
      recentlyPlayed: recentResult.fold((_) => [], (r) => r),
      favorites: favResult.fold((_) => [], (r) => r),
      errorMessage: null,
    );
  }

  void setSearchQuery(String query) =>
      state = state.copyWith(searchQuery: query);

  void clearSearch() => state = state.copyWith(searchQuery: '');

  void setSortOrder(VideoSortOrder order) =>
      state = state.copyWith(sortOrder: order);

  void toggleView() =>
      state = state.copyWith(isGridView: !state.isGridView);

  Future<void> toggleFavorite(String videoPath) async {
    await _toggleFavorite(ToggleFavouriteParams(videoPath: videoPath));
    // Optimistic update.
    final updated = state.videos.map((v) {
      if (v.filePath == videoPath) return v.copyWith(isFavourite: !v.isFavourite);
      return v;
    }).toList();
    state = state.copyWith(
      videos: updated,
      favorites: updated.where((v) => v.isFavorite).toList(),
    );
  }

  Future<void> savePosition(String videoPath, int positionMs) =>
      _savePosition(SavePlaybackPositionParams(
        videoPath: videoPath,
        positionMs: positionMs,
      ));

  Future<void> markPlayed(String videoPath) =>
      _markAsPlayed(RecordVideoPlayParams(videoPath: videoPath));

  Future<String?> getThumbnail(String videoPath) async {
    final result = await _generateThumbnail(GenerateThumbnailParams(videoPath: videoPath));
    return result.fold((l) => null, (r) => r);
  }
}

// ── Provider ───────────────────────────────────────────────────────────────

final videoLibraryProvider =
    StateNotifierProvider<VideoLibraryNotifier, VideoLibraryState>((ref) {
  return VideoLibraryNotifier(
    syncVideoLibrary: ref.watch(syncVideoLibraryProvider),
    getAllVideos: ref.watch(getAllVideosProvider),
    getAllFolders: ref.watch(getAllFoldersProvider),
    getRecentlyPlayed: ref.watch(getRecentlyPlayedVideosProvider),
    getFavorites: ref.watch(getFavoriteVideosProvider),
    toggleFavorite: ref.watch(toggleVideoFavoriteProvider),
    markAsPlayed: ref.watch(markVideoAsPlayedProvider),
    savePosition: ref.watch(savePlaybackPositionProvider),
    generateThumbnail: ref.watch(generateThumbnailProvider),
  );
});
