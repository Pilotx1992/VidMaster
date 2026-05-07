import 'package:flutter/material.dart';

/// Center play/pause with ±10s — LTR row for consistent layout.
class PlayerTransportControls extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final VoidCallback onReplay10;
  final VoidCallback onForward10;
  final double centerIconSize;

  const PlayerTransportControls({
    super.key,
    required this.isPlaying,
    required this.onPlayPause,
    required this.onReplay10,
    required this.onForward10,
    this.centerIconSize = 72,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            iconSize: 48,
            tooltip: 'Back 10 seconds',
            icon: const Icon(Icons.replay_10, color: Colors.white),
            onPressed: onReplay10,
          ),
          IconButton(
            iconSize: centerIconSize,
            tooltip: isPlaying ? 'Pause' : 'Play',
            icon: Icon(
              isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
              color: const Color(0xFFF9A825),
            ),
            onPressed: onPlayPause,
          ),
          IconButton(
            iconSize: 48,
            tooltip: 'Forward 10 seconds',
            icon: const Icon(Icons.forward_10, color: Colors.white),
            onPressed: onForward10,
          ),
        ],
      ),
    );
  }
}
