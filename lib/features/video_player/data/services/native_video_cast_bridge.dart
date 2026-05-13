import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum NativeVideoCastConnectionState {
  unavailable,
  disconnected,
  connecting,
  connected,
  disconnecting,
  suspended,
  unknown,
}

@immutable
class NativeVideoCastSessionState {
  final bool isAvailable;
  final NativeVideoCastConnectionState connectionState;
  final bool isConnected;
  final String? platform;
  final String? deviceId;
  final String? deviceName;
  final String? sessionId;
  final int? errorCode;
  final String? error;

  const NativeVideoCastSessionState({
    required this.isAvailable,
    required this.connectionState,
    required this.isConnected,
    this.platform,
    this.deviceId,
    this.deviceName,
    this.sessionId,
    this.errorCode,
    this.error,
  });

  const NativeVideoCastSessionState.unavailable([String? error])
      : this(
          isAvailable: false,
          connectionState: NativeVideoCastConnectionState.unavailable,
          isConnected: false,
          error: error,
        );

  factory NativeVideoCastSessionState.fromMap(Map<Object?, Object?> map) {
    return NativeVideoCastSessionState(
      isAvailable: map['isAvailable'] == true,
      connectionState: _connectionStateFromValue(map['connectionState']),
      isConnected: map['isConnected'] == true,
      platform: map['platform'] as String?,
      deviceId: map['deviceId'] as String?,
      deviceName: map['deviceName'] as String?,
      sessionId: map['sessionId'] as String?,
      errorCode: map['errorCode'] as int?,
      error: map['error'] as String?,
    );
  }
}

class NativeVideoCastBridge {
  const NativeVideoCastBridge();

  static const MethodChannel _methodChannel = MethodChannel(
    'vidmaster/native_cast',
  );
  static const EventChannel _sessionEventChannel = EventChannel(
    'vidmaster/native_cast/session',
  );

  bool get isPlatformSupported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  Future<NativeVideoCastSessionState> getSessionState() async {
    if (!isPlatformSupported) {
      return const NativeVideoCastSessionState.unavailable(
        'Native Cast is only available on Android.',
      );
    }

    try {
      final value = await _methodChannel.invokeMapMethod<Object?, Object?>(
        'getSessionState',
      );
      return NativeVideoCastSessionState.fromMap(value ?? const {});
    } on MissingPluginException catch (e) {
      return NativeVideoCastSessionState.unavailable(e.message);
    } on PlatformException catch (e) {
      return NativeVideoCastSessionState.unavailable(e.message);
    }
  }

  Stream<NativeVideoCastSessionState> watchSessionState() async* {
    if (!isPlatformSupported) {
      yield const NativeVideoCastSessionState.unavailable(
        'Native Cast is only available on Android.',
      );
      return;
    }

    yield await getSessionState();

    yield* _sessionEventChannel.receiveBroadcastStream().map((event) {
      if (event is Map) {
        return NativeVideoCastSessionState.fromMap(
          event.cast<Object?, Object?>(),
        );
      }
      return const NativeVideoCastSessionState.unavailable(
        'Unexpected native Cast session event.',
      );
    });
  }
}

NativeVideoCastConnectionState _connectionStateFromValue(Object? value) {
  return switch (value) {
    'unavailable' => NativeVideoCastConnectionState.unavailable,
    'disconnected' => NativeVideoCastConnectionState.disconnected,
    'connecting' => NativeVideoCastConnectionState.connecting,
    'connected' => NativeVideoCastConnectionState.connected,
    'disconnecting' => NativeVideoCastConnectionState.disconnecting,
    'suspended' => NativeVideoCastConnectionState.suspended,
    _ => NativeVideoCastConnectionState.unknown,
  };
}
