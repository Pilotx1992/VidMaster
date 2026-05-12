import 'package:flutter/material.dart';

import '../../domain/entities/video_entity.dart';

/// Bottom sheet that mirrors the "long-press / 3-dot" actions panel from the
/// reference screenshot. Owners pass the [video] and the per-action handlers;
/// the sheet stays purely presentational so it can be reused from list view,
/// grid view, or anywhere else a single-video action set is needed.
///
/// Each tile closes the sheet BEFORE invoking the callback so dialogs /
/// snackbars launched by the action have a clean route stack.
class VideoActionsSheet extends StatelessWidget {
  final VideoEntity video;
  final VoidCallback onLockVault;
  final VoidCallback onConvertMp3;
  final VoidCallback onAddToPlaylist;
  final VoidCallback onDelete;
  final VoidCallback onShare;
  final VoidCallback onRename;
  final VoidCallback onProperties;

  const VideoActionsSheet({
    super.key,
    required this.video,
    required this.onLockVault,
    required this.onConvertMp3,
    required this.onAddToPlaylist,
    required this.onDelete,
    required this.onShare,
    required this.onRename,
    required this.onProperties,
  });

  /// Convenience launcher so callers don't repeat `showModalBottomSheet`
  /// boilerplate. Returns a future that completes when the sheet is dismissed.
  ///
  /// `isScrollControlled: true` is required because the action list (7 tiles +
  /// header + safe-area inset) exceeds the default 9/16 ≈ 56 % screen-height
  /// cap that Flutter's bottom sheets enforce. Without it, the sheet content
  /// overflows by ~96 px on a 411x914 dp device. The widget body also wraps
  /// itself in `SingleChildScrollView` so it stays safe on truly tiny screens.
  static Future<void> show(
    BuildContext context, {
    required VideoEntity video,
    required VoidCallback onLockVault,
    required VoidCallback onConvertMp3,
    required VoidCallback onAddToPlaylist,
    required VoidCallback onDelete,
    required VoidCallback onShare,
    required VoidCallback onRename,
    required VoidCallback onProperties,
  }) {
    final screen = MediaQuery.sizeOf(context);
    return showModalBottomSheet<void>(
      context: context,
      // `isScrollControlled: true` lifts the default 9/16 height cap and lets
      // the sheet grow tall enough for all 7 actions + header. The explicit
      // `constraints.maxHeight` is a belt-and-suspenders guard so the sheet
      // can climb up to ~85 % of the screen on tall devices — without this,
      // some Flutter versions still cap modal sheets at half-screen.
      isScrollControlled: true,
      useSafeArea: true,
      constraints: BoxConstraints(
        maxHeight: screen.height * 0.85,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => VideoActionsSheet(
        video: video,
        onLockVault: onLockVault,
        onConvertMp3: onConvertMp3,
        onAddToPlaylist: onAddToPlaylist,
        onDelete: onDelete,
        onShare: onShare,
        onRename: onRename,
        onProperties: onProperties,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // `SingleChildScrollView` keeps the sheet safe on devices where the 7
    // action tiles + safe-area inset would otherwise be taller than the
    // shrink-to-content bottom-sheet box. Combined with `isScrollControlled:
    // true` in [show], the sheet renders fully when it fits and gracefully
    // scrolls when it doesn't — no more 96 px RenderFlex overflows.
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
          // Grab handle
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
          // File name header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Text(
              video.fileName,
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
            icon: Icons.lock_outline,
            label: 'Lock in Private Folder',
            onTap: () {
              Navigator.of(context).pop();
              onLockVault();
            },
          ),
          _ActionTile(
            icon: Icons.music_note_outlined,
            label: 'Convert to MP3',
            onTap: () {
              Navigator.of(context).pop();
              onConvertMp3();
            },
          ),
          _ActionTile(
            icon: Icons.playlist_add_outlined,
            label: 'Add to playlist',
            onTap: () {
              Navigator.of(context).pop();
              onAddToPlaylist();
            },
          ),
          _ActionTile(
            icon: Icons.delete_outline,
            label: 'Delete',
            onTap: () {
              Navigator.of(context).pop();
              onDelete();
            },
          ),
          _ActionTile(
            icon: Icons.share_outlined,
            label: 'Share',
            onTap: () {
              Navigator.of(context).pop();
              onShare();
            },
          ),
          _ActionTile(
            icon: Icons.edit_outlined,
            label: 'Rename',
            onTap: () {
              Navigator.of(context).pop();
              onRename();
            },
          ),
          _ActionTile(
            icon: Icons.info_outline,
            label: 'Properties',
            onTap: () {
              Navigator.of(context).pop();
              onProperties();
            },
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
        // Vertical padding trimmed 12 → 10 so 7 tiles + header still clear a
        // ~393 dp default modal-sheet box (51 px → 44 px saves ~50 px overall).
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
