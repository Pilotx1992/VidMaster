import 'package:flutter/material.dart';

import 'player_control_helpers.dart';

/// Centered playback row: optional `Previous` · `Replay 10` · `Play/Pause` ·
/// `Forward 10` · optional `Next`, with an optional `Lock` pinned far-left
/// (landscape only).
///
/// All extra buttons are opt-in via boolean flags so the existing portrait
/// 3-button layout is preserved for every caller that doesn't surface a queue
/// or a lock. When [onPrevious] / [onNext] is null but the corresponding
/// `show*` flag is `true`, the button renders in its disabled state — this is
/// how queue boundaries (first / last item) are communicated without changing
/// the row geometry.
class PlayerTransportControls extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final VoidCallback onReplay10;
  final VoidCallback onForward10;
  final VoidCallback? onLock;
  final VoidCallback? onAspect;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  /// Render the Previous-track button outboard-left of `Replay 10`. Host
  /// widgets typically gate this on `state.queue.length > 1` so the row is
  /// untouched when no queue is active.
  final bool showPrevious;

  /// Render the Next-track button outboard-right of `Forward 10`.
  final bool showNext;

  /// Render the `Replay 10s` button. Defaults to `true` so existing callers
  /// (landscape) are untouched; portrait turns this off because users have
  /// the double-tap-left gesture and the seek bar for the same affordance.
  final bool showReplay10;

  /// Render the `Forward 10s` button. Mirrors [showReplay10] for symmetry.
  final bool showForward10;

  final double centerIconSize;

  const PlayerTransportControls({
    super.key,
    required this.isPlaying,
    required this.onPlayPause,
    required this.onReplay10,
    required this.onForward10,
    this.onLock,
    this.onAspect,
    this.onPrevious,
    this.onNext,
    this.showPrevious = false,
    this.showNext = false,
    this.showReplay10 = true,
    this.showForward10 = true,
    this.centerIconSize = 72,
  });

  @override
  Widget build(BuildContext context) {
    // Visual hierarchy: Play/Pause >> Replay/Forward > Previous/Next.
    final skipSize = (centerIconSize * 0.48).clamp(30.0, 42.0);
    // Bumped clamp floor 26 → 30 so Prev/Next are slightly more substantial
    // — still smaller than ±10s (skipSize) but easier to hit on phones.
    final prevNextSize = (centerIconSize * 0.50).clamp(30.0, 36.0);

    final playbackRow = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (showPrevious)
          IconButton(
            iconSize: prevNextSize,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            padding: EdgeInsets.zero,
            tooltip: 'Previous track',
            style: IconButton.styleFrom(
              foregroundColor: Colors.white,
              overlayColor: Colors.white.withValues(alpha: 0.12),
              disabledForegroundColor: Colors.white.withValues(alpha: 0.25),
            ),
            icon: const Icon(Icons.skip_previous_rounded),
            onPressed: onPrevious,
          ),
        if (showReplay10)
          IconButton(
            iconSize: skipSize,
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            padding: EdgeInsets.zero,
            tooltip: 'Back 10 seconds',
            style: IconButton.styleFrom(
              foregroundColor: Colors.white,
              overlayColor: Colors.white.withValues(alpha: 0.12),
            ),
            icon: const Icon(Icons.replay_10_rounded),
            onPressed: onReplay10,
          ),
        IconButton(
          iconSize: centerIconSize,
          constraints: const BoxConstraints(minWidth: 88, minHeight: 88),
          padding: EdgeInsets.zero,
          tooltip: isPlaying ? 'Pause' : 'Play',
          style: IconButton.styleFrom(
            foregroundColor: kPlayerAccent,
            overlayColor: kPlayerAccent.withValues(alpha: 0.2),
          ),
          icon: Icon(
            isPlaying ? Icons.pause_circle_rounded : Icons.play_circle_rounded,
          ),
          onPressed: onPlayPause,
        ),
        if (showForward10)
          IconButton(
            iconSize: skipSize,
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            padding: EdgeInsets.zero,
            tooltip: 'Forward 10 seconds',
            style: IconButton.styleFrom(
              foregroundColor: Colors.white,
              overlayColor: Colors.white.withValues(alpha: 0.12),
            ),
            icon: const Icon(Icons.forward_10_rounded),
            onPressed: onForward10,
          ),
        if (showNext)
          IconButton(
            iconSize: prevNextSize,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            padding: EdgeInsets.zero,
            tooltip: 'Next track',
            style: IconButton.styleFrom(
              foregroundColor: Colors.white,
              overlayColor: Colors.white.withValues(alpha: 0.12),
              disabledForegroundColor: Colors.white.withValues(alpha: 0.25),
            ),
            icon: const Icon(Icons.skip_next_rounded),
            onPressed: onNext,
          ),
      ],
    );

    final lockCallback = onLock;
    final aspectCallback = onAspect;
    if (lockCallback == null && aspectCallback == null) {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: playbackRow,
      );
    }

    // Edge-anchored variant: Lock far-left (when wired), Aspect far-right
    // (when wired), playback group centered. The Stack lets the playback row
    // stay perfectly centered relative to the available width while we
    // anchor the edge controls independently — same approach as the original
    // landscape Lock layout, now extended symmetrically for Aspect.
    return Directionality(
      textDirection: TextDirection.ltr,
      child: SizedBox(
        height: 88,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (lockCallback != null)
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: IconButton(
                    iconSize: skipSize,
                    constraints:
                        const BoxConstraints(minWidth: 44, minHeight: 44),
                    padding: EdgeInsets.zero,
                    tooltip: 'Lock screen',
                    style: IconButton.styleFrom(
                      foregroundColor: Colors.white,
                      overlayColor: Colors.white.withValues(alpha: 0.12),
                    ),
                    icon: const Icon(Icons.lock_outline_rounded),
                    onPressed: lockCallback,
                  ),
                ),
              ),
            if (aspectCallback != null)
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: IconButton(
                    iconSize: skipSize,
                    constraints:
                        const BoxConstraints(minWidth: 44, minHeight: 44),
                    padding: EdgeInsets.zero,
                    tooltip: 'Aspect ratio (tap to cycle)',
                    style: IconButton.styleFrom(
                      foregroundColor: Colors.white,
                      overlayColor: Colors.white.withValues(alpha: 0.12),
                    ),
                    icon: const Icon(Icons.fit_screen_rounded),
                    onPressed: aspectCallback,
                  ),
                ),
              ),
            playbackRow,
          ],
        ),
      ),
    );
  }
}
