import 'package:isar/isar.dart';

import '../../domain/entities/playlist_entity.dart';

part 'playlist_model.g.dart';

@collection
class PlaylistModel {
  Id get id => Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String playlistId;

  String name;
  List<String> trackIds;
  String? coverArtPath;
  DateTime createdAt;
  DateTime updatedAt;

  PlaylistModel({
    required this.playlistId,
    required this.name,
    required this.trackIds,
    required this.createdAt,
    required this.updatedAt,
    this.coverArtPath,
  });

  PlaylistEntity toDomain() {
    return PlaylistEntity(
      id: playlistId,
      name: name,
      trackIds: trackIds,
      createdAt: createdAt,
      updatedAt: updatedAt,
      coverArtPath: coverArtPath,
    );
  }

  factory PlaylistModel.fromDomain(PlaylistEntity entity) {
    return PlaylistModel(
      playlistId: entity.id,
      name: entity.name,
      trackIds: entity.trackIds,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      coverArtPath: entity.coverArtPath,
    );
  }
}
