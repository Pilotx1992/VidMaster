import 'package:flutter/material.dart';

import '../../domain/entities/video_playback_state.dart';
import '../providers/video_player_notifier.dart';
import 'player_control_helpers.dart';
import 'player_speed_menu_button.dart';
import 'player_subtitle_track_menu.dart';

/// Mute · (Lock) · (Subtitle) · (Aspect) · Speed. Lock / Subtitle / Aspect are
/// opt-in via [showLock] / [showSubtitle] / [showAspect] — once Lock and
/// Aspect were promoted to the transport row's edge anchors, this row hides
/// them by default so the surface stays uncrowded.
class PlayerQuickActionsRow extends StatelessWidget {
  final VideoPlayerState state;
  final VideoPlayerNotifier notifier;
  final bool compact;
  final bool showLabels;
  final bool showLock;
  final bool showSubtitle;

  /// Render the Aspect-ratio chip inside this row. Defaults to `false` because
  /// the transport-row right anchor now owns that affordance; pass `true` if a
  /// future surface wants the in-row chip back.
  final bool showAspect;

  const PlayerQuickActionsRow({
    super.key,
    required this.state,
    required this.notifier,
    this.compact = false,
    this.showLabels = false,
    this.showLock = false,
    this.showSubtitle = false,
    this.showAspect = false,
  });

  @override
  Widget build(BuildContext context) {
    final muted = state.volume < 0.01;
    final size = compact ? 44.0 : 52.0;
    final iconSz = compact ? 22.0 : 24.0;
    final labelStyle = TextStyle(
      color: Colors.white.withValues(alpha: 0.75),
      fontSize: 10,
      fontWeight: FontWeight.w500,
    );

    Widget circleTap({
      required IconData icon,
      required String tooltip,
      required VoidCallback onTap,
    }) {
      return Tooltip(
        message: tooltip,
        child: Material(
          color: Colors.white.withValues(alpha: 0.14),
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: size,
              height: size,
              child: Icon(icon, color: Colors.white, size: iconSz),
            ),
          ),
        ),
      );
    }

    Widget wrapLabel(Widget w, String label) {
      if (!showLabels || compact) return w;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          w,
          const SizedBox(height: 4),
          Text(label, style: labelStyle),
        ],
      );
    }

    final speedChip = PlayerSpeedMenuButton(
      speed: state.playbackSpeed,
      onSelected: (v) {
        notifier.setPlaybackSpeed(v);
        notifier.bumpControlsAutoHide();
      },
      menuChild: Material(
        color: Colors.white.withValues(alpha: 0.14),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: size,
          height: size,
          child: Center(
            child: Text(
              // Lowercase "x" suffix (e.g. "1x", "1.5x", "2x") matches the
              // dropdown menu items and reads as "speed" at a glance —
              // previously this showed just the number ("1", "1.5") which
              // was ambiguous next to the other chip icons.
              formatSpeedLabel(state.playbackSpeed).toLowerCase(),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: compact ? 12 : 13,
              ),
            ),
          ),
        ),
      ),
    );

    final gap = SizedBox(width: compact ? 12 : 18);

    final subtitleChip = PlayerSubtitleTrackMenu(
      state: state,
      notifier: notifier,
      menuChild: Material(
        color: Colors.white.withValues(alpha: 0.14),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            Icons.closed_caption,
            color: Colors.white,
            size: iconSz,
          ),
        ),
      ),
    );

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          wrapLabel(
            circleTap(
              icon: muted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
              tooltip: muted ? 'Unmute' : 'Mute',
              onTap: () {
                if (muted) {
                  notifier.setVolume(1.0);
                } else {
                  notifier.setVolume(0.0);
                }
                notifier.bumpControlsAutoHide();
              },
            ),
            'Mute',
          ),
          if (showLock) ...[
            gap,
            wrapLabel(
              circleTap(
                icon: Icons.lock_outline_rounded,
                tooltip: 'Lock screen',
                onTap: () {
                  notifier.bumpControlsAutoHide();
                  notifier.toggleLockMode();
                },
              ),
              'Lock',
            ),
          ],
          if (showSubtitle) ...[
            gap,
            wrapLabel(
              Tooltip(message: 'Subtitles', child: subtitleChip),
              'CC',
            ),
          ],
          if (showAspect) ...[
            gap,
            wrapLabel(
              circleTap(
                icon: Icons.fit_screen_rounded,
                tooltip:
                    '${aspectRatioModeLabel(state.aspectRatioMode)} — tap to change',
                onTap: () {
                  notifier.cycleAspectRatio();
                  notifier.bumpControlsAutoHide();
                },
              ),
              'Aspect',
            ),
          ],
          gap,
          wrapLabel(
            Tooltip(
              message: 'Speed',
              child: speedChip,
            ),
            'Speed',
          ),
        ],
      ),
    );
  }
}

