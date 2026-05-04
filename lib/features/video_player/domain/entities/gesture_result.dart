// lib/domain/entities/gesture_result.dart

import 'gesture_engine.dart'; // For GestureType

class GestureResult {
  final GestureType type;
  final Duration?   seek;
  final double?     value;

  const GestureResult._(this.type, {this.seek, this.value});
  const GestureResult.none()            : this._(GestureType.none);
  factory GestureResult.seek(Duration d)   => GestureResult._(GestureType.seek,       seek: d);
  factory GestureResult.volume(double v)   => GestureResult._(GestureType.volume,      value: v);
  factory GestureResult.brightness(double b) => GestureResult._(GestureType.brightness, value: b);
}