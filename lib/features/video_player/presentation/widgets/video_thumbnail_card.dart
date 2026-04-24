import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/video_entity.dart';
import '../providers/video_library_provider.dart';

class VideoThumbnailCard extends ConsumerWidget {
  final VideoEntity video;
  final List<VideoEntity> queue;
  final VoidCallback onTap;
  final VoidCallback onFavorite;

  const VideoThumbnailCard({
    required this.video,
    required this.queue,
    required this.onTap,
    required this.onFavorite,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Thumbnail or placeholder
            _ThumbnailImage(video: video, ref: ref),

            // Gradient overlay
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black87],
                  stops: [0.5, 1.0],
                ),
              ),
            ),

            // Resume progress bar
            if (video.resumeProgress > 0.01 && !video.isWatched)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(
                  value: video.resumeProgress,
                  color: const Color(0xFFF9A825),
                  backgroundColor: Colors.white24,
                  minHeight: 3,
                ),
              ),

            // Bottom info
            Positioned(
              left: 8,
              right: 8,
              bottom: 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    video.fileName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    video.formattedDuration,
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),

            // Favorite button (top-right)
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: onFavorite,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    video.isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: video.isFavorite
                        ? const Color(0xFFF9A825)
                        : Colors.white70,
                    size: 16,
                  ),
                ),
              ),
            ),

            // Watched badge
            if (video.isWatched)
              Positioned(
                top: 4,
                left: 4,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1565C0).withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Watched',
                    style: TextStyle(color: Colors.white, fontSize: 9),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ThumbnailImage extends StatefulWidget {
  final VideoEntity video;
  final WidgetRef ref;
  const _ThumbnailImage({required this.video, required this.ref});

  @override
  State<_ThumbnailImage> createState() => _ThumbnailImageState();
}

class _ThumbnailImageState extends State<_ThumbnailImage> {
  String? _thumbPath;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _thumbPath = widget.video.thumbnailPath;
    if (_thumbPath == null) _loadThumbnail();
  }

  Future<void> _loadThumbnail() async {
    if (_loading) return;
    setState(() => _loading = true);
    final path = await widget.ref
        .read(videoLibraryProvider.notifier)
        .getThumbnail(widget.video.filePath);
    if (mounted) setState(() => _thumbPath = path);
  }

  @override
  Widget build(BuildContext context) {
    if (_thumbPath != null) {
      return Image.file(
        File(_thumbPath!),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() => Container(
        color: const Color(0xFF1C2B3A),
        child: const Center(
          child: Icon(Icons.movie, color: Colors.white12, size: 36),
        ),
      );
}
