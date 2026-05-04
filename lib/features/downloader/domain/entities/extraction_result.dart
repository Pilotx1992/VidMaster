import 'package:flutter/foundation.dart';
import 'media_format.dart';

/// Result of a successful metadata extraction from a video URL.
@immutable
class ExtractionResult {
  final String              originalUrl;
  final String              title;
  final String?             thumbnailUrl;
  final Duration?           duration;
  final String?             uploaderName;
  final List<MediaFormat>   videoFormats;
  final List<MediaFormat>   audioFormats;
  final DateTime            fetchedAt;

  const ExtractionResult({
    required this.originalUrl,
    required this.title,
    required this.videoFormats,
    required this.audioFormats,
    required this.fetchedAt,
    this.thumbnailUrl,
    this.duration,
    this.uploaderName,
  });

  /// All formats combined, video first then audio.
  List<MediaFormat> get allFormats => [...videoFormats, ...audioFormats];

  /// Best available video quality (highest resolution).
  MediaFormat? get bestVideoFormat {
    if (videoFormats.isEmpty) return null;
    return videoFormats.reduce(
      (a, b) => (a.height ?? 0) > (b.height ?? 0) ? a : b,
    );
  }

  /// Best available audio quality (highest bitrate).
  MediaFormat? get bestAudioFormat {
    if (audioFormats.isEmpty) return null;
    return audioFormats.reduce(
      (a, b) => (a.audioBitrate ?? 0) > (b.audioBitrate ?? 0) ? a : b,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'originalUrl': originalUrl,
      'title': title,
      'thumbnailUrl': thumbnailUrl,
      'durationSeconds': duration?.inSeconds,
      'uploaderName': uploaderName,
      'videoFormats': videoFormats.map((e) => e.toJson()).toList(),
      'audioFormats': audioFormats.map((e) => e.toJson()).toList(),
      'fetchedAt': fetchedAt.toIso8601String(),
    };
  }

  factory ExtractionResult.fromJson(Map<String, dynamic> json) {
    return ExtractionResult(
      originalUrl:  json['originalUrl'] as String,
      title:        json['title'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      duration:     json['durationSeconds'] != null
          ? Duration(seconds: (json['durationSeconds'] as num).toInt())
          : null,
      uploaderName: json['uploaderName'] as String?,
      videoFormats: (json['videoFormats'] as List<dynamic>?)
              ?.cast<Map<String, dynamic>>()
              .map(MediaFormat.fromJson)
              .toList() ??
          [],
      audioFormats: (json['audioFormats'] as List<dynamic>?)
              ?.cast<Map<String, dynamic>>()
              .map(MediaFormat.fromJson)
              .toList() ??
          [],
      fetchedAt:    DateTime.parse(json['fetchedAt'] as String),
    );
  }
}
