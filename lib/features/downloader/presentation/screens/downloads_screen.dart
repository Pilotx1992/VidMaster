import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../domain/entities/download_task_entity.dart';
import '../providers/downloader_provider.dart';

class DownloadsScreen extends ConsumerStatefulWidget {
  const DownloadsScreen({super.key});

  @override
  ConsumerState<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends ConsumerState<DownloadsScreen> {
  final Set<String> _selectedTasks = {};

  bool get _isSelectionMode => _selectedTasks.isNotEmpty;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(downloaderProvider.notifier).loadDownloads();
    });
  }

  void _toggleSelection(String taskId) {
    setState(() {
      if (_selectedTasks.contains(taskId)) {
        _selectedTasks.remove(taskId);
      } else {
        _selectedTasks.add(taskId);
      }
    });
  }

  void _selectAll(List<DownloadTaskEntity> tasks) {
    setState(() {
      if (_selectedTasks.length == tasks.length) {
        _selectedTasks.clear();
      } else {
        _selectedTasks.addAll(tasks.map((t) => t.taskId));
      }
    });
  }

  void _deleteSelected() {
    final notifier = ref.read(downloaderProvider.notifier);
    for (final taskId in _selectedTasks) {
      notifier.deleteDownload(taskId: taskId, deleteFile: true);
    }
    setState(() {
      _selectedTasks.clear();
    });
  }

  void _pauseSelected() {
    final notifier = ref.read(downloaderProvider.notifier);
    for (final taskId in _selectedTasks) {
      notifier.pauseDownload(taskId);
    }
    setState(() {
      _selectedTasks.clear();
    });
  }

  void _resumeSelected() {
    final notifier = ref.read(downloaderProvider.notifier);
    for (final taskId in _selectedTasks) {
      notifier.resumeDownload(taskId);
    }
    setState(() {
      _selectedTasks.clear();
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
    ref.listen<DownloaderState>(downloaderProvider, (previous, next) {
      if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.errorMessage!),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
          ref.read(downloaderProvider.notifier).clearError();
        }
      }
    });

    final state = ref.watch(downloaderProvider);

    return Scaffold(
      appBar: _isSelectionMode
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _selectedTasks.clear();
                  });
                },
              ),
              title: Text('${_selectedTasks.length} Selected'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.select_all),
                  tooltip: 'Select All',
                  onPressed: () => _selectAll(state.tasks),
                ),
                IconButton(
                  icon: const Icon(Icons.pause),
                  tooltip: 'Pause Selected',
                  onPressed: _pauseSelected,
                ),
                IconButton(
                  icon: const Icon(Icons.play_arrow),
                  tooltip: 'Resume Selected',
                  onPressed: _resumeSelected,
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  tooltip: 'Delete Selected',
                  onPressed: _deleteSelected,
                ),
              ],
            )
          : AppBar(
              title: const Text('Downloads'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.checklist),
                  tooltip: 'Select Multiple',
                  onPressed: () {
                    if (state.tasks.isNotEmpty) {
                      setState(() {
                        _selectedTasks.add(state.tasks.first.taskId);
                      });
                    }
                  },
                ),
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
      floatingActionButton: _isSelectionMode
          ? null
          : FloatingActionButton.extended(
              onPressed: () => context.push(AppRoutes.videoBrowser),
              icon: const Icon(Icons.travel_explore),
              label: const Text('Browser'),
              tooltip: 'Open Video Browser',
            ),
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
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: tasks.length,
      cacheExtent: 500,
      physics: const AlwaysScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final task = tasks[index];
        final isSelected = _selectedTasks.contains(task.taskId);

        return _DownloadTaskTile(
          task: task,
          isSelected: isSelected,
          isSelectionMode: _isSelectionMode,
          onTap: () {
            if (_isSelectionMode) {
              _toggleSelection(task.taskId);
            }
          },
          onLongPress: () {
            if (!_isSelectionMode) {
              _toggleSelection(task.taskId);
            }
          },
        );
      },
    );
  }
}

class _DownloadTaskTile extends ConsumerWidget {
  final DownloadTaskEntity task;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _DownloadTaskTile({
    required this.task,
    required this.isSelected,
    required this.isSelectionMode,
    required this.onTap,
    required this.onLongPress,
  });

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
        case DownloadStatus.extracting:
          return Icons.search;
        case DownloadStatus.merging:
          return Icons.merge;
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
        case DownloadStatus.extracting:
        case DownloadStatus.merging:
          return Theme.of(context).colorScheme.secondary;
        default:
          return Theme.of(context).disabledColor;
      }
    }

    // Convert bytes to readable string
    String formatBytes(int? bytes) {
      if (bytes == null || bytes == 0) return '0 B';
      const units = ['B', 'KB', 'MB', 'GB', 'TB'];
      int unitIndex = 0;
      double size = bytes.toDouble();
      while (size >= 1024 && unitIndex < units.length - 1) {
        size /= 1024;
        unitIndex++;
      }
      return '${size.toStringAsFixed(1)} ${units[unitIndex]}';
    }

    String getETA() {
      final eta = task.etaSeconds;
      if (eta == null || eta <= 0) return '';
      if (eta < 60) return '$eta s';
      if (eta < 3600) return '${(eta / 60).floor()} m';
      return '${(eta / 3600).floor()} h';
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          decoration: isSelected
              ? BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withValues(alpha: 0.2),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 1,
                  ),
                )
              : null,
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: getStatusColor().withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: isSelectionMode
                        ? Checkbox(
                            value: isSelected,
                            onChanged: (_) => onTap(),
                          )
                        : Icon(getStatusIcon(), color: getStatusColor()),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.fileName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              task.status.name.toUpperCase(),
                              style: TextStyle(
                                color: getStatusColor(),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${formatBytes(task.downloadedBytes)} / ${formatBytes(task.totalBytes)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (!isSelectionMode) _buildActions(notifier),
                ],
              ),
              if (task.isActive || task.status == DownloadStatus.paused) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: task.progressPercent / 100,
                    minHeight: 6,
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(getStatusColor()),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.speed, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          task.formattedSpeed,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    if (task.status == DownloadStatus.running)
                      Row(
                        children: [
                          const Icon(Icons.timer_outlined, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            getETA(),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    Text(
                      '${task.progressPercent}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: getStatusColor(),
                          ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActions(DownloaderNotifier notifier) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        switch (value) {
          case 'pause':
            notifier.pauseDownload(task.taskId);
            break;
          case 'resume':
            notifier.resumeDownload(task.taskId);
            break;
          case 'retry':
            notifier.retryDownload(task.taskId);
            break;
          case 'cancel':
            notifier.cancelDownload(task.taskId);
            break;
          case 'delete':
            notifier.deleteDownload(taskId: task.taskId, deleteFile: true);
            break;
        }
      },
      itemBuilder: (context) => [
        if (task.status == DownloadStatus.running)
          const PopupMenuItem(
            value: 'pause',
            child: ListTile(
              leading: Icon(Icons.pause),
              title: Text('Pause'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        if (task.status == DownloadStatus.paused)
          const PopupMenuItem(
            value: 'resume',
            child: ListTile(
              leading: Icon(Icons.play_arrow),
              title: Text('Resume'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        if (task.status == DownloadStatus.failed || task.status == DownloadStatus.cancelled)
          const PopupMenuItem(
            value: 'retry',
            child: ListTile(
              leading: Icon(Icons.refresh),
              title: Text('Retry'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        if (task.isActive)
          const PopupMenuItem(
            value: 'cancel',
            child: ListTile(
              leading: Icon(Icons.cancel),
              title: Text('Cancel'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        const PopupMenuItem(
          value: 'delete',
          child: ListTile(
            leading: Icon(Icons.delete_outline, color: Colors.red),
            title: Text('Delete', style: TextStyle(color: Colors.red)),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}