import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../data/data_sources/video_engine.dart';
import '../../data/repositories/isar_resume_repository.dart';
import '../../data/repositories/isar_subtitle_preferences_repository.dart';
import '../../domain/entities/video_playback_state.dart';
import 'video_player_notifier.dart';

// Dependencies
final isarProvider = Provider<Isar>((ref) => throw UnimplementedError());
final videoEngineProvider = Provider<VideoEngine>((ref) => VideoEngine());
final resumeRepositoryProvider = Provider<IsarResumeRepository>((ref) {
  final isar = ref.watch(isarProvider);
  return IsarResumeRepository(isar);
});
final subtitlePreferencesRepositoryProvider = Provider<IsarSubtitlePreferencesRepository>((ref) {
  final isar = ref.watch(isarProvider);
  return IsarSubtitlePreferencesRepository(isar);
});

// Notifier
final videoPlayerProvider = StateNotifierProvider<VideoPlayerNotifier, VideoPlayerState>((ref) {
  final engine = ref.watch(videoEngineProvider);
  final resumeRepo = ref.watch(resumeRepositoryProvider);
  final subtitleRepo = ref.watch(subtitlePreferencesRepositoryProvider);

  return VideoPlayerNotifier(
    engine: engine,
    resumeRepo: resumeRepo,
    subtitlePrefsRepo: subtitleRepo,
    ref: ref,
  );
});
