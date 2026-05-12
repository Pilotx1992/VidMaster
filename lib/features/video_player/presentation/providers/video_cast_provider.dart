import 'dart:async';

import 'package:flutter_chrome_cast/flutter_chrome_cast.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/video_cast_session.dart';

final videoCastSessionProvider = Provider<VideoCastSession>((ref) {
  final session = VideoCastSession();
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
