import 'package:go_router/go_router.dart';
import 'package:vidmaster/main_screen.dart';
import 'package:vidmaster/features/video_player/presentation/screens/video_library_screen.dart';
import 'package:vidmaster/features/music_player/presentation/screens/music_library_screen.dart';
import 'package:vidmaster/features/downloader/presentation/screens/downloads_screen.dart';
import 'package:vidmaster/features/settings/presentation/screens/settings_screen.dart';
import 'package:vidmaster/features/security/presentation/screens/lock_screen.dart';
import 'package:vidmaster/features/security/presentation/screens/vault_screen.dart';
import 'package:vidmaster/features/music_player/presentation/screens/now_playing_screen.dart';
import 'package:vidmaster/features/video_player/presentation/screens/video_player_screen.dart';
import 'package:vidmaster/features/video_player/domain/entities/video_entity.dart';
import 'package:vidmaster/features/music_player/domain/entities/audio_track_entity.dart';

class AppRoutes {
  static const videos = '/videos';
  static const music = '/music';
  static const downloads = '/downloads';
  static const settings = '/settings';
  static const lock = '/lock';
  static const vault = '/vault';
  static const nowPlaying = '/now-playing';
  static const player = '/player';
}

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/videos',
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainScreen(child: child),
        routes: [
          GoRoute(
            path: '/videos',
            builder: (context, state) => const VideoLibraryScreen(),
          ),
          GoRoute(
            path: '/music',
            builder: (context, state) => const MusicLibraryScreen(),
          ),
          GoRoute(
            path: '/downloads',
            builder: (context, state) => const DownloadsScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: '/lock',
            builder: (context, state) => const LockScreen(),
          ),
          GoRoute(
            path: '/vault',
            builder: (context, state) => const VaultScreen(),
          ),
          GoRoute(
            path: '/now-playing',
            builder: (context, state) {
              final args = state.extra as Map<String, dynamic>;
              return NowPlayingScreen(
                track: args['track'] as AudioTrackEntity,
                queue: args['queue'] as List<AudioTrackEntity>,
                queueIndex: args['queueIndex'] as int,
              );
            },
          ),
          GoRoute(
            path: '/player',
            builder: (context, state) {
              final args = state.extra as VideoPlayerArgs;
              return VideoPlayerScreen(args: args);
            },
          ),
        ],
      ),
    ],
  );
}