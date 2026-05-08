import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:media_kit/media_kit.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'package:vidmaster/features/video_player/presentation/providers/video_player_provider.dart';
import 'package:vidmaster/features/video_player/presentation/providers/video_player_notifier.dart';
import 'package:vidmaster/features/video_player/presentation/providers/mini_player_provider.dart';
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

/// Spinner only before first progress, and never while [VideoPlayerState.isPlaying].
bool _showPlayerLoadingOverlay(VideoPlayerState state) {
  if (state.isPlaying) return false;
  if (state.status == PlayerStatus.error) return false;
  if (state.status == PlayerStatus.loading) {
    return state.position <= Duration.zero;
  }
  if (state.status == PlayerStatus.buffering) {
    return state.position <= Duration.zero;
  }
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

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WakelockPlus.enable();

    Future.microtask(() {
      ref.read(videoPlayerProvider.notifier).openVideo(widget.args.video);
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

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) return;

        final currentVideo = state.currentVideo;
        if (currentVideo != null) {
          ref.read(miniPlayerProvider.notifier).show(currentVideo);
        }
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
                            builder: (context, t, child) =>
                                Opacity(opacity: t, child: child),
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
              if (_showPlayerLoadingOverlay(state))
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
                        ? () => notifier.openVideo(state.currentVideo!)
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
