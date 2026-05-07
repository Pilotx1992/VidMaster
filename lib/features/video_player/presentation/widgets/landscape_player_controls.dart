import 'package:flutter/material.dart';

import '../../domain/entities/video_playback_state.dart';
import '../providers/video_player_notifier.dart';
import 'player_control_helpers.dart';
import 'player_quick_actions_row.dart';
import 'player_seek_section.dart';
import 'player_speed_menu_button.dart';
import 'player_subtitle_track_menu.dart';
import 'player_top_bar.dart';
import 'player_transport_controls.dart';

class LandscapePlayerControls extends StatelessWidget {
  final VideoPlayerState state;
  final VideoPlayerNotifier notifier;
  final VoidCallback onBack;
  final VoidCallback onPickSubtitle;
  final VoidCallback onSubtitleStyling;

  const LandscapePlayerControls({
    super.key,
    required this.state,
    required this.notifier,
    required this.onBack,
    required this.onPickSubtitle,
    required this.onSubtitleStyling,
  });

  @override
  Widget build(BuildContext context) {
    final title = state.currentVideo?.name ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PlayerTopBar(
          title: title,
          onBack: onBack,
          actions: [
            IconButton(
              tooltip: 'Open subtitle file',
              icon: const Icon(Icons.subtitles_outlined, color: Colors.white),
              onPressed: onPickSubtitle,
            ),
            PlayerSubtitleTrackMenu(state: state, notifier: notifier),
            IconButton(
              tooltip: 'Subtitle style',
              icon: const Icon(Icons.style, color: Colors.white),
              onPressed: onSubtitleStyling,
            ),
            IconButton(
              tooltip:
                  'Aspect: ${aspectRatioModeLabel(state.aspectRatioMode)} — tap to change',
              icon: const Icon(Icons.aspect_ratio, color: Colors.white),
              onPressed: notifier.cycleAspectRatio,
            ),
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
        PlayerQuickActionsRow(
          state: state,
          notifier: notifier,
          onPickSubtitle: onPickSubtitle,
          onSubtitleStyling: onSubtitleStyling,
          compact: true,
        ),
        const Spacer(),
        if (state.canSeek)
          PlayerSeekSection(
            position: state.position,
            duration: state.duration,
            onSeek: (d) => notifier.seek(d),
          ),
        PlayerTransportControls(
          isPlaying: state.isPlaying,
          centerIconSize: 64,
          onPlayPause: () => state.isPlaying ? notifier.pause() : notifier.play(),
          onReplay10: () => notifier.seek(
            state.position - const Duration(seconds: 10),
          ),
          onForward10: () => notifier.seek(
            state.position + const Duration(seconds: 10),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
