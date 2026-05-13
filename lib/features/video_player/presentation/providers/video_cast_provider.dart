import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_chrome_cast/flutter_chrome_cast.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/local_media_server.dart';
import '../../data/services/native_video_cast_bridge.dart';
import '../../data/services/video_cast_session.dart';

final localMediaServerProvider = Provider<LocalMediaServer>((ref) {
  final server = LocalMediaServer();
  ref.onDispose(() {
    unawaited(server.stop());
  });
  return server;
});

final videoCastSessionProvider = Provider<VideoCastSession>((ref) {
  final mediaServer = ref.watch(localMediaServerProvider);
  final session = VideoCastSession(mediaServer: mediaServer);
  ref.onDispose(() {
    unawaited(session.dispose());
  });
  return session;
});

final videoCastDevicesProvider = StreamProvider<List<GoogleCastDevice>>((ref) {
  final session = ref.watch(videoCastSessionProvider);
  if (!session.isPlatformSupported) {
    return Stream<List<GoogleCastDevice>>.value(const <GoogleCastDevice>[]);
  }
  return session.devicesStream;
});

final videoCastSessionStreamProvider =
    StreamProvider<GoogleCastSession?>((ref) {
  final session = ref.watch(videoCastSessionProvider);
  if (!session.isPlatformSupported) {
    return const Stream<GoogleCastSession?>.empty();
  }
  return session.sessionStream;
});

final videoCastConnectedProvider = Provider<bool>((ref) {
  final session = ref.watch(videoCastSessionProvider);
  final streamedSession = ref.watch(videoCastSessionStreamProvider);
  return session.isConnected ||
      streamedSession.valueOrNull?.connectionState ==
          GoogleCastConnectState.connected;
});

final nativeVideoCastBridgeProvider = Provider<NativeVideoCastBridge>((ref) {
  return const NativeVideoCastBridge();
});

final nativeVideoCastSessionStateProvider =
    StreamProvider<NativeVideoCastSessionState>((ref) {
  return ref.watch(nativeVideoCastBridgeProvider).watchSessionState().map(
    (state) {
      if (kDebugMode) {
        debugPrint(
          '[NativeCast] session state=${state.connectionState.name} '
          'device=${state.deviceName ?? '-'}',
        );
      }
      return state;
    },
  );
});

final nativeVideoCastConnectedProvider = Provider<bool>((ref) {
  return ref
          .watch(nativeVideoCastSessionStateProvider)
          .valueOrNull
          ?.isConnected ??
      false;
});
