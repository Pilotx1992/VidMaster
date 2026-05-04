import 'package:flutter/services.dart';

enum GestureType { none, volume, brightness, seek }

class GestureEngine {
  GestureType _type = GestureType.none;
  bool _isLocked = false;

  double _volume = 0;
  double _brightness = 0;
  Duration _preview = Duration.zero;

  static const double verticalSensitivity = 0.01;
  static const double seekSensitivity = 400; // ms per pixel

  void start({
    required double dx,
    required double screenWidth,
    required Duration position,
    required double volume,
    required double brightness,
  }) {
    _preview = position;
    _volume = volume;
    _brightness = brightness;

    _type = dx < screenWidth / 2
        ? GestureType.brightness
        : GestureType.volume;

    _isLocked = false;
  }

  GestureResult update(
    double dx,
    double dy,
    Duration duration,
  ) {
    // 🔒 lock after threshold
    if (!_isLocked) {
      if (dx.abs() > 4) {
        _type = GestureType.seek;
        _isLocked = true;
        HapticFeedback.lightImpact();
      } else if (dy.abs() > 4) {
        _isLocked = true;
      }
    }

    if (!_isLocked) return const GestureResult.none();

    switch (_type) {
      case GestureType.seek:
        final delta = dx * seekSensitivity;
        _preview += Duration(milliseconds: delta.toInt());

        _preview = Duration(
          milliseconds: _preview.inMilliseconds
              .clamp(0, duration.inMilliseconds),
        );

        return GestureResult.seek(_preview);

      case GestureType.volume:
        _volume -= dy * verticalSensitivity;
        _volume = _volume.clamp(0.0, 1.0);
        return GestureResult.volume(_volume);

      case GestureType.brightness:
        _brightness -= dy * verticalSensitivity;
        _brightness = _brightness.clamp(0.0, 1.0);
        return GestureResult.brightness(_brightness);

      default:
        return const GestureResult.none();
    }
  }

  void reset() {
    _type = GestureType.none;
    _isLocked = false;
  }
}

class GestureResult {
  final GestureType type;
  final Duration? seek;
  final double? value;

  const GestureResult._(this.type, {this.seek, this.value});
  const GestureResult.none() : this._(GestureType.none);

  factory GestureResult.seek(Duration d) =>
      GestureResult._(GestureType.seek, seek: d);

  factory GestureResult.volume(double v) =>
      GestureResult._(GestureType.volume, value: v);

  factory GestureResult.brightness(double b) =>
      GestureResult._(GestureType.brightness, value: b);
}
