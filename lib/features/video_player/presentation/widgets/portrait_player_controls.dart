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

/// Top action row under the title, bottom panel with seek + transport.
/// Portrait keeps Lock in the action row (transport stays uncrowded).
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
    // Only surface Previous/Next when a real queue is bound. A single-item
    // queue (or no queue at all) leaves the transport row identical to the
    // pre-Phase-5 layout.
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
        // Small action row directly under the title — Mute, Subtitle, Speed.
        // Lock and Aspect were promoted to the transport row's left / right
        // edge anchors (see [PlayerTransportControls]), so this row stays
        // compact: just the affordances that don't fit there naturally.
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
          child: PlayerQuickActionsRow(
            state: state,
            notifier: notifier,
            compact: true,
            showLabels: false,
            showSubtitle: true,
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
            color: Colors.black.withValues(alpha: 0.72),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border(
              top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
            ),
          ),
          child: Padding(
            // Bottom inner padding was 12 → 4 → 0 across iterations. The seek
            // bar sits as low as it can without intruding on `bottomPad`
            // (system gesture inset). The 88 dp min constraint on the
            // transport buttons still provides visual breathing room around
            // the icons, so 0 dp inner bottom padding is safe to tap.
            padding: EdgeInsets.fromLTRB(12, 12, 12, bottomPad),
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
                  // Smaller play/pause in portrait — the row is sparser now
                  // (±10s removed), so a 60 dp glyph keeps the visual
                  // hierarchy `Play/Pause > Prev/Next` without dominating
                  // the bottom panel.
                  centerIconSize: 60,
                  // ±10s buttons are hidden in portrait per UX request — the
                  // same affordance is still reachable via the slider and the
                  // double-tap-left / double-tap-right gestures (Phase 3).
                  showPrevious: hasQueue,
                  showNext: hasQueue,
                  showReplay10: false,
                  showForward10: false,
                  // Lock anchored to the row's left, Aspect to the right.
                  // Both bump auto-hide so the panel doesn't disappear mid-
                  // tap. They no longer live in the quick-actions row.
                  onLock: () {
                    notifier.bumpControlsAutoHide();
                    notifier.toggleLockMode();
                  },
                  onAspect: () {
                    notifier.bumpControlsAutoHide();
                    notifier.cycleAspectRatio();
                  },
                  onPlayPause: () {
                    notifier.bumpControlsAutoHide();
                    unawaited(notifier.togglePlayPause());
                  },
                  // onReplay10 / onForward10 are still wired but never
                  // invoked because the buttons aren't rendered here. Kept
                  // non-null so PlayerTransportControls' required-callback
                  // contract is satisfied without forcing every caller to
                  // think about it.
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
                  // Null callbacks at queue boundaries (first / last item)
                  // gray the buttons out via IconButton's built-in disabled
                  // state — the row geometry stays stable across the queue.
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
