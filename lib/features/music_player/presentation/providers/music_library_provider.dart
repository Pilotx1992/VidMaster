import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../di.dart';
import '../../domain/entities/audio_track_entity.dart';
import '../../domain/entities/playlist_entity.dart';
import '../../domain/usecases/music_usecases.dart';

enum MusicLibraryStatus { initial, syncing, loaded, error }

class MusicLibraryState {
  final MusicLibraryStatus status;
  final List<AudioTrackEntity> tracks;
  final List<String> albums;
  final List<String> artists;
  final List<AudioTrackEntity> favorites;
  final List<PlaylistEntity> playlists;
  final String? errorMessage;
  final String? searchQuery;

  const MusicLibraryState({
    this.status = MusicLibraryStatus.initial,
    this.tracks = const [],
    this.albums = const [],
    this.artists = const [],
    this.favorites = const [],
    this.playlists = const [],
    this.errorMessage,
    this.searchQuery = '',
  });

  bool get hasData => tracks.isNotEmpty;
  bool get isLoading => status == MusicLibraryStatus.syncing;
  
  List<AudioTrackEntity> get displayTracks {
    final query = searchQuery ?? '';
    if (query.isEmpty) return tracks;
    final lowerQuery = query.toLowerCase();
    return tracks.where((t) => 
      t.title.toLowerCase().contains(lowerQuery) || 
      t.artist.toLowerCase().contains(lowerQuery)
    ).toList();
  }

  MusicLibraryState copyWith({
    MusicLibraryStatus? status,
    List<AudioTrackEntity>? tracks,
    List<String>? albums,
    List<String>? artists,
    List<AudioTrackEntity>? favorites,
    List<PlaylistEntity>? playlists,
    String? errorMessage,
    String? searchQuery,
    bool clearSearchQuery = false,
  }) {
    return MusicLibraryState(
      status: status ?? this.status,
      tracks: tracks ?? this.tracks,
      albums: albums ?? this.albums,
      artists: artists ?? this.artists,
      favorites: favorites ?? this.favorites,
      playlists: playlists ?? this.playlists,
      errorMessage: errorMessage ?? this.errorMessage,
      searchQuery: clearSearchQuery ? null : (searchQuery ?? this.searchQuery),
    );
  }
}

class MusicLibraryNotifier extends StateNotifier<MusicLibraryState> {
  final SyncMusicLibrary _syncMusicLibrary;
  final GetAllTracks _getAllTracks;
  final GetAllAlbums _getAllAlbums;
  final GetAllArtists _getAllArtists;
  final GetAllPlaylists _getAllPlaylists;
  final ToggleMusicFavourite _toggleFavorite;
  final CreatePlaylist _createPlaylist;
  final DeletePlaylist _deletePlaylist;
  final AddTrackToPlaylist _addTrackToPlaylist;

  MusicLibraryNotifier({
    required SyncMusicLibrary syncMusicLibrary,
    required GetAllTracks getAllTracks,
    required GetAllAlbums getAllAlbums,
    required GetAllArtists getAllArtists,
    required GetAllPlaylists getAllPlaylists,
    required ToggleMusicFavourite toggleFavorite,
    required CreatePlaylist createPlaylist,
    required DeletePlaylist deletePlaylist,
    required AddTrackToPlaylist addTrackToPlaylist,
  })  : _syncMusicLibrary = syncMusicLibrary,
        _getAllTracks = getAllTracks,
        _getAllAlbums = getAllAlbums,
        _getAllArtists = getAllArtists,
        _getAllPlaylists = getAllPlaylists,
        _toggleFavorite = toggleFavorite,
        _createPlaylist = createPlaylist,
        _deletePlaylist = deletePlaylist,
        _addTrackToPlaylist = addTrackToPlaylist,
        super(const MusicLibraryState());

  Future<void> loadLibrary({bool forceSync = false}) async {
    state = state.copyWith(status: MusicLibraryStatus.syncing);

    // Initial check to see if DB has items
    bool shouldSync = forceSync;
    if (!shouldSync) {
      final initialTracks = await _getAllTracks(const NoParams());
      final hasLocalData = initialTracks.fold((_) => false, (l) => l.isNotEmpty);
      if (!hasLocalData) {
        shouldSync = true;
      }
    }

    if (shouldSync) {
      final syncResult = await _syncMusicLibrary(const NoParams());
      if (syncResult.isLeft()) {
        // Log or handle sync error if needed
      }
    }

    final results = await Future.wait([
      _getAllTracks(const NoParams()),
      _getAllAlbums(const NoParams()),
      _getAllArtists(const NoParams()),
      _getAllPlaylists(const NoParams()),
    ]);

    final tracksResult = results[0] as Either<Failure, List<AudioTrackEntity>>;
    final albumsResult = results[1] as Either<Failure, List<String>>;
    final artistsResult = results[2] as Either<Failure, List<String>>;
    final playlistsResult = results[3] as Either<Failure, List<PlaylistEntity>>;

    final firstError = [tracksResult, albumsResult, artistsResult, playlistsResult]
        .where((r) => r.isLeft())
        .map((r) => r.fold((l) => l, (r) => null))
        .firstOrNull;

    if (firstError != null) {
      state = state.copyWith(
        status: MusicLibraryStatus.error,
        errorMessage: firstError.message,
      );
      return;
    }

    final tracks = tracksResult.fold((_) => <AudioTrackEntity>[], (r) => r);
    final albums = albumsResult.fold((_) => <String>[], (r) => List<String>.from(r))..sort();
    final artists = artistsResult.fold((_) => <String>[], (r) => List<String>.from(r))..sort();
    final playlists = playlistsResult.fold((_) => <PlaylistEntity>[], (r) => r);

    state = state.copyWith(
      status: MusicLibraryStatus.loaded,
      tracks: tracks,
      albums: albums,
      artists: artists,
      playlists: playlists,
      favorites: tracks.where((t) => t.isFavourite).toList(),
      errorMessage: null,
    );
  }

  void setSearchQuery(String? query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<void> toggleFavorite(String trackId) async {
    final result = await _toggleFavorite(ToggleMusicFavouriteParams(trackId: trackId));
    result.fold(
      (f) => state = state.copyWith(errorMessage: f.message),
      (updatedTrack) {
        final updatedTracks = state.tracks.map((t) {
          return t.id == trackId ? updatedTrack : t;
        }).toList();
        
        state = state.copyWith(
          tracks: updatedTracks,
          favorites: updatedTracks.where((t) => t.isFavourite).toList(),
        );
      },
    );
  }

  Future<void> createPlaylist(String name) async {
    final result = await _createPlaylist(CreatePlaylistParams(name: name));
    result.fold(
      (f) => state = state.copyWith(errorMessage: f.message),
      (playlist) {
        state = state.copyWith(
          playlists: [...state.playlists, playlist],
        );
      },
    );
  }

  Future<void> deletePlaylist(String playlistId) async {
    final result = await _deletePlaylist(DeletePlaylistParams(playlistId: playlistId));
    result.fold(
      (f) => state = state.copyWith(errorMessage: f.message),
      (_) {
        state = state.copyWith(
          playlists: state.playlists.where((p) => p.id != playlistId).toList(),
        );
      },
    );
  }

  Future<void> addTrackToPlaylist(String playlistId, String trackId) async {
    final result = await _addTrackToPlaylist(AddTrackToPlaylistParams(
      playlistId: playlistId,
      trackId: trackId,
    ));
    result.fold(
      (f) => state = state.copyWith(errorMessage: f.message),
      (updatedPlaylist) {
        final updatedPlaylists = state.playlists.map((p) {
          return p.id == playlistId ? updatedPlaylist : p;
        }).toList();
        state = state.copyWith(playlists: updatedPlaylists);
      },
    );
  }
}

final musicLibraryProvider =
    StateNotifierProvider<MusicLibraryNotifier, MusicLibraryState>((ref) {
  return MusicLibraryNotifier(
    syncMusicLibrary: ref.watch(syncMusicLibraryProvider),
    getAllTracks: ref.watch(getAllTracksProvider),
    getAllAlbums: ref.watch(getAllAlbumsProvider),
    getAllArtists: ref.watch(getAllArtistsProvider),
    getAllPlaylists: ref.watch(getAllPlaylistsProvider),
    toggleFavorite: ref.watch(toggleFavoriteTrackProvider),
    createPlaylist: ref.watch(createPlaylistProvider),
    deletePlaylist: ref.watch(deletePlaylistProvider),
    addTrackToPlaylist: ref.watch(addTrackToPlaylistProvider),
  );
});
