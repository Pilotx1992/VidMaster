import 'package:audio_service/audio_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:isar/isar.dart';
import 'package:just_audio/just_audio.dart';
import 'package:local_auth/local_auth.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Models
import 'features/downloader/data/models/download_task_model.dart';
import 'features/downloader/data/models/extraction_cache_model.dart';
import 'features/music_player/data/models/audio_track_model.dart';
import 'features/music_player/data/models/playlist_model.dart';
import 'features/security/data/models/encrypted_file_metadata_model.dart';
import 'features/video_player/data/models/video_model.dart';

// DataSources
import 'features/downloader/data/datasources/downloader_local_data_source.dart';
import 'features/downloader/data/datasources/downloader_remote_data_source.dart';
import 'features/music_player/data/datasources/music_local_data_source.dart';
import 'features/security/data/datasources/auth_local_data_source.dart';
import 'features/security/data/datasources/vault_metadata_data_source.dart';
import 'features/security/data/datasources/file_encryption_data_source.dart';
import 'features/video_player/data/datasources/video_local_data_source.dart';

// Repositories (implementations)
import 'features/downloader/data/repositories/downloader_repository_impl.dart';
import 'features/downloader/data/repositories/isar_download_repository.dart';
import 'features/downloader/data/repositories/isar_extraction_cache_repository.dart';
import 'features/music_player/data/repositories/music_repository_impl.dart';
import 'features/security/data/repositories/auth_repository_impl.dart';
import 'features/security/data/repositories/vault_repository_impl.dart';
import 'features/video_player/data/repositories/video_repository_impl.dart';

// Repositories (interfaces)
import 'features/downloader/domain/repositories/download_repository.dart';
import 'features/downloader/domain/repositories/extraction_cache_repository.dart';
import 'features/downloader/domain/repositories/downloader_repository.dart';
import 'features/downloader/domain/services/storage_service.dart';
import 'features/downloader/data/services/ffmpeg_merge_service.dart';
import 'features/downloader/domain/services/merge_service.dart';
import 'features/downloader/application/use_cases/merge_streams_use_case.dart';
import 'features/downloader/data/services/ytdlp_extraction_service.dart';
import 'features/downloader/data/services/youtube_explode_service.dart';
import 'features/downloader/data/services/storage_service_impl.dart';
import 'features/music_player/domain/repositories/music_repository.dart';
import 'features/security/domain/repositories/auth_repository.dart';
import 'features/security/domain/repositories/vault_repository.dart';
import 'features/video_player/domain/repositories/video_repository.dart';

// Use Cases
import 'features/video_player/domain/usecases/video_usecases.dart';
import 'features/music_player/domain/usecases/music_usecases.dart';
import 'features/downloader/application/use_cases/extract_metadata_use_case.dart';
import 'features/downloader/application/use_cases/start_download_use_case.dart';
import 'features/downloader/application/services/cleanup_service.dart';
import 'features/downloader/domain/usecases/download_usecases.dart';
import 'features/security/domain/usecases/security_usecases.dart';

// ── Infrastructure ─────────────────────────────────────────────────────────

final isarProvider = Provider<Isar>((ref) => throw UnimplementedError(
    'Isar must be initialized before use. Call initIsar() in main().'));

Future<Isar> initIsar() async {
  final dir = await getApplicationDocumentsDirectory();
  return Isar.open(
    [VideoModelSchema, AudioTrackModelSchema, PlaylistModelSchema, DownloadTaskModelSchema, ExtractionCacheModelSchema],
    directory: dir.path,
  );
}

final vaultBoxProvider = Provider<Box<EncryptedFileMetadataModel>>((ref) => throw UnimplementedError(
    'Hive vault box must be initialized before use.'));

Future<Box<EncryptedFileMetadataModel>> initHive() async {
  await Hive.initFlutter();
  Hive.registerAdapter(EncryptedFileMetadataModelAdapter());
  return Hive.openBox<EncryptedFileMetadataModel>('vault_metadata');
}

// ── Audio Service ──────────────────────────────────────────────────────────
//
// Both providers are initialized in main() and injected via ProviderScope
// overrides — identical pattern to isarProvider and vaultBoxProvider.

final audioHandlerProvider = Provider<AudioHandler>(
  (ref) => throw UnimplementedError(
      'AudioHandler must be initialized in main() via AudioService.init()'),
);

final audioPlayerProvider = Provider<AudioPlayer>(
  (ref) => throw UnimplementedError(
      'AudioPlayer must be initialized in main() before use.'),
);

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(
      'SharedPreferences must be initialized in main() before use.'),
);

final androidEqualizerProvider = Provider<AndroidEqualizer>(
  (ref) => throw UnimplementedError(
      'AndroidEqualizer must be initialized in main() before use.'),
);

// ── 3rd-Party Singletons ──────────────────────────────────────────────────

final dioProvider = Provider<Dio>((ref) => Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 30),
      ),
    ));

final connectivityProvider = Provider<Connectivity>((ref) => Connectivity());

final localAuthProvider = Provider<LocalAuthentication>((ref) => LocalAuthentication());

final secureStorageProvider = Provider<FlutterSecureStorage>(
  (ref) => const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  ),
);

final audioQueryProvider = Provider<OnAudioQuery>((ref) => OnAudioQuery());

// ── DataSources ────────────────────────────────────────────────────────────

final videoLocalDataSourceProvider = Provider<VideoLocalDataSource>(
  (ref) => VideoLocalDataSourceImpl(ref.watch(isarProvider)),
);

final musicLocalDataSourceProvider = Provider<MusicLocalDataSource>(
  (ref) => MusicLocalDataSourceImpl(
    ref.watch(isarProvider),
  ),
);

final downloaderLocalDataSourceProvider = Provider<DownloaderLocalDataSource>(
  (ref) => DownloaderLocalDataSource(
    isar: ref.watch(isarProvider),
  ),
);

final downloaderRemoteDataSourceProvider = Provider<DownloaderRemoteDataSource>(
  (ref) => DownloaderRemoteDataSource(
    dio: ref.watch(dioProvider),
  ),
);

final downloadTaskRepositoryProvider = Provider<DownloadRepository>(
  (ref) => IsarDownloadRepository(
    localDataSource: ref.watch(downloaderLocalDataSourceProvider),
  ),
);

final extractionCacheRepositoryProvider = Provider<ExtractionCacheRepository>(
  (ref) => IsarExtractionCacheRepository(isar: ref.watch(isarProvider)),
);

final ytdlpExtractionServiceProvider = Provider((ref) => YtdlpExtractionService());
final youtubeExplodeServiceProvider = Provider((ref) => YoutubeExplodeService());
final storageServiceProvider = Provider<StorageService>((ref) => StorageServiceImpl());

final extractMetadataUseCaseProvider = Provider(
  (ref) => ExtractMetadataUseCase(
    ytdlp: ref.watch(ytdlpExtractionServiceProvider),
    ytExplode: ref.watch(youtubeExplodeServiceProvider),
    cache: ref.watch(extractionCacheRepositoryProvider),
  ),
);

final startDownloadUseCaseProvider = Provider(
  (ref) => StartDownloadUseCase(
    repo: ref.watch(downloadTaskRepositoryProvider),
    storage: ref.watch(storageServiceProvider),
  ),
);

final mergeStreamsUseCaseProvider = Provider(
  (ref) => MergeStreamsUseCase(
    merger: ref.watch(ffmpegMergeServiceProvider),
    storage: ref.watch(storageServiceProvider),
  ),
);

final ffmpegMergeServiceProvider = Provider<MergeService>((ref) => FfmpegMergeService());

final cleanupServiceProvider = Provider<CleanupService>(
  (ref) => CleanupService(ref.watch(storageServiceProvider)),
);

final vaultDataSourceProvider = Provider<VaultMetadataDataSource>(
  (ref) => VaultMetadataDataSource(ref.watch(vaultBoxProvider)),
);

final fileEncryptionDataSourceProvider = Provider<FileEncryptionDataSource>(
  (ref) => FileEncryptionDataSource(),
);

final authDataSourceProvider = Provider<AuthLocalDataSource>(
  (ref) => AuthLocalDataSource(
    storage: ref.watch(secureStorageProvider),
  ),
);

// ── Repositories ───────────────────────────────────────────────────────────

final videoRepositoryProvider = Provider<VideoRepository>(
  (ref) => VideoRepositoryImpl(localDataSource: ref.watch(videoLocalDataSourceProvider)),
);

final musicRepositoryProvider = Provider<MusicRepository>(
  (ref) => MusicRepositoryImpl(
    localDataSource: ref.watch(musicLocalDataSourceProvider),
    audioQuery: ref.watch(audioQueryProvider),
  ),
);

final downloaderRepositoryProvider = Provider<DownloaderRepository>(
  (ref) => DownloaderRepositoryImpl(
    localDataSource: ref.watch(downloaderLocalDataSourceProvider),
    remoteDataSource: ref.watch(downloaderRemoteDataSourceProvider),
  ),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(dataSource: ref.watch(authDataSourceProvider)),
);

final vaultRepositoryProvider = Provider<VaultRepository>(
  (ref) => VaultRepositoryImpl(
    encryptionDataSource: ref.watch(fileEncryptionDataSourceProvider),
    metadataDataSource: ref.watch(vaultDataSourceProvider),
    authDataSource: ref.watch(authDataSourceProvider),
    // ✅ _vaultDir يُحسب داخلياً في كل عملية عبر _getVaultDir()
  ),
);

// ── Video Use Cases ────────────────────────────────────────────────────────

final getAllVideosProvider = Provider((ref) => GetAllVideos(ref.watch(videoRepositoryProvider)));
final syncVideoLibraryProvider = Provider((ref) => SyncVideoLibrary(ref.watch(videoRepositoryProvider)));
final getVideosByFolderProvider = Provider((ref) => GetVideosByFolder(ref.watch(videoRepositoryProvider)));
final getAllFoldersProvider = Provider((ref) => GetAllVideoFolders(ref.watch(videoRepositoryProvider)));
final searchVideosProvider = Provider((ref) => SearchVideos(ref.watch(videoRepositoryProvider)));
final savePlaybackPositionProvider = Provider((ref) => SavePlaybackPosition(ref.watch(videoRepositoryProvider)));
final markVideoAsPlayedProvider = Provider((ref) => RecordVideoPlay(ref.watch(videoRepositoryProvider)));
final toggleVideoFavoriteProvider = Provider((ref) => ToggleFavourite(ref.watch(videoRepositoryProvider)));
final getFavoriteVideosProvider = Provider((ref) => GetFavouriteVideos(ref.watch(videoRepositoryProvider)));
final generateThumbnailProvider = Provider((ref) => GenerateThumbnail(ref.watch(videoRepositoryProvider)));
final getRecentlyPlayedVideosProvider = Provider((ref) => GetRecentlyPlayed(ref.watch(videoRepositoryProvider)));

// ── Music Use Cases ────────────────────────────────────────────────────────

final getAllTracksProvider = Provider((ref) => GetAllTracks(ref.watch(musicRepositoryProvider)));
final getAllAlbumsProvider = Provider((ref) => GetAllAlbums(ref.watch(musicRepositoryProvider)));
final getAllArtistsProvider = Provider((ref) => GetAllArtists(ref.watch(musicRepositoryProvider)));
final syncMusicLibraryProvider = Provider((ref) => SyncMusicLibrary(ref.watch(musicRepositoryProvider)));
final searchTracksProvider = Provider((ref) => SearchTracks(ref.watch(musicRepositoryProvider)));
final getTracksByAlbumProvider = Provider((ref) => GetTracksByAlbum(ref.watch(musicRepositoryProvider)));
final getTracksByArtistProvider = Provider((ref) => GetTracksByArtist(ref.watch(musicRepositoryProvider)));
final toggleFavoriteTrackProvider = Provider((ref) => ToggleMusicFavourite(ref.watch(musicRepositoryProvider)));
final getAllPlaylistsProvider = Provider((ref) => GetAllPlaylists(ref.watch(musicRepositoryProvider)));
final createPlaylistProvider = Provider((ref) => CreatePlaylist(ref.watch(musicRepositoryProvider)));
final deletePlaylistProvider = Provider((ref) => DeletePlaylist(ref.watch(musicRepositoryProvider)));
final addTrackToPlaylistProvider = Provider((ref) => AddTrackToPlaylist(ref.watch(musicRepositoryProvider)));
final getRecentlyPlayedTracksProvider = Provider((ref) => GetRecentlyPlayedTracks(ref.watch(musicRepositoryProvider)));
final recordMusicPlayProvider = Provider((ref) => RecordMusicPlay(ref.watch(musicRepositoryProvider)));


// ── Downloader Use Cases ───────────────────────────────────────────────────

final probeUrlProvider = Provider((ref) => ValidateDownloadUrl(ref.watch(downloaderRepositoryProvider)));
final startDownloadProvider = Provider((ref) => StartDownload(ref.watch(downloaderRepositoryProvider)));
final pauseDownloadProvider = Provider((ref) => PauseDownload(ref.watch(downloaderRepositoryProvider)));
final resumeDownloadProvider = Provider((ref) => ResumeDownload(ref.watch(downloaderRepositoryProvider)));
final cancelDownloadProvider = Provider((ref) => CancelDownload(ref.watch(downloaderRepositoryProvider)));
final retryDownloadProvider = Provider((ref) => RetryDownload(ref.watch(downloaderRepositoryProvider)));
final getAllDownloadsProvider = Provider((ref) => GetAllDownloads(ref.watch(downloaderRepositoryProvider)));
final deleteDownloadProvider = Provider((ref) => DeleteDownloadRecord(ref.watch(downloaderRepositoryProvider)));
final updateDownloadStatusProvider = Provider((ref) => UpdateDownloadStatus(ref.watch(downloaderRepositoryProvider)));

// ── Security Use Cases ─────────────────────────────────────────────────────

final isPinSetProvider = Provider((ref) => IsPinSet(ref.watch(authRepositoryProvider)));
final setupPinProvider = Provider((ref) => SetupPin(ref.watch(authRepositoryProvider)));
final validatePinProvider = Provider((ref) => ValidatePin(ref.watch(authRepositoryProvider)));
final authenticateWithBiometricProvider = Provider((ref) => AuthenticateWithBiometric(ref.watch(vaultRepositoryProvider)));
final getAuthStateProvider = Provider((ref) => GetAuthState(ref.watch(authRepositoryProvider)));

// Vault
final getVaultItemsProvider = Provider((ref) => GetVaultItems(ref.watch(vaultRepositoryProvider)));
final decryptAndRestoreFromVaultProvider = Provider((ref) => DecryptAndRestoreFromVault(ref.watch(vaultRepositoryProvider)));
final encryptAndMoveToVaultProvider = Provider((ref) => EncryptAndMoveToVault(ref.watch(vaultRepositoryProvider)));

