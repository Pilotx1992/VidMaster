import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_theme.dart';
import 'icons/custom_music_note_icon.dart';
import '../../features/music_player/presentation/widgets/mini_player_bar.dart';
import '../../features/music_player/presentation/providers/music_player_provider.dart';
import '../../features/video_player/presentation/providers/mini_player_provider.dart';
import '../../features/video_player/presentation/providers/video_player_provider.dart';
import '../../features/downloader/application/services/clipboard_monitor.dart';
import '../../features/downloader/presentation/widgets/quality_selection_sheet.dart';
import '../../di.dart';
import '../router/app_router.dart';

class MainShell extends ConsumerStatefulWidget {
  final Widget child;
  const MainShell({required this.child, super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  @override
  void initState() {
    super.initState();
    // Start clipboard monitoring and storage cleanup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(clipboardMonitorProvider).start();
      ref.read(cleanupServiceProvider).cleanTempFiles();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Avoid [GoRouterState.of] here — it can throw if ModalRoute / registry wiring
    // does not match expectations; read from [AppRouter] instead (same as
    // [MiniPlayerLayer] in MaterialApp.builder).
    ref.listen(detectedLinkProvider, (previous, next) {
      if (next != null) {
        _showLinkDetectedSnackBar(next);
      }
    });

    return ListenableBuilder(
      listenable: AppRouter.router.routerDelegate,
      builder: (context, _) {
        final location = AppRouter.router.state.matchedLocation;
        return Scaffold(
          body: widget.child,
          bottomNavigationBar: Directionality(
            textDirection: TextDirection.ltr,
            child: Column(
              textDirection: TextDirection.ltr,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const MiniPlayerBar(),
                _PremiumBottomBar(
                  selectedIndex: _indexFromLocation(location),
                  onTap: (i) => _navigate(context, i),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLinkDetectedSnackBar(String url) {
    final previewLength = url.length > 30 ? 30 : url.length;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Symbols.link,
              color: Theme.of(context).colorScheme.onInverseSurface,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Link detected: ${url.substring(0, previewLength)}...',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 10),
        action: SnackBarAction(
          label: 'DOWNLOAD',
          onPressed: () => _startDownloadFlow(url),
        ),
      ),
    );
  }

  Future<void> _startDownloadFlow(String url) async {
    // Show a loading dialog while extracting
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final result = await ref.read(extractMetadataUseCaseProvider).call(url);

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      result.fold(
        (failure) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Extraction failed: ${failure.message}')),
        ),
        (extractionResult) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) =>
                QualitySelectionSheet(result: extractionResult),
          );
        },
      );
    } catch (e) {
      if (mounted) Navigator.pop(context);
    }

    // Clear the detected link after action
    ref.read(detectedLinkProvider.notifier).state = null;
  }

  int _indexFromLocation(String location) {
    if (location.startsWith(AppRoutes.music)) return 1;
    if (location.startsWith(AppRoutes.playlists)) return 2;
    return 0;
  }

  void _navigate(BuildContext context, int index) {
    // Reading the location at tap-time (not from `build`'s captured value) so
    // rapid Music↔Video taps always see the latest matched route.
    final currentLocation = AppRouter.router.state.matchedLocation;
    final currentIndex = _indexFromLocation(currentLocation);

    if (kDebugMode) {
      String name(int i) => switch (i) {
            0 => 'Video',
            1 => 'Music',
            2 => 'Playlist',
            _ => 'Unknown($i)',
          };
      debugPrint(
        '[MainShellTab] from=${name(currentIndex)}($currentIndex) '
        'to=${name(index)}($index) location=$currentLocation',
      );
    }

    switch (index) {
      case 0:
        // Music → Video: kill the music mini-bar so it doesn't hover over
        // the video library. `stopAndClear` is the only way to dismiss the
        // bar (its visibility is driven by `currentTrack != null`) and it
        // doubles as audio focus — exactly what the user expects when they
        // explicitly switch to a different media context.
        if (currentIndex == 1) {
          if (kDebugMode) {
            debugPrint('[MainShellTab] entering Video -> closing music mini');
          }
          _closeMusicMiniBar();
        }
        context.go(AppRoutes.videos);
        break;
      case 1:
        // Video → Music: dismiss the video mini-layer and pause playback.
        // Mirrors the swipe-to-dismiss gesture on the mini layer itself; the
        // underlying `videoPlayerProvider` keeps its currentVideo so the user
        // can still reopen via the library.
        if (currentIndex == 0) {
          if (kDebugMode) {
            debugPrint('[MainShellTab] entering Music -> closing video mini');
          }
          _closeVideoMiniLayer();
        }
        context.go(AppRoutes.music);
        break;
      case 2:
        // Playlist tab is neutral — both minis stay as-is. (Per request:
        // auto-close is scoped to Music↔Video transitions only.)
        context.go(AppRoutes.playlists);
        break;
    }
  }

  void _closeMusicMiniBar() {
    final musicState = ref.read(musicPlayerProvider);
    if (kDebugMode) {
      debugPrint(
        '[MainShellTab] _closeMusicMiniBar called. '
        'currentTrack=${musicState.currentTrack?.title} '
        'isPlaying=${musicState.isPlaying}',
      );
    }
    if (musicState.currentTrack == null) {
      if (kDebugMode) {
        debugPrint('[MainShellTab] music mini already empty, skipping');
      }
      return;
    }
    ref.read(musicPlayerProvider.notifier).stopAndClear();
    if (kDebugMode) {
      debugPrint('[MainShellTab] stopAndClear() invoked');
    }
  }

  void _closeVideoMiniLayer() {
    final mini = ref.read(miniPlayerProvider);
    if (kDebugMode) {
      debugPrint(
        '[MainShellTab] _closeVideoMiniLayer called. '
        'miniVisible=${mini.isVisible} miniVideo=${mini.video?.name}',
      );
    }
    if (!mini.isVisible) {
      if (kDebugMode) {
        debugPrint('[MainShellTab] video mini already hidden, skipping');
      }
      return;
    }
    ref.read(miniPlayerProvider.notifier).hide();
    // Pause is best-effort — if the engine isn't bound or already paused,
    // this is a no-op. Wrapped just in case the video provider is in a
    // weird transitional state during the tab swap.
    try {
      ref.read(videoPlayerProvider.notifier).pause();
    } catch (_) {}
    if (kDebugMode) {
      debugPrint('[MainShellTab] mini hide() + video pause() invoked');
    }
  }
}

class _PremiumBottomBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  const _PremiumBottomBar({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: kBottomNavigationBarHeight,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppTheme.surfaceDark
              : Colors.white,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppTheme.outlineDark
                  : Colors.black.withValues(alpha: 0.08),
            ),
          ),
          boxShadow: Theme.of(context).brightness == Brightness.dark
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    offset: const Offset(0, -2),
                    blurRadius: 8,
                  ),
                ]
              : null,
        ),
        // RTL would reverse tab order; keep XPlayer-like order on all locales.
        child: Row(
          textDirection: TextDirection.ltr,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _NavItem(
              icon: Symbols.movie_creation,
              label: 'Video',
              selected: selectedIndex == 0,
              onTap: () => onTap(0),
            ),
            _NavItem(
              iconWidgetBuilder: (color) => CustomMusicNoteIcon(
                color: color,
                filled: selectedIndex == 1,
                size: 26,
              ),
              label: 'Music',
              selected: selectedIndex == 1,
              onTap: () => onTap(1),
            ),
            _NavItem(
              icon: Symbols.playlist_play_rounded,
              label: 'Playlist',
              selected: selectedIndex == 2,
              onTap: () => onTap(2),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData? icon;
  final Widget Function(Color color)? iconWidgetBuilder;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.iconWidgetBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = selected ? AppTheme.secondaryColor : cs.onSurface.withValues(alpha: 0.45);
    return Expanded(
      child: InkWell(
        onTap: onTap,
        splashColor: AppTheme.secondaryColor.withValues(alpha: 0.12),
        highlightColor: AppTheme.secondaryColor.withValues(alpha: 0.06),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Fixed icon slot keeps all 3 tabs the same vertical height
            // regardless of the underlying icon's intrinsic size (Material
            // icons render at 30 dp, the custom SVG at 26 dp). Without this,
            // the Music column would be 4 dp shorter and `MainAxisAlignment
            // .center` would shift its label ~2 dp upward.
            SizedBox(
              height: 30,
              child: Center(
                child: iconWidgetBuilder != null
                    ? iconWidgetBuilder!(color)
                    : Icon(icon, size: 30, color: color),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
