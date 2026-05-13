import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../di.dart';
import '../../../../core/router/app_router.dart';
import '../../domain/entities/audio_track_entity.dart';
import '../providers/music_library_provider.dart';
import '../providers/music_player_provider.dart';
import '../widgets/music_track_actions_sheet.dart';

class MusicLibraryScreen extends ConsumerStatefulWidget {
  const MusicLibraryScreen({super.key});

  @override
  ConsumerState<MusicLibraryScreen> createState() => _MusicLibraryScreenState();
}

class _MusicLibraryScreenState extends ConsumerState<MusicLibraryScreen>
    with SingleTickerProviderStateMixin {
  static final RegExp _invalidRenameCharactersPattern =
      RegExp(r'[\/\\:\*\?"<>\|]');

  late TabController _tabController;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(musicLibraryProvider.notifier).loadLibrary();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _syncWithDevice() {
    ref.read(musicLibraryProvider.notifier).loadLibrary(forceSync: true);
  }

  void _playTrack({
    required List<AudioTrackEntity> queue,
    required int index,
  }) {
    final track = queue[index];

    ref.read(musicPlayerProvider.notifier).playQueue(
          queue,
          startIndex: index,
        );

    context.push(
      AppRoutes.nowPlaying,
      extra: NowPlayingArgs(
        track: track,
        queue: queue,
        queueIndex: index,
      ),
    );
  }

  String _trackLabel(AudioTrackEntity track) {
    final title = track.title.trim();
    if (title.isNotEmpty) {
      return title;
    }
    return track.filePath.split(RegExp(r'[\\/]')).last;
  }

  ({String fileName, String baseName, String extension}) _trackFileNameParts(
    String filePath,
  ) {
    final fileName = filePath.split(RegExp(r'[\\/]')).last;
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex <= 0 || dotIndex == fileName.length - 1) {
      return (fileName: fileName, baseName: fileName, extension: '');
    }
    return (
      fileName: fileName,
      baseName: fileName.substring(0, dotIndex),
      extension: fileName.substring(dotIndex),
    );
  }

  String _normalizedRenameBaseName(String rawInput, String extension) {
    final trimmed = rawInput.trim();
    if (extension.isNotEmpty &&
        trimmed.toLowerCase().endsWith(extension.toLowerCase())) {
      return trimmed.substring(0, trimmed.length - extension.length).trimRight();
    }
    return trimmed;
  }

  String _targetTrackPath({
    required String originalFilePath,
    required String newBaseName,
  }) {
    final parts = _trackFileNameParts(originalFilePath);
    final parentPath = File(originalFilePath).parent.path;
    return '$parentPath${Platform.pathSeparator}$newBaseName${parts.extension}';
  }

  Future<String?> _validateRenameBaseName({
    required AudioTrackEntity track,
    required String rawName,
  }) async {
    final parts = _trackFileNameParts(track.filePath);
    final normalizedName = _normalizedRenameBaseName(rawName, parts.extension);
    if (normalizedName.isEmpty) {
      return 'Track name cannot be empty.';
    }
    if (normalizedName == parts.baseName) {
      return 'Enter a different name.';
    }
    if (_invalidRenameCharactersPattern.hasMatch(normalizedName)) {
      return 'Name cannot contain / \\ : * ? " < > |';
    }

    final sourceFile = File(track.filePath);
    if (!await sourceFile.exists()) {
      return 'File not found.';
    }

    final targetPath = _targetTrackPath(
      originalFilePath: track.filePath,
      newBaseName: normalizedName,
    );
    final targetFile = File(targetPath);
    if (await targetFile.exists()) {
      return 'A file with that name already exists in this folder.';
    }

    return null;
  }

  String _formatBytes(int bytes) {
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    double size = bytes.toDouble();
    var unitIndex = 0;
    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }
    final decimals = size >= 100 || unitIndex == 0 ? 0 : 1;
    return '${size.toStringAsFixed(decimals)} ${units[unitIndex]}';
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  Future<void> _addTrackToQueue(AudioTrackEntity track) async {
    await ref.read(musicPlayerProvider.notifier).addToQueue(track);
    _showMessage('Added "${_trackLabel(track)}" to queue');
  }

  Future<void> _playTrackNext(AudioTrackEntity track) async {
    await ref.read(musicPlayerProvider.notifier).playNext(track);
    _showMessage('Will play "${_trackLabel(track)}" next');
  }

  Future<void> _changeTrackCover(AudioTrackEntity track) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      final selectedPath =
          result == null || result.files.isEmpty ? null : result.files.single.path;
      if (selectedPath == null || selectedPath.isEmpty) {
        return;
      }

      final repoResult =
          await ref.read(musicRepositoryProvider).updateTrackCover(
                filePath: track.filePath,
                coverArtPath: selectedPath,
              );

      if (!mounted) {
        return;
      }

      await repoResult.fold(
        (failure) async => _showMessage(failure.message),
        (updatedTrack) async {
          ref.read(musicPlayerProvider.notifier).refreshTrackMetadata(
                updatedTrack,
                originalFilePath: track.filePath,
              );
          await ref.read(musicLibraryProvider.notifier).loadLibrary();
          _showMessage('Cover updated');
        },
      );
    } catch (error) {
      _showMessage('Could not pick cover image: $error');
    }
  }

  Future<String?> _showRenameDialog(AudioTrackEntity track) async {
    final parts = _trackFileNameParts(track.filePath);
    final controller = TextEditingController(text: parts.baseName);
    controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: controller.text.length,
    );

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        var errorText = '';

        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> submitRename() async {
              final normalizedName = _normalizedRenameBaseName(
                controller.text,
                parts.extension,
              );
              final validationMessage = await _validateRenameBaseName(
                track: track,
                rawName: normalizedName,
              );
              if (!dialogContext.mounted) {
                return;
              }
              if (validationMessage != null) {
                setDialogState(() {
                  errorText = validationMessage;
                });
                return;
              }
              Navigator.of(dialogContext).pop(normalizedName);
            }

            return Directionality(
              textDirection: TextDirection.ltr,
              child: AlertDialog(
                title: const Text('Rename track'),
                content: TextField(
                  controller: controller,
                  autofocus: true,
                  textInputAction: TextInputAction.done,
                  onChanged: (_) {
                    if (errorText.isEmpty) {
                      return;
                    }
                    setDialogState(() {
                      errorText = '';
                    });
                  },
                  onSubmitted: (_) => submitRename(),
                  decoration: InputDecoration(
                    labelText: 'Name',
                    suffixText: parts.extension.isEmpty ? null : parts.extension,
                    helperText: parts.extension.isEmpty
                        ? 'The track will stay in the same folder.'
                        : 'The ${parts.extension} extension will be kept automatically.',
                    errorText: errorText.isEmpty ? null : errorText,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: submitRename,
                    child: const Text('Rename'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    controller.dispose();
    return result;
  }

  Future<void> _renameTrack(AudioTrackEntity track) async {
    final newBaseName = await _showRenameDialog(track);
    if (newBaseName == null) {
      return;
    }

    final result = await ref.read(musicRepositoryProvider).renameTrack(
          filePath: track.filePath,
          newName: newBaseName,
        );

    if (!mounted) {
      return;
    }

    await result.fold(
      (failure) async => _showMessage(failure.message),
      (updatedTrack) async {
        await ref.read(musicPlayerProvider.notifier).replaceTrackReferences(
              updatedTrack,
              originalFilePath: track.filePath,
            );
        await ref.read(musicLibraryProvider.notifier).loadLibrary();
        if (!mounted) {
          return;
        }
        final renamedFileName = _trackFileNameParts(updatedTrack.filePath).fileName;
        _showMessage('Renamed to "$renamedFileName"');
      },
    );
  }

  Future<void> _shareTrack(AudioTrackEntity track) async {
    final file = File(track.filePath);
    if (!await file.exists()) {
      _showMessage('File not found');
      return;
    }

    try {
      await Share.shareXFiles(
        [XFile(track.filePath)],
        subject: _trackLabel(track),
      );
    } catch (error) {
      _showMessage('Share failed: $error');
    }
  }

  Future<void> _showPropertiesDialog(AudioTrackEntity track) async {
    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: AlertDialog(
            title: const Text('Properties'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PropertyRow(label: 'Title', value: _trackLabel(track)),
                  _PropertyRow(label: 'Artist', value: track.artist),
                  _PropertyRow(label: 'Album', value: track.album),
                  _PropertyRow(
                    label: 'Duration',
                    value: track.formattedDuration,
                  ),
                  _PropertyRow(
                    label: 'Size',
                    value: track.fileSizeBytes > 0
                        ? _formatBytes(track.fileSizeBytes)
                        : '—',
                  ),
                  _PropertyRow(label: 'Path', value: track.filePath),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openTrackActions({
    required List<AudioTrackEntity> queue,
    required int index,
  }) {
    final track = queue[index];

    return MusicTrackActionsSheet.show(
      context,
      track: track,
      onPlayNow: () => _playTrack(queue: queue, index: index),
      onPlayNext: () => _playTrackNext(track),
      onAddToQueue: () => _addTrackToQueue(track),
      onChangeCover: () => _changeTrackCover(track),
      onShare: () => _shareTrack(track),
      onRename: () => _renameTrack(track),
      onProperties: () => _showPropertiesDialog(track),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(musicLibraryProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final appBarTextColor = theme.appBarTheme.foregroundColor ?? cs.onSurface;
    final appBarSecondaryTextColor = appBarTextColor.withValues(
      alpha: theme.brightness == Brightness.dark ? 0.72 : 0.62,
    );
    final isSyncing = state.status == MusicLibraryStatus.syncing;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: _isSearching
              ? TextField(
                  autofocus: true,
                  cursorColor: appBarTextColor,
                  decoration: InputDecoration(
                    hintText: 'Search songs...',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    filled: false,
                    hintStyle: TextStyle(color: appBarSecondaryTextColor),
                  ),
                  style: TextStyle(color: appBarTextColor),
                  onChanged: (v) =>
                      ref.read(musicLibraryProvider.notifier).setSearchQuery(v),
                )
              : const Text('Music Library'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(kTextTabBarHeight),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TabBar(
                controller: _tabController,
                labelColor: appBarTextColor,
                unselectedLabelColor: appBarSecondaryTextColor,
                indicatorColor: cs.secondary,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                padding: EdgeInsets.zero,
                labelPadding: const EdgeInsetsDirectional.symmetric(
                  horizontal: 16,
                ),
                tabs: const [
                  Tab(text: 'Songs'),
                  Tab(text: 'Folders'),
                  Tab(text: 'Albums'),
                  Tab(text: 'Artists'),
                  Tab(text: 'Playlists'),
                ],
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(_isSearching ? Symbols.close : Symbols.search),
              tooltip: _isSearching ? 'Close search' : 'Search',
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                  if (!_isSearching) {
                    ref.read(musicLibraryProvider.notifier).setSearchQuery('');
                  }
                });
              },
            ),
            PopupMenuButton<String>(
              icon: const Icon(Symbols.more_vert),
              onSelected: (value) {
                switch (value) {
                  case 'sync':
                    if (!isSyncing) {
                      _syncWithDevice();
                    }
                    break;
                  case 'downloads':
                    context.push(AppRoutes.downloads);
                    break;
                  case 'settings':
                    context.push(AppRoutes.settings);
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  value: 'sync',
                  enabled: !isSyncing,
                  child: Row(
                    children: [
                      const Icon(Symbols.sync, size: 20),
                      const SizedBox(width: 12),
                      Text(isSyncing ? 'Syncing...' : 'Sync with Device'),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem<String>(
                  value: 'downloads',
                  child: Row(
                    children: [
                      Icon(Symbols.download, size: 20),
                      SizedBox(width: 12),
                      Text('Downloads'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'settings',
                  child: Row(
                    children: [
                      Icon(Symbols.settings, size: 20),
                      SizedBox(width: 12),
                      Text('Settings'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: _buildBody(state),
      ),
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
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    if (state.status == MusicLibraryStatus.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Symbols.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                state.errorMessage ?? 'Unknown error',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _syncWithDevice,
                child: const Text('Retry Sync'),
              ),
            ],
          ),
        ),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildSongsTab(state),
        _buildFoldersTab(state),
        _buildAlbumsTab(state),
        _buildArtistsTab(state),
        _buildPlaylistsTab(state),
      ],
    );
  }

  Widget _buildFoldersTab(MusicLibraryState state) {
    // Premium UI parity only (feature can be implemented later).
    return _buildEmptyState('Folders view (coming soon).');
  }

  Widget _buildSongsTab(MusicLibraryState state) {
    final tracks = state.displayTracks;

    if (tracks.isEmpty) {
      return _buildEmptyState('No songs found. Try syncing.');
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: tracks.length,
      padding: const EdgeInsetsDirectional.fromSTEB(0, 8, 0, 80),
      separatorBuilder: (context, index) {
        return Divider(
          height: 1,
          indent: 16,
          endIndent: 16,
          color: Theme.of(context).colorScheme.outlineVariant.withValues(
                alpha: 0.35,
              ),
        );
      },
      itemBuilder: (context, index) {
        final track = tracks[index];
        final colorScheme = Theme.of(context).colorScheme;

        return ListTile(
          contentPadding: const EdgeInsetsDirectional.only(
            start: 16,
            end: 8,
          ),
          title: Text(
            _trackLabel(track),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            track.artist,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                track.formattedDuration,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
              IconButton(
                icon: const Icon(Symbols.more_vert),
                tooltip: 'Track actions',
                color: colorScheme.onSurfaceVariant,
                onPressed: () => _openTrackActions(
                  queue: tracks,
                  index: index,
                ),
              ),
            ],
          ),
          onLongPress: () => _openTrackActions(
            queue: tracks,
            index: index,
          ),
          onTap: () => _playTrack(queue: tracks, index: index),
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
          leading: const Icon(Symbols.album),
          title: Text(
            album,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
          onTap: () {
            final albumTracks =
                state.tracks.where((t) => t.album == album).toList();

            if (albumTracks.isEmpty) {
              return;
            }

            _playTrack(queue: albumTracks, index: 0);
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
          leading: const Icon(Symbols.person),
          title: Text(
            artist,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
          onTap: () {
            final artistTracks =
                state.tracks.where((t) => t.artist == artist).toList();

            if (artistTracks.isEmpty) {
              return;
            }

            _playTrack(queue: artistTracks, index: 0);
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
          leading: const Icon(Symbols.playlist_play),
          title: Text(
            playlist.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
          subtitle: Text(
            '${playlist.trackIds.length} songs',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          onTap: () {
            // Implementation for loading playlist tracks would go here
          },
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Symbols.library_music,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _PropertyRow extends StatelessWidget {
  final String label;
  final String value;

  const _PropertyRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: cs.onSurfaceVariant,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value.isEmpty ? '—' : value,
            style: TextStyle(
              color: cs.onSurface,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
