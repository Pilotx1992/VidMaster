import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:media_kit/media_kit.dart';

import '../../domain/entities/video_playback_state.dart';
import '../providers/video_player_notifier.dart';

class PlayerSubtitleTrackMenu extends StatelessWidget {
  final VideoPlayerState state;
  final VideoPlayerNotifier notifier;

  /// Custom tap target. When provided the menu uses this widget as its
  /// trigger (mirrors [PlayerSpeedMenuButton.menuChild]); when null we fall
  /// back to the default closed-caption icon so the top-bar usage is
  /// unchanged.
  final Widget? menuChild;

  const PlayerSubtitleTrackMenu({
    super.key,
    required this.state,
    required this.notifier,
    this.menuChild,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<SubtitleTrack>(
      tooltip: 'Subtitle tracks',
      onSelected: notifier.setSubtitleTrack,
      icon: menuChild == null
          ? const Icon(Symbols.closed_caption, color: Colors.white)
          : null,
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
      child: menuChild,
    );
  }
}
