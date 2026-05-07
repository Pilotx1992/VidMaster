import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/downloader_provider.dart';

class DownloadHarnessScreen extends ConsumerStatefulWidget {
  const DownloadHarnessScreen({super.key});

  @override
  ConsumerState<DownloadHarnessScreen> createState() => _DownloadHarnessScreenState();
}

class _DownloadHarnessScreenState extends ConsumerState<DownloadHarnessScreen> {
  final _urlCtrl = TextEditingController();
  final _nameCtrl = TextEditingController(text: 'sample.bin');

  @override
  void dispose() {
    _urlCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(downloaderProvider);
    final notifier = ref.read(downloaderProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Download Harness (Debug)'),
        actions: [
          IconButton(
            tooltip: 'Reload from storage',
            onPressed: notifier.loadDownloads,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (!kDebugMode)
            const Text('This screen is intended for debug builds only.'),
          TextField(
            controller: _urlCtrl,
            decoration: const InputDecoration(
              labelText: 'Direct file URL',
              hintText: 'https://speed.hetzner.de/100MB.bin',
            ),
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 8),
          const Text(
            'Note: Use a direct downloadable file link. Some servers block HEAD (405) or require cookies; those won’t work in this harness.',
            style: TextStyle(fontSize: 12, color: Colors.white70),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'File name'),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    final url = _urlCtrl.text.trim();
                    final name = _nameCtrl.text.trim();
                    if (url.isEmpty || name.isEmpty) return;
                    await notifier.startDownload(url: url, fileName: name);
                  },
                  child: const Text('Start 1'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    final url = _urlCtrl.text.trim();
                    final name = _nameCtrl.text.trim();
                    if (url.isEmpty || name.isEmpty) return;
                    for (var i = 0; i < 5; i++) {
                      await notifier.startDownload(url: url, fileName: '[$i] $name');
                    }
                  },
                  child: const Text('Start 5'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              OutlinedButton(
                onPressed: () async {
                  for (final t in state.tasks) {
                    if (t.isActive) await notifier.pauseDownload(t.taskId);
                  }
                },
                child: const Text('Pause all active'),
              ),
              OutlinedButton(
                onPressed: () async {
                  for (final t in state.tasks) {
                    if (t.status.name == 'paused') await notifier.resumeDownload(t.taskId);
                  }
                },
                child: const Text('Resume all paused'),
              ),
              OutlinedButton(
                onPressed: () async {
                  for (final t in state.tasks) {
                    if (t.isActive) await notifier.cancelDownload(t.taskId);
                  }
                },
                child: const Text('Cancel all active'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (state.errorMessage != null)
            Text(
              state.errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          const SizedBox(height: 8),
          Text('Tasks: ${state.tasks.length}'),
          const SizedBox(height: 8),
          ...state.tasks.map(
            (t) => ListTile(
              dense: true,
              title: Text(t.fileName, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text('${t.status.name} • ${t.progressPercent}%'),
              trailing: IconButton(
                tooltip: 'Delete record',
                onPressed: () => notifier.deleteDownload(taskId: t.taskId, deleteFile: false),
                icon: const Icon(Icons.delete_outline),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

