import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/video_cast_provider.dart';
import '../providers/video_player_provider.dart';
import 'video_cast_device_picker.dart';

class VideoCastButton extends ConsumerWidget {
  const VideoCastButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isConnected = ref.watch(videoCastConnectedProvider);

    return IconButton(
      tooltip: isConnected ? 'Cast connected' : 'Cast',
      icon: Icon(
        isConnected ? Icons.cast_connected : Icons.cast,
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

    final video = ref.read(videoPlayerProvider).currentVideo;
    if (video == null) {
      _showSnackBar(context, 'No video is currently loaded.');
      return;
    }
    final warning = video.chromecastCompatibilityWarning;
    if (!video.isLikelyChromecastCompatible && warning != null) {
      _showSnackBar(context, warning);
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1C2B3A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const VideoCastDevicePicker(),
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
