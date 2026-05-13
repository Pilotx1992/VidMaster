import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';

import 'package:share_plus/share_plus.dart';
import 'package:vidmaster/features/video_player/domain/entities/video_file.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/states/states.dart';
import '../../../../core/widgets/icons/custom_sort_arrows_icon.dart';
import '../../domain/entities/video_entity.dart';
import 'video_player_screen.dart' show VideoPlayerArgs;
import '../providers/video_library_provider.dart';
import '../providers/video_player_provider.dart';
import '../widgets/video_actions_sheet.dart';
import '../widgets/video_cast_button.dart';
import '../widgets/video_thumbnail_card.dart';

/// Derived (memoized) queue for the current view (after search + sort).
final videoQueueFilesProvider = Provider<List<VideoFile>>((ref) {
  final display = ref.watch(
    videoLibraryProvider.select((s) => s.displayVideos),
  );
  return display
      .map((v) => VideoFile(path: v.filePath, name: v.fileName))
      .toList(growable: false);
});

class VideoLibraryScreen extends ConsumerStatefulWidget {
  const VideoLibraryScreen({super.key});

  @override
  ConsumerState<VideoLibraryScreen> createState() => _VideoLibraryScreenState();
}

class _VideoLibraryScreenState extends ConsumerState<VideoLibraryScreen> {
  static final RegExp _invalidRenameCharactersPattern =
      RegExp(r'[\/\\:\*\?"<>\|]');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(videoLibraryProvider.notifier).loadLibrary();
    });
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(
      videoLibraryProvider.select((s) => s.status),
    );
    final videos = ref.watch(
      videoLibraryProvider.select((s) => s.videos),
    );
    final errorMessage = ref.watch(
      videoLibraryProvider.select((s) => s.errorMessage),
    );
    final isGridView = ref.watch(
      videoLibraryProvider.select((s) => s.isGridView),
    );
    final isSearchMode = ref.watch(
      videoLibraryProvider.select((s) => s.isSearchMode),
    );
    final searchQuery = ref.watch(
      videoLibraryProvider.select((s) => s.searchQuery),
    );
    final displayVideos = ref.watch(
      videoLibraryProvider.select((s) => s.displayVideos),
    );
    final queueFiles = ref.watch(videoQueueFilesProvider);
    final activeTab = ref.watch(
      videoLibraryProvider.select((s) => s.activeTab),
    );
    final selectedFolderName = ref.watch(
      videoLibraryProvider.select((s) => s.selectedFolderName),
    );
    final folders = ref.watch(
      videoLibraryProvider.select((s) => s.folders),
    );
    final recentlyPlayed = ref.watch(
      videoLibraryProvider.select((s) => s.recentlyPlayed),
    );
    final favorites = ref.watch(
      videoLibraryProvider.select((s) => s.favorites),
    );

    final displayedCount = displayVideos.length;
    final displayedBytes =
        displayVideos.fold<int>(0, (sum, v) => sum + v.fileSizeBytes);

    // Whole screen LTR like XPlayer: AppBar (title/actions), control strip, list/grid.
    // Arabic file names still render RTL via unicode bidi inside Text.
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: isSearchMode
              ? TextField(
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Search videos...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.black38),
                  ),
                  style: const TextStyle(color: Colors.black87),
                  cursorColor: Colors.black,
                  onChanged: (v) =>
                      ref.read(videoLibraryProvider.notifier).setSearchQuery(v),
                )
              : const Text('Videos'),
          actions: [
            if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android)
              Builder(
                builder: _buildCastToolbarAction,
              )
            else
              IconButton(
                icon: const Icon(Symbols.cast),
                tooltip: 'Cast',
                onPressed: () {
                  ScaffoldMessenger.of(context)
                    ..clearSnackBars()
                    ..showSnackBar(
                      const SnackBar(
                        content: Text('Cast — coming soon'),
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 2),
                      ),
                    );
                },
              ),
            IconButton(
              icon: Icon(isSearchMode ? Symbols.close : Symbols.search),
              onPressed: () {
                final notifier = ref.read(videoLibraryProvider.notifier);
                if (isSearchMode) {
                  notifier.exitSearch();
                } else {
                  notifier.enterSearch();
                }
              },
            ),
            PopupMenuButton<String>(
              icon: const Icon(Symbols.more_vert),
              itemBuilder: (context) {
                // Disable "Clear recent" when there's nothing to clear so the
                // user doesn't tap it on an empty state and wonder if it did
                // anything. Re-read here (not from the outer scope) so the
                // item updates the next time the menu opens.
                final hasRecent =
                    ref.read(videoLibraryProvider).recentlyPlayed.isNotEmpty;
                return [
                  const PopupMenuItem(
                    value: 'sync',
                    child: _LtrPopupMenuItemContent(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Symbols.sync, size: 20),
                          SizedBox(width: 12),
                          Text('Sync with device'),
                        ],
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'clear_recent',
                    enabled: hasRecent,
                    child: const _LtrPopupMenuItemContent(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Symbols.history, size: 20),
                          SizedBox(width: 12),
                          Text('Clear recent'),
                        ],
                      ),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'downloads',
                    child: _LtrPopupMenuItemContent(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Symbols.download, size: 20),
                          SizedBox(width: 12),
                          Text('Downloads'),
                        ],
                      ),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'settings',
                    child: _LtrPopupMenuItemContent(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Symbols.settings, size: 20),
                          SizedBox(width: 12),
                          Text('Settings'),
                        ],
                      ),
                    ),
                  ),
                ];
              },
              onSelected: (v) async {
                switch (v) {
                  case 'sync':
                    await ref
                        .read(videoLibraryProvider.notifier)
                        .loadLibrary(forceSync: true);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Library synced'),
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 2),
                      ),
                    );
                    break;
                  case 'clear_recent':
                    await ref.read(videoLibraryProvider.notifier).clearRecent();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Recent history cleared'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    break;
                  case 'downloads':
                    context.push(AppRoutes.downloads);
                    break;
                  case 'settings':
                    context.push(AppRoutes.settings);
                    break;
                }
              },
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () => ref
              .read(videoLibraryProvider.notifier)
              .loadLibrary(forceSync: true),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _LibraryTabBar(
                  activeTab: activeTab,
                  onChanged: (t) =>
                      ref.read(videoLibraryProvider.notifier).setActiveTab(t),
                ),
              ),
              if (activeTab == VideoLibraryTab.folders &&
                  selectedFolderName != null)
                SliverToBoxAdapter(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => ref
                          .read(videoLibraryProvider.notifier)
                          .exitFolderBrowse(),
                      icon: const Icon(Symbols.arrow_back_rounded, size: 20),
                      label: const Text('All folders'),
                    ),
                  ),
                ),
              if (!(activeTab == VideoLibraryTab.folders &&
                  selectedFolderName == null))
                SliverToBoxAdapter(
                  child: _TopRightControls(
                    isGridView: isGridView,
                    onSort: () => _showXPlayerSortDialog(context),
                    onToggleView: () =>
                        ref.read(videoLibraryProvider.notifier).toggleView(),
                    totalVideos: displayedCount,
                    totalBytes: displayedBytes,
                  ),
                )
              else
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    child: Text(
                      '${folders.length} folders — tap to open',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ..._buildSlivers(
                status: status,
                activeTab: activeTab,
                selectedFolderName: selectedFolderName,
                folders: folders,
                recentlyPlayed: recentlyPlayed,
                favorites: favorites,
                videos: videos,
                displayVideos: displayVideos,
                queueFiles: queueFiles,
                isGridView: isGridView,
                isSearchMode: isSearchMode,
                searchQuery: searchQuery,
                errorMessage: errorMessage,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;
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

  String _videoFileName(String filePath) {
    return filePath.split(RegExp(r'[\\/]')).last;
  }

  String _videoExtension(String filePath) {
    final fileName = _videoFileName(filePath);
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex <= 0 || dotIndex == fileName.length - 1) {
      return '';
    }
    return fileName.substring(dotIndex);
  }

  String _videoBaseName(String filePath) {
    final fileName = _videoFileName(filePath);
    final extension = _videoExtension(filePath);
    if (extension.isEmpty) {
      return fileName;
    }
    return fileName.substring(0, fileName.length - extension.length);
  }

  String _normalizedRenameBaseName(String rawInput, String extension) {
    final trimmed = rawInput.trim();
    if (extension.isNotEmpty &&
        trimmed.toLowerCase().endsWith(extension.toLowerCase())) {
      return trimmed
          .substring(0, trimmed.length - extension.length)
          .trimRight();
    }
    return trimmed;
  }

  String _targetVideoPath({
    required String originalFilePath,
    required String newBaseName,
  }) {
    final parentPath = File(originalFilePath).parent.path;
    return '$parentPath${Platform.pathSeparator}$newBaseName${_videoExtension(originalFilePath)}';
  }

  VideoFile _videoFileFromEntity(VideoEntity video) {
    return VideoFile(
      path: video.filePath,
      name: video.fileName,
      duration: video.durationMs == null
          ? null
          : Duration(milliseconds: video.durationMs!),
    );
  }

  Future<String?> _validateRenameBaseName({
    required VideoEntity video,
    required String rawName,
  }) async {
    final extension = _videoExtension(video.filePath);
    final normalizedName = _normalizedRenameBaseName(rawName, extension);
    if (normalizedName.isEmpty) {
      return 'Video name cannot be empty.';
    }
    if (normalizedName == _videoBaseName(video.filePath)) {
      return 'Enter a different name.';
    }
    if (_invalidRenameCharactersPattern.hasMatch(normalizedName)) {
      return 'Name cannot contain / \\ : * ? " < > |';
    }

    final sourceFile = File(video.filePath);
    if (!await sourceFile.exists()) {
      return 'File not found.';
    }

    final targetPath = _targetVideoPath(
      originalFilePath: video.filePath,
      newBaseName: normalizedName,
    );
    if (await File(targetPath).exists()) {
      return 'A file with that name already exists in this folder.';
    }

    return null;
  }

  Future<String?> _showRenameDialog(VideoEntity video) async {
    final extension = _videoExtension(video.filePath);
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => _RenameVideoDialog(
        initialName: _videoBaseName(video.filePath),
        extension: extension,
        validateName: (rawName) => _validateRenameBaseName(
          video: video,
          rawName: rawName,
        ),
        normalizeName: (rawName) =>
            _normalizedRenameBaseName(rawName, extension),
      ),
    );
  }

  Widget _buildCastToolbarAction(BuildContext context) {
    final iconColor = IconTheme.of(context).color;
    final useDarkIcon = iconColor == null
        ? Theme.of(context).brightness == Brightness.light
        : iconColor.computeLuminance() < 0.5;

    return VideoCastButton(
      video: null,
      position: Duration.zero,
      duration: Duration.zero,
      onCastStarted: () {},
      useDarkNativeIcon: useDarkIcon,
    );
  }

  List<Widget> _buildSlivers({
    required VideoLibraryStatus status,
    required VideoLibraryTab activeTab,
    required String? selectedFolderName,
    required List<String> folders,
    required List<VideoEntity> recentlyPlayed,
    required List<VideoEntity> favorites,
    required List<VideoEntity> videos,
    required List<VideoEntity> displayVideos,
    required List<VideoFile> queueFiles,
    required bool isGridView,
    required bool isSearchMode,
    required String searchQuery,
    required String? errorMessage,
  }) {
    if (status == VideoLibraryStatus.loading && videos.isEmpty) {
      return const [
        SliverToBoxAdapter(child: SkeletonList.cards(itemCount: 6)),
      ];
    }

    if (status == VideoLibraryStatus.error) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: ErrorStateWidget(
            message: errorMessage ?? 'Failed to load videos',
            onRetry: () =>
                ref.read(videoLibraryProvider.notifier).loadLibrary(),
          ),
        ),
      ];
    }

    if (videos.isEmpty) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyStateWidget(
            icon: Symbols.video_library,
            message: 'No videos found on your device',
          ),
        ),
      ];
    }

    if (activeTab == VideoLibraryTab.folders && selectedFolderName == null) {
      final sorted = [...folders]..sort((a, b) => a.compareTo(b));
      if (sorted.isEmpty) {
        return const [
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyStateWidget(
              icon: Symbols.folder_open,
              message: 'No folders yet',
            ),
          ),
        ];
      }
      return [
        SliverPadding(
          padding: const EdgeInsets.only(bottom: 24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final name = sorted[index];
                final count = videos.where((v) => v.folderName == name).length;
                return ListTile(
                  leading: const Icon(Symbols.folder),
                  title: Text(
                    name.isEmpty ? '(Unknown)' : name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text('$count videos'),
                  onTap: () =>
                      ref.read(videoLibraryProvider.notifier).openFolder(name),
                );
              },
              childCount: sorted.length,
            ),
          ),
        ),
      ];
    }

    if (displayVideos.isEmpty &&
        isSearchMode &&
        searchQuery.trim().isNotEmpty) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: Text('No matches found')),
        ),
      ];
    }

    if (displayVideos.isEmpty && !isSearchMode) {
      if (activeTab == VideoLibraryTab.recent && recentlyPlayed.isEmpty) {
        return const [
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyStateWidget(
              icon: Symbols.history,
              message: 'No recently played videos',
            ),
          ),
        ];
      }
      if (activeTab == VideoLibraryTab.favorites && favorites.isEmpty) {
        return const [
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyStateWidget(
              icon: Symbols.favorite_border,
              message: 'No favorite videos yet',
            ),
          ),
        ];
      }
      if (activeTab == VideoLibraryTab.folders && selectedFolderName != null) {
        return [
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyStateWidget(
              icon: Symbols.video_library,
              message: 'No videos in folder \u201c$selectedFolderName\u201d',
            ),
          ),
        ];
      }
    }

    // Freeze the queue once per build so every row in this rebuild pushes the
    // SAME immutable snapshot to /player. Without this, the player notifier's
    // captured queue could in principle drift if the underlying provider
    // recomputed between tap and push (e.g. a background sync updating
    // `displayVideos`). `List.unmodifiable` also throws on accidental
    // mutation, which is the contract `VideoPlayerArgs.queue` assumes.
    final queueSnapshot = List<VideoFile>.unmodifiable(queueFiles);
    // Snapshot the active sort + tab for the diagnostic logs only; the read
    // is otherwise unused so we don't pay for it in release builds.
    final libState = ref.read(videoLibraryProvider);

    void diagPush(int index) {
      if (!kDebugMode) return;
      final tapped = queueSnapshot[index];
      final firstNames = queueSnapshot.take(10).map((v) => v.name).join(' | ');
      // Print the date keys that drive the Date sort so we can see whether
      // any items have null `fileModifiedAt` (= the historical bug surface).
      final firstDates = displayVideos
          .take(10)
          .map((v) =>
              '${v.fileName}=fm:${v.fileModifiedAt?.toIso8601String() ?? "null"} '
              'lp:${v.lastPlayedAt?.toIso8601String() ?? "null"}')
          .join(' || ');
      debugPrint(
        '[QueuePush] sort=${libState.sortOrder.name} asc=${libState.sortAscending} '
        'tab=${libState.activeTab.name} tappedIndex=$index tapped=${tapped.name}',
      );
      debugPrint('[QueuePush] queue.names=$firstNames');
      debugPrint('[QueuePush] dates=$firstDates');
      debugPrint(
        '[QueuePush] queueLen=${queueSnapshot.length} '
        'displayLen=${displayVideos.length} '
        'sameLength=${queueSnapshot.length == displayVideos.length} '
        'queueIdentity=${identityHashCode(queueSnapshot)}',
      );
    }

    if (isGridView) {
      return [
        SliverPadding(
          padding: const EdgeInsets.all(12),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => VideoThumbnailCard(
                key: ValueKey(displayVideos[index].filePath),
                video: displayVideos[index],
                onTap: () {
                  diagPush(index);
                  context.push(
                    AppRoutes.player,
                    extra: VideoPlayerArgs(
                      video: queueSnapshot[index],
                      queue: queueSnapshot,
                    ),
                  );
                },
                onMore: () => _openVideoActions(displayVideos[index]),
              ),
              childCount: displayVideos.length,
            ),
          ),
        ),
      ];
    }

    return [
      SliverPadding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final v = displayVideos[index];
              return _XPlayerListRow(
                key: ValueKey(v.filePath),
                video: v,
                onTap: () {
                  diagPush(index);
                  context.push(
                    AppRoutes.player,
                    extra: VideoPlayerArgs(
                      video: queueSnapshot[index],
                      queue: queueSnapshot,
                    ),
                  );
                },
                onMore: () => _openVideoActions(v),
              );
            },
            childCount: displayVideos.length,
          ),
        ),
      ),
    ];
  }

  // ── 3-dot action sheet ────────────────────────────────────────────────────
  //
  // The unsupported actions remain stubbed in this pass; Rename is wired to a
  // real backend flow below because it is explicitly in scope.
  void _openVideoActions(VideoEntity video) {
    if (!mounted) return;

    final screenContext = context;
    VideoActionsSheet.show(
      screenContext,
      video: video,
      onLockVault: () =>
          _showComingSoon(screenContext, 'Lock in Private Folder'),
      onConvertMp3: () => _showComingSoon(screenContext, 'Convert to MP3'),
      onAddToPlaylist: () => _showComingSoon(screenContext, 'Add to playlist'),
      onDelete: () => _handleDelete(screenContext, video),
      onShare: () => _handleShare(screenContext, video),
      onRename: () => _handleRename(video),
      onProperties: () => _showPropertiesDialog(screenContext, video),
    );
  }

  void _showComingSoon(BuildContext context, String label) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text('$label — coming soon'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  Future<void> _handleShare(
    BuildContext context,
    VideoEntity video,
  ) async {
    final file = File(video.filePath);
    if (!await file.exists()) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('File not found'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    try {
      await Share.shareXFiles(
        [XFile(video.filePath)],
        subject: video.fileName,
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Share failed: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleDelete(
    BuildContext context,
    VideoEntity video,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.ltr,
        child: AlertDialog(
          title: const Text('Delete video?'),
          content: Text(
            'This will permanently remove\n"${video.fileName}"\nfrom your device.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
              child: const Text('Delete'),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    final ok = await ref
        .read(videoLibraryProvider.notifier)
        .deleteVideo(video.filePath);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Video deleted' : 'Failed to delete video'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleRename(VideoEntity video) async {
    if (!mounted) return;

    final newBaseName = await _showRenameDialog(video);
    if (newBaseName == null) return;

    final result = await ref.read(videoLibraryProvider.notifier).renameVideo(
          filePath: video.filePath,
          newName: newBaseName,
        );

    if (!mounted) return;

    result.fold(
      (failure) => _showMessage(failure.message),
      (updatedVideo) {
        ref.read(videoPlayerProvider.notifier).replaceVideoReferences(
              originalPath: video.filePath,
              updatedVideo: _videoFileFromEntity(updatedVideo),
            );
        _showMessage('Renamed to "${_videoFileName(updatedVideo.filePath)}"');
      },
    );
  }

  void _showPropertiesDialog(BuildContext context, VideoEntity video) {
    final modified = video.fileModifiedAt;
    final resolution =
        (video.resolution ?? '').isEmpty ? '—' : video.resolution!;
    final duration = video.formattedDuration;
    final size = video.formattedSize;
    final modifiedLabel = modified == null
        ? '—'
        : '${modified.year}-${modified.month.toString().padLeft(2, '0')}-'
            '${modified.day.toString().padLeft(2, '0')} '
            '${modified.hour.toString().padLeft(2, '0')}:'
            '${modified.minute.toString().padLeft(2, '0')}';

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Properties'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PropertyRow(label: 'Name', value: video.fileName),
              _PropertyRow(label: 'Folder', value: video.folderName),
              _PropertyRow(label: 'Path', value: video.filePath),
              _PropertyRow(label: 'Size', value: size),
              _PropertyRow(label: 'Duration', value: duration),
              _PropertyRow(label: 'Resolution', value: resolution),
              _PropertyRow(
                label: 'Format',
                value: video.extension.toUpperCase(),
              ),
              _PropertyRow(label: 'Date', value: modifiedLabel),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _RenameVideoDialog extends StatefulWidget {
  final String initialName;
  final String extension;
  final Future<String?> Function(String rawName) validateName;
  final String Function(String rawName) normalizeName;

  const _RenameVideoDialog({
    required this.initialName,
    required this.extension,
    required this.validateName,
    required this.normalizeName,
  });

  @override
  State<_RenameVideoDialog> createState() => _RenameVideoDialogState();
}

class _RenameVideoDialogState extends State<_RenameVideoDialog> {
  late final TextEditingController _controller;
  String _errorText = '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
    _controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _controller.text.length,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submitRename() async {
    final validationMessage = await widget.validateName(_controller.text);
    if (!mounted) return;
    if (validationMessage != null) {
      setState(() {
        _errorText = validationMessage;
      });
      return;
    }

    Navigator.of(context).pop(widget.normalizeName(_controller.text));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: AlertDialog(
        title: const Text('Rename video'),
        content: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.done,
          onChanged: (_) {
            if (_errorText.isEmpty) return;
            setState(() {
              _errorText = '';
            });
          },
          onSubmitted: (_) async {
            await _submitRename();
          },
          decoration: InputDecoration(
            labelText: 'Name',
            suffixText: widget.extension.isEmpty ? null : widget.extension,
            helperText: widget.extension.isEmpty
                ? 'The video will stay in the same folder.'
                : 'The ${widget.extension} extension will be kept automatically.',
            errorText: _errorText.isEmpty ? null : _errorText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: _submitRename,
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }
}

class _PropertyRow extends StatelessWidget {
  final String label;
  final String value;
  const _PropertyRow({required this.label, required this.value});

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
          SelectableText(
            value,
            style: TextStyle(color: cs.onSurface, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _LtrPopupMenuItemContent extends StatelessWidget {
  final Widget child;

  const _LtrPopupMenuItemContent({required this.child});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Align(
        alignment: Alignment.centerLeft,
        child: child,
      ),
    );
  }
}

class _LibraryTabBar extends StatelessWidget {
  final VideoLibraryTab activeTab;
  final ValueChanged<VideoLibraryTab> onChanged;

  const _LibraryTabBar({
    required this.activeTab,
    required this.onChanged,
  });

  static String _label(VideoLibraryTab t) => switch (t) {
        VideoLibraryTab.all => 'All',
        VideoLibraryTab.folders => 'Folders',
        VideoLibraryTab.recent => 'Recent',
        VideoLibraryTab.favorites => 'Favorites',
      };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Row(
        children: [
          for (final t in VideoLibraryTab.values)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: ChoiceChip(
                label: Text(_label(t)),
                selected: activeTab == t,
                onSelected: (_) => onChanged(t),
              ),
            ),
        ],
      ),
    );
  }
}

class _TopRightControls extends StatelessWidget {
  final bool isGridView;
  final VoidCallback onSort;
  final VoidCallback onToggleView;
  final int totalVideos;
  final int totalBytes;

  const _TopRightControls({
    required this.isGridView,
    required this.onSort,
    required this.onToggleView,
    required this.totalVideos,
    required this.totalBytes,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = Theme.of(context).colorScheme;
    final controlIconColor = theme.brightness == Brightness.dark
        ? cs.onSurfaceVariant
        : cs.onSurface;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? Colors.black.withValues(alpha: 0.15)
            : cs.surface,
      ),
      // Count + size on the left; sort + view icons on the right (LTR strip).
      child: Row(
        textDirection: TextDirection.ltr,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${totalVideos.toString()} VIDEOS  ${_formatBytes(totalBytes)}',
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
              ),
            ),
          ),
          const Spacer(),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: CustomSortArrowsIcon(color: controlIconColor, size: 24),
            onPressed: onSort,
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: Icon(
              isGridView ? Symbols.view_list : Symbols.grid_view,
              color: controlIconColor,
            ),
            onPressed: onToggleView,
          ),
        ],
      ),
    );
  }

  static String _formatBytes(int bytes) {
    const kb = 1024.0;
    const mb = kb * 1024.0;
    const gb = mb * 1024.0;
    const tb = gb * 1024.0;

    if (bytes >= tb) return '${(bytes / tb).toStringAsFixed(1)} TB';
    if (bytes >= gb) return '${(bytes / gb).toStringAsFixed(1)} GB';
    if (bytes >= mb) return '${(bytes / mb).toStringAsFixed(0)} MB';
    if (bytes >= kb) return '${(bytes / kb).toStringAsFixed(0)} KB';
    return '$bytes B';
  }
}

extension on _VideoLibraryScreenState {
  Future<void> _showXPlayerSortDialog(BuildContext context) async {
    final current = ref.read(videoLibraryProvider);
    var order = current.sortOrder;
    var asc = current.sortAscending;

    String orderLabel(VideoSortOrder o) => switch (o) {
          VideoSortOrder.name => 'Name',
          VideoSortOrder.date => 'Date',
          VideoSortOrder.size => 'Size',
          VideoSortOrder.duration => 'Length',
        };

    List<String> directionLabels(VideoSortOrder o) => switch (o) {
          VideoSortOrder.name => const ['From A to Z', 'From Z to A'],
          VideoSortOrder.date => const ['From new to old', 'From old to new'],
          VideoSortOrder.size => const [
              'From big to small',
              'From small to big'
            ],
          VideoSortOrder.duration => const [
              'From long to short',
              'From short to long'
            ],
        };

    // In XPlayer UI: first option is DESC for date/size/length, ASC for name.
    bool firstOptionMeansAscending(VideoSortOrder o) => switch (o) {
          VideoSortOrder.name => true, // A -> Z
          VideoSortOrder.date => false, // new -> old
          VideoSortOrder.size => false, // big -> small
          VideoSortOrder.duration => false, // long -> short
        };

    await showDialog<void>(
      context: context,
      builder: (context) {
        // Match XPlayer layout: left aligned text + radios on the left.
        // Even if the app is RTL (Arabic), keep this dialog LTR.
        return Directionality(
          textDirection: TextDirection.ltr,
          child: AlertDialog(
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            title: const Align(
              alignment: Alignment.centerLeft,
              child: Text('Sort by', textAlign: TextAlign.left),
            ),
            content: StatefulBuilder(
              builder: (context, setState) {
                final dir = directionLabels(order);
                final first = dir[0];
                final second = dir[1];
                final firstAsc = firstOptionMeansAscending(order);
                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RadioGroup<VideoSortOrder>(
                        groupValue: order,
                        onChanged: (x) {
                          if (x == null) return;
                          setState(() => order = x);
                          // Default direction like XPlayer: choose the first option by default.
                          setState(() => asc = firstOptionMeansAscending(x));
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ...VideoSortOrder.values.map(
                              (v) => RadioListTile<VideoSortOrder>(
                                value: v,
                                activeColor: Colors.green,
                                dense: true,
                                visualDensity: const VisualDensity(
                                    horizontal: -4, vertical: -4),
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 0),
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                title: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    orderLabel(v),
                                    textAlign: TextAlign.left,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: false,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(),
                      RadioGroup<bool>(
                        groupValue: asc == firstAsc,
                        onChanged: (x) {
                          if (x == null) return;
                          setState(() => asc = x ? firstAsc : !firstAsc);
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            RadioListTile<bool>(
                              value: true, // first option
                              activeColor: Colors.green,
                              dense: true,
                              visualDensity: const VisualDensity(
                                  horizontal: -4, vertical: -4),
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 0),
                              controlAffinity: ListTileControlAffinity.leading,
                              title: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  first,
                                  textAlign: TextAlign.left,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: false,
                                ),
                              ),
                            ),
                            RadioListTile<bool>(
                              value: false, // second option
                              activeColor: Colors.green,
                              dense: true,
                              visualDensity: const VisualDensity(
                                  horizontal: -4, vertical: -4),
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 0),
                              controlAffinity: ListTileControlAffinity.leading,
                              title: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  second,
                                  textAlign: TextAlign.left,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: false,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            actionsAlignment: MainAxisAlignment.end,
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: () {
                  ref.read(videoLibraryProvider.notifier).updateSorting(
                        order: order,
                        ascending: asc,
                      );
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _XPlayerListRow extends ConsumerWidget {
  final VideoEntity video;
  final VoidCallback onTap;
  final VoidCallback onMore;

  const _XPlayerListRow({
    super.key,
    required this.video,
    required this.onTap,
    required this.onMore,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final subtitle = video.resolution != null && video.resolution!.isNotEmpty
        ? '${video.extension.toUpperCase()} (${video.resolution})'
        : video.extension.toUpperCase();
    // Date label = the file's arrival date on this device (`fileModifiedAt`).
    // We intentionally do NOT fall back to `lastPlayedAt` — that would make
    // the label drift on every playback while the row itself stays put under
    // the Date sort key (which is also `fileModifiedAt`). The Recent tab is
    // the dedicated surface for "when did I last watch this".
    final date = _formatShortDate(video.fileModifiedAt);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            textDirection: TextDirection.ltr,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ThumbWithDuration(video: video, ref: ref),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.fileName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          TextStyle(color: cs.onSurfaceVariant, fontSize: 10),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 32, minHeight: 32),
                    icon: Icon(
                      Symbols.more_vert,
                      color: cs.onSurfaceVariant,
                      size: 22,
                    ),
                    tooltip: 'More',
                    onPressed: onMore,
                  ),
                  if (date.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        date,
                        style:
                            TextStyle(color: cs.onSurfaceVariant, fontSize: 10),
                      ),
                    )
                  else
                    const SizedBox(height: 18),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatShortDate(DateTime? dt) {
    if (dt == null) return '';
    // XPlayer style "5-5"
    return '${dt.month}-${dt.day}';
  }
}

class _ThumbWithDuration extends StatefulWidget {
  final VideoEntity video;
  final WidgetRef ref;
  const _ThumbWithDuration({required this.video, required this.ref});

  @override
  State<_ThumbWithDuration> createState() => _ThumbWithDurationState();
}

class _ThumbWithDurationState extends State<_ThumbWithDuration> {
  String? _thumbPath;
  String? _loadingForPath;

  @override
  void initState() {
    super.initState();
    _thumbPath = widget.video.thumbnailPath;
    _loadingForPath = null;
    if (_thumbPath == null) {
      _loadThumbnailFor(widget.video.filePath);
    }
  }

  @override
  void didUpdateWidget(covariant _ThumbWithDuration oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.video.filePath != widget.video.filePath) {
      _syncThumbnailForCurrentVideo();
      return;
    }
    if (oldWidget.video.thumbnailPath != widget.video.thumbnailPath) {
      final fromEntity = widget.video.thumbnailPath;
      setState(() {
        _thumbPath = fromEntity;
        _loadingForPath = null;
      });
      if (fromEntity == null) {
        _loadThumbnailFor(widget.video.filePath);
      }
    }
  }

  void _syncThumbnailForCurrentVideo() {
    final existingThumb = widget.video.thumbnailPath;

    setState(() {
      _thumbPath = existingThumb;
      _loadingForPath = null;
    });

    if (existingThumb == null) {
      _loadThumbnailFor(widget.video.filePath);
    }
  }

  Future<void> _loadThumbnailFor(String videoPath) async {
    if (_loadingForPath == videoPath) return;

    if (!mounted) return;
    setState(() {
      _loadingForPath = videoPath;
    });

    final path = await widget.ref
        .read(videoLibraryProvider.notifier)
        .getThumbnail(videoPath);

    if (!mounted) return;
    if (widget.video.filePath != videoPath) return;

    setState(() {
      _thumbPath = path;
      _loadingForPath = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        children: [
          Container(
            width: 72,
            height: 72,
            color: cs.surfaceContainerHighest,
            child: _thumbPath != null
                ? Image.file(
                    File(_thumbPath!),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _ph(cs),
                  )
                : _ph(cs),
          ),
          Positioned(
            left: 6,
            bottom: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                widget.video.formattedDuration,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
          if (widget.video.resumeProgress > 0.01 && !widget.video.isWatched)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: LinearProgressIndicator(
                value: widget.video.resumeProgress,
                color: Theme.of(context).colorScheme.secondary,
                backgroundColor: Colors.white24,
                minHeight: 3,
              ),
            ),
        ],
      ),
    );
  }

  Widget _ph(ColorScheme cs) => Center(
        child: Icon(Symbols.ondemand_video,
            color: cs.onSurfaceVariant.withValues(alpha: 0.6)),
      );
}
