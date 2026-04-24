/// Represents a single audio track from the device library.
final class AudioTrackEntity {
  /// MediaStore audio ID (as String).
  final String id;
  final String filePath;
  final String title;
  final String artist;
  final String album;
  final String? albumArtPath;
  final int durationMs;
  final int fileSizeBytes;
  final int? trackNumber;
  final int? year;
  final DateTime? lastPlayedAt;
  final int playCount;
  final bool isFavourite;

  const AudioTrackEntity({
    required this.id,
    required this.filePath,
    required this.title,
    required this.artist,
    required this.album,
    required this.durationMs,
    required this.fileSizeBytes,
    this.albumArtPath,
    this.trackNumber,
    this.year,
    this.lastPlayedAt,
    this.playCount = 0,
    this.isFavourite = false,
  });

  // ─── Computed Properties ───────────────────────────────────────────────

  /// Human-readable duration. Example: "3:42"
  String get formattedDuration {
    final minutes = durationMs ~/ 60000;
    final seconds = (durationMs % 60000) ~/ 1000;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  // ─── CopyWith ─────────────────────────────────────────────────────────

  AudioTrackEntity copyWith({
    String? id,
    String? filePath,
    String? title,
    String? artist,
    String? album,
    String? albumArtPath,
    int? durationMs,
    int? fileSizeBytes,
    int? trackNumber,
    int? year,
    DateTime? lastPlayedAt,
    int? playCount,
    bool? isFavourite,
  }) {
    return AudioTrackEntity(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      durationMs: durationMs ?? this.durationMs,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      albumArtPath: albumArtPath ?? this.albumArtPath,
      trackNumber: trackNumber ?? this.trackNumber,
      year: year ?? this.year,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      playCount: playCount ?? this.playCount,
      isFavourite: isFavourite ?? this.isFavourite,
    );
  }

  // ─── Value Equality ───────────────────────────────────────────────────

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioTrackEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'AudioTrackEntity(title: $title, artist: $artist, album: $album)';
}
