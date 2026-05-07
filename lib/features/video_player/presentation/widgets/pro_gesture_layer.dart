import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'gesture_engine.dart';

class ProGestureLayer extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration position;
  final double volume;
  final double brightness;

  final VoidCallback onTap;
  final Function(Duration) onSeekEnd;
  final Function(double) onVolume;
  final Function(double) onBrightness;
  final VoidCallback onDoubleTapLeft;
  final VoidCallback onDoubleTapRight;

  const ProGestureLayer({
    super.key,
    required this.child,
    required this.duration,
    required this.position,
    required this.volume,
    required this.brightness,
    required this.onTap,
    required this.onSeekEnd,
    required this.onVolume,
    required this.onBrightness,
    required this.onDoubleTapLeft,
    required this.onDoubleTapRight,
  });

  @override
  State<ProGestureLayer> createState() => _ProGestureLayerState();
}

class _ProGestureLayerState extends State<ProGestureLayer> {
  final engine = GestureEngine();

  bool _isSeeking = false;
  Duration _preview = Duration.zero;

  Duration _startPosition = Duration.zero;
  GestureType? _levelType;
  double _levelValue = 0;
  Timer? _levelTimer;

  @override
  void dispose() {
    _levelTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: widget.onTap,
          onDoubleTapDown: (details) {
            final isLeft = details.localPosition.dx < width / 2;

            if (isLeft) {
              widget.onDoubleTapLeft();
            } else {
              widget.onDoubleTapRight();
            }

            HapticFeedback.mediumImpact();
          },
          onPanStart: (d) {
            _startPosition = widget.position;
            engine.start(
              dx: d.localPosition.dx,
              screenWidth: width,
              position: widget.position,
              volume: widget.volume,
              brightness: widget.brightness,
            );
          },
          onPanUpdate: (d) {
            final result = engine.update(
              d.delta.dx,
              d.delta.dy,
              widget.duration,
            );

            switch (result.type) {
              case GestureType.seek:
                setState(() {
                  _isSeeking = true;
                  _preview = result.seek!;
                });
                break;

              case GestureType.volume:
                widget.onVolume(result.value!);
                _showLevel(GestureType.volume, result.value!);
                break;

              case GestureType.brightness:
                widget.onBrightness(result.value!);
                _showLevel(GestureType.brightness, result.value!);
                break;

              default:
                break;
            }
          },
          onPanEnd: (_) {
            if (_isSeeking) {
              widget.onSeekEnd(_preview);
              setState(() => _isSeeking = false);
            }
            engine.reset();
          },
          onPanCancel: () {
            if (_isSeeking) {
              setState(() => _isSeeking = false);
            }
            engine.reset();
          },
          child: widget.child,
        ),

        /// 🔥 Seek Preview Overlay
        if (_isSeeking)
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSeekIcon(_preview, _startPosition),
                  const SizedBox(height: 8),
                  Text(
                    _formatSeekPreview(
                      _preview,
                      _startPosition,
                      widget.duration,
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          )
        else if (_levelType != null)
          Center(
            child: Container(
              width: 176,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _levelType == GestureType.volume
                        ? Icons.volume_up
                        : Icons.brightness_6,
                    color: const Color(0xFFF9A825),
                    size: 34,
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: _levelValue,
                    minHeight: 5,
                    borderRadius: BorderRadius.circular(8),
                    backgroundColor: Colors.white24,
                    color: const Color(0xFFF9A825),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(_levelValue * 100).round()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  void _showLevel(GestureType type, double value) {
    _levelTimer?.cancel();
    setState(() {
      _levelType = type;
      _levelValue = value.clamp(0.0, 1.0).toDouble();
    });
    _levelTimer = Timer(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() => _levelType = null);
    });
  }

  Widget _buildSeekIcon(Duration current, Duration start) {
    final isForward = current >= start;
    return Icon(
      isForward ? Icons.fast_forward : Icons.fast_rewind,
      color: isForward ? const Color(0xFFF9A825) : Colors.white,
      size: 42,
    );
  }

  String _formatSeekPreview(Duration current, Duration start, Duration total) {
    final delta = current.inSeconds - start.inSeconds;
    final deltaStr = delta >= 0 ? "+${delta}s" : "${delta}s";

    return "$deltaStr  ${_format(current)} / ${_format(total)}";
  }

  String _format(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }
}
