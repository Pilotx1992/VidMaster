import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';

import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/states/states.dart';
import '../../../../core/widgets/icons/custom_sort_arrows_icon.dart';
import '../../domain/entities/video_entity.dart';
import '../../domain/entities/video_file.dart';
import 'video_player_screen.dart' show VideoPlayerArgs;
import '../providers/video_library_provider.dart';
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
            IconButton(
              icon: const Icon(Icons.sync),
              tooltip: 'Sync with Device',
              onPressed: () =>
                  ref.read(videoLibraryProvider.notifier).loadLibrary(forceSync: true),
            ),
            IconButton(
              icon: Icon(isSearchMode ? Icons.close : Icons.search),
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
              icon: const Icon(Icons.more_vert),
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'downloads', child: Text('Downloads')),
                PopupMenuItem(value: 'settings', child: Text('Settings')),
              ],
              onSelected: (v) {
                switch (v) {
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
          onRefresh: () =>
              ref.read(videoLibraryProvider.notifier).loadLibrary(forceSync: true),
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
                      icon: const Icon(Icons.arrow_back_rounded, size: 20),
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
            onRetry: () => ref.read(videoLibraryProvider.notifier).loadLibrary(),
          ),
        ),
      ];
    }

    if (videos.isEmpty) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyStateWidget(
            icon: Icons.video_library_outlined,
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
              icon: Icons.folder_open_outlined,
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
                final count =
                    videos.where((v) => v.folderName == name).length;
                return ListTile(
                  leading: const Icon(Icons.folder_outlined),
                  title: Text(
                    name.isEmpty ? '(Unknown)' : name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text('$count videos'),
                  onTap: () => ref
                      .read(videoLibraryProvider.notifier)
                      .openFolder(name),
                );
              },
              childCount: sorted.length,
            ),
          ),
        ),
      ];
    }

    if (displayVideos.isEmpty && isSearchMode && searchQuery.trim().isNotEmpty) {
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
              icon: Icons.history,
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
              icon: Icons.favorite_border,
              message: 'No favorite videos yet',
            ),
          ),
        ];
      }
      if (activeTab == VideoLibraryTab.folders &&
          selectedFolderName != null) {
        return [
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyStateWidget(
              icon: Icons.video_library_outlined,
              message:
                  'No videos in folder \u201c$selectedFolderName\u201d',
            ),
          ),
        ];
      }
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
                  context.push(
                    AppRoutes.player,
                    extra: VideoPlayerArgs(video: queueFiles[index], queue: queueFiles),
                  );
                },
                onFavorite: () => ref
                    .read(videoLibraryProvider.notifier)
                    .toggleFavorite(displayVideos[index].filePath),
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
                  context.push(
                    AppRoutes.player,
                    extra:
                        VideoPlayerArgs(video: queueFiles[index], queue: queueFiles),
                  );
                },
                onFavorite: () => ref
                    .read(videoLibraryProvider.notifier)
                    .toggleFavorite(v.filePath),
              );
            },
            childCount: displayVideos.length,
          ),
        ),
      ),
    ];
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
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
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
            icon: CustomSortArrowsIcon(color: cs.onSurfaceVariant, size: 24),
            onPressed: onSort,
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: Icon(
              isGridView ? Icons.view_list : Icons.grid_view,
              color: cs.onSurfaceVariant,
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
          VideoSortOrder.size => const ['From big to small', 'From small to big'],
          VideoSortOrder.duration => const ['From long to short', 'From short to long'],
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
            insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
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
                              visualDensity:
                                  const VisualDensity(horizontal: -4, vertical: -4),
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 0),
                              controlAffinity: ListTileControlAffinity.leading,
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
                            visualDensity:
                                const VisualDensity(horizontal: -4, vertical: -4),
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
                            visualDensity:
                                const VisualDensity(horizontal: -4, vertical: -4),
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
  final VoidCallback onFavorite;

  const _XPlayerListRow({
    super.key,
    required this.video,
    required this.onTap,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final subtitle = video.resolution != null && video.resolution!.isNotEmpty
        ? '${video.extension.toUpperCase()} (${video.resolution})'
        : video.extension.toUpperCase();
    final date = _formatShortDate(video.lastPlayedAt ?? video.fileModifiedAt);

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
                      style: TextStyle(color: cs.onSurfaceVariant, fontSize: 10),
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
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    icon: Icon(
                      video.isFavourite ? Icons.favorite : Icons.favorite_border,
                      color: video.isFavourite
                          ? const Color(0xFFF9A825)
                          : cs.onSurfaceVariant,
                      size: 22,
                    ),
                    onPressed: onFavorite,
                  ),
                  if (date.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        date,
                        style: TextStyle(color: cs.onSurfaceVariant, fontSize: 10),
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
      _thumbPath = null;
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
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
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
        child: Icon(Icons.ondemand_video, color: cs.onSurfaceVariant.withValues(alpha: 0.6)),
      );
}
