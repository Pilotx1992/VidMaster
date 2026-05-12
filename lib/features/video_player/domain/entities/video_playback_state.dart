// lib/features/video_player/domain/entities/video_playback_state.dart
import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart';
import 'subtitle_settings.dart';
import 'video_file.dart';

// Empty queue sentinel keeps the default const-able and lets us
// distinguish "no queue plumbed" from "queue length 0 (impossible)".
const List<VideoFile> _emptyQueue = <VideoFile>[];

enum PlayerStatus {
  idle,
  loading,
  playing,
  paused,
  buffering,
  completed,
  error
}

enum PlayerError {
  unsupportedFormat,
  corruptedFile,
  networkError,
  fileNotFound,
  unknown
}

enum VideoAspectRatioMode { fit, fill, stretch, zoom }

@immutable
class VideoPlayerState {
  final PlayerStatus status;
  final Duration position;
  final Duration duration;
  final double volume;
  final double brightness;
  final bool isLocked;
  final bool showControls;
  final VideoAspectRatioMode aspectRatioMode;
  final double playbackSpeed;
  final SubtitleSettings subtitleSettings;
  final List<SubtitleTrack> availableSubtitleTracks;
  final SubtitleTrack? activeSubtitleTrack;
  final bool isSubtitleSheetLoading;
  final VideoFile? currentVideo;
  final PlayerError? error;

  /// Ordered list the player was opened with (post-filter/sort, as the user
  /// sees it in the library). Empty when no queue was plumbed (e.g. reopening
  /// from the mini-player without a queue).
  final List<VideoFile> queue;

  /// Index of [currentVideo] within [queue]. `-1` when no queue is active
  /// or when the current video can't be located in the queue (e.g. it was
  /// removed from the library after opening).
  final int queueIndex;

  const VideoPlayerState({
    this.status = PlayerStatus.idle,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.volume = 1.0,
    this.brightness = 0.5,
    this.isLocked = false,
    this.showControls = false,
    this.aspectRatioMode = VideoAspectRatioMode.fit,
    this.playbackSpeed = 1.0,
    this.subtitleSettings = SubtitleSettings.defaults,
    this.availableSubtitleTracks = const [],
    this.activeSubtitleTrack,
    this.isSubtitleSheetLoading = false,
    this.currentVideo,
    this.error,
    this.queue = _emptyQueue,
    this.queueIndex = -1,
  });

  // ── Computed ───────────────────────────────────────────────
  bool get isPlaying => status == PlayerStatus.playing;
  bool get isBuffering => status == PlayerStatus.buffering;
  bool get hasError => error != null;
  bool get isLiveStream => duration == Duration.zero;
  bool get canSeek => !isLiveStream && duration > Duration.zero;

  /// True when the queue has at least one entry after [queueIndex].
  bool get hasNext =>
      queueIndex >= 0 && queue.isNotEmpty && queueIndex < queue.length - 1;

  /// True when the queue has at least one entry before [queueIndex].
  bool get hasPrevious => queueIndex > 0 && queue.isNotEmpty;

  // ── copyWith ───────────────────────────────────────────────
  VideoPlayerState copyWith({
    PlayerStatus? status,
    Duration? position,
    Duration? duration,
    double? volume,
    double? brightness,
    bool? isLocked,
    bool? showControls,
    VideoAspectRatioMode? aspectRatioMode,
    double? playbackSpeed,
    SubtitleSettings? subtitleSettings,
    List<SubtitleTrack>? availableSubtitleTracks,
    SubtitleTrack? activeSubtitleTrack,
    bool? isSubtitleSheetLoading,
    VideoFile? currentVideo,
    PlayerError? error,
    List<VideoFile>? queue,
    int? queueIndex,
    bool clearCurrentVideo = false,
    bool clearError = false,
  }) =>
      VideoPlayerState(
        status: status ?? this.status,
        position: position ?? this.position,
        duration: duration ?? this.duration,
        volume: volume ?? this.volume,
        brightness: brightness ?? this.brightness,
        isLocked: isLocked ?? this.isLocked,
        showControls: showControls ?? this.showControls,
        aspectRatioMode: aspectRatioMode ?? this.aspectRatioMode,
        playbackSpeed: playbackSpeed ?? this.playbackSpeed,
        subtitleSettings: subtitleSettings ?? this.subtitleSettings,
        availableSubtitleTracks:
            availableSubtitleTracks ?? this.availableSubtitleTracks,
        activeSubtitleTrack: activeSubtitleTrack ?? this.activeSubtitleTrack,
        isSubtitleSheetLoading:
            isSubtitleSheetLoading ?? this.isSubtitleSheetLoading,
        currentVideo:
            clearCurrentVideo ? null : currentVideo ?? this.currentVideo,
        error: clearError ? null : error ?? this.error,
        queue: queue ?? this.queue,
        queueIndex: queueIndex ?? this.queueIndex,
      );
}
