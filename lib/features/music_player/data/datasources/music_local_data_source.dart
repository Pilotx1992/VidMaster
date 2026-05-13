import 'package:isar_community/isar.dart';

import '../models/audio_track_model.dart';
import '../models/playlist_model.dart';

/// Contract for local database operations related to Music.
abstract interface class MusicLocalDataSource {
  Future<List<AudioTrackModel>> getAllTracks();
  Future<List<AudioTrackModel>> getTracksByAlbum(String album);
  Future<List<AudioTrackModel>> getTracksByArtist(String artist);
  Future<List<AudioTrackModel>> searchTracks(String query);

  Future<List<String>> getAllAlbums();
  Future<List<String>> getAllArtists();

  Future<AudioTrackModel?> getTrackById(String id);
  Future<AudioTrackModel?> getTrackByFilePath(String filePath);
  Future<void> saveTrack(AudioTrackModel track);
  Future<bool> deleteTrackByFilePath(String filePath);

  Future<List<AudioTrackModel>> getRecentlyPlayed({required int limit});
  Future<List<AudioTrackModel>> getMostPlayed({required int limit});

  Future<List<AudioTrackModel>> getFavouriteTracks();

  Future<List<PlaylistModel>> getAllPlaylists();
  Future<PlaylistModel?> getPlaylistById(String playlistId);
  Future<void> savePlaylist(PlaylistModel playlist);
  Future<bool> deletePlaylist(String playlistId);
}

/// Isar implementation of the music local data source.
class MusicLocalDataSourceImpl implements MusicLocalDataSource {
  final Isar _isar;

  MusicLocalDataSourceImpl(this._isar);

  IsarCollection<AudioTrackModel> get _box => _isar.audioTrackModels;
  IsarCollection<PlaylistModel> get _playlistBox => _isar.playlistModels;

  @override
  Future<List<AudioTrackModel>> getAllTracks() async {
    return _box.where().findAll();
  }

  @override
  Future<List<AudioTrackModel>> getTracksByAlbum(String album) async {
    return _box.filter().albumEqualTo(album, caseSensitive: false).findAll();
  }

  @override
  Future<List<AudioTrackModel>> getTracksByArtist(String artist) async {
    return _box.filter().artistEqualTo(artist, caseSensitive: false).findAll();
  }

  @override
  Future<List<AudioTrackModel>> searchTracks(String queryText) async {
    return _box
        .filter()
        .titleContains(queryText, caseSensitive: false)
        .or()
        .artistContains(queryText, caseSensitive: false)
        .or()
        .albumContains(queryText, caseSensitive: false)
        .findAll();
  }

  @override
  Future<List<String>> getAllAlbums() async {
    final albums = await _box.where().albumProperty().findAll();
    return albums.whereType<String>().toSet().toList();
  }

  @override
  Future<List<String>> getAllArtists() async {
    final artists = await _box.where().artistProperty().findAll();
    return artists.whereType<String>().toSet().toList();
  }

  @override
  Future<AudioTrackModel?> getTrackById(String id) async {
    final intId = int.tryParse(id);
    if (intId == null || intId == 0) return null;
    return _box.get(intId);
  }

  @override
  Future<AudioTrackModel?> getTrackByFilePath(String filePath) async {
    return _box.getByFilePath(filePath);
  }

  @override
  Future<void> saveTrack(AudioTrackModel track) async {
    await _isar.writeTxn(() async {
      await _box.put(track);
    });
  }

  @override
  Future<bool> deleteTrackByFilePath(String filePath) async {
    return _isar.writeTxn(() async {
      return _box.deleteByFilePath(filePath);
    });
  }

  @override
  Future<List<AudioTrackModel>> getRecentlyPlayed({required int limit}) async {
    return _box
        .filter()
        .lastPlayedAtIsNotNull()
        .sortByLastPlayedAtDesc()
        .limit(limit)
        .findAll();
  }

  @override
  Future<List<AudioTrackModel>> getMostPlayed({required int limit}) async {
    return _box
        .filter()
        .playCountGreaterThan(0)
        .sortByPlayCountDesc()
        .limit(limit)
        .findAll();
  }

  @override
  Future<List<AudioTrackModel>> getFavouriteTracks() async {
    return _box
        .filter()
        .isFavouriteEqualTo(true)
        .sortByLastPlayedAtDesc()
        .findAll();
  }

  @override
  Future<List<PlaylistModel>> getAllPlaylists() async {
    return _playlistBox.where().sortByUpdatedAtDesc().findAll();
  }

  @override
  Future<PlaylistModel?> getPlaylistById(String playlistId) async {
    return _playlistBox.getByPlaylistId(playlistId);
  }

  @override
  Future<void> savePlaylist(PlaylistModel playlist) async {
    await _isar.writeTxn(() async {
      await _playlistBox.putByPlaylistId(playlist);
    });
  }

  @override
  Future<bool> deletePlaylist(String playlistId) async {
    return _isar.writeTxn(() async {
      return _playlistBox.deleteByPlaylistId(playlistId);
    });
  }
}
