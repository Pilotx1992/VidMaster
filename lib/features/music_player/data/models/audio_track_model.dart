import 'package:isar/isar.dart';

import '../../domain/entities/audio_track_entity.dart';

part 'audio_track_model.g.dart';

/// Isar data model for locally cached audio track metadata.
int fastHash(String string) {
  var hash = 0xcbf29ce484222325;
  var i = 0;
  while (i < string.length) {
    final codeUnit = string.codeUnitAt(i++);
    hash ^= codeUnit >> 8;
    hash *= 0x100000001b3;
    hash ^= codeUnit & 0xFF;
    hash *= 0x100000001b3;
  }
  return hash;
}

@collection
class AudioTrackModel {
  Id get id => fastHash(filePath);
  
  @Index(unique: true, replace: true)
  String filePath;

  String title;
  String artist;
  String album;
  String? albumArtPath;
  int durationMs;
  int fileSizeBytes;
  int? trackNumber;
  int? year;
  DateTime? lastPlayedAt;
  int playCount;
  bool isFavourite;

  AudioTrackModel({
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

  AudioTrackEntity toDomain() {
    return AudioTrackEntity(
      id: filePath.hashCode.toString(),
      filePath: filePath,
      title: title,
      artist: artist,
      album: album,
      durationMs: durationMs,
      fileSizeBytes: fileSizeBytes,
      albumArtPath: albumArtPath,
      trackNumber: trackNumber,
      year: year,
      lastPlayedAt: lastPlayedAt,
      playCount: playCount,
      isFavourite: isFavourite,
    );
  }

  factory AudioTrackModel.fromDomain(AudioTrackEntity entity) {
    return AudioTrackModel(
      filePath: entity.filePath,
      title: entity.title,
      artist: entity.artist,
      album: entity.album,
      durationMs: entity.durationMs,
      fileSizeBytes: entity.fileSizeBytes,
      albumArtPath: entity.albumArtPath,
      trackNumber: entity.trackNumber,
      year: entity.year,
      lastPlayedAt: entity.lastPlayedAt,
      playCount: entity.playCount,
      isFavourite: entity.isFavourite,
    );
  }
}
