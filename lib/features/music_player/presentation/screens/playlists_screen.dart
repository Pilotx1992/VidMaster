import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/music_library_provider.dart';

class PlaylistsScreen extends ConsumerWidget {
  const PlaylistsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(musicLibraryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Playlists'),
        actions: [
          IconButton(
            tooltip: 'Sync',
            onPressed: () => ref.read(musicLibraryProvider.notifier).loadLibrary(forceSync: true),
            icon: const Icon(Icons.sync),
          ),
          IconButton(
            tooltip: 'Create playlist',
            onPressed: () => _createPlaylistDialog(context, ref),
            icon: const Icon(Icons.add),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'settings', child: Text('Settings')),
            ],
            onSelected: (v) {
              if (v == 'settings') {
                // Keep navigation decisions centralized in other screens for now.
                Navigator.of(context).maybePop();
              }
            },
          ),
        ],
      ),
      body: state.playlists.isEmpty
          ? _Empty(message: state.isLoading ? 'Loading...' : 'No playlists yet.')
          : ListView.separated(
              padding: const EdgeInsetsDirectional.fromSTEB(0, 8, 0, 80),
              itemCount: state.playlists.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final p = state.playlists[index];
                return ListTile(
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.playlist_play),
                  ),
                  title: Text(
                    p.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text('${p.trackIds.length} tracks'),
                  trailing: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                    onSelected: (v) async {
                      if (v == 'delete') {
                        await ref.read(musicLibraryProvider.notifier).deletePlaylist(p.id);
                      }
                    },
                  ),
                  onTap: () {
                    // Details screen can be added later; for now keep it simple.
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Playlist details coming soon.')),
                    );
                  },
                );
              },
            ),
    );
  }

  Future<void> _createPlaylistDialog(BuildContext context, WidgetRef ref) async {
    final ctrl = TextEditingController();
    final created = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create playlist'),
          content: TextField(
            controller: ctrl,
            decoration: const InputDecoration(hintText: 'Playlist name'),
            autofocus: true,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
    if (created == true) {
      final name = ctrl.text.trim();
      if (name.isNotEmpty) {
        await ref.read(musicLibraryProvider.notifier).createPlaylist(name);
      }
    }
  }
}

class _Empty extends StatelessWidget {
  final String message;
  const _Empty({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.playlist_play, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

