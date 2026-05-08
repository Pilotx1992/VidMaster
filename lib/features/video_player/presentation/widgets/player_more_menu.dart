import 'package:flutter/material.dart';

/// Secondary actions kept out of the top bar: external subtitle + styling.
class PlayerMoreMenu extends StatelessWidget {
  final VoidCallback onPickSubtitle;
  final VoidCallback onSubtitleStyling;

  const PlayerMoreMenu({
    super.key,
    required this.onPickSubtitle,
    required this.onSubtitleStyling,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'More',
      icon: const Icon(Icons.more_vert, color: Colors.white),
      onSelected: (v) {
        if (v == 'pick') onPickSubtitle();
        if (v == 'style') onSubtitleStyling();
      },
      itemBuilder: (context) => const [
        PopupMenuItem(value: 'pick', child: Text('Open subtitle file')),
        PopupMenuItem(value: 'style', child: Text('Subtitle style')),
      ],
    );
  }
}
