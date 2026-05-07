import '../../../../core/config/build_channel_config.dart';
import '../../core/downloader_log.dart';
import '../../core/link_parser.dart';
import '../../domain/entities/extraction_result.dart';
import '../../domain/entities/media_format.dart';
import '../../domain/services/extraction_service.dart';

class ExtractionEngineCoordinator {
  final ExtractionService _ytdlp;
  final ExtractionService _ytExplode;
  final BuildChannelConfig _config;

  const ExtractionEngineCoordinator({
    required ExtractionService ytdlp,
    required ExtractionService ytExplode,
    required BuildChannelConfig config,
  })  : _ytdlp = ytdlp,
        _ytExplode = ytExplode,
        _config = config;

  Future<ExtractionResult> fetchMetadata(String url) async {
    final cleanUrl = LinkParser.clean(url);
    final platform = LinkParser.identify(cleanUrl);
    final failures = <String>[];

    if (_config.isExperimental) {
      try {
        DownloaderLog.engine('Trying yt-dlp for $cleanUrl');
        final result = await _ytdlp.fetchMetadata(cleanUrl);
        DownloaderLog.engine('yt-dlp succeeded for $cleanUrl');
        return result;
      } on ExtractionException catch (e) {
        failures.add(e.message);
        DownloaderLog.engine('yt-dlp failed: ${e.message}');
      }
    } else {
      DownloaderLog.engine('Skipping yt-dlp on stable channel');
    }

    if (platform == VideoPlatform.youtube) {
      try {
        DownloaderLog.engine('Trying youtube_explode fallback');
        final result = await _ytExplode.fetchMetadata(cleanUrl);
        DownloaderLog.engine('youtube_explode succeeded');
        return result;
      } on ExtractionException catch (e) {
        failures.add(e.message);
        DownloaderLog.engine('youtube_explode failed: ${e.message}');
      }
    }

    if (LinkParser.isDirectMediaUrl(cleanUrl)) {
      DownloaderLog.engine('Using direct media URL fallback');
      return _directMediaResult(cleanUrl);
    }

    throw ExtractionException(_friendlyFailureMessage(failures), url: cleanUrl);
  }

  ExtractionResult _directMediaResult(String url) {
    final uri = Uri.parse(url);
    final fileName = uri.pathSegments.isNotEmpty
        ? Uri.decodeComponent(uri.pathSegments.last)
        : 'media';
    final extension = LinkParser.extensionFromUrl(url) ?? 'mp4';
    final isAudio = LinkParser.audioExtensions.contains(extension);

    final format = MediaFormat(
      formatId: 'direct',
      extension: extension,
      note: isAudio ? 'Direct audio' : 'Direct video',
      url: url,
    );

    return ExtractionResult(
      originalUrl: url,
      title: fileName,
      videoFormats: isAudio ? const [] : [format],
      audioFormats: isAudio ? [format] : const [],
      fetchedAt: DateTime.now(),
    );
  }

  String _friendlyFailureMessage(List<String> failures) {
    final joined = failures.join(' ').toLowerCase();
    if (joined.contains('private')) {
      return 'This media is private and cannot be downloaded without account access.';
    }
    if (joined.contains('login') || joined.contains('sign in')) {
      return 'This media requires login, which VidMaster does not bypass.';
    }
    if (joined.contains('drm')) {
      return 'DRM-protected media is not supported.';
    }
    if (failures.isEmpty) {
      return 'This URL is not supported by the current build channel.';
    }
    return failures.last;
  }
}
