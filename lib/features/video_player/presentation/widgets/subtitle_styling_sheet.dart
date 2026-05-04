import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/subtitle_engine_provider.dart';

class SubtitleStylingSheet extends ConsumerWidget {
  const SubtitleStylingSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(subtitleEngineProvider);
    final notifier = ref.read(subtitleEngineProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1D1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Subtitle Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Font Size Section
          const Text(
            'Font Size',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          Slider(
            value: settings.fontSize,
            min: 12,
            max: 32,
            activeColor: const Color(0xFFF9A825),
            onChanged: (v) => notifier.updateSettings(settings.copyWith(fontSize: v)),
          ),

          const SizedBox(height: 16),

          // Sync Offset Section
          const Text(
            'Sync Offset (Seconds)',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: Colors.white),
                onPressed: () => _updateSync(ref, -500),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '${(settings.syncOffset.inMilliseconds / 1000).toStringAsFixed(1)}s',
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                onPressed: () => _updateSync(ref, 500),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Visibility Toggle
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Show Subtitles', style: TextStyle(color: Colors.white)),
            trailing: Switch(
              value: settings.isVisible,
              activeTrackColor: const Color(0xFFF9A825).withValues(alpha: 0.5),
              activeThumbColor: const Color(0xFFF9A825),
              onChanged: (v) => notifier.updateSettings(settings.copyWith(isVisible: v)),
            ),
          ),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _updateSync(WidgetRef ref, int ms) {
    final notifier = ref.read(subtitleEngineProvider.notifier);
    final settings = ref.read(subtitleEngineProvider);
    notifier.updateSettings(settings.copyWith(
      syncOffset: settings.syncOffset + Duration(milliseconds: ms),
    ));
  }
}
