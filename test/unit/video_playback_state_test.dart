import 'package:flutter_test/flutter_test.dart';
import 'package:vidmaster/features/video_player/domain/entities/subtitle_settings.dart';
import 'package:vidmaster/features/video_player/domain/entities/video_file.dart';
import 'package:vidmaster/features/video_player/domain/entities/video_playback_state.dart';

void main() {
  group('VideoPlayerState', () {
    test('default state has correct initial values', () {
      const state = VideoPlayerState();

      expect(state.status, PlayerStatus.idle);
      expect(state.position, Duration.zero);
      expect(state.duration, Duration.zero);
      expect(state.volume, 1.0);
      expect(state.brightness, 0.5);
      expect(state.isLocked, false);
      expect(state.showControls, false);
      expect(state.aspectRatioMode, VideoAspectRatioMode.fit);
      expect(state.playbackSpeed, 1.0);
      expect(state.subtitleSettings, SubtitleSettings.defaults);
      expect(state.availableSubtitleTracks, isEmpty);
      expect(state.activeSubtitleTrack, isNull);
      expect(state.isSubtitleSheetLoading, false);
      expect(state.currentVideo, isNull);
      expect(state.error, isNull);
      expect(state.isPlaying, false);
      expect(state.isBuffering, false);
      expect(state.hasError, false);
      expect(state.isLiveStream, true);
      expect(state.canSeek, false);
    });

    test('copyWith updates only provided fields', () {
      const original = VideoPlayerState(status: PlayerStatus.loading, volume: 0.2);
      final updated = original.copyWith(
        status: PlayerStatus.playing,
        volume: 0.8,
      );

      expect(updated.status, PlayerStatus.playing);
      expect(updated.volume, 0.8);
      expect(updated.position, original.position);
      expect(updated.brightness, original.brightness);
      expect(updated.showControls, original.showControls);
    });

    test('canSeek returns true when duration is greater than zero', () {
      const state = VideoPlayerState(duration: Duration(seconds: 100));
      expect(state.canSeek, true);
    });

    test('isPlaying and isBuffering reflect status', () {
      const playing = VideoPlayerState(status: PlayerStatus.playing);
      const buffering = VideoPlayerState(status: PlayerStatus.buffering);

      expect(playing.isPlaying, true);
      expect(playing.isBuffering, false);
      expect(buffering.isPlaying, false);
      expect(buffering.isBuffering, true);
    });

    test('copyWith can change currentVideo and error fields', () {
      const video = VideoFile(path: '/tmp/video.mp4', name: 'video', duration: Duration(minutes: 5));
      final state = const VideoPlayerState().copyWith(
        currentVideo: video,
        error: PlayerError.networkError,
      );

      expect(state.currentVideo, video);
      expect(state.error, PlayerError.networkError);
    });
  });
}
