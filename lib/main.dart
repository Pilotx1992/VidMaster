import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:just_audio/just_audio.dart';
import 'package:media_kit/media_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/music_player/data/audio_handler.dart';
import 'features/settings/presentation/providers/settings_provider.dart';
import 'di.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── media_kit: must be called before any Player() is created ──────────────
  MediaKit.ensureInitialized();

  // ── audio_service: must be initialized before any AudioPlayer is created ───
  // Creates a single AudioPlayer instance shared across the app lifetime.
  // The Foreground Service (foregroundServiceType="mediaPlayback") is started
  // automatically by audio_service when playback begins.
  final audioPlayer = AudioPlayer();
  final audioHandler = await AudioService.init(
    builder: () => VidMasterAudioHandler(audioPlayer),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.vidmaster.audio',
      androidNotificationChannelName: 'VidMaster Music',
      androidNotificationChannelDescription: 'Music playback controls',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
      notificationColor: Color(0xFF1565C0),
    ),
  );

  // ── flutter_downloader: initialize WorkManager + Foreground Service ────────
  await FlutterDownloader.initialize(debug: true);

  // ── Databases Initialization ──────────────────────────────────────────────
  
  // 1. Initialize Isar Database (Your actual local database)
  final isar = await initIsar();

  // 2. Initialize Hive (For the Encrypted Vault Metadata)
  final vaultBox = await initHive();

  // ── Persistence: SharedPreferences for app settings ──────────────────────
  final sharedPrefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        isarProvider.overrideWithValue(isar),
        vaultBoxProvider.overrideWithValue(vaultBox),
        audioHandlerProvider.overrideWithValue(audioHandler),
        audioPlayerProvider.overrideWithValue(audioPlayer),
        sharedPreferencesProvider.overrideWithValue(sharedPrefs),
      ],
      child: const VidMasterApp(),
    ),
  );
}

class VidMasterApp extends ConsumerWidget {
  const VidMasterApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp.router(
      title: 'VidMaster',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.themeMode,
      routerConfig: AppRouter.router,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('ar'), // Arabic
      ],
      locale: Locale(settings.locale),
      debugShowCheckedModeBanner: false,
    );
  }
}
