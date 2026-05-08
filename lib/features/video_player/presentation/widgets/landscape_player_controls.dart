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

/// Overlay on video: minimal top bar, compact quick row, bottom gradient + seek + transport.
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
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: PlayerQuickActionsRow(
              state: state,
              notifier: notifier,
              compact: true,
              showLabels: false,
            ),
          ),
        ),
        Expanded(
          child: IgnorePointer(
            ignoring: true,
            child: SizedBox.expand(),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.55),
                Colors.black.withValues(alpha: 0.88),
              ],
              stops: const [0.0, 0.45, 1.0],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(top: 24, bottom: 8 + bottomPad),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (state.canSeek)
                  PlayerSeekSection(
                    position: state.position,
                    duration: state.duration,
                    onSeekEnd: (d) => notifier.seek(d),
                  ),
                PlayerTransportControls(
                  isPlaying: state.isPlaying,
                  centerIconSize: 64,
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
