import 'package:flutter/material.dart';

import 'player_control_helpers.dart';

/// replay_10 · play/pause · forward_10 — LTR, white side icons, accent play.
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
    // Keep ±10 clearly smaller than the main play/pause control.
    final skipSize = (centerIconSize * 0.48).clamp(30.0, 42.0);

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            iconSize: skipSize,
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            padding: EdgeInsets.zero,
            tooltip: 'Back 10 seconds',
            icon: const Icon(Icons.replay_10, color: Colors.white),
            onPressed: onReplay10,
          ),
          IconButton(
            iconSize: centerIconSize,
            constraints: const BoxConstraints(minWidth: 88, minHeight: 88),
            padding: EdgeInsets.zero,
            tooltip: isPlaying ? 'Pause' : 'Play',
            icon: Icon(
              isPlaying ? Icons.pause_circle : Icons.play_circle,
              color: kPlayerAccent,
            ),
            onPressed: onPlayPause,
          ),
          IconButton(
            iconSize: skipSize,
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            padding: EdgeInsets.zero,
            tooltip: 'Forward 10 seconds',
            icon: const Icon(Icons.forward_10, color: Colors.white),
            onPressed: onForward10,
          ),
        ],
      ),
    );
  }
}
