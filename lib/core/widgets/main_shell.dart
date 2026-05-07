import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'icons/custom_music_note_icon.dart';
import '../../features/music_player/presentation/widgets/mini_player_bar.dart';
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
    final location = GoRouterState.of(context).matchedLocation;

    // Listen for detected links from clipboard
    ref.listen(detectedLinkProvider, (previous, next) {
      if (next != null) {
        _showLinkDetectedSnackBar(next);
      }
    });

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
  }

  void _showLinkDetectedSnackBar(String url) {
    final previewLength = url.length > 30 ? 30 : url.length;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.link,
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
    switch (index) {
      case 0:
        context.go(AppRoutes.videos);
        break;
      case 1:
        context.go(AppRoutes.music);
        break;
      case 2:
        context.go(AppRoutes.playlists);
        break;
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
              ? Colors.black
              : Colors.white,
          border: Border(
            top: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
          ),
        ),
        // RTL would reverse tab order; keep XPlayer-like order on all locales.
        child: Row(
          textDirection: TextDirection.ltr,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _NavItem(
              icon: Icons.movie_creation_outlined,
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
              icon: Icons.playlist_play_rounded,
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

  static const _active = Color(0xFF00C853);
  static const _inactive = Color(0xFF9E9E9E);

  @override
  Widget build(BuildContext context) {
    final color = selected ? _active : _inactive;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (iconWidgetBuilder != null)
              iconWidgetBuilder!(color)
            else
              Icon(icon, size: 30, color: color),
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
