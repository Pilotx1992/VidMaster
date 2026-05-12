import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_chrome_cast/flutter_chrome_cast.dart';

import '../../domain/entities/video_file.dart';
import 'local_media_server.dart';

enum VideoCastFailureReason {
  unsupportedPlatform,
  noActiveSession,
  incompatibleMedia,
  sourceFileMissing,
  localMediaServerUnavailable,
  sessionStartFailed,
  loadFailed,
  controlFailed,
}

@immutable
class VideoCastResult {
  final bool isSuccess;
  final String message;
  final VideoCastFailureReason? failureReason;
  final Object? error;

  const VideoCastResult({
    required this.isSuccess,
    required this.message,
    this.failureReason,
    this.error,
  });

  const VideoCastResult.success([String message = 'OK'])
      : this(isSuccess: true, message: message);

  const VideoCastResult.failure({
    required VideoCastFailureReason reason,
    required String message,
    Object? error,
  }) : this(
          isSuccess: false,
          message: message,
          failureReason: reason,
          error: error,
        );

  bool get isFailure => !isSuccess;
}

@immutable
class VideoCastLoadResult extends VideoCastResult {
  final MediaTicket? ticket;
  final GoogleCastMediaInformation? mediaInformation;

  const VideoCastLoadResult({
    required super.isSuccess,
    required super.message,
    super.failureReason,
    super.error,
    this.ticket,
    this.mediaInformation,
  });

  const VideoCastLoadResult.success({
    required MediaTicket ticket,
    required GoogleCastMediaInformation mediaInformation,
    String message = 'Video loaded on Cast receiver.',
  }) : this(
          isSuccess: true,
          message: message,
          ticket: ticket,
          mediaInformation: mediaInformation,
        );

  const VideoCastLoadResult.failure({
    required VideoCastFailureReason reason,
    required String message,
    Object? error,
  }) : this(
          isSuccess: false,
          message: message,
          failureReason: reason,
          error: error,
        );
}

abstract interface class VideoCastClient {
  bool get isPlatformSupported;
  bool get hasConnectedSession;
  GoogleCastConnectState get connectionState;
  Stream<GoogleCastSession?> get sessionStream;
  Stream<List<GoogleCastDevice>> get devicesStream;

  Future<bool> startSessionWithDevice(GoogleCastDevice device);
  Future<bool> endSession();
  Future<bool> endSessionAndStopCasting();
  Future<void> loadMedia(
    GoogleCastMediaInformation mediaInformation, {
    required bool autoPlay,
    required Duration playPosition,
  });
  Future<void> pause();
  Future<void> play();
  Future<void> seek(Duration position);
  Future<void> stop();
}

/// Thin adapter around `flutter_chrome_cast`.
///
/// The platform guards are deliberately here, not in UI code, so future callers
/// can ask the service for Cast capability without accidentally touching native
/// Cast channels on unsupported targets.
final class FlutterChromeVideoCastClient implements VideoCastClient {
  const FlutterChromeVideoCastClient();

  @override
  bool get isPlatformSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  bool get hasConnectedSession =>
      isPlatformSupported &&
      GoogleCastSessionManager.instance.hasConnectedSession;

  @override
  GoogleCastConnectState get connectionState => isPlatformSupported
      ? GoogleCastSessionManager.instance.connectionState
      : GoogleCastConnectState.disconnected;

  @override
  Stream<GoogleCastSession?> get sessionStream {
    if (!isPlatformSupported) return const Stream<GoogleCastSession?>.empty();
    return GoogleCastSessionManager.instance.currentSessionStream;
  }

  @override
  Stream<List<GoogleCastDevice>> get devicesStream {
    if (!isPlatformSupported) {
      return Stream<List<GoogleCastDevice>>.value(const <GoogleCastDevice>[]);
    }
    return GoogleCastDiscoveryManager.instance.devicesStream;
  }

  @override
  Future<bool> startSessionWithDevice(GoogleCastDevice device) {
    if (!isPlatformSupported) return Future<bool>.value(false);
    return GoogleCastSessionManager.instance.startSessionWithDevice(device);
  }

  @override
  Future<bool> endSession() {
    if (!isPlatformSupported) return Future<bool>.value(false);
    return GoogleCastSessionManager.instance.endSession();
  }

  @override
  Future<bool> endSessionAndStopCasting() {
    if (!isPlatformSupported) return Future<bool>.value(false);
    return GoogleCastSessionManager.instance.endSessionAndStopCasting();
  }

  @override
  Future<void> loadMedia(
    GoogleCastMediaInformation mediaInformation, {
    required bool autoPlay,
    required Duration playPosition,
  }) {
    if (!isPlatformSupported) return Future<void>.value();
    return GoogleCastRemoteMediaClient.instance.loadMedia(
      mediaInformation,
      autoPlay: autoPlay,
      playPosition: playPosition,
    );
  }

  @override
  Future<void> pause() {
    if (!isPlatformSupported) return Future<void>.value();
    return GoogleCastRemoteMediaClient.instance.pause();
  }

  @override
  Future<void> play() {
    if (!isPlatformSupported) return Future<void>.value();
    return GoogleCastRemoteMediaClient.instance.play();
  }

  @override
  Future<void> seek(Duration position) {
    if (!isPlatformSupported) return Future<void>.value();
    return GoogleCastRemoteMediaClient.instance.seek(
      GoogleCastMediaSeekOption(
        position: _nonNegativeDuration(position),
        resumeState: GoogleCastMediaResumeState.unchanged,
      ),
    );
  }

  @override
  Future<void> stop() {
    if (!isPlatformSupported) return Future<void>.value();
    return GoogleCastRemoteMediaClient.instance.stop();
  }
}

/// Service-layer abstraction for loading a local [VideoFile] onto a Cast
/// receiver.
///
/// This class intentionally does not own any UI. Future screens/providers can
/// use it for device discovery, session lifecycle, and remote media loading.
class VideoCastSession {
  final LocalMediaServer _mediaServer;
  final VideoCastClient _castClient;
  final Duration _registrationTtl;
  final bool _ownsMediaServer;

  MediaTicket? _activeTicket;

  VideoCastSession({
    LocalMediaServer? mediaServer,
    VideoCastClient? castClient,
    Duration registrationTtl = LocalMediaServer.defaultTtl,
  })  : _mediaServer = mediaServer ?? LocalMediaServer(),
        _castClient = castClient ?? const FlutterChromeVideoCastClient(),
        _registrationTtl = registrationTtl,
        _ownsMediaServer = mediaServer == null;

  bool get isPlatformSupported => _castClient.isPlatformSupported;

  bool get isConnected =>
      _castClient.hasConnectedSession ||
      _castClient.connectionState == GoogleCastConnectState.connected;

  Stream<GoogleCastSession?> get sessionStream => _castClient.sessionStream;

  Stream<List<GoogleCastDevice>> get devicesStream => _castClient.devicesStream;

  MediaTicket? get activeTicket => _activeTicket;

  Future<VideoCastResult> startSessionWithDevice(
    GoogleCastDevice device,
  ) async {
    if (!isPlatformSupported) {
      return const VideoCastResult.failure(
        reason: VideoCastFailureReason.unsupportedPlatform,
        message: 'Chromecast is only available on Android and iOS.',
      );
    }
    if (isConnected) {
      return const VideoCastResult.success('Cast session already connected.');
    }

    try {
      final started = await _castClient.startSessionWithDevice(device);
      if (!started) {
        return VideoCastResult.failure(
          reason: VideoCastFailureReason.sessionStartFailed,
          message: 'Unable to start Cast session with ${device.friendlyName}.',
        );
      }
      return VideoCastResult.success(
        'Cast session started with ${device.friendlyName}.',
      );
    } catch (e) {
      return VideoCastResult.failure(
        reason: VideoCastFailureReason.sessionStartFailed,
        message: 'Unable to start Cast session with ${device.friendlyName}.',
        error: e,
      );
    }
  }

  Future<VideoCastLoadResult> castVideo(
    VideoFile video, {
    Duration startPosition = Duration.zero,
    Duration? duration,
    bool autoPlay = true,
  }) async {
    if (!isPlatformSupported) {
      return const VideoCastLoadResult.failure(
        reason: VideoCastFailureReason.unsupportedPlatform,
        message: 'Chromecast is only available on Android and iOS.',
      );
    }
    if (!isConnected) {
      return const VideoCastLoadResult.failure(
        reason: VideoCastFailureReason.noActiveSession,
        message: 'No active Cast session.',
      );
    }
    if (!video.isLikelyChromecastCompatible) {
      return VideoCastLoadResult.failure(
        reason: VideoCastFailureReason.incompatibleMedia,
        message: video.chromecastCompatibilityWarning ??
            'This video format is unlikely to play on Chromecast.',
      );
    }

    late final MediaTicket ticket;
    try {
      ticket = await _registerVideo(video);
    } on FileSystemException catch (e) {
      return VideoCastLoadResult.failure(
        reason: VideoCastFailureReason.sourceFileMissing,
        message: 'Video file was not found.',
        error: e,
      );
    } on StateError catch (e) {
      return VideoCastLoadResult.failure(
        reason: VideoCastFailureReason.localMediaServerUnavailable,
        message: e.message,
        error: e,
      );
    } catch (e) {
      return VideoCastLoadResult.failure(
        reason: VideoCastFailureReason.localMediaServerUnavailable,
        message: 'Unable to prepare local media server.',
        error: e,
      );
    }

    final mediaInformation = _buildMediaInformation(
      video: video,
      ticket: ticket,
      duration: duration,
    );
    final playPosition = _clampStartPosition(startPosition, duration);

    try {
      await _castClient.loadMedia(
        mediaInformation,
        autoPlay: autoPlay,
        playPosition: playPosition,
      );

      _replaceActiveTicket(ticket);
      return VideoCastLoadResult.success(
        ticket: ticket,
        mediaInformation: mediaInformation,
      );
    } catch (e) {
      _unregisterTicket(ticket);
      return VideoCastLoadResult.failure(
        reason: VideoCastFailureReason.loadFailed,
        message: 'Unable to load video on Cast receiver.',
        error: e,
      );
    }
  }

  Future<VideoCastResult> pause() => _runRemoteControl(
        actionName: 'pause Cast playback',
        action: _castClient.pause,
      );

  Future<VideoCastResult> play() => _runRemoteControl(
        actionName: 'resume Cast playback',
        action: _castClient.play,
      );

  Future<VideoCastResult> seek(Duration position) => _runRemoteControl(
        actionName: 'seek Cast playback',
        action: () => _castClient.seek(_nonNegative(position)),
      );

  Future<VideoCastResult> stop() async {
    final result = await _runRemoteControl(
      actionName: 'stop Cast playback',
      action: _castClient.stop,
    );
    if (result.isSuccess) {
      _unregisterActiveTicket();
    }
    return result;
  }

  Future<VideoCastResult> disconnect({bool stopCasting = true}) async {
    if (!isPlatformSupported) {
      return const VideoCastResult.failure(
        reason: VideoCastFailureReason.unsupportedPlatform,
        message: 'Chromecast is only available on Android and iOS.',
      );
    }

    if (!isConnected) {
      if (stopCasting) {
        await _releaseActiveMedia(stopServerIfOwned: true);
      }
      return const VideoCastResult.success('No active Cast session.');
    }

    try {
      final ended = stopCasting
          ? await _castClient.endSessionAndStopCasting()
          : await _castClient.endSession();
      if (!ended) {
        return const VideoCastResult.failure(
          reason: VideoCastFailureReason.controlFailed,
          message: 'Unable to disconnect Cast session.',
        );
      }
      if (stopCasting) {
        await _releaseActiveMedia(stopServerIfOwned: true);
      }
      return const VideoCastResult.success('Cast session disconnected.');
    } catch (e) {
      return VideoCastResult.failure(
        reason: VideoCastFailureReason.controlFailed,
        message: 'Unable to disconnect Cast session.',
        error: e,
      );
    }
  }

  Future<void> dispose() async {
    await _releaseActiveMedia(stopServerIfOwned: true);
  }

  Future<MediaTicket> _registerVideo(VideoFile video) async {
    if (!_mediaServer.isRunning) {
      await _mediaServer.start();
    }
    return _mediaServer.register(video.path, ttl: _registrationTtl);
  }

  GoogleCastMediaInformation _buildMediaInformation({
    required VideoFile video,
    required MediaTicket ticket,
    required Duration? duration,
  }) {
    return GoogleCastMediaInformation(
      contentId: ticket.url,
      contentUrl: Uri.parse(ticket.url),
      streamType: CastMediaStreamType.buffered,
      contentType: ticket.mimeType,
      duration: duration,
      metadata: GoogleCastMovieMediaMetadata(
        title: video.name,
        subtitle: video.extension.toUpperCase(),
      ),
    );
  }

  Future<VideoCastResult> _runRemoteControl({
    required String actionName,
    required Future<void> Function() action,
  }) async {
    if (!isPlatformSupported) {
      return const VideoCastResult.failure(
        reason: VideoCastFailureReason.unsupportedPlatform,
        message: 'Chromecast is only available on Android and iOS.',
      );
    }
    if (!isConnected) {
      return const VideoCastResult.failure(
        reason: VideoCastFailureReason.noActiveSession,
        message: 'No active Cast session.',
      );
    }

    try {
      await action();
      return VideoCastResult.success('Successfully completed: $actionName.');
    } catch (e) {
      return VideoCastResult.failure(
        reason: VideoCastFailureReason.controlFailed,
        message: 'Unable to $actionName.',
        error: e,
      );
    }
  }

  void _replaceActiveTicket(MediaTicket ticket) {
    final previous = _activeTicket;
    _activeTicket = ticket;
    if (previous != null && previous.token != ticket.token) {
      _mediaServer.unregister(previous.token);
    }
  }

  void _unregisterActiveTicket() {
    _unregisterTicket(_activeTicket);
    _activeTicket = null;
  }

  void _unregisterTicket(MediaTicket? ticket) {
    if (ticket == null) return;
    _mediaServer.unregister(ticket.token);
  }

  Future<void> _releaseActiveMedia({required bool stopServerIfOwned}) async {
    _unregisterActiveTicket();
    if (stopServerIfOwned && _ownsMediaServer && _mediaServer.isRunning) {
      await _mediaServer.stop();
    }
  }

  static Duration _clampStartPosition(Duration value, Duration? duration) {
    final normalized = _nonNegative(value);
    if (duration == null || duration <= Duration.zero) return normalized;
    if (normalized > duration) return duration;
    return normalized;
  }

  static Duration _nonNegative(Duration value) {
    return _nonNegativeDuration(value);
  }
}

Duration _nonNegativeDuration(Duration value) {
  return value < Duration.zero ? Duration.zero : value;
}
