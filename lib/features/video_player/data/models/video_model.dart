import 'package:isar_community/isar.dart';

import '../../domain/entities/video_entity.dart';

part 'video_model.g.dart';

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

/// Isar data model for locally cached video metadata.
@collection
class VideoModel {
  Id get id => fastHash(filePath);
  
  @Index(unique: true, replace: true)
  String filePath;

  String fileName;
  String folderName;
  String? thumbnailPath;
  int? durationMs;
  int? lastPositionMs;
  int fileSizeBytes;
  String? resolution;
  DateTime? lastPlayedAt;
  int playCount;
  bool isFavourite;
  bool isInVault;

  VideoModel({
    required this.filePath,
    required this.fileName,
    required this.folderName,
    required this.fileSizeBytes,
    this.thumbnailPath,
    this.durationMs,
    this.lastPositionMs,
    this.resolution,
    this.lastPlayedAt,
    this.playCount = 0,
    this.isFavourite = false,
    this.isInVault = false,
  });

  // ─── Mapper: Model → Domain ───────────────────────────────────────────

  VideoEntity toDomain() {
    return VideoEntity(
      filePath: filePath,
      title: fileName,
      folderName: folderName,
      fileSizeBytes: fileSizeBytes,
      thumbnailPath: thumbnailPath,
      durationMs: durationMs,
      lastPositionMs: lastPositionMs,
      resolution: resolution,
      lastPlayedAt: lastPlayedAt,
      playCount: playCount,
      isFavourite: isFavourite,
      isInVault: isInVault,
    );
  }

  // ─── Mapper: Domain → Model ───────────────────────────────────────────

  factory VideoModel.fromDomain(VideoEntity entity) {
    return VideoModel(
      filePath: entity.filePath,
      fileName: entity.fileName,
      folderName: entity.folderName,
      fileSizeBytes: entity.fileSizeBytes,
      thumbnailPath: entity.thumbnailPath,
      durationMs: entity.durationMs,
      lastPositionMs: entity.lastPositionMs,
      resolution: entity.resolution,
      lastPlayedAt: entity.lastPlayedAt,
      playCount: entity.playCount,
      isFavourite: entity.isFavorite,
      isInVault: entity.isInVault,
    );
  }
}
