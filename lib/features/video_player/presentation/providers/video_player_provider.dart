import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../../../di.dart';
import '../../domain/entities/video_entity.dart';
import '../../domain/usecases/video_usecases.dart';

// ── State ──────────────────────────────────────────────────────────────────

enum PlayerStatus { idle, loading, playing, paused, buffering, error }
enum AspectRatioMode { fit, fill, sixteenNine, fourThree, crop }

class VideoPlayerState {
  final PlayerStatus status;
  final VideoEntity? currentVideo;
  final List<VideoEntity> queue;       // Videos in current folder/playlist
  final int currentIndex;
  final Duration position;
  final Duration duration;
  final double playbackSpeed;
  final double volume;
  final double brightness;
  final bool isControlsVisible;
  final bool isLocked;                 // Screen lock (no accidental touches)
  final String? errorMessage;
  final String? subtitlePath;
  final bool isFullscreen;
  final AspectRatioMode aspectRatioMode;

  const VideoPlayerState({
    this.status = PlayerStatus.idle,
    this.currentVideo,
    this.queue = const [],
    this.currentIndex = 0,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.playbackSpeed = 1.0,
    this.volume = 1.0,
    this.brightness = 0.5,
    this.isControlsVisible = true,
    this.isLocked = false,
    this.errorMessage,
    this.subtitlePath,
    this.isFullscreen = false,
    this.aspectRatioMode = AspectRatioMode.fit,
  });

  double get progressFraction =>
      duration.inMilliseconds == 0
          ? 0.0
          : (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);

  bool get hasNext => currentIndex < queue.length - 1;
  bool get hasPrevious => currentIndex > 0;
  bool get isPlaying => status == PlayerStatus.playing;

  VideoPlayerState copyWith({
    PlayerStatus? status,
    VideoEntity? currentVideo,
    List<VideoEntity>? queue,
    int? currentIndex,
    Duration? position,
    Duration? duration,
    double? playbackSpeed,
    double? volume,
    double? brightness,
    bool? isControlsVisible,
    bool? isLocked,
    String? errorMessage,
    String? subtitlePath,
    bool? isFullscreen,
    AspectRatioMode? aspectRatioMode,
  }) =>
      VideoPlayerState(
        status: status ?? this.status,
        currentVideo: currentVideo ?? this.currentVideo,
        queue: queue ?? this.queue,
        currentIndex: currentIndex ?? this.currentIndex,
        position: position ?? this.position,
        duration: duration ?? this.duration,
        playbackSpeed: playbackSpeed ?? this.playbackSpeed,
        volume: volume ?? this.volume,
        brightness: brightness ?? this.brightness,
        isControlsVisible: isControlsVisible ?? this.isControlsVisible,
        isLocked: isLocked ?? this.isLocked,
        errorMessage: errorMessage ?? this.errorMessage,
        subtitlePath: subtitlePath ?? this.subtitlePath,
        isFullscreen: isFullscreen ?? this.isFullscreen,
        aspectRatioMode: aspectRatioMode ?? this.aspectRatioMode,
      );
}

// ── Notifier ───────────────────────────────────────────────────────────────

class VideoPlayerNotifier extends StateNotifier<VideoPlayerState> {
  final Player _player;
  final VideoController controller;
  final SavePlaybackPosition _savePosition;
  final RecordVideoPlay _markAsPlayed;

  Timer? _controlsTimer;
  Timer? _positionSaveTimer;
  StreamSubscription? _positionSub;
  StreamSubscription? _durationSub;
  StreamSubscription? _statusSub;
  StreamSubscription? _completedSub;

  VideoPlayerNotifier({
    required Player player,
    required VideoController videoController,
    required SavePlaybackPosition savePosition,
    required RecordVideoPlay markAsPlayed,
  })  : _player = player,
        controller = videoController,
        _savePosition = savePosition,
        _markAsPlayed = markAsPlayed,
        super(const VideoPlayerState()) {
    _subscribeToPlayer();
  }

  void _subscribeToPlayer() {
    _positionSub = _player.stream.position.listen((position) {
      state = state.copyWith(position: position);
    });

    _durationSub = _player.stream.duration.listen((duration) {
      state = state.copyWith(duration: duration);
    });

    _statusSub = _player.stream.playing.listen((playing) {
      if (!mounted) return;
      state = state.copyWith(
        status: playing ? PlayerStatus.playing : PlayerStatus.paused,
      );
    });

    _completedSub = _player.stream.completed.listen((completed) {
      if (completed) _onVideoCompleted();
    });

    // Save playback position every 5 seconds while playing.
    _positionSaveTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      final video = state.currentVideo;
      if (video != null && state.isPlaying) {
        _savePosition(SavePlaybackPositionParams(
          videoPath: video.filePath,
          positionMs: state.position.inMilliseconds,
        ));
      }
    });
  }

  // ── Playback Control ──────────────────────────────────────────────────────
  Future<void> savePosition(String videoPath, int positionMs) async {
    await _savePosition(SavePlaybackPositionParams(
      videoPath: videoPath,
      positionMs: positionMs,
    ));
  }

  Future<void> openVideo(VideoEntity video, {List<VideoEntity>? queue}) async {
    state = state.copyWith(
      status: PlayerStatus.loading,
      currentVideo: video,
      queue: queue ?? [video],
      currentIndex: queue?.indexOf(video) ?? 0,
      errorMessage: null,
    );

    try {
      await _player.open(Media(video.filePath));

      // Resume from last position if available.
      if (video.lastPositionMs != null && video.lastPositionMs! > 0) {
        await _player.seek(Duration(milliseconds: video.lastPositionMs!));
      }

      await _markAsPlayed(RecordVideoPlayParams(videoPath: video.filePath));
      showControls();
    } catch (e) {
      state = state.copyWith(
        status: PlayerStatus.error,
        errorMessage: 'Cannot play this file: ${e.toString()}',
      );
    }
  }

  Future<void> playPause() async {
    state.isPlaying ? await _player.pause() : await _player.play();
  }

  Future<void> seekTo(Duration position) => _player.seek(position);

  Future<void> seekForward([int seconds = 10]) async {
    final target = state.position + Duration(seconds: seconds);
    await _player.seek(target > state.duration ? state.duration : target);
  }

  Future<void> seekBackward([int seconds = 10]) async {
    final target = state.position - Duration(seconds: seconds);
    await _player.seek(target < Duration.zero ? Duration.zero : target);
  }

  Future<void> setSpeed(double speed) async {
    await _player.setRate(speed);
    state = state.copyWith(playbackSpeed: speed);
  }

  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume * 100);
    state = state.copyWith(volume: volume.clamp(0.0, 1.0));
  }

  void setBrightness(double brightness) {
    // Brightness is handled via platform channel in the widget layer.
    state = state.copyWith(brightness: brightness.clamp(0.0, 1.0));
  }

  // ── Queue Navigation ──────────────────────────────────────────────────────

  Future<void> playNext() async {
    if (!state.hasNext) return;
    final nextIndex = state.currentIndex + 1;
    // openVideo() يُعيّن currentIndex تلقائياً عبر queue.indexOf(video)
    await openVideo(state.queue[nextIndex], queue: state.queue);
  }

  Future<void> playPrevious() async {
    // If > 3 seconds in, restart current video instead.
    if (state.position.inSeconds > 3) {
      await _player.seek(Duration.zero);
      return;
    }
    if (!state.hasPrevious) return;
    final prevIndex = state.currentIndex - 1;
    await openVideo(state.queue[prevIndex], queue: state.queue);
  }

  // ── Controls Visibility ───────────────────────────────────────────────────

  void showControls() {
    state = state.copyWith(isControlsVisible: true);
    _resetControlsTimer();
  }

  void hideControls() {
    _controlsTimer?.cancel();
    state = state.copyWith(isControlsVisible: false);
  }

  void toggleControls() {
    state.isControlsVisible ? hideControls() : showControls();
  }

  void _resetControlsTimer() {
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 3), () {
      if (state.isPlaying && mounted) {
        state = state.copyWith(isControlsVisible: false);
      }
    });
  }

  // ── Subtitle ──────────────────────────────────────────────────────────────

  Future<void> loadSubtitle(String path) async {
    await _player.setSubtitleTrack(SubtitleTrack.uri(path));
    state = state.copyWith(subtitlePath: path);
  }

  // ── Screen Lock ───────────────────────────────────────────────────────────

  void toggleLock() => state = state.copyWith(isLocked: !state.isLocked);

  // ── Aspect Ratio ─────────────────────────────────────────────────────────

  void cycleAspectRatio() {
    const modes = AspectRatioMode.values;
    final nextIndex = (state.aspectRatioMode.index + 1) % modes.length;
    state = state.copyWith(aspectRatioMode: modes[nextIndex]);
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  void _onVideoCompleted() {
    if (state.hasNext) {
      playNext();
    } else {
      state = state.copyWith(status: PlayerStatus.paused);
    }
  }

  @override
  void dispose() {
    _controlsTimer?.cancel();
    _positionSaveTimer?.cancel();
    _positionSub?.cancel();
    _durationSub?.cancel();
    _statusSub?.cancel();
    _completedSub?.cancel();
    _player.dispose();
    super.dispose();
  }
}

// ── Providers ─────────────────────────────────────────────────────────────

/// A single player instance scoped to the video player screen.
/// Disposed automatically when the screen is popped.
final videoPlayerProvider =
    StateNotifierProvider.autoDispose<VideoPlayerNotifier, VideoPlayerState>(
        (ref) {
  final player = Player();
  final controller = VideoController(player);

  return VideoPlayerNotifier(
    player: player,
    videoController: controller,
    savePosition: ref.watch(savePlaybackPositionProvider),
    markAsPlayed: ref.watch(markVideoAsPlayedProvider),
  );
});
