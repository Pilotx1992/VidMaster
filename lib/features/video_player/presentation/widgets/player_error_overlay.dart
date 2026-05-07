import 'package:flutter/material.dart';

import '../../domain/entities/video_playback_state.dart';

class PlayerErrorOverlay extends StatelessWidget {
  final PlayerError? error;
  final VoidCallback onBack;
  final VoidCallback? onRetry;

  const PlayerErrorOverlay({
    super.key,
    required this.error,
    required this.onBack,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final msg = switch (error) {
      PlayerError.fileNotFound => 'Could not find this video file.',
      PlayerError.unsupportedFormat => 'This format is not supported.',
      PlayerError.corruptedFile => 'This file appears damaged.',
      PlayerError.networkError => 'Network error.',
      PlayerError.unknown => 'Could not play this video.',
      null => 'Could not play this video.',
    };

    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.88),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.redAccent, size: 56),
                const SizedBox(height: 16),
                Text(
                  msg,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 24),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  children: [
                    OutlinedButton(
                      onPressed: onBack,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white54),
                      ),
                      child: const Text('Back'),
                    ),
                    if (onRetry != null)
                      FilledButton(
                        onPressed: onRetry,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFF9A825),
                          foregroundColor: Colors.black,
                        ),
                        child: const Text('Retry'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
