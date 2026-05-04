import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../../domain/entities/extraction_result.dart';
import '../../domain/entities/media_format.dart';
import '../../domain/services/extraction_service.dart';

/// Lightweight YouTube-only extraction using youtube_explode_dart.
/// Used as fallback when yt-dlp is unavailable or fails.
class YoutubeExplodeService implements ExtractionService {
  final YoutubeExplode _yt = YoutubeExplode();

  @override
  Future<ExtractionResult> fetchMetadata(String url) async {
    try {
      final videoId = VideoId(url);
      final video   = await _yt.videos.get(videoId);
      final manifest = await _yt.videos.streamsClient.getManifest(videoId);

      final videoFormats = <MediaFormat>[];
      final audioFormats = <MediaFormat>[];

      // Muxed streams (video + audio — usually up to 720p)
      for (final stream in manifest.muxed) {
        videoFormats.add(MediaFormat(
          formatId:      stream.tag.toString(),
          extension:     stream.container.name,
          note:          stream.qualityLabel,
          height:        stream.videoResolution.height,
          width:         stream.videoResolution.width,
          fileSizeBytes: stream.size.totalBytes,
          url:           stream.url.toString(),
        ));
      }

      // Video-only streams for DASH
      final bestAudio = manifest.audioOnly.withHighestBitrate();
      for (final stream in manifest.videoOnly) {
        videoFormats.add(MediaFormat(
          formatId:     stream.tag.toString(),
          extension:    stream.container.name,
          note:         stream.qualityLabel,
          height:       stream.videoResolution.height,
          width:        stream.videoResolution.width,
          fileSizeBytes: stream.size.totalBytes,
          videoUrl:     stream.url.toString(),
          audioUrl:     bestAudio.url.toString(),
        ));
      }

      // Audio-only streams
      for (final stream in manifest.audioOnly) {
        audioFormats.add(MediaFormat(
          formatId:      stream.tag.toString(),
          extension:     stream.container.name,
          note:          'Audio ${stream.bitrate.kiloBitsPerSecond.round()}kbps',
          audioBitrate:  stream.bitrate.kiloBitsPerSecond.round(),
          fileSizeBytes: stream.size.totalBytes,
          url:           stream.url.toString(),
        ));
      }

      videoFormats.sort((a, b) => (b.height ?? 0).compareTo(a.height ?? 0));
      audioFormats.sort(
          (a, b) => (b.audioBitrate ?? 0).compareTo(a.audioBitrate ?? 0));

      return ExtractionResult(
        originalUrl:  url,
        title:        video.title,
        thumbnailUrl: video.thumbnails.highResUrl,
        duration:     video.duration,
        uploaderName: video.author,
        videoFormats: videoFormats,
        audioFormats: audioFormats,
        fetchedAt:    DateTime.now(),
      );
    } on VideoUnavailableException {
      throw ExtractionException('Video is unavailable or private', url: url);
    } catch (e) {
      throw ExtractionException('youtube_explode error: $e', url: url);
    }
  }

  void dispose() => _yt.close();
}
