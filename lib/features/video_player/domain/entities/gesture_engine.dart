// lib/domain/entities/gesture_engine.dart
// ⚠️ NO Flutter imports allowed in this file

import 'package:flutter/services.dart'; // Only for HapticFeedback
import 'package:flutter/gestures.dart'; // For DragUpdateDetails

import 'gesture_result.dart'; // For GestureResult

enum GestureType { none, seek, volume, brightness }

class GestureEngine {
  GestureType _type     = GestureType.none;
  bool        _isLocked = false;
  Duration    _preview  = Duration.zero;
  double      _vol      = 0.0;
  double      _bright   = 0.0;

  // ── Configurable Parameters ────────────────────────────────
  final double threshold;       // default: 8.0 px
  final double fastThreshold;   // default: 10.0 px/frame
  final double seekSlowMs;      // default: 400.0 ms/px
  final double seekFastMs;      // default: 1200.0 ms/px
  final double vertSensitivity; // default: 0.01 (1% per pixel)

  GestureEngine({
    this.threshold      = 8.0,
    this.fastThreshold  = 10.0,
    this.seekSlowMs     = 400.0,
    this.seekFastMs     = 1200.0,
    this.vertSensitivity= 0.01,
  });

  void onStart({
    required double   dx,
    required double   screenWidth,
    required Duration currentPosition,
    required double   volume,
    required double   brightness,
  }) {
    _preview  = currentPosition;
    _vol      = volume;
    _bright   = brightness;
    // Tentative vertical type based on screen half
    _type     = dx < screenWidth / 2 ? GestureType.brightness : GestureType.volume;
    _isLocked = false;
  }

  GestureResult onUpdate(DragUpdateDetails d, Duration totalDuration) {
    // Phase 1: lock determination — horizontal beats vertical if simultaneous
    if (!_isLocked) {
      if (d.delta.dx.abs() > threshold) {
        _type = GestureType.seek;
        _isLocked = true;
        HapticFeedback.lightImpact();
      } else if (d.delta.dy.abs() > threshold) {
        _isLocked = true; // _type already set by onStart (volume or brightness)
      }
    }

    if (!_isLocked) return const GestureResult.none();

    // Phase 2: execute on locked type
    switch (_type) {
      case GestureType.seek:
        final speed = d.delta.dx.abs() > fastThreshold ? seekFastMs : seekSlowMs;
        _preview += Duration(milliseconds: (d.delta.dx * speed).toInt());
        if (_preview <= Duration.zero) {
          _preview = Duration.zero;
          HapticFeedback.heavyImpact();
        } else if (_preview >= totalDuration) {
          _preview = totalDuration;
          HapticFeedback.heavyImpact();
        }
        return GestureResult.seek(_preview);

      case GestureType.volume:
        _vol = (_vol - d.delta.dy * vertSensitivity).clamp(0.0, 1.0);
        return GestureResult.volume(_vol);

      case GestureType.brightness:
        _bright = (_bright - d.delta.dy * vertSensitivity).clamp(0.0, 1.0);
        return GestureResult.brightness(_bright);

      default:
        return const GestureResult.none();
    }
  }

  void reset() {
    _type     = GestureType.none;
    _isLocked = false;
  }
}