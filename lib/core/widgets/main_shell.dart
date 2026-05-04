import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
      body: Stack(
        children: [
          widget.child,
          const Positioned(
            left: 0,
            right: 0,
            bottom: kBottomNavigationBarHeight,
            child: MiniPlayerBar(),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indexFromLocation(location),
        onDestinationSelected: (i) => _navigate(context, i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.video_library_outlined),
            selectedIcon: Icon(Icons.video_library),
            label: 'Videos',
          ),
          NavigationDestination(
            icon: Icon(Icons.music_note_outlined),
            selectedIcon: Icon(Icons.music_note),
            label: 'Music',
          ),
          NavigationDestination(
            icon: Icon(Icons.download_outlined),
            selectedIcon: Icon(Icons.download),
            label: 'Downloads',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  void _showLinkDetectedSnackBar(String url) {
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
                'Link detected: ${url.substring(0, url.length.clamp(0, 30))}...',
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
            builder: (context) => QualitySelectionSheet(result: extractionResult),
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
    if (location.startsWith(AppRoutes.downloads)) return 2;
    if (location.startsWith(AppRoutes.settings)) return 3;
    return 0;
  }

  void _navigate(BuildContext context, int index) {
    switch (index) {
      case 0: context.go(AppRoutes.videos);
      case 1: context.go(AppRoutes.music);
      case 2: context.go(AppRoutes.downloads);
      case 3: context.go(AppRoutes.settings);
    }
  }
}
