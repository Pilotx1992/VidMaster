// lib/features/video_player/domain/entities/video_playback_state.dart
import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart';
import 'subtitle_settings.dart';
import 'video_file.dart';

enum PlayerStatus    { idle, loading, playing, paused, buffering, completed, error }
enum PlayerError     { unsupportedFormat, corruptedFile, networkError, fileNotFound, unknown }
enum VideoAspectRatioMode { fit, fill, stretch, zoom }

@immutable
class VideoPlayerState {
  final PlayerStatus         status;
  final Duration             position;
  final Duration             duration;
  final double               volume;
  final double               brightness;
  final bool                 isLocked;
  final bool                 showControls;
  final VideoAspectRatioMode aspectRatioMode;
  final double               playbackSpeed;
  final SubtitleSettings     subtitleSettings;
  final List<SubtitleTrack>  availableSubtitleTracks;
  final SubtitleTrack?        activeSubtitleTrack;
  final bool                 isSubtitleSheetLoading;
  final VideoFile?           currentVideo;
  final PlayerError?         error;

  const VideoPlayerState({
    this.status                  = PlayerStatus.idle,
    this.position                = Duration.zero,
    this.duration                = Duration.zero,
    this.volume                  = 1.0,
    this.brightness              = 0.5,
    this.isLocked                = false,
    this.showControls            = false,
    this.aspectRatioMode         = VideoAspectRatioMode.fit,
    this.playbackSpeed           = 1.0,
    this.subtitleSettings        = SubtitleSettings.defaults,
    this.availableSubtitleTracks = const [],
    this.activeSubtitleTrack,
    this.isSubtitleSheetLoading  = false,
    this.currentVideo,
    this.error,
  });

  // ── Computed ───────────────────────────────────────────────
  bool get isPlaying    => status == PlayerStatus.playing;
  bool get isBuffering  => status == PlayerStatus.buffering;
  bool get hasError     => error != null;
  bool get isLiveStream => duration == Duration.zero;
  bool get canSeek      => !isLiveStream && duration > Duration.zero;

  // ── copyWith ───────────────────────────────────────────────
  VideoPlayerState copyWith({
    PlayerStatus?         status,
    Duration?             position,
    Duration?             duration,
    double?               volume,
    double?               brightness,
    bool?                 isLocked,
    bool?                 showControls,
    VideoAspectRatioMode? aspectRatioMode,
    double?               playbackSpeed,
    SubtitleSettings?     subtitleSettings,
    List<SubtitleTrack>?  availableSubtitleTracks,
    SubtitleTrack?        activeSubtitleTrack,
    bool?                 isSubtitleSheetLoading,
    VideoFile?            currentVideo,
    PlayerError?          error,
  }) =>
      VideoPlayerState(
        status:                  status                  ?? this.status,
        position:                position                ?? this.position,
        duration:                duration                ?? this.duration,
        volume:                  volume                  ?? this.volume,
        brightness:              brightness              ?? this.brightness,
        isLocked:                isLocked                ?? this.isLocked,
        showControls:            showControls            ?? this.showControls,
        aspectRatioMode:         aspectRatioMode         ?? this.aspectRatioMode,
        playbackSpeed:           playbackSpeed           ?? this.playbackSpeed,
        subtitleSettings:        subtitleSettings        ?? this.subtitleSettings,
        availableSubtitleTracks: availableSubtitleTracks ?? this.availableSubtitleTracks,
        activeSubtitleTrack:     activeSubtitleTrack     ?? this.activeSubtitleTrack,
        isSubtitleSheetLoading:  isSubtitleSheetLoading  ?? this.isSubtitleSheetLoading,
        currentVideo:            currentVideo            ?? this.currentVideo,
        error:                   error                   ?? this.error,
      );
}