import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../providers/music_library_provider.dart';
import '../providers/music_player_provider.dart';

class MusicLibraryScreen extends ConsumerStatefulWidget {
  const MusicLibraryScreen({super.key});

  @override
  ConsumerState<MusicLibraryScreen> createState() => _MusicLibraryScreenState();
}

class _MusicLibraryScreenState extends ConsumerState<MusicLibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(musicLibraryProvider.notifier).loadLibrary();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(musicLibraryProvider);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search songs...',
                  border: InputBorder.none,
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: (v) => ref.read(musicLibraryProvider.notifier).setSearchQuery(v),
              )
            : const Text('Music Library'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).colorScheme.onPrimary,
          unselectedLabelColor: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.7),
          indicatorColor: Theme.of(context).colorScheme.secondary,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Songs'),
            Tab(text: 'Albums'),
            Tab(text: 'Artists'),
            Tab(text: 'Playlists'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: 'Sync with Device',
            onPressed: () {
              ref.read(musicLibraryProvider.notifier).loadLibrary(forceSync: true);
            },
          ),
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  ref.read(musicLibraryProvider.notifier).setSearchQuery('');
                }
              });
            },
          ),
        ],
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(MusicLibraryState state) {
    if (state.status == MusicLibraryStatus.initial ||
        state.status == MusicLibraryStatus.syncing) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Scanning device storage...',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    if (state.status == MusicLibraryStatus.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline,
                size: 48, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text(
              state.errorMessage ?? 'Unknown error',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(musicLibraryProvider.notifier).loadLibrary(forceSync: true),
              child: const Text('Retry Sync'),
            ),
          ],
        ),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildSongsTab(state),
        _buildAlbumsTab(state),
        _buildArtistsTab(state),
        _buildPlaylistsTab(state),
      ],
    );
  }

  Widget _buildSongsTab(MusicLibraryState state) {
    final tracks = state.displayTracks;
    if (tracks.isEmpty) {
      return _buildEmptyState('No songs found. Try syncing.');
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: tracks.length,
      padding: const EdgeInsetsDirectional.fromSTEB(0, 8, 0, 80),
      itemBuilder: (context, index) {
        final track = tracks[index];
        return ListTile(
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.music_note, color: Theme.of(context).colorScheme.primary),
          ),
          title: Text(
            track.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
          subtitle: Text(
            track.artist,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          trailing: Text(
            track.formattedDuration,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          onTap: () {
            ref.read(musicPlayerProvider.notifier).playQueue(tracks, initialIndex: index);
            context.push(AppRoutes.nowPlaying, extra: {
              'track': track,
              'queue': tracks,
              'queueIndex': index,
            });
          },
        );
      },
    );
  }

  Widget _buildAlbumsTab(MusicLibraryState state) {
    if (state.albums.isEmpty) {
      return _buildEmptyState('No albums found.');
    }

    return ListView.builder(
      itemCount: state.albums.length,
      padding: const EdgeInsetsDirectional.all(8),
      itemBuilder: (context, index) {
        final album = state.albums[index];
        return ListTile(
          leading: const Icon(Icons.album),
          title: Text(album, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          onTap: () {
             final albumTracks = state.tracks.where((t) => t.album == album).toList();
             ref.read(musicPlayerProvider.notifier).playQueue(albumTracks);
             context.push(AppRoutes.nowPlaying, extra: {
              'track': albumTracks.first,
              'queue': albumTracks,
              'queueIndex': 0,
            });
          },
        );
      },
    );
  }

  Widget _buildArtistsTab(MusicLibraryState state) {
    if (state.artists.isEmpty) {
      return _buildEmptyState('No artists found.');
    }

    return ListView.builder(
      itemCount: state.artists.length,
      padding: const EdgeInsetsDirectional.all(8),
      itemBuilder: (context, index) {
        final artist = state.artists[index];
        return ListTile(
          leading: const Icon(Icons.person),
          title: Text(artist, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          onTap: () {
             final artistTracks = state.tracks.where((t) => t.artist == artist).toList();
             ref.read(musicPlayerProvider.notifier).playQueue(artistTracks);
             context.push(AppRoutes.nowPlaying, extra: {
              'track': artistTracks.first,
              'queue': artistTracks,
              'queueIndex': 0,
            });
          },
        );
      },
    );
  }

  Widget _buildPlaylistsTab(MusicLibraryState state) {
    if (state.playlists.isEmpty) {
      return _buildEmptyState('No playlists yet.');
    }

    return ListView.builder(
      itemCount: state.playlists.length,
      padding: const EdgeInsetsDirectional.all(8),
      itemBuilder: (context, index) {
        final playlist = state.playlists[index];
        return ListTile(
          leading: const Icon(Icons.playlist_play),
          title: Text(playlist.name, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          subtitle: Text('${playlist.trackIds.length} songs', style: const TextStyle(fontSize: 12)),
          onTap: () {
             // Implementation for loading playlist tracks would go here
          },
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.library_music_outlined,
              size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}