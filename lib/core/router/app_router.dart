import 'package:go_router/go_router.dart';
import 'package:vidmaster/core/widgets/main_shell.dart';
import 'package:vidmaster/features/video_player/presentation/screens/video_library_screen.dart';
import 'package:vidmaster/features/music_player/presentation/screens/music_library_screen.dart';
import 'package:vidmaster/features/downloader/presentation/screens/downloads_screen.dart';
import 'package:vidmaster/features/downloader/presentation/screens/video_browser_screen.dart';
import 'package:vidmaster/features/settings/presentation/screens/settings_screen.dart';
import 'package:vidmaster/features/security/presentation/screens/lock_screen.dart';
import 'package:vidmaster/features/security/presentation/screens/vault_screen.dart';
import 'package:vidmaster/features/music_player/presentation/screens/now_playing_screen.dart';
import 'package:vidmaster/features/music_player/presentation/screens/equalizer_screen.dart';
import 'package:vidmaster/features/video_player/presentation/screens/video_player_screen.dart';

import 'package:vidmaster/features/music_player/domain/entities/audio_track_entity.dart';
import 'package:vidmaster/features/video_player/domain/entities/video_file.dart';

class AppRoutes {
  static const videos = '/videos';
  static const music = '/music';
  static const downloads = '/downloads';
  static const videoBrowser = '/video-browser';
  static const settings = '/settings';
  static const lock = '/lock';
  static const vault = '/vault';
  static const nowPlaying = '/now-playing';
  static const player = '/player';
  static const equalizer = '/equalizer';
}

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/videos',
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
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
            path: '/video-browser',
            builder: (context, state) => const VideoBrowserScreen(),
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
              final extra = state.extra;
              if (extra is Map<String, dynamic>) {
                try {
                  return NowPlayingScreen(
                    track: extra['track'] as AudioTrackEntity,
                    queue: extra['queue'] as List<AudioTrackEntity>,
                    queueIndex: extra['queueIndex'] as int,
                  );
                } catch (e) {
                  return const _ErrorScreen(message: 'Invalid arguments for Now Playing');
                }
              }
              return const _ErrorScreen(message: 'Missing arguments for Now Playing');
            },
          ),
          GoRoute(
            path: '/equalizer',
            builder: (context, state) => const EqualizerScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/player',
        name: 'video_player',
        builder: (context, state) {
          final extra = state.extra;
          if (extra is VideoPlayerArgs) {
            return VideoPlayerScreen(args: extra);
          } else if (extra is Map) {
            try {
              final args = VideoPlayerArgs(
                video: extra['video'] as VideoFile,
                queue: extra['queue'] as List<VideoFile>?,
              );
              return VideoPlayerScreen(args: args);
            } catch (e) {
              return const _ErrorScreen(message: 'Invalid video player arguments');
            }
          }
          return const _ErrorScreen(message: 'Missing video player arguments');
        },
      ),
    ],
  );
}

class _ErrorScreen extends StatelessWidget {
  final String message;
  const _ErrorScreen({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(message, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.videos),
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}