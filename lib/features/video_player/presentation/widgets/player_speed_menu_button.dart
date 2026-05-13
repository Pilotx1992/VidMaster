import 'package:flutter/material.dart';

import 'package:material_symbols_icons/symbols.dart';
import '../providers/video_player_notifier.dart';
import 'player_control_helpers.dart';

class PlayerSpeedMenuButton extends StatelessWidget {
  final double speed;
  final ValueChanged<double> onSelected;
  final Widget? menuChild;

  const PlayerSpeedMenuButton({
    super.key,
    required this.speed,
    required this.onSelected,
    this.menuChild,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<double>(
      tooltip: 'Playback speed',
      initialValue: speed,
      onSelected: onSelected,
      itemBuilder: (context) => [
        for (final s in VideoPlayerNotifier.supportedPlaybackSpeeds)
          PopupMenuItem<double>(
            value: s,
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  child: s == speed
                      ? const Icon(Symbols.check, size: 18, color: Colors.white)
                      : const SizedBox.shrink(),
                ),
                Text(formatSpeedLabel(s).toLowerCase()),
              ],
            ),
          ),
      ],
      child: menuChild ??
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Center(
              child: Text(
                formatSpeedLabel(speed),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
    );
  }
}
