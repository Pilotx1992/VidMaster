import 'package:flutter/material.dart';

@immutable
class SubtitleSettings {
  final double fontSize;
  final bool isVisible;
  final Duration syncOffset;

  const SubtitleSettings({
    this.fontSize = 16.0,
    this.isVisible = true,
    this.syncOffset = Duration.zero,
  });

  static const defaults = SubtitleSettings();

  SubtitleSettings copyWith({
    double? fontSize,
    bool? isVisible,
    Duration? syncOffset,
  }) {
    return SubtitleSettings(
      fontSize: fontSize ?? this.fontSize,
      isVisible: isVisible ?? this.isVisible,
      syncOffset: syncOffset ?? this.syncOffset,
    );
  }
}