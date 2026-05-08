import 'package:flutter/material.dart';

import '../../domain/entities/video_playback_state.dart';

/// Premium player accent (XPlayer-like green).
const Color kPlayerAccent = Color(0xFF10B919);

String formatPlayerDuration(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  if (h > 0) return '$h:$m:$s';
  return '$m:$s';
}

String aspectRatioModeLabel(VideoAspectRatioMode mode) => switch (mode) {
      VideoAspectRatioMode.fit => 'Fit',
      VideoAspectRatioMode.fill => 'Fill',
      VideoAspectRatioMode.stretch => 'Stretch',
      VideoAspectRatioMode.zoom => 'Zoom',
    };

String formatSpeedLabel(double speed) {
  if (speed <= 0) return '1X';
  final rounded = (speed * 100).round() / 100;
  if ((rounded * 100) % 100 == 0) return '${rounded.toStringAsFixed(0)}X';
  final s = rounded.toString();
  return '${s.endsWith('.0') ? s.substring(0, s.length - 2) : s}X';
}
