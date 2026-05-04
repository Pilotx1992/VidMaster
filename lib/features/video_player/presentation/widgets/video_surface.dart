import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../../domain/entities/video_playback_state.dart';
import '../providers/subtitle_engine_provider.dart';

class VideoSurface extends ConsumerWidget {
  final VideoController controller;
  final VideoAspectRatioMode mode;
  final String? heroTag;
  
  const VideoSurface({
    super.key,
    required this.controller,
    this.mode = VideoAspectRatioMode.fit,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subSettings = ref.watch(subtitleEngineProvider);
    
    final boxFit = switch (mode) {
      VideoAspectRatioMode.fit => BoxFit.contain,
      VideoAspectRatioMode.fill => BoxFit.fill,
      VideoAspectRatioMode.stretch => BoxFit.fitWidth,
      VideoAspectRatioMode.zoom => BoxFit.cover,
    };

    final subtitleConfig = SubtitleViewConfiguration(
      style: TextStyle(
        fontSize: subSettings.fontSize,
        color: Colors.white,
        backgroundColor: Colors.black45,
      ),
      textAlign: TextAlign.center,
      padding: const EdgeInsets.all(24.0),
    );

    Widget videoWidget = Video(
      controller: controller,
      fit: boxFit,
      fill: Colors.black,
      controls: NoVideoControls,
      subtitleViewConfiguration: subSettings.isVisible ? subtitleConfig : const SubtitleViewConfiguration(style: TextStyle(fontSize: 0)),
    );

    if (heroTag != null) {
      videoWidget = Hero(
        tag: heroTag!,
        child: videoWidget,
      );
    }

    return Center(child: videoWidget);
  }
}
