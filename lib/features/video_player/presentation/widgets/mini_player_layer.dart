import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/mini_player_provider.dart';
import '../providers/video_player_provider.dart';
import '../screens/video_player_screen.dart';
import 'video_surface.dart';

class MiniPlayerLayer extends ConsumerStatefulWidget {
  const MiniPlayerLayer({super.key});

  @override
  ConsumerState<MiniPlayerLayer> createState() => _MiniPlayerLayerState();
}

class _MiniPlayerLayerState extends ConsumerState<MiniPlayerLayer> {
  double _dragOffset = 0.0;
  
  @override
  Widget build(BuildContext context) {
    final mini = ref.watch(miniPlayerProvider);
    final player = ref.watch(videoPlayerProvider);
    final notifier = ref.read(videoPlayerProvider.notifier);

    if (!mini.isVisible || mini.video == null) {
      return const SizedBox.shrink();
    }

    final width = MediaQuery.of(context).size.width;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      bottom: 16,
      left: 16 + _dragOffset,
      right: 16 - _dragOffset,
      height: 72,
      child: GestureDetector(
        onHorizontalDragUpdate: (details) {
          setState(() {
            _dragOffset += details.delta.dx;
          });
        },
        onHorizontalDragEnd: (details) {
          final velocity = details.primaryVelocity ?? 0;
          if (velocity.abs() > 800 || _dragOffset.abs() > width * 0.4) {
            ref.read(miniPlayerProvider.notifier).hide();
            notifier.pause();
            setState(() => _dragOffset = 0);
          } else {
            setState(() => _dragOffset = 0);
          }
        },
        onTap: () {
          context.goNamed(
            'video_player',
            extra: VideoPlayerArgs(video: mini.video!),
          );
          ref.read(miniPlayerProvider.notifier).hide();
        },
        child: Material(
          color: Colors.black,
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Row(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: VideoSurface(
                      controller: notifier.controller,
                      heroTag: 'video_player',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          player.currentVideo?.name ?? 'Video',
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${_format(player.position)} / ${_format(player.duration)}',
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      player.isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                    ),
                    onPressed: () => player.isPlaying ? notifier.pause() : notifier.play(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      ref.read(miniPlayerProvider.notifier).hide();
                      notifier.pause();
                    },
                  ),
                ],
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(
                  value: player.duration.inMilliseconds == 0
                      ? 0
                      : player.position.inMilliseconds / player.duration.inMilliseconds,
                  backgroundColor: Colors.white12,
                  color: const Color(0xFFF9A825),
                  minHeight: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$m:$s";
  }
}
