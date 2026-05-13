import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vidmaster/features/video_player/domain/entities/video_file.dart';

import '../providers/video_cast_provider.dart';
import 'native_video_cast_button.dart';
import 'video_cast_device_picker.dart';

class VideoCastButton extends ConsumerWidget {
  final VideoFile? video;
  final Duration position;
  final Duration duration;
  final FutureOr<void> Function() onCastStarted;
  final bool useDarkNativeIcon;

  const VideoCastButton({
    super.key,
    required this.video,
    required this.position,
    required this.duration,
    required this.onCastStarted,
    this.useDarkNativeIcon = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      ref.watch(nativeVideoCastSessionStateProvider);
      return SizedBox(
        width: 40,
        height: 40,
        child: NativeVideoCastButton(
          iconStyle: useDarkNativeIcon
              ? NativeVideoCastIconStyle.dark
              : NativeVideoCastIconStyle.light,
        ),
      );
    }

    final isConnected = ref.watch(videoCastConnectedProvider);

    return IconButton(
      tooltip: isConnected ? 'Cast connected' : 'Cast',
      icon: Icon(
        isConnected ? Symbols.cast_connected : Symbols.cast,
        color: isConnected ? const Color(0xFFF9A825) : Colors.white,
      ),
      onPressed: () => _openDevicePicker(context, ref),
    );
  }

  void _openDevicePicker(BuildContext context, WidgetRef ref) {
    final castSession = ref.read(videoCastSessionProvider);
    if (!castSession.isPlatformSupported) {
      _showSnackBar(
          context, 'Chromecast is only available on Android and iOS.');
      return;
    }

    final currentVideo = video;
    if (currentVideo == null) {
      _showSnackBar(context, 'No video is currently loaded.');
      return;
    }
    if (!currentVideo.isLikelyChromecastCompatible) {
      _showSnackBar(
        context,
        currentVideo.chromecastCompatibilityWarning ??
            'This video format is unlikely to play on Chromecast.',
      );
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1C2B3A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => VideoCastDevicePicker(
        video: currentVideo,
        position: position,
        duration: duration,
        onCastStarted: onCastStarted,
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
  }
}
