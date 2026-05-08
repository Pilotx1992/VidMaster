import 'package:flutter/material.dart';

class PlayerLockedOverlay extends StatelessWidget {
  final VoidCallback onUnlock;

  const PlayerLockedOverlay({super.key, required this.onUnlock});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: ColoredBox(color: Colors.black.withValues(alpha: 0.35)),
        ),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white24),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_rounded, color: Colors.white, size: 22),
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
        SafeArea(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 28),
              child: FloatingActionButton.small(
                heroTag: 'player_unlock',
                tooltip: 'Unlock',
                onPressed: onUnlock,
                backgroundColor: Colors.white.withValues(alpha: 0.16),
                foregroundColor: Colors.white,
                child: const Icon(Icons.lock_open_rounded),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
