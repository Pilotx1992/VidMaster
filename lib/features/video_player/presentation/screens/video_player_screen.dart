import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:media_kit/media_kit.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'package:vidmaster/features/video_player/presentation/providers/video_player_provider.dart';
import 'package:vidmaster/features/video_player/presentation/providers/video_player_notifier.dart';
import 'package:vidmaster/features/video_player/presentation/providers/mini_player_provider.dart';
import 'package:vidmaster/features/video_player/presentation/providers/video_library_provider.dart';
import 'package:vidmaster/features/video_player/domain/entities/video_file.dart';
import 'package:vidmaster/features/video_player/domain/entities/video_playback_state.dart';
import 'package:vidmaster/features/video_player/presentation/widgets/video_surface.dart';
import 'package:vidmaster/features/video_player/presentation/widgets/pro_gesture_layer.dart';
import 'package:vidmaster/features/video_player/presentation/widgets/subtitle_styling_sheet.dart';
import 'package:vidmaster/features/video_player/presentation/widgets/landscape_player_controls.dart';
import 'package:vidmaster/features/video_player/presentation/widgets/portrait_player_controls.dart';
import 'package:vidmaster/features/video_player/presentation/widgets/player_locked_overlay.dart';
import 'package:vidmaster/features/video_player/presentation/widgets/player_loading_overlay.dart';
import 'package:vidmaster/features/video_player/presentation/widgets/player_error_overlay.dart';

/// Full-screen spinner is allowed ONLY before the very first decoded frame of a
/// freshly-opened media item. The conditions below are deliberately defensive
/// because, in the wild, media_kit's `playing`, `buffering`, `position`, and
/// `duration` streams can arrive out of order across a source switch — the
/// previous implementation could leave a spinner on top of an already-playing
/// surface (the bug we observed when switching videos).
///
/// The spinner is suppressed when ANY of the following is true:
///   * `state.isPlaying` is true (playback is active),
///   * playback has produced progress (`position > 0`),
///   * a duration is already known and we're past the very first open step
///     (i.e. a ready video surface exists),
///   * the player is in an error state (PlayerErrorOverlay owns that surface).
///
/// It is shown only during the initial `loading` (pre-first-frame) window, or
/// during early `buffering` BEFORE any duration/position is available.
bool _showPlayerLoadingOverlay(VideoPlayerState state) {
  if (state.isPlaying) return false;
  if (state.hasError || state.status == PlayerStatus.error) return false;
  if (state.position > Duration.zero) return false;

  // A ready surface = we have at least a duration. The only moment a duration
  // can be > 0 while we still want a spinner is the brief instant right at the
  // very first open of a media item before any frame is decoded — represented
  // by `status == loading` with `position == 0` AND `duration == 0`. As soon
  // as duration is published, the surface is ready and we must NOT cover it.
  final isInitialLoad = state.status == PlayerStatus.loading &&
      state.position == Duration.zero &&
      state.duration == Duration.zero;
  if (state.duration > Duration.zero && !isInitialLoad) return false;

  if (state.status == PlayerStatus.loading) return true;
  if (state.status == PlayerStatus.buffering) return true;
  return false;
}

class VideoPlayerArgs {
  final VideoFile video;
  final List<VideoFile>? queue;

  VideoPlayerArgs({required this.video, this.queue});
}

class VideoPlayerScreen extends ConsumerStatefulWidget {
  final VideoPlayerArgs args;

  const VideoPlayerScreen({super.key, required this.args});

  @override
  ConsumerState<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends ConsumerState<VideoPlayerScreen>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  static final _controlsFadeTween = Tween<double>(begin: 0, end: 1);

  // Temporary instrumentation for the stuck-spinner bug observed when
  // switching videos. Logs ONLY in debug builds and ONLY when the visibility
  // of the loading overlay actually flips. Safe to remove once we have a
  // confirmed root cause.
  bool? _lastShouldShowLoading;

  @override
  bool get wantKeepAlive => true;

  void _diagLoadingOverlay(VideoPlayerState state, bool shouldShow) {
    if (!kDebugMode) return;
    if (_lastShouldShowLoading == shouldShow) return;
    _lastShouldShowLoading = shouldShow;
    debugPrint(
      '[VideoPlayer][loading] shouldShowLoading=$shouldShow '
      'status=${state.status.name} '
      'isPlaying=${state.isPlaying} '
      'isBuffering=${state.isBuffering} '
      'position=${state.position} '
      'duration=${state.duration}',
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WakelockPlus.enable();
    // CRITICAL: every Riverpod mutation that happens "on enter" must be
    // deferred past the current frame. Calling `notifier.hide()` directly
    // here (as we used to) runs while the widget tree is still mounting,
    // and Riverpod throws "Tried to modify a provider while the widget tree
    // was building" the moment any consumer of `miniPlayerProvider` rebuilds
    // in the same frame. A single post-frame callback also keeps the order
    // deterministic: hide mini first, then open the new source.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(miniPlayerProvider.notifier).hide();
      ref.read(videoPlayerProvider.notifier).openVideo(
            widget.args.video,
            queue: widget.args.queue,
          );
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      WakelockPlus.disable();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(videoPlayerProvider);
    final notifier = ref.read(videoPlayerProvider.notifier);
    final orientation = MediaQuery.orientationOf(context);
    final isLandscape = orientation == Orientation.landscape;
    final shouldShowLoading = _showPlayerLoadingOverlay(state);
    _diagLoadingOverlay(state, shouldShowLoading);

    // Record every successful "current video" change into the library so the
    // "Recent" tab reflects the user's actual session. Covers all entry paths:
    // initial open, Next/Previous in a queue, auto-advance on completion, and
    // mini → full re-open with a different source. The library notifier
    // refreshes its `recentlyPlayed` list in-place so no full re-sync runs.
    ref.listen<String?>(
      videoPlayerProvider.select((s) => s.currentVideo?.path),
      (previous, next) {
        if (next == null) return;
        if (previous == next) return;
        ref.read(videoLibraryProvider.notifier).markPlayed(next);
      },
    );

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) return;

        final currentVideo = state.currentVideo;
        if (currentVideo == null) return;
        // Capture the notifier now: by the time the post-frame callback
        // fires, this screen is unmounted (the mini layer outlives us, so
        // its notifier reference is still valid). Deferring avoids the
        // "modify provider during build" crash when the navigator is mid-
        // way through tearing down this route.
        final miniNotifier = ref.read(miniPlayerProvider.notifier);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          miniNotifier.show(currentVideo);
        });
      },
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            fit: StackFit.expand,
            // Hit-test / z-order: ProGestureLayer is built ONLY while controls are
            // hidden — never stacked above Portrait/Landscape controls.
            children: [
              const ColoredBox(color: Colors.black),
              Positioned.fill(
                child: Center(
                  child: VideoSurface(
                    controller: notifier.controller,
                    mode: state.aspectRatioMode,
                    heroTag: 'video_player',
                  ),
                ),
              ),
              if (!state.isLocked &&
                  !state.showControls &&
                  state.status != PlayerStatus.error)
                Positioned.fill(
                  child: ProGestureLayer(
                    duration: state.duration,
                    position: state.position,
                    volume: state.volume,
                    brightness: state.brightness,
                    onTap: notifier.toggleControls,
                    onSeekEnd: (position) =>
                        notifier.seek(position, revealControls: false),
                    onVolume: notifier.setVolume,
                    onBrightness: notifier.setBrightness,
                    onDoubleTapLeft: () => notifier.seek(
                      state.position - const Duration(seconds: 10),
                      revealControls: false,
                    ),
                    onDoubleTapRight: () => notifier.seek(
                      state.position + const Duration(seconds: 10),
                      revealControls: false,
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
              if (!state.isLocked &&
                  state.showControls &&
                  state.status != PlayerStatus.error)
                Positioned.fill(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Dismiss layer: must sit *under* controls so play/seek/CC win
                      // hit tests (parent GestureDetector used to compete with IconButtons).
                      Positioned.fill(
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: notifier.toggleControls,
                          child: const ColoredBox(color: Colors.transparent),
                        ),
                      ),
                      Positioned.fill(
                        child: RepaintBoundary(
                          child: TweenAnimationBuilder<double>(
                            tween: _controlsFadeTween,
                            duration: const Duration(milliseconds: 240),
                            curve: Curves.easeOutCubic,
                            builder: (context, t, child) {
                              // Android platform views do not reliably render
                              // inside the animated controls opacity layer,
                              // which hides the native CAF cast button in the
                              // player top bar. Keep the same show/hide logic,
                              // but skip the fade host on Android.
                              if (!kIsWeb &&
                                  defaultTargetPlatform ==
                                      TargetPlatform.android) {
                                return child!;
                              }
                              return Opacity(opacity: t, child: child);
                            },
                            child: isLandscape
                                ? LandscapePlayerControls(
                                    state: state,
                                    notifier: notifier,
                                    onBack: () => context.pop(),
                                    onPickSubtitle: () =>
                                        _pickExternalSubtitle(
                                            context, notifier),
                                    onSubtitleStyling: () =>
                                        _showSubtitleStyling(context),
                                  )
                                : PortraitPlayerControls(
                                    state: state,
                                    notifier: notifier,
                                    onBack: () => context.pop(),
                                    onPickSubtitle: () =>
                                        _pickExternalSubtitle(
                                            context, notifier),
                                    onSubtitleStyling: () =>
                                        _showSubtitleStyling(context),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (shouldShowLoading)
                const Positioned.fill(child: PlayerLoadingOverlay()),
              if (state.isLocked)
                Positioned.fill(
                  child: PlayerLockedOverlay(
                    onUnlock: notifier.toggleLockMode,
                  ),
                ),
              if (state.hasError)
                Positioned.fill(
                  child: PlayerErrorOverlay(
                    error: state.error,
                    onBack: () => context.pop(),
                    onRetry: state.currentVideo != null
                        ? () => notifier.openVideo(
                              state.currentVideo!,
                              // Preserve queue context across retries so
                              // auto-advance / next / previous remain wired
                              // after recovering from an error.
                              queue: state.queue.isEmpty
                                  ? widget.args.queue
                                  : state.queue,
                            )
                        : null,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickExternalSubtitle(
    BuildContext context,
    VideoPlayerNotifier notifier,
  ) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['srt', 'vtt', 'ass'],
    );

    if (result != null && result.files.single.path != null) {
      await notifier
          .setSubtitleTrack(SubtitleTrack.uri(result.files.single.path!));
    }
  }

  void _showSubtitleStyling(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const SubtitleStylingSheet(),
    );
  }
}
