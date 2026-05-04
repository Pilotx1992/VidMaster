import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../../domain/entities/video_file.dart';
import '../../domain/entities/video_playback_state.dart';
import '../../domain/entities/subtitle_settings.dart';
import '../../domain/repositories/resume_repository.dart';
import '../../domain/repositories/subtitle_preferences_repository.dart';
import '../../data/data_sources/video_engine.dart';
import 'subtitle_engine_provider.dart';

class VideoPlayerNotifier extends StateNotifier<VideoPlayerState> {
  final VideoEngine                   _engine;
  final ResumeRepository              _resumeRepo;
  final SubtitlePreferencesRepository _subtitlePrefsRepo;
  final Ref                           _ref;

  final List<StreamSubscription> _subscriptions = [];

  VideoPlayerNotifier({
    required VideoEngine                   engine,
    required ResumeRepository              resumeRepo,
    required SubtitlePreferencesRepository subtitlePrefsRepo,
    required Ref                           ref,
  })  : _engine            = engine,
        _resumeRepo        = resumeRepo,
        _subtitlePrefsRepo = subtitlePrefsRepo,
        _ref               = ref,
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
      if (mounted) state = state.copyWith(position: pos);
    }));
    _subscriptions.add(_engine.player.stream.duration.listen((dur) {
      if (mounted) state = state.copyWith(duration: dur);
    }));
    _subscriptions.add(_engine.player.stream.playing.listen((playing) {
      if (mounted) state = state.copyWith(status: playing ? PlayerStatus.playing : PlayerStatus.paused);
    }));
    _subscriptions.add(_engine.player.stream.buffering.listen((buffering) {
      if (mounted && buffering) state = state.copyWith(status: PlayerStatus.buffering);
    }));
    _subscriptions.add(_engine.player.stream.track.listen((track) {
      if (mounted) state = state.copyWith(activeSubtitleTrack: track.subtitle);
    }));
    _subscriptions.add(_engine.player.stream.tracks.listen((tracks) {
      if (mounted) state = state.copyWith(availableSubtitleTracks: tracks.subtitle);
    }));
  }

  Future<void> openVideo(VideoFile video) async {
    if (state.currentVideo?.path == video.path) {
      play();
      return;
    }

    state = state.copyWith(status: PlayerStatus.loading, currentVideo: video);
    
    await _engine.pause();
    
    final savedPosition = await _resumeRepo.loadPosition(video.path);
    await _engine.open(Media(video.path));
    
    if (savedPosition != null && savedPosition > Duration.zero) {
      await _engine.seek(savedPosition);
    }
    
    await _engine.play();
  }

  Future<void> play() async => _engine.play();
  Future<void> pause() async => _engine.pause();
  Future<void> seek(Duration pos) async => _engine.seek(pos);

  // 🔥 RESTORED: Needed for UI and stability
  Future<void> setSubtitleTrack(SubtitleTrack track) async {
    await _engine.setSubtitleTrack(track);
    // Persist if it's an external track (id usually contains the path for URI tracks)
    final isExternal = track.id.contains('/') || track.id.contains('\\') || track.id.startsWith('http');
    if (isExternal && state.currentVideo != null) {
      await _subtitlePrefsRepo.saveExternalTrackPath(state.currentVideo!.path, track.id);
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
    state = state.copyWith(showControls: !state.showControls);
  }

  void toggleLockMode() {
    state = state.copyWith(isLocked: !state.isLocked, showControls: false);
  }

  @override
  void dispose() {
    for (var sub in _subscriptions) {
      sub.cancel();
    }
    super.dispose();
  }
}