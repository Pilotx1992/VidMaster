import 'dart:async';

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../domain/entities/audio_track_entity.dart';

typedef TrackActionCallback = FutureOr<void> Function();

class MusicTrackActionsSheet extends StatelessWidget {
  final AudioTrackEntity track;
  final TrackActionCallback onPlayNow;
  final TrackActionCallback? onPlayNext;
  final TrackActionCallback? onAddToQueue;
  final TrackActionCallback? onChangeCover;
  final TrackActionCallback? onDelete;
  final TrackActionCallback? onShare;
  final TrackActionCallback? onRename;
  final TrackActionCallback? onProperties;

  const MusicTrackActionsSheet({
    super.key,
    required this.track,
    required this.onPlayNow,
    this.onPlayNext,
    this.onAddToQueue,
    this.onChangeCover,
    this.onDelete,
    this.onShare,
    this.onRename,
    this.onProperties,
  });

  static Future<void> show(
    BuildContext context, {
    required AudioTrackEntity track,
    required TrackActionCallback onPlayNow,
    TrackActionCallback? onPlayNext,
    TrackActionCallback? onAddToQueue,
    TrackActionCallback? onChangeCover,
    TrackActionCallback? onDelete,
    TrackActionCallback? onShare,
    TrackActionCallback? onRename,
    TrackActionCallback? onProperties,
  }) {
    final screen = MediaQuery.sizeOf(context);
    final theme = Theme.of(context);
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      constraints: BoxConstraints(
        maxHeight: screen.height * 0.85,
      ),
      backgroundColor:
          theme.bottomSheetTheme.backgroundColor ?? theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Directionality(
        textDirection: TextDirection.ltr,
        child: MusicTrackActionsSheet(
          track: track,
          onPlayNow: onPlayNow,
          onPlayNext: onPlayNext,
          onAddToQueue: onAddToQueue,
          onChangeCover: onChangeCover,
          onDelete: onDelete,
          onShare: onShare,
          onRename: onRename,
          onProperties: onProperties,
        ),
      ),
    );
  }

  String get _headerText {
    if (track.title.trim().isNotEmpty) {
      return track.title.trim();
    }

    final segments = track.filePath.split(RegExp(r'[\\/]'));
    return segments.isNotEmpty ? segments.last : track.filePath;
  }

  void _handleAction(BuildContext context, TrackActionCallback action) {
    Navigator.of(context).pop();
    Future<void>.microtask(() => Future.sync(action));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 4),
              child: Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.onSurface.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Text(
                _headerText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: cs.onSurface.withValues(alpha: 0.55),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Divider(height: 1, color: cs.outline.withValues(alpha: 0.18)),
            _ActionTile(
              icon: Symbols.play_arrow,
              label: 'Play now',
              onTap: () => _handleAction(context, onPlayNow),
            ),
            if (onPlayNext != null)
              _ActionTile(
                icon: Symbols.play_circle,
                label: 'Play next',
                onTap: () => _handleAction(context, onPlayNext!),
              ),
            if (onAddToQueue != null)
              _ActionTile(
                icon: Symbols.queue_music,
                label: 'Add to queue',
                onTap: () => _handleAction(context, onAddToQueue!),
              ),
            if (onChangeCover != null)
              _ActionTile(
                icon: Symbols.image,
                label: 'Change cover',
                onTap: () => _handleAction(context, onChangeCover!),
              ),
            if (onDelete != null)
              _ActionTile(
                icon: Symbols.delete_outline,
                label: 'Delete',
                onTap: () => _handleAction(context, onDelete!),
              ),
            if (onShare != null)
              _ActionTile(
                icon: Symbols.share,
                label: 'Share',
                onTap: () => _handleAction(context, onShare!),
              ),
            if (onRename != null)
              _ActionTile(
                icon: Symbols.edit,
                label: 'Rename',
                onTap: () => _handleAction(context, onRename!),
              ),
            if (onProperties != null)
              _ActionTile(
                icon: Symbols.info,
                label: 'Properties',
                onTap: () => _handleAction(context, onProperties!),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, size: 18, color: cs.onSurface),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
