import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/video_entity.dart';
import '../providers/video_player_provider.dart';

class VideoPlayerScreen extends ConsumerStatefulWidget {
  final VideoPlayerArgs args;
  const VideoPlayerScreen({required this.args, super.key});

  @override
  ConsumerState<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends ConsumerState<VideoPlayerScreen>
    with WidgetsBindingObserver {

  static const _pip = MethodChannel('vidmaster/pip');
  static const _brightness = MethodChannel('vidmaster/brightness');

  double _dragVolume = 0.0;
  double _dragBrightness = 0.0;
  bool _isDraggingSeek = false;
  Duration _seekPreview = Duration.zero;
  Duration _seekDragStart = Duration.zero; // موقع البداية عند أول لمسة

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _enterFullscreen();
    WakelockPlus.enable();

    // Open video after first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(videoPlayerProvider.notifier).openVideo(
            widget.args.video,
            queue: widget.args.queue,
          );
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _exitFullscreen();
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Auto-enter PiP when app is hidden (home button).
    if (state == AppLifecycleState.inactive) {
      _enterPip();
    }
  }

  void _enterFullscreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void _exitFullscreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  Future<void> _enterPip() async {
    try {
      await _pip.invokeMethod('enterPip');
    } on PlatformException {
      // PiP not supported on this device — silently ignore.
    }
  }

  Future<void> _setBrightness(double value) async {
    try {
      await _brightness.invokeMethod('setBrightness', {'value': value});
    } on PlatformException {
      // Ignore on unsupported devices.
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(videoPlayerProvider);
    final notifier = ref.read(videoPlayerProvider.notifier);

    return PopScope(
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) return;
        // Save position before leaving.
        final video = state.currentVideo;
        if (video != null) {
          notifier.savePosition(video.filePath, state.position.inMilliseconds);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onTap: state.isLocked ? null : notifier.toggleControls,
          child: Stack(
            children: [
              // ── Video Surface ─────────────────────────────────────────
              _VideoSurface(
                controller: notifier.controller,
                mode: state.aspectRatioMode,
              ),

              // ── Gesture Overlay ───────────────────────────────────────
              if (!state.isLocked)
                _GestureOverlay(
                  onBrightnessChange: (delta) {
                    final newBrightness =
                        (_dragBrightness + delta).clamp(0.0, 1.0);
                    _dragBrightness = newBrightness;
                    notifier.setBrightness(newBrightness);
                    _setBrightness(newBrightness);
                  },
                  onVolumeChange: (delta) {
                    final newVol = (_dragVolume + delta).clamp(0.0, 1.0);
                    _dragVolume = newVol;
                    notifier.setVolume(newVol);
                  },
                  onSeekStart: () {
                    // تسجيل موقع البداية مرة واحدة فقط
                    _seekDragStart = state.position;
                    _isDraggingSeek = true;
                  },
                  onSeek: (delta) {
                    // نُضيف الـ delta إلى موقع البداية الثابت
                    final target = _seekDragStart + delta;
                    _seekPreview = target.isNegative
                        ? Duration.zero
                        : (target > state.duration ? state.duration : target);
                  },
                  onSeekEnd: () {
                    if (_isDraggingSeek) {
                      notifier.seekTo(_seekPreview);
                      _isDraggingSeek = false;
                    }
                  },
                  onDoubleTapLeft: () => notifier.seekBackward(10),
                  onDoubleTapRight: () => notifier.seekForward(10),
                ),

              // ── Controls Overlay ──────────────────────────────────────
              if (state.isControlsVisible && !state.isLocked)
                _ControlsOverlay(state: state, notifier: notifier),

              // ── Lock indicator ────────────────────────────────────────
              if (state.isLocked)
                Positioned(
                  top: 16,
                  right: 16,
                  child: GestureDetector(
                    onTap: notifier.toggleLock,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(Icons.lock, color: Colors.white),
                    ),
                  ),
                ),

              // ── Status indicators (volume / brightness) ───────────────
              if (state.isControlsVisible)
                _StatusIndicators(state: state),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Video Surface ──────────────────────────────────────────────────────────

class _VideoSurface extends StatelessWidget {
  final VideoController controller;
  final AspectRatioMode mode;
  const _VideoSurface({required this.controller, this.mode = AspectRatioMode.fit});

  @override
  Widget build(BuildContext context) {
    final boxFit = switch (mode) {
      AspectRatioMode.fit => BoxFit.contain,
      AspectRatioMode.fill => BoxFit.fill,
      AspectRatioMode.sixteenNine => BoxFit.contain,
      AspectRatioMode.fourThree => BoxFit.contain,
      AspectRatioMode.crop => BoxFit.cover,
    };

    Widget video = Video(
      controller: controller,
      fit: boxFit,
      fill: Colors.black,
    );

    // Wrap in AspectRatio for forced ratios
    if (mode == AspectRatioMode.sixteenNine) {
      video = AspectRatio(aspectRatio: 16 / 9, child: video);
    } else if (mode == AspectRatioMode.fourThree) {
      video = AspectRatio(aspectRatio: 4 / 3, child: video);
    }

    return Center(child: video);
  }
}

// ── Gesture Overlay ────────────────────────────────────────────────────────

class _GestureOverlay extends StatelessWidget {
  final void Function(double delta) onBrightnessChange;
  final void Function(double delta) onVolumeChange;
  final VoidCallback onSeekStart;
  final void Function(Duration delta) onSeek;
  final VoidCallback onSeekEnd;
  final VoidCallback onDoubleTapLeft;
  final VoidCallback onDoubleTapRight;

  const _GestureOverlay({
    required this.onBrightnessChange,
    required this.onVolumeChange,
    required this.onSeekStart,
    required this.onSeek,
    required this.onSeekEnd,
    required this.onDoubleTapLeft,
    required this.onDoubleTapRight,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left half: brightness control
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onDoubleTap: onDoubleTapLeft,
            onVerticalDragUpdate: (d) =>
                onBrightnessChange(-d.delta.dy / 200),
            onHorizontalDragStart: (_) => onSeekStart(),
            onHorizontalDragUpdate: (d) =>
                onSeek(Duration(milliseconds: (d.delta.dx * 300).toInt())),
            onHorizontalDragEnd: (_) => onSeekEnd(),
          ),
        ),
        // Right half: volume control
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onDoubleTap: onDoubleTapRight,
            onVerticalDragUpdate: (d) =>
                onVolumeChange(-d.delta.dy / 200),
            onHorizontalDragStart: (_) => onSeekStart(),
            onHorizontalDragUpdate: (d) =>
                onSeek(Duration(milliseconds: (d.delta.dx * 300).toInt())),
            onHorizontalDragEnd: (_) => onSeekEnd(),
          ),
        ),
      ],
    );
  }
}

// ── Controls Overlay ───────────────────────────────────────────────────────

class _ControlsOverlay extends StatelessWidget {
  final VideoPlayerState state;
  final VideoPlayerNotifier notifier;
  const _ControlsOverlay({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.playerOverlay,
      child: Column(
        children: [
          // Top bar
          _TopBar(state: state, notifier: notifier),
          const Spacer(),
          // Center play controls
          _CenterControls(state: state, notifier: notifier),
          const Spacer(),
          // Bottom seek bar + time
          _BottomBar(state: state, notifier: notifier),
        ],
      ),
    );
  }
}

// ── Top Bar ────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final VideoPlayerState state;
  final VideoPlayerNotifier notifier;
  const _TopBar({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            Expanded(
              child: Text(
                state.currentVideo?.fileName ?? '',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Lock screen
            IconButton(
              icon: Icon(
                state.isLocked ? Icons.lock : Icons.lock_open,
                color: Colors.white,
              ),
              onPressed: notifier.toggleLock,
            ),
            // Aspect Ratio
            _AspectRatioButton(state: state, notifier: notifier),
            // Subtitle
            IconButton(
              icon: const Icon(Icons.subtitles_outlined, color: Colors.white),
              onPressed: () => _showSubtitlePicker(context, notifier),
            ),
            // PiP
            IconButton(
              icon: const Icon(Icons.picture_in_picture_alt, color: Colors.white),
              onPressed: () async {
                try {
                  await const MethodChannel('vidmaster/pip')
                      .invokeMethod('enterPip');
                } catch (_) {}
              },
            ),
            // Speed
            _SpeedButton(state: state, notifier: notifier),
          ],
        ),
      ),
    );
  }

  void _showSubtitlePicker(BuildContext context, VideoPlayerNotifier notifier) async {
    await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Subtitles'),
        content: const Text('Select a subtitle file from your device.'),
        actions: [
          TextButton(
            onPressed: () {
              notifier.loadSubtitle('');
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Disable'),
          ),
          FilledButton(
            onPressed: () async {
              final pickResult = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['srt', 'ass', 'vtt', 'sub'],
              );
              
              if (pickResult != null && pickResult.files.single.path != null) {
                notifier.loadSubtitle(pickResult.files.single.path!);
              }
              
              if (!context.mounted) return;
              Navigator.pop(context);
            },
            child: const Text('Browse...'),
          ),
        ],
      ),
    );
  }
}

// ── Aspect Ratio Button ────────────────────────────────────────────────────

class _AspectRatioButton extends StatelessWidget {
  final VideoPlayerState state;
  final VideoPlayerNotifier notifier;
  const _AspectRatioButton({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    final label = switch (state.aspectRatioMode) {
      AspectRatioMode.fit => 'Fit',
      AspectRatioMode.fill => 'Fill',
      AspectRatioMode.sixteenNine => '16:9',
      AspectRatioMode.fourThree => '4:3',
      AspectRatioMode.crop => 'Crop',
    };

    return GestureDetector(
      onTap: notifier.cycleAspectRatio,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.aspect_ratio, color: Colors.white, size: 16),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

// ── Speed Button ───────────────────────────────────────────────────────────

class _SpeedButton extends StatelessWidget {
  final VideoPlayerState state;
  final VideoPlayerNotifier notifier;
  const _SpeedButton({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<double>(
      initialValue: state.playbackSpeed,
      onSelected: notifier.setSpeed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '${state.playbackSpeed}x',
          style: const TextStyle(color: Colors.white, fontSize: 13),
        ),
      ),
      itemBuilder: (_) => [
        0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0, 3.0, 4.0
      ]
          .map((s) => PopupMenuItem(
                value: s,
                child: Text('${s}x'),
              ))
          .toList(),
    );
  }
}

// ── Center Controls ────────────────────────────────────────────────────────

class _CenterControls extends StatelessWidget {
  final VideoPlayerState state;
  final VideoPlayerNotifier notifier;
  const _CenterControls({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Previous
        IconButton(
          iconSize: 36,
          icon: const Icon(Icons.skip_previous, color: Colors.white),
          onPressed: state.hasPrevious ? notifier.playPrevious : null,
        ),
        const SizedBox(width: 8),
        // Seek back 10s
        IconButton(
          iconSize: 32,
          icon: const Icon(Icons.replay_10, color: Colors.white),
          onPressed: notifier.seekBackward,
        ),
        const SizedBox(width: 8),
        // Play/Pause
        _PlayPauseButton(state: state, notifier: notifier),
        const SizedBox(width: 8),
        // Seek forward 10s
        IconButton(
          iconSize: 32,
          icon: const Icon(Icons.forward_10, color: Colors.white),
          onPressed: notifier.seekForward,
        ),
        const SizedBox(width: 8),
        // Next
        IconButton(
          iconSize: 36,
          icon: const Icon(Icons.skip_next, color: Colors.white),
          onPressed: state.hasNext ? notifier.playNext : null,
        ),
      ],
    );
  }
}

class _PlayPauseButton extends StatelessWidget {
  final VideoPlayerState state;
  final VideoPlayerNotifier notifier;
  const _PlayPauseButton({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: notifier.playPause,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white30, width: 1.5),
        ),
        child: state.status == PlayerStatus.loading ||
                state.status == PlayerStatus.buffering
            ? const Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Icon(
                state.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 36,
              ),
      ),
    );
  }
}

// ── Bottom Bar ─────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final VideoPlayerState state;
  final VideoPlayerNotifier notifier;
  const _BottomBar({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Seek bar
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 3,
                thumbShape:
                    const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape:
                    const RoundSliderOverlayShape(overlayRadius: 14),
                activeTrackColor: const Color(0xFFF9A825),
                inactiveTrackColor: Colors.white24,
                thumbColor: const Color(0xFFF9A825),
              ),
              child: Slider(
                value: state.progressFraction,
                onChanged: (v) => notifier
                    .seekTo(Duration(
                      milliseconds:
                          (v * state.duration.inMilliseconds).toInt(),
                    )),
              ),
            ),
            // Time row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_format(state.position), style: AppTextStyles.playerTime),
                  Text(_format(state.duration), style: AppTextStyles.playerTime),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _format(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }
}

// ── Status Indicators ──────────────────────────────────────────────────────

class _StatusIndicators extends StatelessWidget {
  final VideoPlayerState state;
  const _StatusIndicators({required this.state});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 60,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _IndicatorPill(
            icon: Icons.brightness_6,
            value: state.brightness,
          ),
          _IndicatorPill(
            icon: Icons.volume_up,
            value: state.volume,
          ),
        ],
      ),
    );
  }
}

class _IndicatorPill extends StatelessWidget {
  final IconData icon;
  final double value;
  const _IndicatorPill({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          SizedBox(
            width: 60,
            child: LinearProgressIndicator(
              value: value,
              color: Colors.white,
              backgroundColor: Colors.white30,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}

class VideoPlayerArgs {
  final VideoEntity video;
  final List<VideoEntity>? queue;

  const VideoPlayerArgs({
    required this.video,
    this.queue,
  });
}

