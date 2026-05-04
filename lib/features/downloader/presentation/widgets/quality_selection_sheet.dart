import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/extraction_result.dart';
import '../../domain/entities/media_format.dart';
import '../providers/social_downloader_provider.dart';

class QualitySelectionSheet extends ConsumerWidget {
  final ExtractionResult result;

  const QualitySelectionSheet({super.key, required this.result});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(socialDownloaderProvider.notifier);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize:     0.95,
      minChildSize:     0.5,
      expand: false,
      builder: (context, controller) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ListView(
          controller: controller,
          padding: const EdgeInsets.all(20),
          children: [
            // ── Handle ────────────────────────────────────
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // ── Header ────────────────────────────────────
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (result.thumbnailUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: result.thumbnailUrl!,
                    width:    100, height: 75,
                    fit:      BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                  ),
                ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(result.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        )),
                    const SizedBox(height: 4),
                    if (result.duration != null)
                      Text(_formatDuration(result.duration!),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          )),
                  ],
                ),
              ),
            ]),
            const SizedBox(height: 32),

            // ── Video Section ──────────────────────────────
            Text('Video Quality',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                )),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12, runSpacing: 12,
              children: result.videoFormats.map((f) =>
                  _FormatCard(format: f, onTap: () {
                    Navigator.pop(context);
                    notifier.startDownload(f);
                  }),
              ).toList(),
            ),
            const SizedBox(height: 32),

            // ── Audio Section ──────────────────────────────
            Text('Audio Only',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                )),
            const SizedBox(height: 8),
            ...result.audioFormats.map((f) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.music_note, color: Theme.of(context).colorScheme.secondary),
              title:   Text(f.note, style: const TextStyle(fontWeight: FontWeight.w500)),
              trailing: Text(f.formattedSize,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              onTap: () {
                Navigator.pop(context);
                notifier.startDownload(f);
              },
            )),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }
}

class _FormatCard extends StatelessWidget {
  final MediaFormat  format;
  final VoidCallback onTap;

  const _FormatCard({required this.format, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDash = format.requiresMerge;
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: colorScheme.secondaryContainer.withValues(alpha: 0.3),
          border: Border.all(color: colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(format.qualityLabel,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16)),
            Text(format.formattedSize,
                style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12)),
            if (isDash)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text('HD+', style: TextStyle(
                    color: Theme.of(context).colorScheme.primary, 
                    fontWeight: FontWeight.bold, 
                    fontSize: 10)),
              ),
          ],
        ),
      ),
    );
  }
}
