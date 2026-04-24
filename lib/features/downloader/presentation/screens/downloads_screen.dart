import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/download_task_entity.dart';
import '../providers/downloader_provider.dart';

class DownloadsScreen extends ConsumerStatefulWidget {
  const DownloadsScreen({super.key});

  @override
  ConsumerState<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends ConsumerState<DownloadsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(downloaderProvider.notifier).loadDownloads();
    });
  }

  void _showAddDownloadDialog() {
    final urlController = TextEditingController();
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Download'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: urlController,
                decoration: const InputDecoration(labelText: 'URL'),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'File Name (with extension)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final url = urlController.text.trim();
                final name = nameController.text.trim();
                if (url.isNotEmpty && name.isNotEmpty) {
                  ref.read(downloaderProvider.notifier).startDownload(
                        url: url,
                        fileName: name,
                      );
                  Navigator.pop(context);
                }
              },
              child: const Text('Start Download'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(downloaderProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Downloads'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_link),
            tooltip: 'Add Download',
            onPressed: _showAddDownloadDialog,
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.tasks.isEmpty
              ? _buildEmptyState()
              : _buildList(state.tasks),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.download_done, size: 64, color: Theme.of(context).disabledColor),
          const SizedBox(height: 16),
          Text(
            'No downloads yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).disabledColor,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<DownloadTaskEntity> tasks) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: tasks.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _DownloadTaskTile(task: task);
      },
    );
  }
}

class _DownloadTaskTile extends ConsumerWidget {
  final DownloadTaskEntity task;

  const _DownloadTaskTile({required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(downloaderProvider.notifier);

    IconData getStatusIcon() {
      switch (task.status) {
        case DownloadStatus.completed:
          return Icons.check_circle;
        case DownloadStatus.failed:
          return Icons.error;
        case DownloadStatus.paused:
          return Icons.pause_circle;
        case DownloadStatus.cancelled:
          return Icons.cancel;
        case DownloadStatus.running:
          return Icons.downloading;
        case DownloadStatus.queued:
          return Icons.access_time;
      }
    }

    Color getStatusColor() {
      switch (task.status) {
        case DownloadStatus.completed:
          return Colors.green;
        case DownloadStatus.failed:
          return Theme.of(context).colorScheme.error;
        case DownloadStatus.running:
          return Theme.of(context).colorScheme.primary;
        default:
          return Theme.of(context).disabledColor;
      }
    }

    // Convert bytes to MB string easily. 
    String formatBytes(int? bytes) {
      if (bytes == null || bytes == 0) return '0 B';
      final mb = bytes / (1024 * 1024);
      return '${mb.toStringAsFixed(1)} MB';
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: getStatusColor().withValues(alpha: 0.1),
        child: Icon(getStatusIcon(), color: getStatusColor()),
      ),
      title: Text(task.fileName, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          if (task.isActive) ...[
            LinearProgressIndicator(
              value: task.progressPercent / 100,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${task.progressPercent}% - ${task.formattedSpeed}'),
                Text('${formatBytes(task.downloadedBytes)} / ${formatBytes(task.totalBytes)}'),
              ],
            ),
          ] else
            Text(
              task.status.name.toUpperCase(),
              style: TextStyle(color: getStatusColor(), fontSize: 12, fontWeight: FontWeight.bold),
            ),
        ],
      ),
      trailing: _buildActions(notifier),
    );
  }

  Widget _buildActions(DownloaderNotifier notifier) {
    if (task.status == DownloadStatus.running) {
      return IconButton(
        icon: const Icon(Icons.pause),
        onPressed: () => notifier.pauseDownload(task.taskId),
      );
    } else if (task.status == DownloadStatus.paused) {
      return IconButton(
        icon: const Icon(Icons.play_arrow),
        onPressed: () => notifier.resumeDownload(task.taskId),
      );
    } else if (task.status == DownloadStatus.failed || task.status == DownloadStatus.cancelled) {
      return IconButton(
        icon: const Icon(Icons.refresh),
        onPressed: () => notifier.retryDownload(task.taskId),
      );
    } else if (task.status == DownloadStatus.completed) {
      return IconButton(
        icon: const Icon(Icons.delete_outline),
        onPressed: () => notifier.cancelDownload(task.taskId), // Cancel also removes from list 
      );
    }
    return const SizedBox.shrink();
  }
}