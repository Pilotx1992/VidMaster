import 'package:flutter/material.dart';

import 'player_control_helpers.dart';

/// LTR seek row; previews while dragging, seeks only on [onChangeEnd].
class PlayerSeekSection extends StatefulWidget {
  final Duration position;
  final Duration duration;
  final ValueChanged<Duration> onSeekEnd;

  const PlayerSeekSection({
    super.key,
    required this.position,
    required this.duration,
    required this.onSeekEnd,
  });

  @override
  State<PlayerSeekSection> createState() => _PlayerSeekSectionState();
}

class _PlayerSeekSectionState extends State<PlayerSeekSection> {
  double? _dragValueMs;

  @override
  Widget build(BuildContext context) {
    final maxMs = widget.duration.inMilliseconds <= 0
        ? 1.0
        : widget.duration.inMilliseconds.toDouble();
    final cap = widget.duration.inMilliseconds <= 0
        ? 1
        : widget.duration.inMilliseconds;
    final realValue = widget.position.inMilliseconds
        .clamp(0, cap)
        .toDouble();
    final value = (_dragValueMs ?? realValue).clamp(0.0, maxMs);

    final displayPos = Duration(milliseconds: value.round());

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            SizedBox(
              width: 52,
              child: Text(
                formatPlayerDuration(displayPos),
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: kPlayerAccent,
                  inactiveTrackColor: Colors.white24,
                  thumbColor: kPlayerAccent,
                  overlayColor: kPlayerAccent.withValues(alpha: 0.2),
                ),
                child: Slider(
                  value: value,
                  max: maxMs,
                  onChangeStart: (_) {
                    setState(() => _dragValueMs = realValue);
                  },
                  onChanged: (v) {
                    setState(() => _dragValueMs = v);
                  },
                  onChangeEnd: (v) {
                    final ms = v.round().clamp(0, cap);
                    setState(() => _dragValueMs = null);
                    widget.onSeekEnd(Duration(milliseconds: ms));
                  },
                ),
              ),
            ),
            SizedBox(
              width: 52,
              child: Text(
                formatPlayerDuration(widget.duration),
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
