/// A user-created playlist of audio tracks.
final class PlaylistEntity {
  final String id;
  final String name;

  /// Ordered list of [AudioTrackEntity.id] references.
  final List<String> trackIds;
  final String? coverArtPath;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PlaylistEntity({
    required this.id,
    required this.name,
    required this.trackIds,
    required this.createdAt,
    required this.updatedAt,
    this.coverArtPath,
  });

  // ─── Computed Properties ───────────────────────────────────────────────

  int get trackCount => trackIds.length;

  // ─── CopyWith ─────────────────────────────────────────────────────────

  PlaylistEntity copyWith({
    String? name,
    List<String>? trackIds,
    String? coverArtPath,
    DateTime? updatedAt,
  }) {
    return PlaylistEntity(
      id: id,
      name: name ?? this.name,
      trackIds: trackIds ?? this.trackIds,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      coverArtPath: coverArtPath ?? this.coverArtPath,
    );
  }

  // ─── Value Equality ───────────────────────────────────────────────────

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaylistEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'PlaylistEntity(name: $name, tracks: $trackCount)';
}
