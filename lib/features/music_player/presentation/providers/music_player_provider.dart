import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../../../../di.dart';
import '../../../video_player/presentation/providers/video_player_provider.dart';
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

  double get progressFraction => duration.inMilliseconds == 0
      ? 0.0
      : (position.inMilliseconds / duration.inMilliseconds)
          .clamp(0.0, 1.0)
          .toDouble();

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
    bool clearCurrentTrack = false,
    bool clearSleepTimer = false,
  }) =>
      MusicPlayerState(
        currentTrack:
            clearCurrentTrack ? null : (currentTrack ?? this.currentTrack),
        queue: queue ?? this.queue,
        currentIndex: currentIndex ?? this.currentIndex,
        position: position ?? this.position,
        duration: duration ?? this.duration,
        isPlaying: isPlaying ?? this.isPlaying,
        isLoading: isLoading ?? this.isLoading,
        repeatMode: repeatMode ?? this.repeatMode,
        shuffleMode: shuffleMode ?? this.shuffleMode,
        volume: volume ?? this.volume,
        sleepTimerRemaining: clearSleepTimer
            ? null
            : (sleepTimerRemaining ?? this.sleepTimerRemaining),
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
  final Ref _ref;

  Timer? _sleepTimer;
  Timer? _sleepCountdown;
  StreamSubscription? _positionSub;
  StreamSubscription? _durationSub;
  StreamSubscription? _playingSub;
  StreamSubscription? _currentIndexSub;
  bool _suppressIndexUpdates = false;

  MusicPlayerNotifier({
    required AudioPlayer player,
    required AudioHandler audioHandler,
    required RecordMusicPlay markAsPlayed,
    required Ref ref,
  })  : _player = player,
        _audioHandler = audioHandler,
        _markAsPlayed = markAsPlayed,
        _ref = ref,
        super(const MusicPlayerState()) {
    _subscribeToPlayer();
  }

  /// Symmetric counterpart of `VideoPlayerNotifier._pauseMusicIfPlaying`: when
  /// the user starts (or resumes) a music track, any active video must yield
  /// the audio output. Fire-and-forget; never blocks the music open path.
  void _pauseVideoIfPlaying() {
    try {
      final videoState = _ref.read(videoPlayerProvider);
      if (!videoState.isPlaying) return;
      unawaited(_ref.read(videoPlayerProvider.notifier).pause());
    } catch (_) {}
  }

  void _subscribeToPlayer() {
    _player.playingStream.listen((playing) {
      // Music playback is handled by the dedicated music handler
    });

    _positionSub = _player.positionStream
        .listen((p) => state = state.copyWith(position: p));

    _durationSub = _player.durationStream
        .listen((d) => state = state.copyWith(duration: d ?? Duration.zero));

    _playingSub = _player.playingStream
        .listen((playing) => state = state.copyWith(isPlaying: playing));

    _currentIndexSub = _player.currentIndexStream.listen((index) async {
      if (_suppressIndexUpdates) return;
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

    final sources = tracks.map((t) => _createAudioSource(t.filePath)).toList();

    await _player.setAudioSource(
      ConcatenatingAudioSource(children: sources),
      initialIndex: startIndex,
    );

    _pauseVideoIfPlaying();
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

  Future<void> playPause() async {
    if (state.isPlaying) {
      await _player.pause();
    } else {
      _pauseVideoIfPlaying();
      await _player.play();
    }
  }

  /// Stops playback and hides the mini player (clears current track + queue).
  Future<void> stopAndClear() async {
    _suppressIndexUpdates = true;
    try {
      await _player.stop();
    } catch (_) {
      // ignore
    }
    state = state.copyWith(
      clearCurrentTrack: true,
      queue: const [],
      currentIndex: 0,
      position: Duration.zero,
      duration: Duration.zero,
      isPlaying: false,
      isLoading: false,
      errorMessage: null,
      clearSleepTimer: true,
    );
    // Allow streams to settle before accepting index updates again.
    Future.delayed(const Duration(milliseconds: 200), () {
      _suppressIndexUpdates = false;
    });
  }

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
    final volume = v.clamp(0.0, 1.0).toDouble();
    await _player.setVolume(volume);
    state = state.copyWith(volume: volume);
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
      artUri:
          track.albumArtPath != null ? _safeFileUri(track.albumArtPath!) : null,
    ));
  }

  // ── Library ────────────────────────────────────────────────────────────────

  Future<void> addToQueue(AudioTrackEntity track) async {
    final updated = [...state.queue, track];
    state = state.copyWith(queue: updated);
    final src = _player.audioSource as ConcatenatingAudioSource?;
    await src?.add(_createAudioSource(track.filePath));
  }

  Future<void> playNext(AudioTrackEntity track) async {
    if (state.queue.isEmpty || state.currentTrack == null) {
      await playTrack(track);
      return;
    }

    final source = _player.audioSource as ConcatenatingAudioSource?;
    final currentIndex = state.currentIndex.clamp(0, state.queue.length - 1);
    final updatedQueue = [...state.queue];
    final existingIndex =
        updatedQueue.indexWhere((t) => t.filePath == track.filePath);

    var insertIndex = currentIndex + 1;

    if (existingIndex >= 0) {
      final existingTrack = updatedQueue.removeAt(existingIndex);
      if (existingIndex < insertIndex) {
        insertIndex -= 1;
      }
      updatedQueue.insert(insertIndex, existingTrack);
      if (source == null) {
        await playQueue(updatedQueue, startIndex: currentIndex);
        return;
      }
      state = state.copyWith(queue: updatedQueue);
      await source.move(existingIndex, insertIndex);
      return;
    }

    updatedQueue.insert(insertIndex, track);
    if (source == null) {
      await playQueue(updatedQueue, startIndex: currentIndex);
      return;
    }
    state = state.copyWith(queue: updatedQueue);
    await source.insert(insertIndex, _createAudioSource(track.filePath));
  }

  void refreshTrackMetadata(
    AudioTrackEntity updatedTrack, {
    String? originalFilePath,
  }) {
    final matchPath = originalFilePath ?? updatedTrack.filePath;
    final updatedQueue = state.queue
        .map((track) => track.filePath == matchPath ? updatedTrack : track)
        .toList(growable: false);
    final updatedCurrentTrack = state.currentTrack?.filePath == matchPath
        ? updatedTrack
        : state.currentTrack;

    state = state.copyWith(
      queue: updatedQueue,
      currentTrack: updatedCurrentTrack,
    );

    if (updatedCurrentTrack != null &&
        updatedCurrentTrack.filePath == updatedTrack.filePath) {
      _updateMediaItem(updatedTrack);
    }
  }

  Future<void> replaceTrackReferences(
    AudioTrackEntity updatedTrack, {
    required String originalFilePath,
  }) async {
    final hasMatchingQueueEntry = state.queue.any(
      (track) => track.filePath == originalFilePath,
    );
    final updatedQueue = state.queue
        .map((track) => track.filePath == originalFilePath ? updatedTrack : track)
        .toList(growable: false);
    final updatedCurrentTrack = state.currentTrack?.filePath == originalFilePath
        ? updatedTrack
        : state.currentTrack;

    state = state.copyWith(
      queue: updatedQueue,
      currentTrack: updatedCurrentTrack,
    );

    if (updatedCurrentTrack != null &&
        updatedCurrentTrack.filePath == updatedTrack.filePath) {
      _updateMediaItem(updatedTrack);
    }

    if (!hasMatchingQueueEntry || updatedQueue.isEmpty) {
      return;
    }

    final resumePlayback = state.isPlaying;
    final restoreIndex = state.currentIndex.clamp(0, updatedQueue.length - 1);
    final restorePosition = state.position;

    _suppressIndexUpdates = true;
    try {
      if (resumePlayback) {
        await _player.pause();
      }

      await _player.setAudioSource(
        ConcatenatingAudioSource(
          children: updatedQueue
              .map((track) => _createAudioSource(track.filePath))
              .toList(growable: false),
        ),
        initialIndex: restoreIndex,
        initialPosition: restorePosition,
      );

      if (resumePlayback) {
        _pauseVideoIfPlaying();
        await _player.play();
      }
    } catch (error) {
      state = state.copyWith(
        errorMessage: 'Could not refresh the renamed track in the queue.',
      );
    } finally {
      Future.delayed(const Duration(milliseconds: 200), () {
        _suppressIndexUpdates = false;
      });
    }
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
    ref: ref,
  );
});
