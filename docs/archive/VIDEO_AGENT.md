# VidMaster Phase 1 — Premium Video Player Core

> **Purpose:** Give this file to an AI coding agent to implement the first production-quality video module of VidMaster.
>
> **Target:** Build a premium local video player experience inspired by XPlayer: polished video library, smooth fullscreen player, gesture controls, resume, subtitles, and performance hardening.
>
> **Important Rule:** Work only inside the existing Flutter project. Do **not** create a new app. Preserve current Clean Architecture, Riverpod, Isar, Hive vault metadata, go_router, and build flavors.

---

## 0. Global Execution Rules for the AI Agent

### 0.1 Do not break these rules

1. `stable` is the production-safe flavor.
2. `experimental` is only for sandbox features such as yt-dlp / Chaquopy / social downloader.
3. Do not add social downloader work in this phase.
4. Do not change package name unless explicitly asked.
5. Do not introduce WebView.
6. Do not store video bytes in Hive.
7. Use Isar for video metadata, resume, subtitle preferences, and library cache.
8. Hive is only for vault metadata or already-existing app configuration if the project uses it.
9. Avoid heavy work on the main isolate.
10. Do not call `player.seek()` during gesture `onPanUpdate`; only call real seek once on `onPanEnd`.
11. Keep UI and code text in English.
12. Preserve RTL support globally, but video player controls should remain visually stable and predictable.
13. Run `flutter analyze` after every major phase.
14. Do not mark any phase complete if build fails.

### 0.2 Required commands

```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter analyze
flutter run -d "<device>" --flavor stable
flutter build apk --release --flavor stable --split-per-abi
```

### 0.3 Required build verification

The implementation is not complete unless these pass:

```bash
flutter analyze
flutter build apk --debug --flavor stable
flutter build apk --release --flavor stable --split-per-abi
```

---

## 1. Phase Overview

The work is divided into 6 implementation phases:

1. **Video Library UX/UI**
2. **Premium Player Screen UI**
3. **Pro Gesture Engine**
4. **Resume System**
5. **Subtitle Engine Basic v1**
6. **Performance + Stability Hardening**

Recommended execution order:

```text
Video Library UI
→ Player Screen UI
→ Gesture Engine
→ Resume
→ Subtitles
→ Performance Hardening
```

---

# Phase 1 — Video Library UX/UI

## 1.1 Goal

Make the video library feel like a real premium media app, not a default Flutter list.

The screen must support:

- All videos
- Folders
- Recent videos
- Favorites
- Search
- Grid/List toggle
- Sort by name/date/size/duration
- Polished video cards with thumbnail, duration, resume progress, favorite button, and watched badge

---

## 1.2 Files to inspect first

Inspect these existing files before editing:

```text
lib/features/video_player/presentation/screens/video_library_screen.dart
lib/features/video_player/presentation/widgets/video_thumbnail_card.dart
lib/features/video_player/presentation/providers/video_library_provider.dart
lib/features/video_player/domain/entities/video_entity.dart
lib/features/video_player/domain/repositories/video_repository.dart
lib/features/video_player/data/repositories/video_repository_impl.dart
lib/features/video_player/data/datasources/video_local_data_source.dart
lib/core/router/app_router.dart
lib/core/theme/app_theme.dart
```

If any file does not exist, search the project for similarly named files before creating duplicates.

---

## 1.3 Desired UX

### Header layout

```text
Videos
Search your videos...

[All] [Folders] [Recent] [Favorites]

Sort: Recent         Grid/List Toggle
```

### Video grid card

```text
┌──────────────────────────┐
│        THUMBNAIL         │
│                    12:45 │
│ ━━━━━ resume progress    │
└──────────────────────────┘
Movie Name.mp4
Downloads · 1.2 GB
```

---

## 1.4 Suggested enum additions

If not already available, add these enums inside the provider or a separate file:

```dart
enum VideoLibraryTab { all, folders, recent, favorites }

enum VideoSortOrder { name, date, size, duration }
```

---

## 1.5 VideoLibraryState target shape

Adjust existing state carefully. Do not remove existing fields without checking usage.

```dart
class VideoLibraryState {
  final bool isLoading;
  final String? errorMessage;
  final List<VideoEntity> videos;
  final List<VideoEntity> recentlyPlayed;
  final List<VideoEntity> favorites;
  final List<String> folders;
  final String searchQuery;
  final VideoLibraryTab activeTab;
  final VideoSortOrder sortOrder;
  final bool isGridView;

  const VideoLibraryState({
    this.isLoading = false,
    this.errorMessage,
    this.videos = const [],
    this.recentlyPlayed = const [],
    this.favorites = const [],
    this.folders = const [],
    this.searchQuery = '',
    this.activeTab = VideoLibraryTab.all,
    this.sortOrder = VideoSortOrder.date,
    this.isGridView = true,
  });

  VideoLibraryState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<VideoEntity>? videos,
    List<VideoEntity>? recentlyPlayed,
    List<VideoEntity>? favorites,
    List<String>? folders,
    String? searchQuery,
    VideoLibraryTab? activeTab,
    VideoSortOrder? sortOrder,
    bool? isGridView,
    bool clearError = false,
  }) {
    return VideoLibraryState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      videos: videos ?? this.videos,
      recentlyPlayed: recentlyPlayed ?? this.recentlyPlayed,
      favorites: favorites ?? this.favorites,
      folders: folders ?? this.folders,
      searchQuery: searchQuery ?? this.searchQuery,
      activeTab: activeTab ?? this.activeTab,
      sortOrder: sortOrder ?? this.sortOrder,
      isGridView: isGridView ?? this.isGridView,
    );
  }
}
```

---

## 1.6 Provider methods target

Add or verify these methods in `VideoLibraryNotifier`:

```dart
Future<void> loadLibrary();
void setSearchQuery(String query);
void setActiveTab(VideoLibraryTab tab);
void setSortOrder(VideoSortOrder order);
void toggleViewMode();
Future<void> toggleFavorite(VideoEntity video);
Future<String?> getThumbnail(VideoEntity video);
```

Search and sort should be fast and should not rescan storage on every keystroke.

---

## 1.7 VideoLibraryScreen implementation skeleton

Use this as a guide, not necessarily an exact replacement if the project already has a better structure.

```dart
class VideoLibraryScreen extends ConsumerStatefulWidget {
  const VideoLibraryScreen({super.key});

  @override
  ConsumerState<VideoLibraryScreen> createState() => _VideoLibraryScreenState();
}

class _VideoLibraryScreenState extends ConsumerState<VideoLibraryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(videoLibraryProvider.notifier).loadLibrary();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(videoLibraryProvider);
    final notifier = ref.read(videoLibraryProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _VideoLibraryHeader(
                searchQuery: state.searchQuery,
                activeTab: state.activeTab,
                sortOrder: state.sortOrder,
                isGridView: state.isGridView,
                onSearchChanged: notifier.setSearchQuery,
                onTabChanged: notifier.setActiveTab,
                onSortChanged: notifier.setSortOrder,
                onToggleView: notifier.toggleViewMode,
              ),
            ),
            if (state.isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state.errorMessage != null)
              SliverFillRemaining(
                child: _VideoLibraryError(
                  message: state.errorMessage!,
                  onRetry: notifier.loadLibrary,
                ),
              )
            else
              _buildContent(context, state),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, VideoLibraryState state) {
    final videos = _visibleVideos(state);

    if (videos.isEmpty) {
      return const SliverFillRemaining(
        child: _VideoLibraryEmptyState(),
      );
    }

    if (state.isGridView) {
      return SliverPadding(
        padding: const EdgeInsets.all(16),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.78,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final video = videos[index];
              return VideoThumbnailCard(
                video: video,
                onTap: () => _openVideo(context, video, videos),
                onFavoriteTap: () => ref
                    .read(videoLibraryProvider.notifier)
                    .toggleFavorite(video),
              );
            },
            childCount: videos.length,
          ),
        ),
      );
    }

    return SliverList.separated(
      itemBuilder: (context, index) {
        final video = videos[index];
        return VideoListTile(
          video: video,
          onTap: () => _openVideo(context, video, videos),
          onFavoriteTap: () => ref
              .read(videoLibraryProvider.notifier)
              .toggleFavorite(video),
        );
      },
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemCount: videos.length,
    );
  }

  List<VideoEntity> _visibleVideos(VideoLibraryState state) {
    final base = switch (state.activeTab) {
      VideoLibraryTab.all => state.videos,
      VideoLibraryTab.recent => state.recentlyPlayed,
      VideoLibraryTab.favorites => state.favorites,
      VideoLibraryTab.folders => state.videos,
    };

    final query = state.searchQuery.trim().toLowerCase();
    final filtered = query.isEmpty
        ? [...base]
        : base.where((v) {
            return v.title.toLowerCase().contains(query) ||
                v.folderName.toLowerCase().contains(query) ||
                v.filePath.toLowerCase().contains(query);
          }).toList();

    filtered.sort((a, b) {
      return switch (state.sortOrder) {
        VideoSortOrder.name => a.title.compareTo(b.title),
        VideoSortOrder.date => (b.lastPlayedAt ?? DateTime.fromMillisecondsSinceEpoch(0))
            .compareTo(a.lastPlayedAt ?? DateTime.fromMillisecondsSinceEpoch(0)),
        VideoSortOrder.size => b.fileSizeBytes.compareTo(a.fileSizeBytes),
        VideoSortOrder.duration => (b.durationMs ?? 0).compareTo(a.durationMs ?? 0),
      };
    });

    return filtered;
  }

  void _openVideo(
    BuildContext context,
    VideoEntity video,
    List<VideoEntity> queue,
  ) {
    context.push(
      AppRoutes.player,
      extra: VideoPlayerArgs(video: video, queue: queue),
    );
  }
}
```

If `SliverList.separated` is not supported in the current Flutter version, replace it with `SliverList` and manually add separators.

---

## 1.8 VideoThumbnailCard target

Create or update:

```text
lib/features/video_player/presentation/widgets/video_thumbnail_card.dart
```

Target behavior:

- 16:10 thumbnail area
- duration badge bottom/right
- resume progress line at bottom
- gradient overlay
- favorite icon top/right
- watched badge if progress > 90%
- fallback icon if no thumbnail

Skeleton:

```dart
class VideoThumbnailCard extends StatelessWidget {
  final VideoEntity video;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;

  const VideoThumbnailCard({
    super.key,
    required this.video,
    required this.onTap,
    required this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = video.resumeProgress.clamp(0.0, 1.0);
    final watched = progress >= 0.9;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _ThumbnailImage(path: video.thumbnailPath),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black45,
                          Colors.transparent,
                          Colors.black87,
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _CircleIconButton(
                      icon: video.isFavourite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      onTap: onFavoriteTap,
                    ),
                  ),
                  Positioned(
                    right: 8,
                    bottom: 10,
                    child: _DurationBadge(text: video.formattedDuration),
                  ),
                  if (watched)
                    const Positioned(
                      left: 8,
                      top: 8,
                      child: _WatchedBadge(),
                    ),
                  if (progress > 0 && progress < 1)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 3,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            video.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${video.folderName} · ${_formatBytes(video.fileSizeBytes)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const kb = 1024;
    const mb = kb * 1024;
    const gb = mb * 1024;
    if (bytes >= gb) return '${(bytes / gb).toStringAsFixed(1)} GB';
    if (bytes >= mb) return '${(bytes / mb).toStringAsFixed(1)} MB';
    if (bytes >= kb) return '${(bytes / kb).toStringAsFixed(1)} KB';
    return '$bytes B';
  }
}
```

Add private helper widgets in the same file:

```dart
class _ThumbnailImage extends StatelessWidget {
  final String? path;

  const _ThumbnailImage({required this.path});

  @override
  Widget build(BuildContext context) {
    if (path == null || path!.isEmpty) {
      return Container(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const Center(
          child: Icon(Icons.play_circle_fill_rounded, size: 52),
        ),
      );
    }

    return Image.file(
      File(path!),
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const Center(
          child: Icon(Icons.play_circle_fill_rounded, size: 52),
        ),
      ),
    );
  }
}
```

Remember to import:

```dart
import 'dart:io';
import 'package:flutter/material.dart';
```

---

## 1.9 Phase 1 Definition of Done

- [ ] Video library opens without crash.
- [ ] Permission denied state is handled clearly.
- [ ] Loading, empty, error, and loaded states exist.
- [ ] Grid and list modes work.
- [ ] Search does not trigger full storage rescan every keystroke.
- [ ] Sort works.
- [ ] Favorite toggle works.
- [ ] Tapping a video opens `/player` with `VideoPlayerArgs`.
- [ ] `flutter analyze` passes.

---

# Phase 2 — Premium Player Screen UI

## 2.1 Goal

Create a fullscreen player that feels premium, clean, and touch-friendly.

Core UI layers:

```text
Video Surface
→ Gesture Layer
→ Controls Overlay
→ Status/Feedback Overlays
→ Subtitle Menu Bottom Sheet
```

---

## 2.2 Files to inspect first

```text
lib/features/video_player/presentation/screens/video_player_screen.dart
lib/features/video_player/presentation/providers/video_player_provider.dart
lib/core/router/app_router.dart
lib/features/video_player/domain/entities/video_entity.dart
```

---

## 2.3 Player Screen requirements

The screen must:

- enter immersive fullscreen on open
- allow landscape/portrait based on current implementation
- keep screen awake while playing
- restore system UI and orientation on exit
- show controls on tap
- auto-hide controls after 3 seconds
- save position on back
- show graceful error UI if playback fails

---

## 2.4 UI structure target

```dart
class VideoPlayerScreen extends ConsumerStatefulWidget {
  final VideoPlayerArgs args;

  const VideoPlayerScreen({
    super.key,
    required this.args,
  });

  @override
  ConsumerState<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends ConsumerState<VideoPlayerScreen> {
  @override
  void initState() {
    super.initState();
    _enterFullscreen();
    Future.microtask(() {
      ref.read(videoPlayerProvider.notifier).openVideo(
            widget.args.video,
            queue: widget.args.queue,
          );
    });
  }

  @override
  void dispose() {
    _exitFullscreen();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(videoPlayerProvider);
    final notifier = ref.read(videoPlayerProvider.notifier);

    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) async {
        await notifier.saveCurrentPosition();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            _VideoSurface(state: state),
            ProGestureLayer(
              duration: state.duration,
              position: state.position,
              volume: state.volume,
              brightness: state.brightness,
              isLocked: state.isLocked,
              onTap: notifier.toggleControls,
              onSeekEnd: notifier.seekTo,
              onVolume: notifier.setVolume,
              onBrightness: notifier.setBrightness,
              onDoubleTapLeft: () => notifier.seekRelative(
                const Duration(seconds: -10),
              ),
              onDoubleTapRight: () => notifier.seekRelative(
                const Duration(seconds: 10),
              ),
              child: const SizedBox.expand(),
            ),
            ControlsOverlay(
              visible: state.isControlsVisible,
              state: state,
              onBack: () => Navigator.of(context).maybePop(),
              onPlayPause: notifier.playPause,
              onSeek: notifier.seekTo,
              onSeekBackward: () => notifier.seekRelative(
                const Duration(seconds: -10),
              ),
              onSeekForward: () => notifier.seekRelative(
                const Duration(seconds: 10),
              ),
              onLock: notifier.toggleLock,
              onSpeedChanged: notifier.setSpeed,
              onSubtitleTap: () => _showSubtitleSheet(context),
              onPip: notifier.enterPip,
            ),
            if (state.isLocked)
              LockModeHint(onUnlock: notifier.toggleLock),
            if (state.errorMessage != null)
              PlayerErrorOverlay(
                message: state.errorMessage!,
                onRetry: () => notifier.openVideo(
                  widget.args.video,
                  queue: widget.args.queue,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _enterFullscreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _exitFullscreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  void _showSubtitleSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SubtitleMenuSheet(),
    );
  }
}
```

Adapt method names to match the existing provider. Do not duplicate provider logic.

---

## 2.5 ControlsOverlay requirements

Create or update:

```text
lib/features/video_player/presentation/widgets/controls_overlay.dart
```

Controls overlay must include:

### Top bar

- Back
- Video title
- Lock button
- Subtitle button
- Speed button
- PiP button or More menu

### Center controls

- Previous
- Back 10 seconds
- Play/Pause
- Forward 10 seconds
- Next

### Bottom bar

- current position
- seek slider
- total duration
- aspect ratio button if available

---

## 2.6 ControlsOverlay skeleton

```dart
class ControlsOverlay extends StatelessWidget {
  final bool visible;
  final VideoPlayerState state;
  final VoidCallback onBack;
  final VoidCallback onPlayPause;
  final ValueChanged<Duration> onSeek;
  final VoidCallback onSeekBackward;
  final VoidCallback onSeekForward;
  final VoidCallback onLock;
  final ValueChanged<double> onSpeedChanged;
  final VoidCallback onSubtitleTap;
  final VoidCallback onPip;

  const ControlsOverlay({
    super.key,
    required this.visible,
    required this.state,
    required this.onBack,
    required this.onPlayPause,
    required this.onSeek,
    required this.onSeekBackward,
    required this.onSeekForward,
    required this.onLock,
    required this.onSpeedChanged,
    required this.onSubtitleTap,
    required this.onPip,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: Duration(milliseconds: visible ? 150 : 200),
        curve: visible ? Curves.easeOutCubic : Curves.easeIn,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.75),
                Colors.transparent,
                Colors.black.withOpacity(0.82),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _TopControlsBar(
                  title: state.currentVideo?.title ?? '',
                  isLocked: state.isLocked,
                  speed: state.playbackSpeed,
                  onBack: onBack,
                  onLock: onLock,
                  onSubtitleTap: onSubtitleTap,
                  onPip: onPip,
                  onSpeedChanged: onSpeedChanged,
                ),
                const Spacer(),
                _CenterControls(
                  isPlaying: state.isPlaying,
                  onPlayPause: onPlayPause,
                  onSeekBackward: onSeekBackward,
                  onSeekForward: onSeekForward,
                  onPrevious: null,
                  onNext: null,
                ),
                const Spacer(),
                _BottomSeekBar(
                  position: state.position,
                  duration: state.duration,
                  onSeek: onSeek,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## 2.7 Phase 2 Definition of Done

- [ ] Fullscreen mode works.
- [ ] Controls fade in/out smoothly.
- [ ] Tap toggles controls.
- [ ] Play/Pause works.
- [ ] Seek slider works.
- [ ] Speed menu works.
- [ ] Lock button works.
- [ ] PiP button does not crash on unsupported devices.
- [ ] Back saves position and exits cleanly.
- [ ] `flutter analyze` passes.

---

# Phase 3 — Pro Gesture Engine

## 3.1 Goal

Implement XPlayer-like gestures without hurting playback performance.

Features:

- single tap toggles controls
- double tap left/right skips ±10 seconds
- horizontal swipe shows seek preview
- real seek happens once on release
- vertical swipe left controls brightness
- vertical swipe right controls volume
- lock mode blocks gestures
- haptic feedback for important actions

---

## 3.2 Files to create

```text
lib/features/video_player/domain/entities/gesture_result.dart
lib/features/video_player/domain/entities/gesture_engine.dart
lib/features/video_player/presentation/widgets/pro_gesture_layer.dart
lib/features/video_player/presentation/widgets/seek_preview_overlay.dart
lib/features/video_player/presentation/widgets/level_indicator_overlay.dart
```

---

## 3.3 GestureResult

```dart
enum GestureType { none, seek, volume, brightness }

class GestureResult {
  final GestureType type;
  final Duration? seek;
  final double? value;

  const GestureResult._(this.type, {this.seek, this.value});

  const GestureResult.none() : this._(GestureType.none);

  factory GestureResult.seek(Duration target) {
    return GestureResult._(GestureType.seek, seek: target);
  }

  factory GestureResult.volume(double value) {
    return GestureResult._(GestureType.volume, value: value);
  }

  factory GestureResult.brightness(double value) {
    return GestureResult._(GestureType.brightness, value: value);
  }
}
```

---

## 3.4 GestureEngine

```dart
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';

import 'gesture_result.dart';

class GestureEngine {
  GestureType _type = GestureType.none;
  bool _isLocked = false;
  Duration _preview = Duration.zero;
  double _volume = 1.0;
  double _brightness = 0.5;

  final double threshold;
  final double fastThreshold;
  final double seekSlowMs;
  final double seekFastMs;
  final double verticalSensitivity;

  GestureEngine({
    this.threshold = 8.0,
    this.fastThreshold = 10.0,
    this.seekSlowMs = 400.0,
    this.seekFastMs = 1200.0,
    this.verticalSensitivity = 0.01,
  });

  void onStart({
    required double dx,
    required double screenWidth,
    required Duration currentPosition,
    required double volume,
    required double brightness,
  }) {
    _preview = currentPosition;
    _volume = volume;
    _brightness = brightness;
    _type = dx < screenWidth / 2 ? GestureType.brightness : GestureType.volume;
    _isLocked = false;
  }

  GestureResult onUpdate(DragUpdateDetails details, Duration totalDuration) {
    if (!_isLocked) {
      if (details.delta.dx.abs() > threshold) {
        _type = GestureType.seek;
        _isLocked = true;
        HapticFeedback.lightImpact();
      } else if (details.delta.dy.abs() > threshold) {
        _isLocked = true;
      }
    }

    if (!_isLocked) return const GestureResult.none();

    switch (_type) {
      case GestureType.seek:
        if (totalDuration <= Duration.zero) return const GestureResult.none();

        final speed = details.delta.dx.abs() > fastThreshold
            ? seekFastMs
            : seekSlowMs;

        _preview += Duration(
          milliseconds: (details.delta.dx * speed).toInt(),
        );

        if (_preview <= Duration.zero) {
          _preview = Duration.zero;
          HapticFeedback.heavyImpact();
        } else if (_preview >= totalDuration) {
          _preview = totalDuration;
          HapticFeedback.heavyImpact();
        }

        return GestureResult.seek(_preview);

      case GestureType.volume:
        _volume = (_volume - details.delta.dy * verticalSensitivity)
            .clamp(0.0, 1.0);
        return GestureResult.volume(_volume);

      case GestureType.brightness:
        _brightness = (_brightness - details.delta.dy * verticalSensitivity)
            .clamp(0.0, 1.0);
        return GestureResult.brightness(_brightness);

      case GestureType.none:
        return const GestureResult.none();
    }
  }

  void reset() {
    _type = GestureType.none;
    _isLocked = false;
  }
}
```

Note: if your project enforces pure Dart domain entities with no Flutter imports, move haptics out of `GestureEngine` and trigger them in `ProGestureLayer` instead. The most important rule is to avoid `player.seek()` during drag updates.

---

## 3.5 ProGestureLayer

```dart
class ProGestureLayer extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration position;
  final double volume;
  final double brightness;
  final bool isLocked;
  final VoidCallback onTap;
  final ValueChanged<Duration> onSeekEnd;
  final ValueChanged<double> onVolume;
  final ValueChanged<double> onBrightness;
  final VoidCallback onDoubleTapLeft;
  final VoidCallback onDoubleTapRight;

  const ProGestureLayer({
    super.key,
    required this.child,
    required this.duration,
    required this.position,
    required this.volume,
    required this.brightness,
    required this.isLocked,
    required this.onTap,
    required this.onSeekEnd,
    required this.onVolume,
    required this.onBrightness,
    required this.onDoubleTapLeft,
    required this.onDoubleTapRight,
  });

  @override
  State<ProGestureLayer> createState() => _ProGestureLayerState();
}

class _ProGestureLayerState extends State<ProGestureLayer> {
  final GestureEngine _engine = GestureEngine();

  bool _isSeeking = false;
  Duration _seekPreview = Duration.zero;
  GestureType _levelType = GestureType.none;
  double _levelValue = 0.0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: widget.isLocked ? null : widget.onTap,
          onDoubleTapDown: widget.isLocked ? null : _handleDoubleTap,
          onPanStart: widget.isLocked ? null : _handlePanStart,
          onPanUpdate: widget.isLocked ? null : _handlePanUpdate,
          onPanEnd: widget.isLocked ? null : _handlePanEnd,
          child: widget.child,
        ),
        if (_isSeeking)
          SeekPreviewOverlay(
            preview: _seekPreview,
            current: widget.position,
            duration: widget.duration,
          ),
        if (_levelType == GestureType.volume ||
            _levelType == GestureType.brightness)
          LevelIndicatorOverlay(
            type: _levelType,
            value: _levelValue,
          ),
      ],
    );
  }

  void _handleDoubleTap(TapDownDetails details) {
    final width = MediaQuery.sizeOf(context).width;
    final isLeft = details.localPosition.dx < width / 2;
    HapticFeedback.mediumImpact();
    if (isLeft) {
      widget.onDoubleTapLeft();
    } else {
      widget.onDoubleTapRight();
    }
  }

  void _handlePanStart(DragStartDetails details) {
    _engine.onStart(
      dx: details.localPosition.dx,
      screenWidth: MediaQuery.sizeOf(context).width,
      currentPosition: widget.position,
      volume: widget.volume,
      brightness: widget.brightness,
    );
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    final result = _engine.onUpdate(details, widget.duration);

    switch (result.type) {
      case GestureType.seek:
        setState(() {
          _isSeeking = true;
          _seekPreview = result.seek!;
          _levelType = GestureType.none;
        });
        break;

      case GestureType.volume:
        widget.onVolume(result.value!);
        setState(() {
          _levelType = GestureType.volume;
          _levelValue = result.value!;
        });
        break;

      case GestureType.brightness:
        widget.onBrightness(result.value!);
        setState(() {
          _levelType = GestureType.brightness;
          _levelValue = result.value!;
        });
        break;

      case GestureType.none:
        break;
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    if (_isSeeking) {
      Duration target = _seekPreview;
      final vx = details.velocity.pixelsPerSecond.dx;

      if (vx.abs() > 500 && widget.duration > Duration.zero) {
        final targetMs = target.inMilliseconds + (vx * 0.15).toInt();
        target = Duration(
          milliseconds: targetMs.clamp(0, widget.duration.inMilliseconds),
        );
      }

      widget.onSeekEnd(target);
    }

    setState(() {
      _isSeeking = false;
      _levelType = GestureType.none;
    });

    _engine.reset();
  }
}
```

---

## 3.6 SeekPreviewOverlay

```dart
class SeekPreviewOverlay extends StatelessWidget {
  final Duration preview;
  final Duration current;
  final Duration duration;

  const SeekPreviewOverlay({
    super.key,
    required this.preview,
    required this.current,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    final forward = preview >= current;
    final delta = (preview - current).abs();

    return Center(
      child: RepaintBoundary(
        child: AnimatedScale(
          scale: 1,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.75),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  forward
                      ? Icons.fast_forward_rounded
                      : Icons.fast_rewind_rounded,
                  color: Colors.white,
                  size: 42,
                ),
                const SizedBox(height: 8),
                Text(
                  '${_fmt(preview)} / ${_fmt(duration)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '[ ${forward ? '+' : '-'}${_fmt(delta)} ]',
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _fmt(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (hours > 0) return '$hours:$minutes:$seconds';
    return '$minutes:$seconds';
  }
}
```

---

## 3.7 Phase 3 Definition of Done

- [ ] Horizontal swipe shows preview only.
- [ ] Real seek is called once per pan gesture.
- [ ] Double tap left/right works.
- [ ] Volume and brightness gestures work.
- [ ] Gesture lock prevents accidental switching.
- [ ] Lock mode blocks gestures.
- [ ] No visible video stutter while scrubbing.
- [ ] `flutter analyze` passes.

---

# Phase 4 — Resume System

## 4.1 Goal

Resume playback reliably per video.

Requirements:

- save position every 5 seconds during playback
- save position when seeking
- save position when leaving player
- restore position if saved position > 10 seconds
- optionally show resume dialog
- clear position or mark watched when video completes

---

## 4.2 Files to inspect first

```text
lib/features/video_player/data/models/video_resume_isar.dart
lib/features/video_player/data/repositories/isar_resume_repository.dart
lib/features/video_player/domain/repositories/resume_repository.dart
lib/features/video_player/presentation/providers/video_player_provider.dart
lib/main.dart
lib/di.dart
```

---

## 4.3 ResumeRepository target interface

```dart
abstract class ResumeRepository {
  Future<Duration?> loadPosition(String videoPath);
  Future<void> savePosition(String videoPath, Duration position);
  Future<void> clearPosition(String videoPath);
}
```

---

## 4.4 Video player notifier target logic

Inside `VideoPlayerNotifier`:

```dart
Timer? _positionSaveTimer;

void _startPositionSaveTimer() {
  _positionSaveTimer?.cancel();
  _positionSaveTimer = Timer.periodic(const Duration(seconds: 5), (_) {
    saveCurrentPosition();
  });
}

Future<void> saveCurrentPosition() async {
  final video = state.currentVideo;
  if (video == null) return;
  if (state.position <= Duration.zero) return;
  if (state.duration > Duration.zero && state.position >= state.duration) return;

  await _resumeRepository.savePosition(video.filePath, state.position);
}

Future<void> openVideo(VideoEntity video, {List<VideoEntity> queue = const []}) async {
  state = state.copyWith(
    status: PlayerStatus.loading,
    currentVideo: video,
    queue: queue,
    errorMessage: null,
  );

  try {
    await _player.open(Media(Uri.file(video.filePath).toString()));

    final saved = await _resumeRepository.loadPosition(video.filePath);
    if (saved != null && saved > const Duration(seconds: 10)) {
      await _player.seek(saved);
    }

    await _player.play();
    _startPositionSaveTimer();
  } catch (e) {
    state = state.copyWith(
      status: PlayerStatus.error,
      errorMessage: 'Could not play this video.',
    );
  }
}

@override
void dispose() {
  saveCurrentPosition();
  _positionSaveTimer?.cancel();
  _player.dispose();
  super.dispose();
}
```

Adapt names to your existing provider.

---

## 4.5 Optional resume dialog

If you want a premium UX, show this before seeking:

```text
Resume from 23:41?
[Start over] [Resume]
```

Implementation option:

- provider exposes saved position in state
- screen shows dialog once after open
- if user chooses Resume: seek to saved
- if Start over: clear position and seek zero

If this complicates the current architecture, auto-resume first and add dialog later.

---

## 4.6 Phase 4 Definition of Done

- [ ] Position saves every 5 seconds.
- [ ] Position saves on seek.
- [ ] Position saves on back.
- [ ] Reopening same video restores position.
- [ ] Very short positions under 10 seconds are ignored.
- [ ] Completed videos do not resume from the end.
- [ ] `flutter analyze` passes.

---

# Phase 5 — Subtitle Engine Basic v1

## 5.1 Goal

Add a clean basic subtitle experience first. Do not overbuild.

v1 subtitle features:

- load external `.srt` / `.vtt` / `.ass` / `.ssa`
- list embedded subtitle tracks if available
- turn subtitles off
- delay adjustment from -10s to +10s
- basic style controls
- save per-video delay and external subtitle path

---

## 5.2 Files to create or inspect

```text
lib/features/video_player/domain/entities/subtitle_settings.dart
lib/features/video_player/domain/repositories/subtitle_preferences_repository.dart
lib/features/video_player/data/models/subtitle_settings_isar.dart
lib/features/video_player/data/repositories/isar_subtitle_preferences_repository.dart
lib/features/video_player/presentation/widgets/subtitle_menu_sheet.dart
lib/features/video_player/presentation/widgets/subtitle_live_preview.dart
lib/features/video_player/presentation/providers/video_player_provider.dart
```

---

## 5.3 SubtitleSettings entity

```dart
import 'package:flutter/material.dart';

enum SubtitleFontSize {
  small(16),
  medium(20),
  large(24),
  xLarge(32),
  xxLarge(40);

  final double value;
  const SubtitleFontSize(this.value);
}

enum SubtitleFontStyle { normal, bold, boldShadow }

class SubtitleSettings {
  final SubtitleFontSize fontSize;
  final Color textColor;
  final Color backgroundColor;
  final double backgroundOpacity;
  final SubtitleFontStyle fontStyle;
  final double delaySeconds;

  const SubtitleSettings({
    this.fontSize = SubtitleFontSize.large,
    this.textColor = Colors.white,
    this.backgroundColor = Colors.black,
    this.backgroundOpacity = 0.54,
    this.fontStyle = SubtitleFontStyle.boldShadow,
    this.delaySeconds = 0.0,
  });

  Color get effectiveBackground => backgroundColor.withOpacity(backgroundOpacity);

  TextStyle get textStyle {
    return TextStyle(
      fontSize: fontSize.value,
      color: textColor,
      backgroundColor: effectiveBackground,
      fontWeight: fontStyle == SubtitleFontStyle.normal
          ? FontWeight.normal
          : FontWeight.bold,
      shadows: fontStyle == SubtitleFontStyle.boldShadow
          ? const [
              Shadow(
                color: Colors.black87,
                blurRadius: 6,
                offset: Offset(1, 2),
              ),
            ]
          : null,
    );
  }

  SubtitleSettings copyWith({
    SubtitleFontSize? fontSize,
    Color? textColor,
    Color? backgroundColor,
    double? backgroundOpacity,
    SubtitleFontStyle? fontStyle,
    double? delaySeconds,
  }) {
    return SubtitleSettings(
      fontSize: fontSize ?? this.fontSize,
      textColor: textColor ?? this.textColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      backgroundOpacity: backgroundOpacity ?? this.backgroundOpacity,
      fontStyle: fontStyle ?? this.fontStyle,
      delaySeconds: delaySeconds ?? this.delaySeconds,
    );
  }

  static const defaults = SubtitleSettings();
}
```

---

## 5.4 Subtitle provider methods

Add or verify in `VideoPlayerNotifier`:

```dart
Future<void> loadExternalSubtitleFile(String path);
Future<void> setSubtitleDelay(double seconds);
void nudgeSubtitleDelay(double delta);
void resetSubtitleDelay();
void updateSubtitleStyle({
  SubtitleFontSize? fontSize,
  Color? textColor,
  Color? backgroundColor,
  double? backgroundOpacity,
  SubtitleFontStyle? fontStyle,
});
void resetSubtitleStyle();
Future<void> setSubtitleTrack(SubtitleTrack track);
```

---

## 5.5 External subtitle loading

Use `file_picker`:

```dart
Future<void> pickAndLoadSubtitle() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['srt', 'vtt', 'ass', 'ssa'],
  );

  final path = result?.files.single.path;
  if (path == null) return;

  await loadExternalSubtitleFile(path);
}
```

Then use media_kit:

```dart
await _player.setSubtitleTrack(SubtitleTrack.uri(path));
```

If the current media_kit API differs, inspect installed API and adapt.

---

## 5.6 Subtitle delay

```dart
Future<void> setSubtitleDelay(double seconds) async {
  final clamped = seconds.clamp(-10.0, 10.0).toDouble();

  state = state.copyWith(
    subtitleSettings: state.subtitleSettings.copyWith(
      delaySeconds: clamped,
    ),
  );

  await _player.setProperty('sub-delay', clamped.toStringAsFixed(2));

  final video = state.currentVideo;
  if (video != null) {
    await _subtitlePreferencesRepository.saveDelayForVideo(
      video.filePath,
      clamped,
    );
  }
}
```

---

## 5.7 SubtitleMenuSheet UX

Tabs:

1. Tracks
2. Sync
3. Style

### Tracks tab

- Off
- Embedded subtitle tracks
- Load from storage

### Sync tab

- Slider -10s to +10s
- -0.5s button
- reset
- +0.5s button

### Style tab

- size chips
- text color chips
- background opacity slider
- style chips
- live preview
- reset defaults

---

## 5.8 Phase 5 Definition of Done

- [ ] User can load `.srt` or `.vtt` file.
- [ ] User can turn subtitles off.
- [ ] Delay can be adjusted from -10s to +10s.
- [ ] Delay persists per video.
- [ ] Basic style changes apply live.
- [ ] Missing external subtitle file does not crash the app.
- [ ] `flutter analyze` passes.

---

# Phase 6 — Performance + Stability Hardening

## 6.1 Goal

Make the player smooth on real Android devices.

Target:

- smooth 720p/1080p playback
- no gesture stutter
- no rebuild flooding
- no crash on unsupported/corrupt files
- reliable open/close lifecycle

---

## 6.2 Performance rules

1. Do not recreate `Player` or `VideoController` on every build.
2. Do not rebuild `Video` widget unnecessarily.
3. Keep gesture preview local inside `ProGestureLayer`.
4. Use `RepaintBoundary` around overlays.
5. Use Riverpod `select()` where possible.
6. Throttle position UI updates if needed.
7. Lazy-load thumbnails.
8. Cache generated thumbnails.
9. Avoid heavy scan on main isolate.
10. Always catch playback errors.

---

## 6.3 Riverpod select examples

Instead of:

```dart
final state = ref.watch(videoPlayerProvider);
```

Use for frequently updating widgets:

```dart
final position = ref.watch(
  videoPlayerProvider.select((s) => s.position),
);

final duration = ref.watch(
  videoPlayerProvider.select((s) => s.duration),
);

final isPlaying = ref.watch(
  videoPlayerProvider.select((s) => s.isPlaying),
);
```

---

## 6.4 Error handling requirements

Handle these cases:

- file not found
- unsupported format
- corrupt video
- permission denied
- media_kit init failure
- subtitle file not found
- subtitle parse failure
- PiP unsupported
- brightness channel failure

Player error UI should show:

```text
Could not play this video
[Try again] [Back]
```

---

## 6.5 QA checklist

Test on a real Android phone.

### Library

- [ ] First app open with permission request
- [ ] Permission denied
- [ ] Empty library
- [ ] 10 videos
- [ ] 100+ videos
- [ ] Grid/List toggle
- [ ] Search
- [ ] Sort
- [ ] Favorites

### Playback

- [ ] Open video
- [ ] Play/Pause
- [ ] Seek slider
- [ ] Double tap skip
- [ ] Swipe seek
- [ ] Volume swipe
- [ ] Brightness swipe
- [ ] Lock mode
- [ ] Speed 0.5x / 1x / 1.5x / 2x
- [ ] Back saves position
- [ ] Reopen resumes position
- [ ] App background
- [ ] PiP if supported

### Subtitles

- [ ] Load SRT
- [ ] Load VTT
- [ ] Delay -1.5s
- [ ] Delay +1.5s
- [ ] Change size
- [ ] Change opacity
- [ ] Reopen same video restores delay

### Stability

- [ ] Open invalid file
- [ ] Delete file then open from library
- [ ] Rapidly open/close 5 videos
- [ ] Rotate device if supported
- [ ] Low storage scenario if possible

---

## 6.6 Final Definition of Done for Phase 1 Video Core

- [ ] `flutter analyze` passes.
- [ ] `flutter build apk --debug --flavor stable` passes.
- [ ] `flutter build apk --release --flavor stable --split-per-abi` passes.
- [ ] Video library looks polished and usable.
- [ ] Player screen feels premium.
- [ ] Gestures work without stutter.
- [ ] Resume works.
- [ ] Basic subtitles work.
- [ ] No known P1 crash remains open.
- [ ] Stable flavor does not include yt-dlp / Chaquopy / experimental social downloader work.

---

# Suggested AI Agent Prompt

Copy this prompt into your coding agent after attaching this file:

```text
You are working inside the existing VidMaster Flutter project.

Implement "VidMaster Phase 1 — Premium Video Player Core" from the attached markdown file.

Follow the phases in order:
1. Video Library UX/UI
2. Premium Player Screen UI
3. Pro Gesture Engine
4. Resume System
5. Subtitle Engine Basic v1
6. Performance + Stability Hardening

Rules:
- Do not create a new project.
- Do not implement social downloader features.
- Do not touch experimental yt-dlp / Chaquopy work.
- Keep stable flavor production-safe.
- Preserve Clean Architecture, Riverpod, Isar, go_router, and current project structure.
- Use English for UI/code text.
- Do not call player.seek() during gesture onPanUpdate.
- Run flutter analyze after each phase.
- Run stable debug build and stable release split-per-abi build at the end.

Before editing, inspect the existing files mentioned in each phase and adapt to the current codebase instead of duplicating classes.

After implementation, report:
- files changed
- features completed
- commands run
- analyzer/build results
- any remaining issues
```

---

# Notes for the Human Owner

Recommended first release scope:

```text
VidMaster v1 = Premium Local Video/Music Player + Basic URL Downloader
```

Do not delay the first strong APK by trying to complete:

- social downloader
- Chromecast
- equalizer
- AI subtitle features
- OpenSubtitles
- full vault UI polish

For this phase, the video player must become the hero feature.

