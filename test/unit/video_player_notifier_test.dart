import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:media_kit/media_kit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vidmaster/features/video_player/data/data_sources/video_engine.dart';
import 'package:vidmaster/features/video_player/domain/entities/subtitle_settings.dart' as domain;
import 'package:vidmaster/features/video_player/domain/entities/video_file.dart';
import 'package:vidmaster/features/video_player/domain/entities/video_playback_state.dart';
import 'package:vidmaster/features/video_player/domain/repositories/resume_repository.dart';
import 'package:vidmaster/features/video_player/domain/repositories/subtitle_preferences_repository.dart';
import 'package:vidmaster/features/video_player/presentation/providers/video_player_notifier.dart';

class MockVideoEngine extends Mock implements VideoEngine {}
class MockPlayer extends Mock implements Player {}
class MockPlayerStream extends Mock implements PlayerStream {}
class MockResumeRepository extends Mock implements ResumeRepository {}
class MockSubtitlePreferencesRepository extends Mock implements SubtitlePreferencesRepository {}
class MockRef extends Mock implements Ref {}
class MockProviderSubscription extends Mock implements ProviderSubscription<domain.SubtitleSettings> {}

void main() {
  late MockVideoEngine mockEngine;
  late MockPlayer mockPlayer;
  late MockPlayerStream mockPlayerStream;
  late MockResumeRepository mockResumeRepo;
  late MockSubtitlePreferencesRepository mockSubtitlePrefsRepo;
  late MockRef mockRef;

  setUpAll(() {
    registerFallbackValue(Media('file:///tmp/video.mp4'));
    registerFallbackValue(SubtitleTrack.no());
    registerFallbackValue(const Duration());
    registerFallbackValue(const domain.SubtitleSettings());
  });

  setUp(() {
    mockEngine = MockVideoEngine();
    mockPlayer = MockPlayer();
    mockPlayerStream = MockPlayerStream();
    mockResumeRepo = MockResumeRepository();
    mockSubtitlePrefsRepo = MockSubtitlePreferencesRepository();
    mockRef = MockRef();

    when(() => mockEngine.player).thenReturn(mockPlayer);
    when(() => mockPlayer.stream).thenReturn(mockPlayerStream);
    when(() => mockPlayerStream.duration).thenAnswer((_) => const Stream<Duration>.empty());
    when(() => mockPlayerStream.position).thenAnswer((_) => const Stream<Duration>.empty());
    when(() => mockPlayerStream.playing).thenAnswer((_) => const Stream<bool>.empty());
    when(() => mockPlayerStream.completed).thenAnswer((_) => const Stream<bool>.empty());
    when(() => mockPlayerStream.buffering).thenAnswer((_) => const Stream<bool>.empty());
    when(() => mockPlayerStream.error).thenAnswer((_) => const Stream<String>.empty());
    when(() => mockPlayerStream.tracks).thenAnswer((_) => const Stream<Tracks>.empty());
    when(() => mockPlayerStream.track).thenAnswer((_) => const Stream<Track>.empty());
    
    // Mock ref.listen to avoid errors
    when(() => mockRef.listen<domain.SubtitleSettings>(any(), any())).thenReturn(MockProviderSubscription());
  });

  group('VideoPlayerNotifier', () {
    test('setAspectRatio updates the state', () async {
      final notifier = VideoPlayerNotifier(
        engine: mockEngine,
        resumeRepo: mockResumeRepo,
        subtitlePrefsRepo: mockSubtitlePrefsRepo,
        ref: mockRef,
      );

      notifier.cycleAspectRatio(); // Test the restored method

      expect(notifier.state.aspectRatioMode, isNot(VideoAspectRatioMode.fit));
    });

    test('openVideo restores persisted external subtitle track before playback', () async {
      const video = VideoFile(path: '/tmp/video.mp4', name: 'video', duration: Duration.zero);
      when(() => mockEngine.open(any())).thenAnswer((_) async {});
      when(() => mockResumeRepo.loadPosition(video.path)).thenAnswer((_) async => Duration.zero);
      when(() => mockEngine.setSubtitleTrack(any())).thenAnswer((_) async {});
      when(() => mockEngine.play()).thenAnswer((_) async {});
      when(() => mockEngine.pause()).thenAnswer((_) async {});

      final notifier = VideoPlayerNotifier(
        engine: mockEngine,
        resumeRepo: mockResumeRepo,
        subtitlePrefsRepo: mockSubtitlePrefsRepo,
        ref: mockRef,
      );

      await notifier.openVideo(video);

      verify(() => mockEngine.play()).called(1);
    });

    test('setSubtitleTrack persists URI-based external track path for current video', () async {
      const video = VideoFile(path: '/tmp/video.mp4', name: 'video', duration: Duration.zero);
      final notifier = VideoPlayerNotifier(
        engine: mockEngine,
        resumeRepo: mockResumeRepo,
        subtitlePrefsRepo: mockSubtitlePrefsRepo,
        ref: mockRef,
      );

      notifier.state = notifier.state.copyWith(currentVideo: video);
      when(() => mockSubtitlePrefsRepo.saveExternalTrackPath(video.path, '/tmp/subtitles.srt'))
          .thenAnswer((_) async {});

      await notifier.setSubtitleTrack(SubtitleTrack.uri('/tmp/subtitles.srt'));

      verify(() => mockSubtitlePrefsRepo.saveExternalTrackPath(video.path, '/tmp/subtitles.srt')).called(1);
    });
  });
}
