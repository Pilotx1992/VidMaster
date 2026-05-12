import 'dart:async';
import 'dart:io';

import 'package:flutter_chrome_cast/flutter_chrome_cast.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vidmaster/features/video_player/data/services/local_media_server.dart';
import 'package:vidmaster/features/video_player/data/services/video_cast_session.dart';
import 'package:vidmaster/features/video_player/domain/entities/video_file.dart';

void main() {
  group('VideoCastSession', () {
    test('rejects unsupported platforms before touching server', () async {
      final server = _FakeLocalMediaServer();
      final client = _FakeVideoCastClient(platformSupported: false);
      final session = VideoCastSession(
        mediaServer: server,
        castClient: client,
      );

      final result = await session.castVideo(
        const VideoFile(path: '/tmp/movie.mp4', name: 'Movie'),
      );

      expect(result.isFailure, isTrue);
      expect(
        result.failureReason,
        VideoCastFailureReason.unsupportedPlatform,
      );
      expect(server.startCalls, 0);
      expect(server.registerCalls, 0);
      expect(client.loadCalls, 0);
    });

    test('rejects incompatible containers before registration', () async {
      final server = _FakeLocalMediaServer();
      final client = _FakeVideoCastClient();
      final session = VideoCastSession(
        mediaServer: server,
        castClient: client,
      );

      final result = await session.castVideo(
        const VideoFile(path: '/tmp/movie.mkv', name: 'Movie'),
      );

      expect(result.isFailure, isTrue);
      expect(result.failureReason, VideoCastFailureReason.incompatibleMedia);
      expect(server.registerCalls, 0);
      expect(client.loadCalls, 0);
    });

    test('registers local media and loads Cast media information', () async {
      final server = _FakeLocalMediaServer();
      final client = _FakeVideoCastClient();
      final session = VideoCastSession(
        mediaServer: server,
        castClient: client,
      );

      final result = await session.castVideo(
        const VideoFile(path: '/tmp/movie.mp4', name: 'Movie'),
        startPosition: const Duration(seconds: 12),
        duration: const Duration(minutes: 2),
      );

      expect(result.isSuccess, isTrue);
      expect(server.startCalls, 1);
      expect(server.registerCalls, 1);
      expect(client.loadCalls, 1);
      expect(client.loadedMedia?.contentId, 'http://127.0.0.1:1234/v/token1');
      expect(client.loadedMedia?.contentUrl,
          Uri.parse(client.loadedMedia!.contentId));
      expect(client.loadedMedia?.contentType, 'video/mp4');
      expect(client.loadedMedia?.streamType, CastMediaStreamType.buffered);
      expect(client.loadedMedia?.duration, const Duration(minutes: 2));
      expect(client.loadedPlayPosition, const Duration(seconds: 12));
      expect(session.activeTicket?.token, 'token1');
    });

    test('clamps negative and beyond-duration start positions', () async {
      final server = _FakeLocalMediaServer();
      final client = _FakeVideoCastClient();
      final session = VideoCastSession(
        mediaServer: server,
        castClient: client,
      );

      await session.castVideo(
        const VideoFile(path: '/tmp/movie.mp4', name: 'Movie'),
        startPosition: const Duration(seconds: -5),
      );
      expect(client.loadedPlayPosition, Duration.zero);

      await session.castVideo(
        const VideoFile(path: '/tmp/movie.mp4', name: 'Movie'),
        startPosition: const Duration(minutes: 5),
        duration: const Duration(minutes: 2),
      );
      expect(client.loadedPlayPosition, const Duration(minutes: 2));
    });

    test('unregisters newly registered ticket when load fails', () async {
      final server = _FakeLocalMediaServer();
      final client = _FakeVideoCastClient(loadError: StateError('load failed'));
      final session = VideoCastSession(
        mediaServer: server,
        castClient: client,
      );

      final result = await session.castVideo(
        const VideoFile(path: '/tmp/movie.mp4', name: 'Movie'),
      );

      expect(result.isFailure, isTrue);
      expect(result.failureReason, VideoCastFailureReason.loadFailed);
      expect(server.unregisteredTokens, ['token1']);
      expect(session.activeTicket, isNull);
    });
  });
}

class _FakeLocalMediaServer extends LocalMediaServer {
  bool running = false;
  int startCalls = 0;
  int stopCalls = 0;
  int registerCalls = 0;
  final List<String> unregisteredTokens = [];

  @override
  bool get isRunning => running;

  @override
  Future<void> start() async {
    startCalls += 1;
    running = true;
  }

  @override
  Future<void> stop() async {
    stopCalls += 1;
    running = false;
  }

  @override
  Future<MediaTicket> register(
    String filePath, {
    Duration? ttl,
  }) async {
    if (!running) {
      throw StateError('LocalMediaServer.register() called before start().');
    }
    if (filePath.endsWith('missing.mp4')) {
      throw FileSystemException('Source file not found', filePath);
    }

    registerCalls += 1;
    return MediaTicket(
      token: 'token$registerCalls',
      url: 'http://127.0.0.1:1234/v/token$registerCalls',
      mimeType: filePath.endsWith('.webm') ? 'video/webm' : 'video/mp4',
      sizeBytes: 1024,
    );
  }

  @override
  void unregister(String token) {
    unregisteredTokens.add(token);
  }
}

class _FakeVideoCastClient implements VideoCastClient {
  final bool platformSupported;
  final Object? loadError;

  int loadCalls = 0;
  GoogleCastMediaInformation? loadedMedia;
  bool? loadedAutoPlay;
  Duration? loadedPlayPosition;

  _FakeVideoCastClient({
    this.platformSupported = true,
    this.loadError,
  });

  @override
  bool get isPlatformSupported => platformSupported;

  @override
  bool get hasConnectedSession => true;

  @override
  GoogleCastConnectState get connectionState =>
      GoogleCastConnectState.connected;

  @override
  Stream<GoogleCastSession?> get sessionStream =>
      const Stream<GoogleCastSession?>.empty();

  @override
  Stream<List<GoogleCastDevice>> get devicesStream =>
      Stream<List<GoogleCastDevice>>.value(const <GoogleCastDevice>[]);

  @override
  Future<bool> startSessionWithDevice(GoogleCastDevice device) async => true;

  @override
  Future<bool> endSession() async => true;

  @override
  Future<bool> endSessionAndStopCasting() async => true;

  @override
  Future<void> loadMedia(
    GoogleCastMediaInformation mediaInformation, {
    required bool autoPlay,
    required Duration playPosition,
  }) async {
    loadCalls += 1;
    if (loadError != null) throw loadError!;
    loadedMedia = mediaInformation;
    loadedAutoPlay = autoPlay;
    loadedPlayPosition = playPosition;
  }

  @override
  Future<void> pause() async {}

  @override
  Future<void> play() async {}

  @override
  Future<void> seek(Duration position) async {}

  @override
  Future<void> stop() async {}
}
