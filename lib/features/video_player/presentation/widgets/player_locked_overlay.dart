import 'dart:async';

import 'package:flutter/material.dart';

import 'package:material_symbols_icons/symbols.dart';
/// Full-screen overlay shown while the player is in lock mode.
///
/// Behaviour:
/// * Absorbs every gesture inside the player surface (taps, drags, pinches,
///   double-taps) so playback cannot be controlled while locked.
/// * Shows a "Locked" badge in the center and an unlock FAB at the bottom for
///   a short moment, then fades them out (matches normal-controls auto-hide).
/// * A single tap anywhere inside the overlay brings both back and re-arms
///   the hide timer — without ever letting the tap reach the video surface
///   below.
class PlayerLockedOverlay extends StatefulWidget {
  final VoidCallback onUnlock;

  const PlayerLockedOverlay({super.key, required this.onUnlock});

  @override
  State<PlayerLockedOverlay> createState() => _PlayerLockedOverlayState();
}

class _PlayerLockedOverlayState extends State<PlayerLockedOverlay> {
  static const Duration _autoHideDelay = Duration(seconds: 3);
  static const Duration _fadeDuration = Duration(milliseconds: 220);

  bool _chromeVisible = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _scheduleHide();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  void _scheduleHide() {
    _hideTimer?.cancel();
    _hideTimer = Timer(_autoHideDelay, () {
      if (!mounted) return;
      setState(() => _chromeVisible = false);
    });
  }

  void _revealChrome() {
    if (!mounted) return;
    setState(() => _chromeVisible = true);
    _scheduleHide();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Gesture barrier — replaces the previous bare AbsorbPointer so we
        // can intercept a single tap (to re-reveal the badge + unlock FAB)
        // while still swallowing every other gesture (pan / scale /
        // double-tap / long-press never have handlers, so they fall on the
        // floor inside the gesture arena).
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _revealChrome,
            child: const ColoredBox(color: Color(0x59000000)),
          ),
        ),

        // Center "Locked" badge — purely visual, never absorbs hits so a tap
        // on its area still reveals chrome via the barrier above.
        IgnorePointer(
          ignoring: true,
          child: AnimatedOpacity(
            duration: _fadeDuration,
            curve: Curves.easeOutCubic,
            opacity: _chromeVisible ? 1.0 : 0.0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.white24),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Symbols.lock_rounded, color: Colors.white, size: 22),
                    SizedBox(width: 10),
                    Text(
                      'Locked',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Unlock FAB — interactive only while visible. When faded out,
        // IgnorePointer skips it so the same screen area routes to the
        // gesture barrier and a tap re-reveals chrome (then a second tap
        // can hit the FAB to unlock).
        IgnorePointer(
          ignoring: !_chromeVisible,
          child: AnimatedOpacity(
            duration: _fadeDuration,
            curve: Curves.easeOutCubic,
            opacity: _chromeVisible ? 1.0 : 0.0,
            child: SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 28),
                  child: FloatingActionButton.small(
                    heroTag: 'player_unlock',
                    tooltip: 'Unlock',
                    onPressed: widget.onUnlock,
                    backgroundColor: Colors.white.withValues(alpha: 0.16),
                    foregroundColor: Colors.white,
                    child: const Icon(Symbols.lock_open_rounded),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
