import 'dart:async';

import 'package:flutter/material.dart';

import '../../domain/entities/video_playback_state.dart';
import '../providers/video_player_notifier.dart';
import 'player_more_menu.dart';
import 'player_quick_actions_row.dart';
import 'player_seek_section.dart';
import 'player_top_bar.dart';
import 'player_transport_controls.dart';
import 'video_cast_button.dart';

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
    // Surface Previous/Next only when an actual queue is bound. Mirrors the
    // portrait host's rule so behavior is consistent across orientations.
    final hasQueue = state.queue.length > 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PlayerTopBar(
          title: title,
          onBack: onBack,
          actions: [
            const VideoCastButton(),
            PlayerMoreMenu(
              onPickSubtitle: onPickSubtitle,
              onSubtitleStyling: onSubtitleStyling,
            ),
          ],
        ),
        // CC (subtitle) is now part of the compact quick-actions row right
        // next to Aspect (Fit), per UX request. The widget itself still
        // reuses [PlayerSubtitleTrackMenu] under the hood, so the callback
        // and track list are unchanged.
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: PlayerQuickActionsRow(
              state: state,
              notifier: notifier,
              compact: true,
              showLabels: false,
              showSubtitle: true,
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
            // Top padding controls the gradient's "visible content" start;
            // the seek bar's screen position is governed by the bottom
            // padding because the panel is anchored to the screen bottom.
            // Bottom went 8 → 4 to nudge Seek + Transport one notch lower
            // while still leaving a small cushion above `bottomPad`.
            padding: EdgeInsets.only(top: 32, bottom: 4 + bottomPad),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (state.canSeek)
                  PlayerSeekSection(
                    position: state.position,
                    duration: state.duration,
                    onDragStart: notifier.pauseControlsAutoHide,
                    onDragEnd: notifier.resumeControlsAutoHide,
                    onSeekEnd: (d) => notifier.seek(d),
                  ),
                PlayerTransportControls(
                  isPlaying: state.isPlaying,
                  centerIconSize: 64,
                  showPrevious: hasQueue,
                  showNext: hasQueue,
                  onLock: () {
                    notifier.bumpControlsAutoHide();
                    notifier.toggleLockMode();
                  },
                  // Aspect joins Lock on the row's edge anchors. Removed
                  // from the quick-actions row above so we don't surface the
                  // same affordance twice.
                  onAspect: () {
                    notifier.bumpControlsAutoHide();
                    notifier.cycleAspectRatio();
                  },
                  onPlayPause: () {
                    notifier.bumpControlsAutoHide();
                    unawaited(notifier.togglePlayPause());
                  },
                  onReplay10: () {
                    notifier.bumpControlsAutoHide();
                    notifier.seek(
                      state.position - const Duration(seconds: 10),
                    );
                  },
                  onForward10: () {
                    notifier.bumpControlsAutoHide();
                    notifier.seek(
                      state.position + const Duration(seconds: 10),
                    );
                  },
                  // Null callbacks at queue boundaries grey out the buttons
                  // via IconButton's disabled state, keeping the centered
                  // playback group geometry stable.
                  onPrevious: state.hasPrevious
                      ? () {
                          notifier.bumpControlsAutoHide();
                          unawaited(notifier.playPrevious());
                        }
                      : null,
                  onNext: state.hasNext
                      ? () {
                          notifier.bumpControlsAutoHide();
                          unawaited(notifier.playNext());
                        }
                      : null,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
