import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/video_entity.dart';
import '../providers/video_library_provider.dart';

class VideoThumbnailCard extends ConsumerWidget {
  final VideoEntity video;
  final VoidCallback onTap;
  final VoidCallback onFavorite;

  const VideoThumbnailCard({
    required this.video,
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
            _ThumbnailImage(
              key: ValueKey(video.filePath),
              video: video,
              ref: ref,
            ),

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
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${video.folderName} · ${video.formattedSize}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 7,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    video.formattedDuration,
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 8,
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
                    video.isFavourite ? Icons.favorite : Icons.favorite_border,
                    color: video.isFavourite
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
                    style: TextStyle(color: Colors.white, fontSize: 7),
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
  const _ThumbnailImage({super.key, required this.video, required this.ref});

  @override
  State<_ThumbnailImage> createState() => _ThumbnailImageState();
}

class _ThumbnailImageState extends State<_ThumbnailImage> {
  String? _thumbPath;
  String? _loadingForPath;

  @override
  void initState() {
    super.initState();
    _thumbPath = widget.video.thumbnailPath;
    _loadingForPath = null;
    if (_thumbPath == null) {
      _loadThumbnailFor(widget.video.filePath);
    }
  }

  @override
  void didUpdateWidget(covariant _ThumbnailImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.video.filePath != widget.video.filePath) {
      _syncThumbnailForCurrentVideo();
    }
  }

  void _syncThumbnailForCurrentVideo() {
    final existingThumb = widget.video.thumbnailPath;

    setState(() {
      _thumbPath = existingThumb;
      _loadingForPath = null;
    });

    if (existingThumb == null) {
      _loadThumbnailFor(widget.video.filePath);
    }
  }

  Future<void> _loadThumbnailFor(String videoPath) async {
    if (_loadingForPath == videoPath) return;

    if (!mounted) return;
    setState(() {
      _loadingForPath = videoPath;
      _thumbPath = null;
    });

    final path = await widget.ref
        .read(videoLibraryProvider.notifier)
        .getThumbnail(videoPath);

    if (!mounted) return;
    if (widget.video.filePath != videoPath) return;

    setState(() {
      _thumbPath = path;
      _loadingForPath = null;
    });
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
