import 'package:flutter/material.dart';

import 'player_control_helpers.dart';

/// Seek row with LTR slider (correct progress direction in RTL app locales).
class PlayerSeekSection extends StatelessWidget {
  final Duration position;
  final Duration duration;
  final ValueChanged<Duration> onSeek;

  const PlayerSeekSection({
    super.key,
    required this.position,
    required this.duration,
    required this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    final maxMs = duration.inMilliseconds <= 0
        ? 1.0
        : duration.inMilliseconds.toDouble();
    final valueMs = position.inMilliseconds
        .clamp(0, duration.inMilliseconds <= 0 ? 1 : duration.inMilliseconds)
        .toDouble();

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            SizedBox(
              width: 52,
              child: Text(
                formatPlayerDuration(position),
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
            Expanded(
              child: Slider(
                value: valueMs,
                max: maxMs,
                activeColor: const Color(0xFFF9A825),
                inactiveColor: Colors.white24,
                onChanged: (v) =>
                    onSeek(Duration(milliseconds: v.toInt())),
              ),
            ),
            SizedBox(
              width: 52,
              child: Text(
                formatPlayerDuration(duration),
                textAlign: TextAlign.end,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
