import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../domain/entities/audio_track_entity.dart';
import '../providers/music_player_provider.dart';

class MiniPlayerBar extends ConsumerWidget {
  const MiniPlayerBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTrack = ref.watch(
      musicPlayerProvider.select((s) => s.currentTrack),
    );
    final currentIndex = ref.watch(
      musicPlayerProvider.select((s) => s.currentIndex),
    );
    final queue = ref.watch(
      musicPlayerProvider.select((s) => s.queue),
    );

    return ListenableBuilder(
      listenable: AppRouter.router.routerDelegate,
      builder: (context, _) {
        final isNowPlayingRoute =
            AppRouter.router.state.uri.path == AppRoutes.nowPlaying;
        final shouldShow = currentTrack != null && !isNowPlayingRoute;

        return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ),
        );

        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      child: !shouldShow
          ? const SizedBox(
              key: ValueKey('mini_player_hidden'),
            )
          : _MiniPlayerContainer(
              key: const ValueKey('mini_player'),
              currentTrack: currentTrack,
              currentIndex: currentIndex,
              queue: queue,
            ),
        );
      },
    );
  }
}

class _MiniPlayerContainer extends StatelessWidget {
  final AudioTrackEntity currentTrack;
  final int currentIndex;
  final List<AudioTrackEntity> queue;

  const _MiniPlayerContainer({
    super.key,
    required this.currentTrack,
    required this.currentIndex,
    required this.queue,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      elevation: 12,
      color: Colors.transparent,
      child: Container(
        height: _MiniPlayerDimens.barHeight,
        decoration: BoxDecoration(
          color: cs.surface.withValues(alpha: 0.96),
          border: Border(
            top: BorderSide(
              color: cs.outlineVariant.withValues(alpha: 0.2),
            ),
          ),
        ),
        child: Column(
          children: [
            const _MiniPlayerProgress(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  textDirection: TextDirection.ltr,
                  children: [
                    const _CloseButton(),
                    const SizedBox(width: 4),
                    RepaintBoundary(
                      child: _MiniPlayerArtwork(
                        artworkPath: currentTrack.albumArtPath,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () {
                          context.push(
                            AppRoutes.nowPlaying,
                            extra: NowPlayingArgs(
                              track: currentTrack,
                              queue: queue,
                              queueIndex: currentIndex,
                            ),
                          );
                        },
                        child: _TrackInfo(
                          title: currentTrack.title,
                          artist: currentTrack.artist,
                        ),
                      ),
                    ),
                    const _PlayPauseButton(),
                    const _MoreButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniPlayerProgress extends ConsumerWidget {
  const _MiniPlayerProgress();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(
      musicPlayerProvider.select((s) => s.progressFraction),
    );
    final cs = Theme.of(context).colorScheme;

    return RepaintBoundary(
      child: LinearProgressIndicator(
        value: progress.clamp(0.0, 1.0).toDouble(),
        minHeight: 2,
        backgroundColor: cs.surfaceContainerHighest,
        valueColor: AlwaysStoppedAnimation(cs.primary),
      ),
    );
  }
}

class _CloseButton extends ConsumerWidget {
  const _CloseButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(musicPlayerProvider.notifier);
    final cs = Theme.of(context).colorScheme;

    return IconButton(
      onPressed: () async {
        await notifier.stopAndClear();
      },
      icon: Icon(
        Icons.close_rounded,
        size: 20,
        color: cs.onSurfaceVariant,
      ),
      splashRadius: 20,
    );
  }
}

class _PlayPauseButton extends ConsumerWidget {
  const _PlayPauseButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPlaying = ref.watch(
      musicPlayerProvider.select((s) => s.isPlaying),
    );
    final notifier = ref.read(musicPlayerProvider.notifier);
    final cs = Theme.of(context).colorScheme;

    return IconButton(
      onPressed: () async {
        await notifier.playPause();
      },
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, animation) =>
            ScaleTransition(scale: animation, child: child),
        child: Icon(
          isPlaying
              ? Icons.pause_circle_filled_rounded
              : Icons.play_circle_fill_rounded,
          key: ValueKey(isPlaying),
          size: 34,
          color: cs.primary,
        ),
      ),
      splashRadius: 24,
    );
  }
}

class _MoreButton extends ConsumerWidget {
  const _MoreButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    return IconButton(
      onPressed: () => _showMenu(context, ref),
      icon: Icon(
        Icons.more_vert_rounded,
        color: cs.onSurfaceVariant,
      ),
      splashRadius: 20,
    );
  }

  void _showMenu(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(musicPlayerProvider.notifier);
    final cs = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: cs.surface,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.skip_previous_rounded),
                title: const Text('Previous'),
                onTap: () async {
                  Navigator.pop(context);
                  await notifier.previous();
                },
              ),
              ListTile(
                leading: const Icon(Icons.skip_next_rounded),
                title: const Text('Next'),
                onTap: () async {
                  Navigator.pop(context);
                  await notifier.next();
                },
              ),
              ListTile(
                leading: const Icon(Icons.stop_circle_rounded),
                title: const Text('Stop Playback'),
                onTap: () async {
                  Navigator.pop(context);
                  await notifier.stopAndClear();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TrackInfo extends StatelessWidget {
  final String title;
  final String artist;

  const _TrackInfo({
    required this.title,
    required this.artist,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          artist,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            color: cs.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _MiniPlayerArtwork extends StatelessWidget {
  final String? artworkPath;

  const _MiniPlayerArtwork({
    required this.artworkPath,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: _MiniPlayerDimens.artworkSize,
      height: _MiniPlayerDimens.artworkSize,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: cs.surfaceContainerHighest,
      ),
      child: artworkPath == null
          ? _fallback(cs)
          : Image.file(
              File(artworkPath!),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _fallback(cs),
            ),
    );
  }

  Widget _fallback(ColorScheme cs) {
    return Icon(
      Icons.music_note_rounded,
      size: 22,
      color: cs.onSurfaceVariant,
    );
  }
}

abstract class _MiniPlayerDimens {
  static const double barHeight = 64;
  static const double artworkSize = 46;
}
