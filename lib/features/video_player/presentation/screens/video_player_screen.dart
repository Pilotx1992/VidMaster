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

class _VideoPlayerScreenState extends ConsumerState<VideoPlayerScreen> with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  
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
    // 🔥 Stability: Release resources or pause if critical, but for multitasking we might keep playing
    if (state == AppLifecycleState.detached) {
      WakelockPlus.disable();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final state = ref.watch(videoPlayerProvider);
    final notifier = ref.read(videoPlayerProvider.notifier);

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) return;
        
        final currentVideo = state.currentVideo;
        if (currentVideo != null) {
          ref.read(miniPlayerProvider.notifier).show(currentVideo);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: state.status == PlayerStatus.error
            ? _buildErrorState(state.error)
            : Stack(
                children: [
                  VideoSurface(
                    controller: notifier.controller,
                    mode: state.aspectRatioMode,
                    heroTag: 'video_player',
                  ),

                  if (!state.isLocked) ...[
                    GestureDetector(
                      onTap: notifier.toggleControls,
                      behavior: HitTestBehavior.opaque,
                      child: AnimatedOpacity(
                        opacity: state.showControls ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: _ControlsOverlay(
                          state: state,
                          notifier: notifier,
                          onPickSubtitle: () => _pickExternalSubtitle(context, notifier),
                        ),
                      ),
                    ),
                  ],

                  if (state.showControls || state.isLocked)
                    Positioned(
                      left: 16,
                      bottom: 100,
                      child: FloatingActionButton.small(
                        heroTag: 'lock_btn',
                        onPressed: notifier.toggleLockMode,
                        backgroundColor: Colors.black45,
                        child: Icon(
                          state.isLocked ? Icons.lock : Icons.lock_open,
                          color: Colors.white,
                        ),
                      ),
                    ),

                  if (!state.isLocked && !state.showControls)
                    ProGestureLayer(
                      duration: state.duration,
                      position: state.position,
                      volume: state.volume,
                      brightness: state.brightness,
                      onTap: notifier.toggleControls,
                      onSeekEnd: notifier.seek,
                      onVolume: (v) => notifier.controller.player.setVolume(v * 100),
                      onBrightness: (b) => {}, 
                      onDoubleTapLeft: () => notifier.seek(state.position - const Duration(seconds: 10)),
                      onDoubleTapRight: () => notifier.seek(state.position + const Duration(seconds: 10)),
                      child: const SizedBox.expand(),
                    ),

                  if (state.status == PlayerStatus.loading || state.status == PlayerStatus.buffering)
                    const Center(
                      child: CircularProgressIndicator(color: Color(0xFFF9A825)),
                    ),
                ],
              ),
      ),
    );
  }

  Widget _buildErrorState(PlayerError? error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 64),
          const SizedBox(height: 16),
          Text(
            error == PlayerError.fileNotFound ? 'File not found' : 'Playback error',
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.pop(),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF9A825)),
            child: const Text('Go Back', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Future<void> _pickExternalSubtitle(BuildContext context, VideoPlayerNotifier notifier) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['srt', 'vtt', 'ass'],
    );

    if (result != null && result.files.single.path != null) {
      await notifier.setSubtitleTrack(SubtitleTrack.uri(result.files.single.path!));
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

class _ControlsOverlay extends StatelessWidget {
  final VideoPlayerState state;
  final VideoPlayerNotifier notifier;
  final VoidCallback onPickSubtitle;

  const _ControlsOverlay({
    required this.state,
    required this.notifier,
    required this.onPickSubtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black45,
      child: Column(
        children: [
          SafeArea(
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => context.pop(),
                ),
                Expanded(
                  child: Text(
                    state.currentVideo?.name ?? '',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.subtitles, color: Colors.white),
                  onPressed: onPickSubtitle,
                ),
                _buildSubtitleMenu(context),
                IconButton(
                  icon: const Icon(Icons.style, color: Colors.white),
                  onPressed: () => (context.findAncestorStateOfType<_VideoPlayerScreenState>())?._showSubtitleStyling(context),
                ),
                IconButton(
                  icon: const Icon(Icons.aspect_ratio, color: Colors.white),
                  onPressed: notifier.cycleAspectRatio,
                ),
              ],
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                iconSize: 48,
                icon: const Icon(Icons.replay_10, color: Colors.white),
                onPressed: () => notifier.seek(state.position - const Duration(seconds: 10)),
              ),
              IconButton(
                iconSize: 72,
                icon: Icon(
                  state.status == PlayerStatus.playing ? Icons.pause_circle_filled : Icons.play_circle_filled,
                  color: const Color(0xFFF9A825),
                ),
                onPressed: state.status == PlayerStatus.playing ? notifier.pause : notifier.play,
              ),
              IconButton(
                iconSize: 48,
                icon: const Icon(Icons.forward_10, color: Colors.white),
                onPressed: () => notifier.seek(state.position + const Duration(seconds: 10)),
              ),
            ],
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Row(
              children: [
                Text(_formatDuration(state.position), style: const TextStyle(color: Colors.white, fontSize: 12)),
                Expanded(
                  child: Slider(
                    value: state.position.inMilliseconds.toDouble().clamp(0, state.duration.inMilliseconds.toDouble()),
                    max: state.duration.inMilliseconds.toDouble() > 0 ? state.duration.inMilliseconds.toDouble() : 1,
                    activeColor: const Color(0xFFF9A825),
                    inactiveColor: Colors.white24,
                    onChanged: (v) => notifier.seek(Duration(milliseconds: v.toInt())),
                  ),
                ),
                Text(_formatDuration(state.duration), style: const TextStyle(color: Colors.white, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtitleMenu(BuildContext context) {
    return PopupMenuButton<SubtitleTrack>(
      icon: const Icon(Icons.closed_caption, color: Colors.white),
      onSelected: notifier.setSubtitleTrack,
      itemBuilder: (context) => [
        ...state.availableSubtitleTracks.map((t) => PopupMenuItem(
          value: t,
          child: Text(t.title ?? t.language ?? 'Track ${state.availableSubtitleTracks.indexOf(t) + 1}'),
        )),
      ],
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$m:$s";
  }
}
