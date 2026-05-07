import 'package:flutter/material.dart';

import '../../domain/entities/video_playback_state.dart';
import '../providers/video_player_notifier.dart';
import 'player_control_helpers.dart';
import 'player_speed_menu_button.dart';
import 'player_subtitle_track_menu.dart';

/// Horizontal quick actions: lock, mute, aspect cycle, CC, speed, more.
class PlayerQuickActionsRow extends StatelessWidget {
  final VideoPlayerState state;
  final VideoPlayerNotifier notifier;
  final VoidCallback onPickSubtitle;
  final VoidCallback onSubtitleStyling;
  final bool compact;

  const PlayerQuickActionsRow({
    super.key,
    required this.state,
    required this.notifier,
    required this.onPickSubtitle,
    required this.onSubtitleStyling,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final muted = state.volume < 0.01;
    final iconSize = compact ? 20.0 : 22.0;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            IconButton(
              tooltip: 'Lock screen',
              iconSize: iconSize + 4,
              icon: const Icon(Icons.lock_outline, color: Colors.white),
              onPressed: notifier.toggleLockMode,
            ),
            IconButton(
              tooltip: muted ? 'Unmute' : 'Mute',
              iconSize: iconSize + 4,
              icon: Icon(
                muted ? Icons.volume_off : Icons.volume_up,
                color: Colors.white,
              ),
              onPressed: () {
                if (muted) {
                  notifier.setVolume(1.0);
                } else {
                  notifier.setVolume(0.0);
                }
              },
            ),
            IconButton(
              tooltip:
                  'Aspect: ${aspectRatioModeLabel(state.aspectRatioMode)} — tap to change',
              iconSize: iconSize + 4,
              icon: const Icon(Icons.fit_screen, color: Colors.white),
              onPressed: notifier.cycleAspectRatio,
            ),
            PlayerSubtitleTrackMenu(state: state, notifier: notifier),
            PlayerSpeedMenuButton(
              speed: state.playbackSpeed,
              onSelected: (v) => notifier.setPlaybackSpeed(v),
            ),
            PopupMenuButton<String>(
              tooltip: 'More',
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (v) {
                if (v == 'pick') onPickSubtitle();
                if (v == 'style') onSubtitleStyling();
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'pick', child: Text('Open subtitle file')),
                PopupMenuItem(value: 'style', child: Text('Subtitle style')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
