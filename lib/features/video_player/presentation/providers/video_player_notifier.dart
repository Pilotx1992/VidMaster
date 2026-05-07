import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../../domain/entities/video_file.dart';
import '../../domain/entities/video_playback_state.dart';
import '../../domain/entities/subtitle_settings.dart';
import '../../domain/repositories/resume_repository.dart';
import '../../domain/repositories/subtitle_preferences_repository.dart';
import '../../domain/services/platform_brightness_service.dart';
import '../../data/data_sources/video_engine.dart';
import 'subtitle_engine_provider.dart';

class VideoPlayerNotifier extends StateNotifier<VideoPlayerState> {
  final VideoEngine _engine;
  final ResumeRepository _resumeRepo;
  final SubtitlePreferencesRepository _subtitlePrefsRepo;
  final PlatformBrightnessService? _brightnessService;
  final Ref _ref;

  static const List<double> supportedPlaybackSpeeds = [
    0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 2.0, 3.0, 4.0,
  ];

  final List<StreamSubscription> _subscriptions = [];
  DateTime? _lastResumeSaveAt;
  Duration? _lastSavedPosition;
  bool _resumeSaveInFlight = false;
  Timer? _controlsAutoHideTimer;
  static const Duration _controlsAutoHideDelay = Duration(seconds: 3);

  VideoPlayerNotifier({
    required VideoEngine engine,
    required ResumeRepository resumeRepo,
    required SubtitlePreferencesRepository subtitlePrefsRepo,
    PlatformBrightnessService? brightnessService,
    required Ref ref,
  })  : _engine = engine,
        _resumeRepo = resumeRepo,
        _subtitlePrefsRepo = subtitlePrefsRepo,
        _brightnessService = brightnessService,
        _ref = ref,
        super(const VideoPlayerState()) {
    _initStreams();
    _listenToSubtitleSettings();
  }

  VideoController get controller => _engine.controller;

  void _listenToSubtitleSettings() {
    _ref.listen<SubtitleSettings>(subtitleEngineProvider, (prev, next) {
      if (prev?.syncOffset != next.syncOffset) {
        _engine.setSubtitleDelay(next.syncOffset);
      }
    });
  }

  void _initStreams() {
    _subscriptions.add(_engine.player.stream.position.listen((pos) {
      if (!mounted) return;
      state = state.copyWith(position: pos);
      unawaited(_saveResumePositionIfNeeded(pos));
    }));
    _subscriptions.add(_engine.player.stream.duration.listen((dur) {
      if (mounted) {
        state = state.copyWith(duration: dur);
      }
    }));
    _subscriptions.add(_engine.player.stream.playing.listen((playing) {
      if (mounted) {
        state = state.copyWith(
          status: playing ? PlayerStatus.playing : PlayerStatus.paused,
        );
        if (playing) {
          _scheduleControlsAutoHide();
        } else {
          _cancelControlsAutoHide();
        }
      }
    }));
    _subscriptions.add(_engine.player.stream.buffering.listen((buffering) {
      if (mounted && buffering) {
        state = state.copyWith(status: PlayerStatus.buffering);
        _cancelControlsAutoHide();
      }
    }));
    _subscriptions.add(_engine.player.stream.error.listen((error) {
      // ignore: avoid_print
      print('[VideoPlayer] player stream error: $error');
      if (mounted) {
        state = state.copyWith(
          status: PlayerStatus.error,
          error: PlayerError.unknown,
        );
      }
    }));
    _subscriptions.add(_engine.player.stream.track.listen((track) {
      if (mounted) {
        state = state.copyWith(activeSubtitleTrack: track.subtitle);
      }
    }));
    _subscriptions.add(_engine.player.stream.tracks.listen((tracks) {
      if (mounted) {
        state = state.copyWith(availableSubtitleTracks: tracks.subtitle);
      }
    }));
  }

  Future<void> openVideo(VideoFile video) async {
    if (state.currentVideo?.path == video.path) {
      await play();
      try {
        await _engine.setPlaybackSpeed(state.playbackSpeed);
      } catch (_) {}
      showControls();
      return;
    }

    await _saveResumePositionIfNeeded(state.position, force: true);
    final platformBrightness = await _readPlatformBrightness();

    state = state.copyWith(
      status: PlayerStatus.loading,
      currentVideo: video,
      position: Duration.zero,
      duration: Duration.zero,
      brightness: platformBrightness ?? state.brightness,
      isLocked: false,
      showControls: true,
      clearError: true,
      playbackSpeed: 1.0,
    );

    try {
      await _engine.pause();

      // media_kit expects a URI-like string; use file:// for local paths.
      final file = File(video.path);
      if (!await file.exists()) {
        state = state.copyWith(
            status: PlayerStatus.error, error: PlayerError.fileNotFound);
        return;
      }

      final savedPosition = await _resumeRepo.loadPosition(video.path);
      final uri = Uri.file(video.path).toString();
      // ignore: avoid_print
      print('[VideoPlayer] open: $uri');
      await _engine.open(Media(uri));

      if (savedPosition != null && savedPosition > Duration.zero) {
        await _engine.seek(savedPosition);
      }

      await _engine.play();
      await _engine.setPlaybackSpeed(state.playbackSpeed);
      _scheduleControlsAutoHide();
    } catch (e, st) {
      // ignore: avoid_print
      print('[VideoPlayer] open failed: $e');
      // ignore: avoid_print
      print(st);
      state = state.copyWith(
          status: PlayerStatus.error, error: PlayerError.unknown);
    }
  }

  Future<void> play() async {
    await _engine.play();
    showControls();
  }

  Future<void> pause() async {
    await _engine.pause();
    await _saveResumePositionIfNeeded(state.position, force: true);
    showControls();
  }

  Future<void> seek(Duration pos, {bool revealControls = true}) async {
    await _engine.seek(pos);
    await _saveResumePositionIfNeeded(pos, force: true);
    if (revealControls) showControls();
  }

  Future<void> setVolume(double value) async {
    final clamped = value.clamp(0.0, 1.0).toDouble();
    state = state.copyWith(volume: clamped);
    await _engine.setVolume(clamped);
  }

  Future<void> setBrightness(double value) async {
    final clamped = value.clamp(0.0, 1.0).toDouble();
    state = state.copyWith(brightness: clamped);
    await _brightnessService?.setBrightness(clamped);
  }

  Future<void> setPlaybackSpeed(double speed) async {
    final normalized = supportedPlaybackSpeeds.contains(speed) ? speed : 1.0;
    state = state.copyWith(playbackSpeed: normalized);
    try {
      await _engine.setPlaybackSpeed(normalized);
    } catch (_) {
      state = state.copyWith(playbackSpeed: 1.0);
      try {
        await _engine.setPlaybackSpeed(1.0);
      } catch (_) {}
    }
  }

  // 🔥 RESTORED: Needed for UI and stability
  Future<void> setSubtitleTrack(SubtitleTrack track) async {
    await _engine.setSubtitleTrack(track);
    // Persist if it's an external track (id usually contains the path for URI tracks)
    final isExternal = track.id.contains('/') ||
        track.id.contains('\\') ||
        track.id.startsWith('http');
    if (isExternal && state.currentVideo != null) {
      await _subtitlePrefsRepo.saveExternalTrackPath(
          state.currentVideo!.path, track.id);
    }
  }

  void cycleAspectRatio() {
    final nextMode = switch (state.aspectRatioMode) {
      VideoAspectRatioMode.fit => VideoAspectRatioMode.fill,
      VideoAspectRatioMode.fill => VideoAspectRatioMode.stretch,
      VideoAspectRatioMode.stretch => VideoAspectRatioMode.zoom,
      VideoAspectRatioMode.zoom => VideoAspectRatioMode.fit,
    };
    state = state.copyWith(aspectRatioMode: nextMode);
  }

  void toggleControls() {
    if (state.isLocked) return;
    state.showControls ? hideControls() : showControls();
  }

  void showControls() {
    if (state.isLocked) return;
    state = state.copyWith(showControls: true);
    _scheduleControlsAutoHide();
  }

  void hideControls() {
    _cancelControlsAutoHide();
    if (state.isLocked) return;
    state = state.copyWith(showControls: false);
  }

  void toggleLockMode() {
    _cancelControlsAutoHide();
    state = state.copyWith(isLocked: !state.isLocked, showControls: false);
  }

  @override
  void dispose() {
    _cancelControlsAutoHide();
    unawaited(_saveResumePositionIfNeeded(state.position, force: true));
    for (var sub in _subscriptions) {
      sub.cancel();
    }
    super.dispose();
  }

  Future<double?> _readPlatformBrightness() async {
    final brightnessService = _brightnessService;
    if (brightnessService == null) return null;

    try {
      return await brightnessService.getBrightness();
    } catch (_) {
      return null;
    }
  }

  void _scheduleControlsAutoHide() {
    _cancelControlsAutoHide();
    if (!mounted ||
        state.isLocked ||
        !state.showControls ||
        state.status != PlayerStatus.playing) {
      return;
    }

    _controlsAutoHideTimer = Timer(_controlsAutoHideDelay, () {
      if (!mounted || state.isLocked) return;
      state = state.copyWith(showControls: false);
    });
  }

  void _cancelControlsAutoHide() {
    _controlsAutoHideTimer?.cancel();
    _controlsAutoHideTimer = null;
  }

  Future<void> _saveResumePositionIfNeeded(
    Duration position, {
    bool force = false,
  }) async {
    final video = state.currentVideo;
    if (video == null || position <= Duration.zero) return;
    if (_resumeSaveInFlight) return;

    final now = DateTime.now();
    final lastSavedPosition = _lastSavedPosition;
    final lastSaveAt = _lastResumeSaveAt;
    final movedEnough = lastSavedPosition == null ||
        (position - lastSavedPosition).abs() >= const Duration(seconds: 5);
    final elapsedEnough = lastSaveAt == null ||
        now.difference(lastSaveAt) >= const Duration(seconds: 5);

    if (!force && (!movedEnough || !elapsedEnough)) return;

    _resumeSaveInFlight = true;
    try {
      await _resumeRepo.savePosition(video.path, position);
      _lastSavedPosition = position;
      _lastResumeSaveAt = now;
    } finally {
      _resumeSaveInFlight = false;
    }
  }
}
