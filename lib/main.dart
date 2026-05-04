import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:media_kit/media_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'di.dart';
import 'features/music_player/data/audio_handler.dart';
import 'l10n/app_localizations.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_chrome_cast/flutter_chrome_cast.dart';
import 'features/video_player/presentation/widgets/mini_player_layer.dart';
import 'dart:io';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ⚠️ REQUIRED: Must be called before creating any Player instance.
  // Without this, media_kit will crash with a fatal native error.
  MediaKit.ensureInitialized();

  await FlutterDownloader.initialize(debug: true, ignoreSsl: true);

  // Initialize Google Cast context
  const appId = 'CC1AD845';
  GoogleCastOptions? castOptions;
  if (Platform.isAndroid) {
    castOptions = GoogleCastOptionsAndroid(
      appId: appId,
      stopCastingOnAppTerminated: true,
    );
  } else if (Platform.isIOS) {
    castOptions = IOSGoogleCastOptions(
      GoogleCastDiscoveryCriteriaInitialize.initWithApplicationID(appId),
      stopCastingOnAppTerminated: true,
    );
  }

  if (castOptions != null) {
    await GoogleCastContext.instance.setSharedInstanceWithOptions(castOptions);
  }

  final isar = await initIsar();
  final vaultBox = await initHive();
  final sharedPreferences = await SharedPreferences.getInstance();

  final equalizer = AndroidEqualizer();
  final audioPlayer = AudioPlayer(
    audioPipeline: AudioPipeline(androidAudioEffects: [equalizer]),
  );

  final audioHandler = await AudioService.init(
    builder: () => VidMasterAudioHandler(audioPlayer),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.vidmaster.app.audio',
      androidNotificationChannelName: 'VidMaster Playback',
      androidNotificationOngoing: true,
    ),
  );

  runApp(
    ProviderScope(
      overrides: [
        isarProvider.overrideWithValue(isar),
        vaultBoxProvider.overrideWithValue(vaultBox),
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        androidEqualizerProvider.overrideWithValue(equalizer),
        audioPlayerProvider.overrideWithValue(audioPlayer),
        audioHandlerProvider.overrideWithValue(audioHandler),
      ],
      child: const VidMasterApp(),
    ),
  );
}

class VidMasterApp extends StatelessWidget {
  const VidMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: AppRouter.router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) {
        return Stack(
          children: [
            child!,
            const MiniPlayerLayer(),
          ],
        );
      },
    );
  }
}

