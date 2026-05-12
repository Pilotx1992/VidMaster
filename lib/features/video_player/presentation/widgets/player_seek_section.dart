import 'package:flutter/material.dart';

import 'player_control_helpers.dart';

/// LTR seek row; previews while dragging, seeks only on [onChangeEnd].
///
/// [onDragStart] / [onDragEnd] let the host suspend the controls auto-hide
/// timer for the duration of a drag, so the panel never vanishes under the
/// user's finger. Seek is still committed only on drag end.
class PlayerSeekSection extends StatefulWidget {
  final Duration position;
  final Duration duration;
  final ValueChanged<Duration> onSeekEnd;
  final VoidCallback? onDragStart;
  final VoidCallback? onDragEnd;

  const PlayerSeekSection({
    super.key,
    required this.position,
    required this.duration,
    required this.onSeekEnd,
    this.onDragStart,
    this.onDragEnd,
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
              // Shrink the slider's vertical footprint so its visible track
              // sits closer to the Play/Pause row below. Material's default
              // overlay (radius 24) + padded tap target reserves ~48dp of
              // vertical space; trimming both removes the perceived gap
              // between the seek bar and the transport row. Drag preview /
              // onChangeEnd-only commit is unchanged.
              child: Theme(
                data: Theme.of(context).copyWith(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: kPlayerAccent,
                    inactiveTrackColor: Colors.white24,
                    thumbColor: kPlayerAccent,
                    overlayColor: kPlayerAccent.withValues(alpha: 0.2),
                    overlayShape:
                        const RoundSliderOverlayShape(overlayRadius: 14),
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 8),
                    trackHeight: 3,
                  ),
                  child: Slider(
                    value: value,
                    max: maxMs,
                    onChangeStart: (_) {
                      setState(() => _dragValueMs = realValue);
                      widget.onDragStart?.call();
                    },
                    onChanged: (v) {
                      setState(() => _dragValueMs = v);
                    },
                    onChangeEnd: (v) {
                      final ms = v.round().clamp(0, cap);
                      setState(() => _dragValueMs = null);
                      widget.onDragEnd?.call();
                      widget.onSeekEnd(Duration(milliseconds: ms));
                    },
                  ),
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
