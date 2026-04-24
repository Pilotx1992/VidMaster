import 'package:isar/isar.dart';

import '../models/audio_track_model.dart';
// Note: PlaylistModel omitted as per previous task constraints; 
// playlist operations will throw Unimplemented or CacheFailure in RepoImpl.

/// Contract for local database operations related to Music.
abstract interface class MusicLocalDataSource {
  Future<List<AudioTrackModel>> getAllTracks();
  Future<List<AudioTrackModel>> getTracksByAlbum(String album);
  Future<List<AudioTrackModel>> getTracksByArtist(String artist);
  Future<List<AudioTrackModel>> searchTracks(String query);
  
  Future<List<String>> getAllAlbums();
  Future<List<String>> getAllArtists();

  Future<AudioTrackModel?> getTrackById(String id);
  Future<void> saveTrack(AudioTrackModel track);

  Future<List<AudioTrackModel>> getRecentlyPlayed({required int limit});
  Future<List<AudioTrackModel>> getMostPlayed({required int limit});
  
  Future<List<AudioTrackModel>> getFavouriteTracks();
}

/// Isar implementation of the music local data source.
class MusicLocalDataSourceImpl implements MusicLocalDataSource {
  final Isar _isar;

  MusicLocalDataSourceImpl(this._isar);

  IsarCollection<AudioTrackModel> get _box => _isar.audioTrackModels;

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
  Future<void> saveTrack(AudioTrackModel track) async {
    await _isar.writeTxn(() async {
      await _box.put(track);
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
}

