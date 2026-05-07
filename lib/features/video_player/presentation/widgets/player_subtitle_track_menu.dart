import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';

import '../../domain/entities/video_playback_state.dart';
import '../providers/video_player_notifier.dart';

class PlayerSubtitleTrackMenu extends StatelessWidget {
  final VideoPlayerState state;
  final VideoPlayerNotifier notifier;

  const PlayerSubtitleTrackMenu({
    super.key,
    required this.state,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<SubtitleTrack>(
      tooltip: 'Subtitle tracks',
      icon: const Icon(Icons.closed_caption, color: Colors.white),
      onSelected: notifier.setSubtitleTrack,
      itemBuilder: (context) => [
        if (state.availableSubtitleTracks.isEmpty)
          const PopupMenuItem<SubtitleTrack>(
            enabled: false,
            child: Text('No subtitle tracks'),
          )
        else
          ...state.availableSubtitleTracks.map((t) {
            final i = state.availableSubtitleTracks.indexOf(t);
            return PopupMenuItem<SubtitleTrack>(
              value: t,
              child: Text(
                t.title ?? t.language ?? 'Track ${i + 1}',
              ),
            );
          }),
      ],
    );
  }
}
