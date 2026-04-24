import 'package:flutter/material.dart';
import '../../domain/entities/download_task_entity.dart';

class DownloadItemTile extends StatelessWidget {
  final DownloadTaskEntity task;
  final VoidCallback? onPause;
  final VoidCallback? onResume;
  final VoidCallback? onCancel;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const DownloadItemTile({
    required this.task,
    this.onPause,
    this.onResume,
    this.onCancel,
    this.onDelete,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: _buildLeading(theme),
      title: Text(
        task.fileName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          _buildStatusRow(theme),
          if (task.isActive) ...[
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: task.progressPercent / 100,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ],
      ),
      trailing: _buildTrailing(theme),
    );
  }

  Widget _buildLeading(ThemeData theme) {
    IconData icon;
    Color color;

    if (task.isFinished) {
      icon = Icons.check_circle;
      color = Colors.green;
    } else if (task.status == DownloadStatus.failed) {
      icon = Icons.error;
      color = theme.colorScheme.error;
    } else if (task.status == DownloadStatus.paused) {
      icon = Icons.pause_circle_filled;
      color = theme.colorScheme.secondary;
    } else {
      icon = Icons.downloading;
      color = theme.colorScheme.primary;
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color),
    );
  }

  Widget _buildStatusRow(ThemeData theme) {
    String statusText = '';
    if (task.isActive) {
      statusText = '${task.progressPercent}% • ${task.status.name.toUpperCase()}';
    } else if (task.isFinished) {
      statusText = 'Completed';
    } else {
      statusText = task.status.name.toUpperCase();
    }

    return Text(
      statusText,
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildTrailing(ThemeData theme) {
    if (task.isFinished) {
      return IconButton(
        icon: const Icon(Icons.delete_outline),
        onPressed: onDelete,
      );
    }

    if (task.status == DownloadStatus.running) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(icon: const Icon(Icons.pause), onPressed: onPause),
          IconButton(icon: const Icon(Icons.close), onPressed: onCancel),
        ],
      );
    }

    if (task.status == DownloadStatus.paused) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(icon: const Icon(Icons.play_arrow), onPressed: onResume),
          IconButton(icon: const Icon(Icons.close), onPressed: onCancel),
        ],
      );
    }

    return IconButton(
      icon: const Icon(Icons.close),
      onPressed: onCancel,
    );
  }
}
