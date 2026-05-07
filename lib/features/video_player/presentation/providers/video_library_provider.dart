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

enum VideoLibraryTab { all, folders, recent, favorites }

class VideoLibraryState {
  final VideoLibraryStatus status;
  final List<VideoEntity> videos;
  final int totalBytes;
  final List<String> folders;
  final List<VideoEntity> recentlyPlayed;
  final List<VideoEntity> favorites;
  final String? errorMessage;
  final bool isSearchMode;
  final String searchQuery;
  final VideoSortOrder sortOrder;
  final bool sortAscending;
  final bool isGridView;
  final VideoLibraryTab activeTab;
  /// When [activeTab] is [VideoLibraryTab.folders], filters by folder name; null = folder picker root.
  final String? selectedFolderName;

  const VideoLibraryState({
    this.status = VideoLibraryStatus.initial,
    this.videos = const [],
    this.totalBytes = 0,
    this.folders = const [],
    this.recentlyPlayed = const [],
    this.favorites = const [],
    this.errorMessage,
    this.isSearchMode = false,
    this.searchQuery = '',
    this.sortOrder = VideoSortOrder.date,
    this.sortAscending = false, // new → old
    this.isGridView = false, // list view by default
    this.activeTab = VideoLibraryTab.all,
    this.selectedFolderName,
  });

  /// Base list for the current tab (no search/sort yet). Not used for folders root picker.
  List<VideoEntity> get tabVideos {
    switch (activeTab) {
      case VideoLibraryTab.all:
        return videos;
      case VideoLibraryTab.recent:
        return recentlyPlayed;
      case VideoLibraryTab.favorites:
        return favorites;
      case VideoLibraryTab.folders:
        if (selectedFolderName == null) return const [];
        return videos.where((v) => v.folderName == selectedFolderName).toList();
    }
  }

  List<VideoEntity> get displayVideos {
    var list = List<VideoEntity>.from(tabVideos);

    final q = searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list
          .where((v) =>
              v.fileName.toLowerCase().contains(q) ||
              v.folderName.toLowerCase().contains(q) ||
              v.filePath.toLowerCase().contains(q))
          .toList();
    }

    int cmp(VideoEntity a, VideoEntity b) => switch (sortOrder) {
          VideoSortOrder.name => a.fileName.compareTo(b.fileName),
          VideoSortOrder.date => (a.lastPlayedAt ?? a.fileModifiedAt ?? DateTime(0))
              .compareTo(b.lastPlayedAt ?? b.fileModifiedAt ?? DateTime(0)),
          VideoSortOrder.size => a.fileSizeBytes.compareTo(b.fileSizeBytes),
          VideoSortOrder.duration => (a.durationMs ?? 0).compareTo(b.durationMs ?? 0),
        };

    list.sort((a, b) => sortAscending ? cmp(a, b) : cmp(b, a));
    return list;
  }

  bool get hasVideos => videos.isNotEmpty;
  bool get isSearching => isSearchMode; // legacy name used in UI
  bool get hasSearchQuery => searchQuery.trim().isNotEmpty;

  VideoLibraryState copyWith({
    VideoLibraryStatus? status,
    List<VideoEntity>? videos,
    int? totalBytes,
    List<String>? folders,
    List<VideoEntity>? recentlyPlayed,
    List<VideoEntity>? favorites,
    String? errorMessage,
    bool? isSearchMode,
    String? searchQuery,
    VideoSortOrder? sortOrder,
    bool? sortAscending,
    bool? isGridView,
    VideoLibraryTab? activeTab,
    String? selectedFolderName,
    bool clearSelectedFolder = false,
  }) =>
      VideoLibraryState(
        status: status ?? this.status,
        videos: videos ?? this.videos,
        totalBytes: totalBytes ?? this.totalBytes,
        folders: folders ?? this.folders,
        recentlyPlayed: recentlyPlayed ?? this.recentlyPlayed,
        favorites: favorites ?? this.favorites,
        errorMessage: errorMessage ?? this.errorMessage,
        isSearchMode: isSearchMode ?? this.isSearchMode,
        searchQuery: searchQuery ?? this.searchQuery,
        sortOrder: sortOrder ?? this.sortOrder,
        sortAscending: sortAscending ?? this.sortAscending,
        isGridView: isGridView ?? this.isGridView,
        activeTab: activeTab ?? this.activeTab,
        selectedFolderName: clearSelectedFolder
            ? null
            : (selectedFolderName ?? this.selectedFolderName),
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

    final loadedVideos = videosResult.fold<List<VideoEntity>>(
      (_) => const [],
      (r) => r,
    );
    state = state.copyWith(
      status: VideoLibraryStatus.loaded,
      videos: loadedVideos,
      totalBytes: loadedVideos.fold<int>(0, (sum, v) => sum + v.fileSizeBytes),
      folders: foldersResult.fold((_) => [], (r) => r),
      recentlyPlayed: recentResult.fold((_) => [], (r) => r),
      favorites: favResult.fold((_) => [], (r) => r),
      errorMessage: null,
    );
  }

  void setSearchQuery(String query) =>
      state = state.copyWith(searchQuery: query);

  void enterSearch() => state = state.copyWith(isSearchMode: true);

  void exitSearch() =>
      state = state.copyWith(isSearchMode: false, searchQuery: '');

  void clearSearchQuery() => state = state.copyWith(searchQuery: '');

  void setActiveTab(VideoLibraryTab tab) {
    state = state.copyWith(
      activeTab: tab,
      clearSelectedFolder: true,
    );
  }

  void openFolder(String folderName) {
    state = state.copyWith(
      activeTab: VideoLibraryTab.folders,
      selectedFolderName: folderName,
    );
  }

  void exitFolderBrowse() {
    state = state.copyWith(clearSelectedFolder: true);
  }

  void setSortOrder(VideoSortOrder order) =>
      state = state.copyWith(sortOrder: order);

  void setSortAscending(bool ascending) =>
      state = state.copyWith(sortAscending: ascending);

  void updateSorting({
    required VideoSortOrder order,
    required bool ascending,
  }) =>
      state = state.copyWith(sortOrder: order, sortAscending: ascending);

  void toggleView() =>
      state = state.copyWith(isGridView: !state.isGridView);

  Future<void> toggleFavorite(String videoPath) async {
    await _toggleFavorite(ToggleFavouriteParams(videoPath: videoPath));

    VideoEntity? updatedVideo;
    final updated = state.videos.map((v) {
      if (v.filePath != videoPath) return v;
      updatedVideo = v.copyWith(isFavourite: !v.isFavourite);
      return updatedVideo!;
    }).toList();

    if (updatedVideo == null) return;

    final newFav = updatedVideo!.isFavourite;
    final recent = state.recentlyPlayed
        .map(
          (v) =>
              v.filePath == videoPath ? v.copyWith(isFavourite: newFav) : v,
        )
        .toList();

    state = state.copyWith(
      videos: updated,
      totalBytes: updated.fold<int>(0, (sum, v) => sum + v.fileSizeBytes),
      recentlyPlayed: recent,
      favorites: updated.where((v) => v.isFavourite).toList(),
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
