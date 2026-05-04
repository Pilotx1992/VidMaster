import 'package:flutter/foundation.dart';

/// Represents a single downloadable stream format from the extraction engine.
@immutable
class MediaFormat {
  /// Platform-specific format identifier (e.g. "137+140" for YouTube DASH).
  final String formatId;

  /// File extension without dot (e.g. "mp4", "webm", "m4a").
  final String extension;

  /// Video width in pixels. Null for audio-only formats.
  final int? width;

  /// Video height in pixels. Null for audio-only formats.
  final int? height;

  /// Human-readable quality note (e.g. "1080p", "720p HD", "Audio 320kbps").
  final String note;

  /// Estimated file size in bytes. Null if unknown.
  final int? fileSizeBytes;

  /// Direct stream URL. May be null for DASH (uses separate videoUrl + audioUrl).
  final String? url;

  /// Separate video-only URL for DASH streams (1080p+).
  final String? videoUrl;

  /// Separate audio-only URL for DASH streams (1080p+).
  final String? audioUrl;

  /// Bitrate in kbps for audio formats.
  final int? audioBitrate;

  const MediaFormat({
    required this.formatId,
    required this.extension,
    required this.note,
    this.width,
    this.height,
    this.fileSizeBytes,
    this.url,
    this.videoUrl,
    this.audioUrl,
    this.audioBitrate,
  });

  /// True for audio-only formats (MP3, M4A, etc.).
  bool get isAudioOnly => width == null && height == null;

  /// True when this format requires a separate DASH merge operation.
  bool get requiresMerge =>
      videoUrl != null && audioUrl != null && url == null;

  /// Formatted file size string (e.g. "245 MB").
  String get formattedSize {
    if (fileSizeBytes == null) return 'Unknown size';
    final mb = fileSizeBytes! / (1024 * 1024);
    return mb >= 1024
        ? '${(mb / 1024).toStringAsFixed(1)} GB'
        : '${mb.toStringAsFixed(0)} MB';
  }

  /// Quality label for display (e.g. "1080p", "720p HD", "320kbps").
  String get qualityLabel {
    if (height != null) return '${height}p';
    if (audioBitrate != null) return '${audioBitrate}kbps';
    return note;
  }

  Map<String, dynamic> toJson() {
    return {
      'formatId': formatId,
      'extension': extension,
      'width': width,
      'height': height,
      'note': note,
      'fileSizeBytes': fileSizeBytes,
      'url': url,
      'videoUrl': videoUrl,
      'audioUrl': audioUrl,
      'audioBitrate': audioBitrate,
    };
  }

  factory MediaFormat.fromJson(Map<String, dynamic> json) {
    return MediaFormat(
      formatId:     json['formatId'] as String,
      extension:    json['extension'] as String? ?? 'mp4',
      note:         json['note'] as String? ?? 'Unknown',
      width:        json['width'] as int?,
      height:       json['height'] as int?,
      fileSizeBytes: json['fileSizeBytes'] as int?,
      url:          json['url'] as String?,
      videoUrl:     json['videoUrl'] as String?,
      audioUrl:     json['audioUrl'] as String?,
      audioBitrate: json['audioBitrate'] as int?,
    );
  }

  @override
  String toString() =>
      'MediaFormat($formatId, $qualityLabel, ${isAudioOnly ? "audio" : "video"})';
}
