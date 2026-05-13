import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:vidmaster/features/video_player/domain/entities/video_file.dart';
import '../../../music_player/presentation/providers/music_player_provider.dart';
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
    0.25,
    0.5,
    0.75,
    1.0,
    1.25,
    1.5,
    2.0,
    3.0,
    4.0,
  ];

  final List<StreamSubscription> _subscriptions = [];
  DateTime? _lastResumeSaveAt;
  Duration? _lastSavedPosition;
  bool _resumeSaveInFlight = false;
  Timer? _controlsAutoHideTimer;
  bool _autoHidePaused = false;
  static const Duration _controlsAutoHideDelay = Duration(seconds: 3);

  /// Last `playing` value from [Player.stream.playing] (avoids buffering overwriting playing).
  bool _playingFromStream = false;

  /// Monotonic counter that identifies the in-flight call to [openVideo].
  /// Every awaited step inside the open flow re-checks `gen != _openGeneration`
  /// before mutating state or calling the engine; that way two near-simultaneous
  /// opens cannot interleave their `pause → open → seek → play` sequences.
  int _openGeneration = 0;

  /// `true` from the moment we decide to swap the media source until media_kit
  /// has accepted the new one. Stream listeners check this flag and skip
  /// state-mutating writes during this window so that lingering events from the
  /// previous source cannot leak into the new video's state (e.g. writing the
  /// old position under the new `currentVideo.path` and corrupting resume).
  bool _isSwitchingSource = false;

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
      // Drop position events while the source is being swapped — they belong
      // to the previous media item and would otherwise corrupt resume save
      // or trip the loading-overlay defensive predicate for the new video.
      if (_isSwitchingSource) return;

      var nextStatus = state.status;
      if (state.status == PlayerStatus.buffering &&
          _playingFromStream &&
          pos > Duration.zero) {
        nextStatus = PlayerStatus.playing;
      } else if (state.status == PlayerStatus.loading && pos > Duration.zero) {
        nextStatus =
            _playingFromStream ? PlayerStatus.playing : PlayerStatus.paused;
      }

      state = state.copyWith(position: pos, status: nextStatus);
      unawaited(_saveResumePositionIfNeeded(pos));
    }));
    _subscriptions.add(_engine.player.stream.duration.listen((dur) {
      if (!mounted) return;
      if (_isSwitchingSource) return;
      state = state.copyWith(duration: dur);
    }));
    _subscriptions.add(_engine.player.stream.playing.listen((playing) {
      if (!mounted) return;
      // We still want to track `_playingFromStream` for later (used right
      // after the switch completes), but we must not let `playing=false` from
      // the outgoing source overwrite the new video's `loading` status.
      _playingFromStream = playing;
      if (_isSwitchingSource) return;
      state = state.copyWith(
        status: playing ? PlayerStatus.playing : PlayerStatus.paused,
      );
      if (playing) {
        _scheduleControlsAutoHide();
      } else {
        _cancelControlsAutoHide();
      }
    }));
    _subscriptions.add(_engine.player.stream.buffering.listen((buffering) {
      if (!mounted) return;
      if (_isSwitchingSource) return;
      if (buffering) {
        if (!state.isPlaying &&
            state.status != PlayerStatus.loading &&
            state.status != PlayerStatus.error) {
          state = state.copyWith(status: PlayerStatus.buffering);
          _cancelControlsAutoHide();
        }
      } else if (state.status == PlayerStatus.buffering) {
        state = state.copyWith(
          status:
              _playingFromStream ? PlayerStatus.playing : PlayerStatus.paused,
        );
        if (_playingFromStream) {
          _scheduleControlsAutoHide();
        }
      }
    }));
    _subscriptions.add(_engine.player.stream.error.listen((error) {
      // ignore: avoid_print
      print('[VideoPlayer] player stream error: $error');
      if (!mounted) return;
      // An error during a source swap is almost always the outgoing media's
      // EOF / "interrupted" — surfacing it as the new video's error would
      // be wrong. Ignore until the swap settles.
      if (_isSwitchingSource) return;
      state = state.copyWith(
        status: PlayerStatus.error,
        error: PlayerError.unknown,
      );
    }));
    _subscriptions.add(_engine.player.stream.track.listen((track) {
      if (!mounted) return;
      if (_isSwitchingSource) return;
      state = state.copyWith(activeSubtitleTrack: track.subtitle);
    }));
    _subscriptions.add(_engine.player.stream.tracks.listen((tracks) {
      if (!mounted) return;
      if (_isSwitchingSource) return;
      state = state.copyWith(availableSubtitleTracks: tracks.subtitle);
    }));
    // Auto-advance when a queue is active. When no queue (or at end), settle
    // into the existing PlayerStatus.completed slot so the UI shows the play
    // button (isPlaying = false) and resume save still works.
    _subscriptions.add(_engine.player.stream.completed.listen((completed) {
      if (!mounted) return;
      if (!completed) return;
      if (_isSwitchingSource) return;
      // Defensive: some sources transiently emit completed=true before the
      // first frame is decoded (e.g. during initial probing). Require both a
      // real position and a real duration so we only treat genuine EOF as
      // "ended". The Phase 4 switching gate already blocks events during the
      // open swap; these two checks cover the pre-first-frame edge case.
      if (state.position <= Duration.zero) return;
      if (state.duration <= Duration.zero) return;
      if (state.hasNext) {
        unawaited(playNext());
      } else {
        state = state.copyWith(status: PlayerStatus.completed);
      }
    }));
  }

  Future<void> openVideo(
    VideoFile video, {
    List<VideoFile>? queue,
  }) async {
    // Resolve the queue + index up-front so both the same-path fast path and
    // the full-swap path agree on what queue the player is currently bound to.
    final resolvedQueue = queue ?? state.queue;
    final resolvedIndex = resolvedQueue.isEmpty
        ? -1
        : resolvedQueue.indexWhere((v) => v.path == video.path);

    if (kDebugMode) {
      final firstNames = resolvedQueue
          .take(10)
          .map((v) => v.name)
          .join(' | ');
      debugPrint(
        '[QueueOpen] video=${video.name} index=$resolvedIndex '
        'len=${resolvedQueue.length} '
        'queuePassed=${queue != null} '
        'queueIdentity=${identityHashCode(resolvedQueue)}',
      );
      debugPrint('[QueueOpen] queue=$firstNames');
    }

    // Fast path: same media item already loaded — just (re)play.
    if (state.currentVideo?.path == video.path) {
      if (queue != null) {
        // A caller (library tap, mini-player) handed us a fresh queue for the
        // same currently-loaded video; refresh queue/index without touching
        // the engine.
        state = state.copyWith(
          queue: resolvedQueue,
          queueIndex: resolvedIndex,
        );
      }
      await play();
      try {
        await _engine.setPlaybackSpeed(state.playbackSpeed);
      } catch (_) {}
      showControls();
      return;
    }

    // Full source swap — assign a new generation token and snapshot the
    // outgoing media identity BEFORE any state mutation so a late stream
    // event cannot write the previous video's position under the new
    // currentVideo.path.
    final gen = ++_openGeneration;
    final previousVideo = state.currentVideo;
    final previousPosition = state.position;

    // Explicit resume save for the OUTGOING video. We do NOT call
    // _saveResumePositionIfNeeded here because that helper reads
    // state.currentVideo, which we're about to overwrite.
    if (previousVideo != null && previousPosition > Duration.zero) {
      try {
        await _resumeRepo.savePosition(previousVideo.path, previousPosition);
        _lastSavedPosition = previousPosition;
        _lastResumeSaveAt = DateTime.now();
      } catch (_) {
        // Resume save is best-effort; never block the open path on it.
      }
    }
    if (gen != _openGeneration || !mounted) return;

    final platformBrightness = await _readPlatformBrightness();
    if (gen != _openGeneration || !mounted) return;

    // Engage the switching gate BEFORE the loading-state mutation so that any
    // position/duration events still in flight from the outgoing source are
    // dropped (see the listener guards in _initStreams).
    _isSwitchingSource = true;

    state = state.copyWith(
      status: PlayerStatus.loading,
      currentVideo: video,
      queue: resolvedQueue,
      queueIndex: resolvedIndex,
      position: Duration.zero,
      duration: Duration.zero,
      brightness: platformBrightness ?? state.brightness,
      isLocked: false,
      showControls: true,
      clearError: true,
      playbackSpeed: 1.0,
    );
    _playingFromStream = false;
    // Reset the resume bookkeeping for the new video so the throttled save
    // doesn't think the new position is "close enough" to the previous save.
    _lastSavedPosition = null;
    _lastResumeSaveAt = null;

    try {
      await _engine.pause();
      if (gen != _openGeneration || !mounted) return;

      // media_kit expects a URI-like string; use file:// for local paths.
      final file = File(video.path);
      if (!await file.exists()) {
        if (gen == _openGeneration && mounted) {
          state = state.copyWith(
              status: PlayerStatus.error, error: PlayerError.fileNotFound);
        }
        return;
      }
      if (gen != _openGeneration || !mounted) return;

      final savedPosition = await _resumeRepo.loadPosition(video.path);
      if (gen != _openGeneration || !mounted) return;

      final uri = Uri.file(video.path).toString();
      // ignore: avoid_print
      print('[VideoPlayer] open: $uri');
      await _engine.open(Media(uri));
      if (gen != _openGeneration || !mounted) return;

      // The new source is accepted by media_kit; release the gate so its
      // position/duration/tracks/playing streams can drive state again.
      _isSwitchingSource = false;

      if (savedPosition != null && savedPosition > Duration.zero) {
        await _engine.seek(savedPosition);
        if (gen != _openGeneration || !mounted) return;
      }

      // Pause any music BEFORE engaging the video engine so the two players
      // never overlap audibly even for a frame. The fast-path (same source)
      // already gets this via `play()`.
      _pauseMusicIfPlaying();
      await _engine.play();
      if (gen != _openGeneration || !mounted) return;
      await _engine.setPlaybackSpeed(state.playbackSpeed);
      if (gen != _openGeneration || !mounted) return;
      _scheduleControlsAutoHide();
    } catch (e, st) {
      // ignore: avoid_print
      print('[VideoPlayer] open failed: $e');
      // ignore: avoid_print
      print(st);
      if (gen == _openGeneration && mounted) {
        state = state.copyWith(
            status: PlayerStatus.error, error: PlayerError.unknown);
      }
    } finally {
      // Safety net: if anything above bailed before we cleared the flag,
      // ensure the latest generation always re-opens the listener gate.
      if (gen == _openGeneration) {
        _isSwitchingSource = false;
      }
    }
  }

  /// Open the next item in [VideoPlayerState.queue]. No-op when [hasNext] is
  /// false, so it's safe for callers to invoke without first checking.
  Future<void> playNext() async {
    if (!state.hasNext) return;
    final queue = state.queue;
    final nextIndex = state.queueIndex + 1;
    final next = queue[nextIndex];
    if (kDebugMode) {
      final firstNames = queue.take(10).map((v) => v.name).join(' | ');
      debugPrint(
        '[QueueNext] currentVideo=${state.currentVideo?.name} '
        'currentIndex=${state.queueIndex} target=$nextIndex '
        'targetVideo=${next.name} len=${queue.length}',
      );
      debugPrint('[QueueNext] queue=$firstNames');
    }
    await openVideo(next, queue: queue);
    bumpControlsAutoHide();
  }

  /// Open the previous item in [VideoPlayerState.queue]. No-op when
  /// [hasPrevious] is false.
  Future<void> playPrevious() async {
    if (!state.hasPrevious) return;
    final queue = state.queue;
    final prevIndex = state.queueIndex - 1;
    final prev = queue[prevIndex];
    if (kDebugMode) {
      final firstNames = queue.take(10).map((v) => v.name).join(' | ');
      debugPrint(
        '[QueuePrev] currentVideo=${state.currentVideo?.name} '
        'currentIndex=${state.queueIndex} target=$prevIndex '
        'targetVideo=${prev.name} len=${queue.length}',
      );
      debugPrint('[QueuePrev] queue=$firstNames');
    }
    await openVideo(prev, queue: queue);
    bumpControlsAutoHide();
  }

  void replaceVideoReferences({
    required String originalPath,
    required VideoFile updatedVideo,
  }) {
    final updatedQueue = state.queue
        .map((video) => video.path == originalPath ? updatedVideo : video)
        .toList(growable: false);
    final updatedCurrentVideo = state.currentVideo?.path == originalPath
        ? updatedVideo
        : state.currentVideo;

    var updatedQueueIndex = state.queueIndex;
    if (updatedQueue.isEmpty) {
      updatedQueueIndex = -1;
    } else if (updatedCurrentVideo != null) {
      final matchedIndex = updatedQueue.indexWhere(
        (video) => video.path == updatedCurrentVideo.path,
      );
      if (matchedIndex >= 0) {
        updatedQueueIndex = matchedIndex;
      }
    }

    state = state.copyWith(
      currentVideo: updatedCurrentVideo,
      queue: updatedQueue,
      queueIndex: updatedQueueIndex,
    );
  }

  Future<void> play() async {
    _pauseMusicIfPlaying();
    await _engine.play();
    showControls();
  }

  /// Best-effort audio-focus: when this video starts producing sound, the
  /// music player must not keep playing on top of it. Read-and-toggle is
  /// idempotent (no-op if music is already paused/empty) and fire-and-forget
  /// so a slow audio_service round-trip never blocks the video open path.
  /// Wrapped in a try/catch because if the music provider isn't bound yet
  /// (cold-start, first run before music tab was ever visited) reading it
  /// can throw, and we don't want to abort video playback over that.
  void _pauseMusicIfPlaying() {
    try {
      final musicState = _ref.read(musicPlayerProvider);
      if (!musicState.isPlaying) return;
      unawaited(_ref.read(musicPlayerProvider.notifier).playPause());
    } catch (_) {}
  }

  Future<void> pause() async {
    await _engine.pause();
    await _saveResumePositionIfNeeded(state.position, force: true);
    showControls();
  }

  bool _isTogglingPlayback = false;

  Future<void> togglePlayPause() async {
    if (_isTogglingPlayback) return;
    if (state.hasError) return;

    _isTogglingPlayback = true;
    final wasPlaying = state.isPlaying;

    try {
      if (wasPlaying) {
        await pause();
      } else {
        await play();
      }
    } finally {
      _isTogglingPlayback = false;
    }
  }

  Future<void> seek(Duration pos, {bool revealControls = true}) async {
    await _engine.seek(pos);
    await _saveResumePositionIfNeeded(pos, force: true);
    if (revealControls) showControls();
  }

  Future<void> setVolume(double value) async {
    final clamped = value.clamp(0.0, 1.0).toDouble();
    final previous = state.volume;
    state = state.copyWith(volume: clamped);
    _maybeEdgeHaptic(previous, clamped);
    await _engine.setVolume(clamped);
  }

  Future<void> setBrightness(double value) async {
    final clamped = value.clamp(0.0, 1.0).toDouble();
    final previous = state.brightness;
    state = state.copyWith(brightness: clamped);
    _maybeEdgeHaptic(previous, clamped);
    await _brightnessService?.setBrightness(clamped);
  }

  /// Fires a light haptic *only* on the transition from a non-edge value to
  /// either 0% or 100%. This gives a tactile "wall" cue when scrubbing volume
  /// or brightness via the gesture layer, without spamming taps that already
  /// sit at the edges (e.g. repeated mute toggles).
  static const double _edgeEpsilon = 1e-3;
  void _maybeEdgeHaptic(double previous, double next) {
    final wasAtMax = previous >= 1.0 - _edgeEpsilon;
    final wasAtMin = previous <= 0.0 + _edgeEpsilon;
    final isAtMax = next >= 1.0 - _edgeEpsilon;
    final isAtMin = next <= 0.0 + _edgeEpsilon;
    if ((isAtMax && !wasAtMax) || (isAtMin && !wasAtMin)) {
      HapticFeedback.selectionClick();
    }
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
        _autoHidePaused ||
        state.status != PlayerStatus.playing) {
      return;
    }

    _controlsAutoHideTimer = Timer(_controlsAutoHideDelay, () {
      if (!mounted || state.isLocked || _autoHidePaused) return;
      state = state.copyWith(showControls: false);
    });
  }

  void _cancelControlsAutoHide() {
    _controlsAutoHideTimer?.cancel();
    _controlsAutoHideTimer = null;
  }

  /// Reset the auto-hide countdown without flipping visibility. Used by every
  /// user interaction on visible controls (slider, speed, aspect, mute, lock,
  /// transport) so that the panel doesn't disappear while the user is actively
  /// engaging with it.
  void bumpControlsAutoHide() {
    if (!mounted || state.isLocked || !state.showControls) return;
    _scheduleControlsAutoHide();
  }

  /// Suspend auto-hide entirely. Used during slider drag so the panel cannot
  /// disappear mid-drag (we never want the thumb to vanish under the finger).
  /// Must be paired with [resumeControlsAutoHide].
  void pauseControlsAutoHide() {
    _autoHidePaused = true;
    _cancelControlsAutoHide();
  }

  /// Resume auto-hide after a previous [pauseControlsAutoHide]. Re-arms the
  /// countdown if controls are still showing and we're in a playing state.
  void resumeControlsAutoHide() {
    if (!_autoHidePaused) return;
    _autoHidePaused = false;
    _scheduleControlsAutoHide();
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
