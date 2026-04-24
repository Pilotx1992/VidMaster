import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/music_player/presentation/widgets/mini_player_bar.dart';
import '../router/app_router.dart';

class MainShell extends ConsumerWidget {
  final Widget child;
  const MainShell({required this.child, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      body: Stack(
        children: [
          child,
          // Mini player sits above the bottom nav bar.
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
