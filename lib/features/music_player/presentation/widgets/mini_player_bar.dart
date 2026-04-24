import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/music_player_provider.dart';

class MiniPlayerBar extends ConsumerWidget {
  const MiniPlayerBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(musicPlayerProvider);
    final notifier = ref.read(musicPlayerProvider.notifier);

    // Hide bar when nothing is loaded.
    if (state.currentTrack == null) return const SizedBox.shrink();

    final track = state.currentTrack!;

    return GestureDetector(
      onTap: () {
        // TODO: navigate to NowPlayingScreen
      },
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: const Color(0xFF1C2B3A),
          border: Border(
            top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress indicator
            LinearProgressIndicator(
              value: state.progressFraction,
              color: const Color(0xFFF9A825),
              backgroundColor: Colors.white10,
              minHeight: 2,
            ),
            Expanded(
              child: Row(
                children: [
                  // Album art
                  Container(
                    width: 44,
                    height: 44,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: const Color(0xFF0D1B2A),
                      image: track.albumArtPath != null
                          ? DecorationImage(
                              image: FileImage(File(track.albumArtPath!)),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: track.albumArtPath == null
                        ? const Icon(Icons.music_note,
                            color: Colors.white38, size: 20)
                        : null,
                  ),

                  // Track info
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          track.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          track.artist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Previous
                  IconButton(
                    icon: const Icon(Icons.skip_previous,
                        color: Colors.white70, size: 22),
                    onPressed: state.hasPrevious ? notifier.previous : null,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 36),
                  ),

                  // Play / Pause
                  IconButton(
                    icon: Icon(
                      state.isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: notifier.playPause,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 40),
                  ),

                  // Next
                  IconButton(
                    icon: const Icon(Icons.skip_next,
                        color: Colors.white70, size: 22),
                    onPressed: state.hasNext ? notifier.next : null,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 36),
                  ),

                  const SizedBox(width: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
