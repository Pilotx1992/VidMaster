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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Locked — tap unlock below',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        SafeArea(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: FloatingActionButton.small(
                heroTag: 'player_unlock',
                tooltip: 'Unlock controls',
                onPressed: onUnlock,
                backgroundColor: Colors.black54,
                foregroundColor: Colors.white,
                child: const Icon(Icons.lock_open),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
