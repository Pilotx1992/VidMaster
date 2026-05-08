import 'package:flutter/material.dart';

import '../../domain/entities/video_playback_state.dart';
import '../providers/video_player_notifier.dart';
import 'player_control_helpers.dart';
import 'player_speed_menu_button.dart';

/// Lock, Mute, Aspect, Speed only — no subtitle / more (those live in [PlayerTopBar]).
class PlayerQuickActionsRow extends StatelessWidget {
  final VideoPlayerState state;
  final VideoPlayerNotifier notifier;
  final bool compact;
  final bool showLabels;

  const PlayerQuickActionsRow({
    super.key,
    required this.state,
    required this.notifier,
    this.compact = false,
    this.showLabels = false,
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
      onSelected: (v) => notifier.setPlaybackSpeed(v),
      menuChild: Material(
        color: Colors.white.withValues(alpha: 0.14),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: size,
          height: size,
          child: Center(
            child: Text(
              _speedShort(state.playbackSpeed),
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

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          wrapLabel(
            circleTap(
              icon: Icons.lock_outline_rounded,
              tooltip: 'Lock screen',
              onTap: notifier.toggleLockMode,
            ),
            'Lock',
          ),
          SizedBox(width: compact ? 12 : 18),
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
              },
            ),
            'Mute',
          ),
          SizedBox(width: compact ? 12 : 18),
          wrapLabel(
            circleTap(
              icon: Icons.fit_screen_rounded,
              tooltip:
                  '${aspectRatioModeLabel(state.aspectRatioMode)} — tap to change',
              onTap: notifier.cycleAspectRatio,
            ),
            'Aspect',
          ),
          SizedBox(width: compact ? 12 : 18),
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

String _speedShort(double speed) {
  if (speed <= 0) return '1';
  final r = (speed * 100).round() / 100;
  if ((r * 100) % 100 == 0) return r.toStringAsFixed(0);
  return r.toString();
}
