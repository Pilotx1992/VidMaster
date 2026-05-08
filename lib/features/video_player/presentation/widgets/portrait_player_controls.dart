import 'dart:async';

import 'package:flutter/material.dart';

import '../../domain/entities/video_playback_state.dart';
import '../providers/video_player_notifier.dart';
import 'player_more_menu.dart';
import 'player_quick_actions_row.dart';
import 'player_seek_section.dart';
import 'player_subtitle_track_menu.dart';
import 'player_top_bar.dart';
import 'player_transport_controls.dart';

/// Bottom-focused panel: top stays minimal; quick actions + seek + transport sit low.
class PortraitPlayerControls extends StatelessWidget {
  final VideoPlayerState state;
  final VideoPlayerNotifier notifier;
  final VoidCallback onBack;
  final VoidCallback onPickSubtitle;
  final VoidCallback onSubtitleStyling;

  const PortraitPlayerControls({
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
    final bottomPad = MediaQuery.viewPaddingOf(context).bottom;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PlayerTopBar(
          title: title,
          onBack: onBack,
          actions: [
            PlayerSubtitleTrackMenu(state: state, notifier: notifier),
            PlayerMoreMenu(
              onPickSubtitle: onPickSubtitle,
              onSubtitleStyling: onSubtitleStyling,
            ),
          ],
        ),
        Expanded(
          child: IgnorePointer(
            ignoring: true,
            child: SizedBox.expand(),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.72),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border(
              top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(12, 16, 12, 12 + bottomPad),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PlayerQuickActionsRow(
                  state: state,
                  notifier: notifier,
                  compact: false,
                  showLabels: true,
                ),
                const SizedBox(height: 16),
                if (state.canSeek)
                  PlayerSeekSection(
                    position: state.position,
                    duration: state.duration,
                    onSeekEnd: (d) => notifier.seek(d),
                  ),
                PlayerTransportControls(
                  isPlaying: state.isPlaying,
                  centerIconSize: 76,
                  onPlayPause: () {
                    unawaited(notifier.togglePlayPause());
                  },
                  onReplay10: () => notifier.seek(
                    state.position - const Duration(seconds: 10),
                  ),
                  onForward10: () => notifier.seek(
                    state.position + const Duration(seconds: 10),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
