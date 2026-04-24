import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/states/states.dart';
import '../providers/video_library_provider.dart';
import '../widgets/video_thumbnail_card.dart';

class VideoLibraryScreen extends ConsumerStatefulWidget {
  const VideoLibraryScreen({super.key});

  @override
  ConsumerState<VideoLibraryScreen> createState() => _VideoLibraryScreenState();
}

class _VideoLibraryScreenState extends ConsumerState<VideoLibraryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(videoLibraryProvider.notifier).loadLibrary());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(videoLibraryProvider);

    return Scaffold(
      appBar: AppBar(
        title: state.isSearching
            ? TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search videos...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white38),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: (v) => ref.read(videoLibraryProvider.notifier).setSearchQuery(v),
              )
            : const Text('Videos'),
        actions: [
          IconButton(
            icon: Icon(state.isSearching ? Icons.close : Icons.search),
            onPressed: () {
              if (state.isSearching) {
                ref.read(videoLibraryProvider.notifier).clearSearch();
              } else {
                ref.read(videoLibraryProvider.notifier).setSearchQuery(' '); // Trigger search mode
              }
            },
          ),
          PopupMenuButton<VideoSortOrder>(
            icon: const Icon(Icons.sort),
            onSelected: (order) => ref.read(videoLibraryProvider.notifier).setSortOrder(order),
            itemBuilder: (context) => [
              const PopupMenuItem(value: VideoSortOrder.name, child: Text('Name')),
              const PopupMenuItem(value: VideoSortOrder.date, child: Text('Date')),
              const PopupMenuItem(value: VideoSortOrder.size, child: Text('Size')),
              const PopupMenuItem(value: VideoSortOrder.duration, child: Text('Duration')),
            ],
          ),
          IconButton(
            icon: Icon(state.isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () => ref.read(videoLibraryProvider.notifier).toggleView(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(videoLibraryProvider.notifier).loadLibrary(),
        child: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(VideoLibraryState state) {
    if (state.status == VideoLibraryStatus.loading && state.videos.isEmpty) {
      return const SkeletonList.cards(itemCount: 6);
    }

    if (state.status == VideoLibraryStatus.error) {
      return ErrorStateWidget(
        message: state.errorMessage ?? 'Failed to load videos',
        onRetry: () => ref.read(videoLibraryProvider.notifier).loadLibrary(),
      );
    }

    if (state.videos.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.video_library_outlined,
        message: 'No videos found on your device',
      );
    }

    final videos = state.displayVideos;
    if (videos.isEmpty && state.isSearching) {
      return const Center(child: Text('No matches found'));
    }

    return state.isGridView
        ? GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            itemCount: videos.length,
            itemBuilder: (context, index) => VideoThumbnailCard(
              video: videos[index],
              queue: videos,
              onTap: () => context.push(AppRoutes.player, extra: {
                'video': videos[index],
                'queue': videos,
              }),
              onFavorite: () => ref.read(videoLibraryProvider.notifier).toggleFavorite(videos[index].filePath),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: videos.length,
            itemBuilder: (context, index) => ListTile(
              leading: const Icon(Icons.movie, color: Colors.white54),
              title: Text(videos[index].fileName, style: const TextStyle(color: Colors.white)),
              subtitle: Text(videos[index].formattedSize, style: const TextStyle(color: Colors.white38)),
              onTap: () => context.push(AppRoutes.player, extra: {
                'video': videos[index],
                'queue': videos,
              }),
            ),
          );
  }
}