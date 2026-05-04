import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../../../../di.dart';
import '../../domain/entities/audio_track_entity.dart';
import '../../domain/usecases/music_usecases.dart';

// ── State ──────────────────────────────────────────────────────────────────

class MusicPlayerState {
  final AudioTrackEntity? currentTrack;
  final List<AudioTrackEntity> queue;
  final int currentIndex;
  final Duration position;
  final Duration duration;
  final bool isPlaying;
  final bool isLoading;
  final RepeatMode repeatMode;
  final ShuffleMode shuffleMode;
  final double volume;
  final Duration? sleepTimerRemaining;
  final String? errorMessage;

  const MusicPlayerState({
    this.currentTrack,
    this.queue = const [],
    this.currentIndex = 0,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.isPlaying = false,
    this.isLoading = false,
    this.repeatMode = RepeatMode.off,
    this.shuffleMode = ShuffleMode.off,
    this.volume = 1.0,
    this.sleepTimerRemaining,
    this.errorMessage,
  });

  double get progressFraction =>
      duration.inMilliseconds == 0
          ? 0.0
          : (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);

  bool get hasNext => currentIndex < queue.length - 1;
  bool get hasPrevious => currentIndex > 0;
  bool get hasSleepTimer => sleepTimerRemaining != null;

  MusicPlayerState copyWith({
    AudioTrackEntity? currentTrack,
    List<AudioTrackEntity>? queue,
    int? currentIndex,
    Duration? position,
    Duration? duration,
    bool? isPlaying,
    bool? isLoading,
    RepeatMode? repeatMode,
    ShuffleMode? shuffleMode,
    double? volume,
    Duration? sleepTimerRemaining,
    String? errorMessage,
    bool clearSleepTimer = false,
  }) =>
      MusicPlayerState(
        currentTrack: currentTrack ?? this.currentTrack,
        queue: queue ?? this.queue,
        currentIndex: currentIndex ?? this.currentIndex,
        position: position ?? this.position,
        duration: duration ?? this.duration,
        isPlaying: isPlaying ?? this.isPlaying,
        isLoading: isLoading ?? this.isLoading,
        repeatMode: repeatMode ?? this.repeatMode,
        shuffleMode: shuffleMode ?? this.shuffleMode,
        volume: volume ?? this.volume,
        sleepTimerRemaining:
            clearSleepTimer ? null : (sleepTimerRemaining ?? this.sleepTimerRemaining),
        errorMessage: errorMessage ?? this.errorMessage,
      );
}

enum RepeatMode { off, repeatOne, repeatAll }
enum ShuffleMode { off, on }

// ── Notifier ───────────────────────────────────────────────────────────────

class MusicPlayerNotifier extends StateNotifier<MusicPlayerState> {
  final AudioPlayer _player;
  final AudioHandler _audioHandler;
  final RecordMusicPlay _markAsPlayed;

  Timer? _sleepTimer;
  Timer? _sleepCountdown;
  StreamSubscription? _positionSub;
  StreamSubscription? _durationSub;
  StreamSubscription? _playingSub;
  StreamSubscription? _currentIndexSub;

  MusicPlayerNotifier({
    required AudioPlayer player,
    required AudioHandler audioHandler,
    required RecordMusicPlay markAsPlayed,
  })  : _player = player,
        _audioHandler = audioHandler,
        _markAsPlayed = markAsPlayed,
        super(const MusicPlayerState()) {
    _subscribeToPlayer();
  }

  void _subscribeToPlayer() {
    _player.playingStream.listen((playing) {
      // Music playback is handled by the dedicated music handler
    });

    _positionSub =
        _player.positionStream.listen((p) => state = state.copyWith(position: p));

    _durationSub = _player.durationStream.listen(
        (d) => state = state.copyWith(duration: d ?? Duration.zero));

    _playingSub = _player.playingStream
        .listen((playing) => state = state.copyWith(isPlaying: playing));

    _currentIndexSub = _player.currentIndexStream.listen((index) async {
      if (index == null || index >= state.queue.length) return;
      
      final track = state.queue[index];
      
      state = state.copyWith(currentTrack: track, currentIndex: index);
      _markAsPlayed(RecordMusicPlayParams(trackId: track.id));
      _updateMediaItem(track);
    });
  }

  // ── Playback ──────────────────────────────────────────────────────────────

  Future<void> playQueue(
    List<AudioTrackEntity> tracks, {
    int startIndex = 0,
  }) async {
    state = state.copyWith(isLoading: true, queue: tracks);

    final sources = tracks
        .map((t) => _createAudioSource(t.filePath))
        .toList();

    await _player.setAudioSource(
      ConcatenatingAudioSource(children: sources),
      initialIndex: startIndex,
    );

    await _player.play();
    state = state.copyWith(isLoading: false);
  }

  Future<void> playTrack(
    AudioTrackEntity track, {
    List<AudioTrackEntity>? queue,
  }) async {
    final q = queue ?? [track];
    final index = q.indexWhere((t) => t.id == track.id);
    await playQueue(q, startIndex: index < 0 ? 0 : index);
  }

  Future<void> playPause() =>
      state.isPlaying ? _player.pause() : _player.play();

  Future<void> next() => _player.seekToNext();

  Future<void> previous() async {
    if (state.position.inSeconds > 3) {
      await _player.seek(Duration.zero);
    } else {
      await _player.seekToPrevious();
    }
  }

  Future<void> seekTo(Duration position) => _player.seek(position);

  Future<void> setVolume(double v) async {
    await _player.setVolume(v.clamp(0.0, 1.0));
    state = state.copyWith(volume: v.clamp(0.0, 1.0));
  }

  // ── Modes ─────────────────────────────────────────────────────────────────

  Future<void> cycleRepeat() async {
    final next = switch (state.repeatMode) {
      RepeatMode.off => RepeatMode.repeatAll,
      RepeatMode.repeatAll => RepeatMode.repeatOne,
      RepeatMode.repeatOne => RepeatMode.off,
    };
    await _player.setLoopMode(switch (next) {
      RepeatMode.off => LoopMode.off,
      RepeatMode.repeatAll => LoopMode.all,
      RepeatMode.repeatOne => LoopMode.one,
    });
    state = state.copyWith(repeatMode: next);
  }

  Future<void> toggleShuffle() async {
    final on = state.shuffleMode == ShuffleMode.off;
    await _player.setShuffleModeEnabled(on);
    state = state.copyWith(
      shuffleMode: on ? ShuffleMode.on : ShuffleMode.off,
    );
  }

  // ── Sleep Timer ────────────────────────────────────────────────────────────

  void setSleepTimer(Duration duration) {
    _sleepTimer?.cancel();
    _sleepCountdown?.cancel();

    state = state.copyWith(sleepTimerRemaining: duration);

    _sleepCountdown = Timer.periodic(const Duration(seconds: 1), (_) {
      final remaining = state.sleepTimerRemaining;
      if (remaining == null || remaining.inSeconds <= 0) {
        _sleepTimer?.cancel();
        _sleepCountdown?.cancel();
        return;
      }
      state = state.copyWith(
        sleepTimerRemaining: remaining - const Duration(seconds: 1),
      );
    });

    _sleepTimer = Timer(duration, () {
      _player.pause();
      state = state.copyWith(clearSleepTimer: true);
    });
  }

  void cancelSleepTimer() {
    _sleepTimer?.cancel();
    _sleepCountdown?.cancel();
    state = state.copyWith(clearSleepTimer: true);
  }

  // ── Now Playing MediaItem sync for notification ────────────────────────────

  void _updateMediaItem(AudioTrackEntity track) {
    _audioHandler.updateMediaItem(MediaItem(
      id: track.filePath,
      title: track.title,
      artist: track.artist,
      album: track.album,
      duration: Duration(milliseconds: track.durationMs),
      artUri: track.albumArtPath != null
          ? _safeFileUri(track.albumArtPath!)
          : null,
    ));
  }

  // ── Library ────────────────────────────────────────────────────────────────

  Future<void> addToQueue(AudioTrackEntity track) async {
    final updated = [...state.queue, track];
    state = state.copyWith(queue: updated);
    final src = _player.audioSource as ConcatenatingAudioSource?;
    await src?.add(_createAudioSource(track.filePath));
  }

  /// Safely creates an AudioSource from a file path, handling platform-specific URI issues.
  AudioSource _createAudioSource(String path) {
    return AudioSource.uri(_safeFileUri(path));
  }

  /// Robustly creates a file URI. On Windows, ensures absolute paths have drive letters.
  Uri _safeFileUri(String path) {
    if (path.startsWith('http')) return Uri.parse(path);
    if (path.startsWith('file://')) return Uri.parse(path);
    
    // Use File.uri which is generally safer as it handles platform specifics
    try {
      return Uri.file(path);
    } catch (_) {
      // If Uri.file fails (e.g. missing drive letter on Windows), try to parse as is
      // or return a dummy URI to avoid crashing the entire app.
      return Uri.parse(path);
    }
  }

  @override
  void dispose() {
    _sleepTimer?.cancel();
    _sleepCountdown?.cancel();
    _positionSub?.cancel();
    _durationSub?.cancel();
    _playingSub?.cancel();
    _currentIndexSub?.cancel();
    _player.dispose();
    super.dispose();
  }
}

// ── Music Player Provider ──────────────────────────────────────────────────
//
// NOT autoDispose — scoped to app lifetime so background playback continues
// when NowPlayingScreen is popped.

final musicPlayerProvider =
    StateNotifierProvider<MusicPlayerNotifier, MusicPlayerState>((ref) {
  final player = ref.watch(audioPlayerProvider);
  final handler = ref.watch(audioHandlerProvider);
  final markPlayed = ref.watch(recordMusicPlayProvider);
  return MusicPlayerNotifier(
    player: player,
    audioHandler: handler,
    markAsPlayed: markPlayed,
  );
});
