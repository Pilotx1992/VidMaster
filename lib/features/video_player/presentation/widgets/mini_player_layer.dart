import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vidmaster/core/router/app_router.dart';
import 'package:vidmaster/core/theme/app_theme.dart';
import '../providers/mini_player_provider.dart';
import '../providers/video_player_provider.dart';
import '../screens/video_player_screen.dart';
import 'video_surface.dart';

class MiniPlayerLayer extends ConsumerStatefulWidget {
  const MiniPlayerLayer({super.key});

  @override
  ConsumerState<MiniPlayerLayer> createState() => _MiniPlayerLayerState();
}

class _MiniPlayerLayerState extends ConsumerState<MiniPlayerLayer> {
  double _dragOffset = 0.0;

  @override
  void initState() {
    super.initState();
    // [MiniPlayerLayer] is built in MaterialApp.router's builder *next to* the router
    // subtree, so [GoRouterState.of] is unavailable. Listen to the delegate instead.
    AppRouter.router.routerDelegate.addListener(_onRouterDelegateChanged);
  }

  @override
  void dispose() {
    AppRouter.router.routerDelegate.removeListener(_onRouterDelegateChanged);
    super.dispose();
  }

  void _onRouterDelegateChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final mini = ref.watch(miniPlayerProvider);
    final player = ref.watch(videoPlayerProvider);
    final notifier = ref.read(videoPlayerProvider.notifier);

    // Layer sits in a Stack above the router; hide while full-screen player is shown.
    final routePath =
        AppRouter.router.routerDelegate.currentConfiguration.uri.path;
    if (routePath == AppRoutes.player) {
      return const SizedBox.shrink();
    }

    if (!mini.isVisible || mini.video == null) {
      return const SizedBox.shrink();
    }

    final width = MediaQuery.of(context).size.width;
    // The mini-player sits in MaterialApp.router's overlay layer, ABOVE the
    // Scaffold — so its `bottom` is measured from the device edge, not from
    // above the navigation bar. Without offsetting for both the nav bar
    // (`kBottomNavigationBarHeight`, 56 dp) and the system gesture inset
    // (`viewPadding.bottom`, 24-48 dp on Android 10+), the mini-player ends
    // up sitting on top of the bottom tabs. The extra +8 keeps a small
    // breathing gap above the tabs.
    final safeBottom = MediaQuery.viewPaddingOf(context).bottom;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      bottom: kBottomNavigationBarHeight + safeBottom + 8,
      left: 16 + _dragOffset,
      right: 16 - _dragOffset,
      height: 76,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragUpdate: (details) {
          setState(() {
            _dragOffset += details.delta.dx;
          });
        },
        onHorizontalDragEnd: (details) {
          final velocity = details.primaryVelocity ?? 0;
          if (velocity.abs() > 800 || _dragOffset.abs() > width * 0.4) {
            ref.read(miniPlayerProvider.notifier).hide();
            notifier.pause();
            setState(() => _dragOffset = 0);
          } else {
            setState(() => _dragOffset = 0);
          }
        },
        onTap: () {
          // Forward the queue currently held by the player notifier so that
          // re-opening from the mini doesn't strip next/previous context.
          // `state.queue` is empty when the user came in via a path that
          // never carried a queue (e.g. an external open); leave it as null
          // in that case so VideoPlayerArgs stays clean.
          final currentQueue = ref.read(videoPlayerProvider).queue;
          ref.read(miniPlayerProvider.notifier).hide();
          AppRouter.router.push(
            AppRoutes.player,
            extra: VideoPlayerArgs(
              video: mini.video!,
              queue: currentQueue.isEmpty ? null : currentQueue,
            ),
          );
        },
        child: Material(
          elevation: 16,
          shadowColor: Colors.black.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(14),
          clipBehavior: Clip.antiAlias,
          color: AppTheme.surfaceDark2,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.outlineDark),
            ),
            child: Stack(
              children: [
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Row(
                    children: [
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: IgnorePointer(
                          // Distinct tag from the full-screen surface
                          // ('video_player') eliminates the Hero collision
                          // foot-gun if both surfaces ever briefly co-exist
                          // during a future transition. They are mutually
                          // exclusive today (this layer hides on /player),
                          // so this change is visually identical.
                          child: VideoSurface(
                            controller: notifier.controller,
                            heroTag: 'video_player_mini',
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              player.currentVideo?.name ?? 'Video',
                              style: const TextStyle(
                                color: AppTheme.onSurfaceDark,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.15,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${_format(player.position)} / ${_format(player.duration)}',
                              style: TextStyle(
                                color: AppTheme.onSurfaceDark.withValues(alpha: 0.65),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: Icon(
                          player.isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: AppTheme.onSurfaceDark,
                        ),
                        onPressed: () =>
                            player.isPlaying ? notifier.pause() : notifier.play(),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: Icon(Icons.close_rounded, color: AppTheme.onSurfaceDark.withValues(alpha: 0.85)),
                        onPressed: () {
                          ref.read(miniPlayerProvider.notifier).hide();
                          notifier.pause();
                        },
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: LinearProgressIndicator(
                      value: player.duration.inMilliseconds == 0
                          ? 0
                          : player.position.inMilliseconds /
                              player.duration.inMilliseconds,
                      backgroundColor: Colors.white.withValues(alpha: 0.08),
                      color: AppTheme.secondaryColor,
                      minHeight: 3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$m:$s";
  }
}
