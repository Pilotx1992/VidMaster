import 'dart:convert';
import 'dart:isolate';
import 'dart:async';

import 'package:flutter/services.dart';

import '../../domain/entities/extraction_result.dart';
import '../../domain/entities/media_format.dart';
import '../../domain/services/extraction_service.dart';
import '../../core/downloader_constants.dart';
import '../../core/link_parser.dart';

/// Extraction service using yt-dlp via Chaquopy (Python on Android).
///
/// Runs the heavy metadata fetching in a separate Dart Isolate
/// to ensure the main UI thread remains completely responsive.
class YtdlpExtractionService implements ExtractionService {

  @override
  Future<ExtractionResult> fetchMetadata(String url) async {
    final cleanUrl = LinkParser.clean(url);

    try {
      // 1. Fetch JSON string from Python via MethodChannel
      // We use a timeout to prevent the app from hanging on slow extractions
      final jsonString = await _fetchInIsolate(cleanUrl)
          .timeout(const Duration(seconds: DownloaderConstants.extractionTimeoutSeconds));

      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      if (data.containsKey('error')) {
        throw ExtractionException(
          data['error'] as String,
          url: cleanUrl,
        );
      }

      return _parseResult(cleanUrl, data);
    } on PlatformException catch (e) {
      throw ExtractionException(
        'yt-dlp platform error: ${e.message}',
        url: cleanUrl,
      );
    } on TimeoutException {
      throw ExtractionException(
        'Extraction timed out after ${DownloaderConstants.extractionTimeoutSeconds}s',
        url: cleanUrl,
      );
    } catch (e) {
      throw ExtractionException(
        'Failed to parse extraction result: $e',
        url: cleanUrl,
      );
    }
  }

  /// Spawns a Dart Isolate to handle the MethodChannel call.
  Future<String> _fetchInIsolate(String url) async {
    final rootToken = RootIsolateToken.instance!;
    final receivePort = ReceivePort();
    
    await Isolate.spawn(
      _isolateEntry, 
      _IsolatePayload(
        sendPort: receivePort.sendPort, 
        url: url, 
        token: rootToken,
      ),
    );
    
    final result = await receivePort.first;
    if (result is String) return result;
    throw Exception('Isolate returned invalid result type');
  }

  /// Entry point for the extraction Isolate.
  static Future<void> _isolateEntry(_IsolatePayload payload) async {
    // ✅ REQUIRED: Initialize binary messenger for MethodChannel in background isolate
    BackgroundIsolateBinaryMessenger.ensureInitialized(payload.token);

    try {
      const channel = MethodChannel('com.vidmaster/ytdlp');
      final result = await channel.invokeMethod<String>('fetchMetadata', payload.url);
      payload.sendPort.send(result ?? '{"error": "Empty response from engine"}');
    } catch (e) {
      payload.sendPort.send('{"error": "$e"}');
    }
  }

  ExtractionResult _parseResult(String url, Map<String, dynamic> data) {
    final rawFormats = (data['formats'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();

    final videoFormats = <MediaFormat>[];
    final audioFormats = <MediaFormat>[];

    for (final f in rawFormats) {
      final vcodec = f['vcodec'] as String? ?? 'none';
      final acodec = f['acodec'] as String? ?? 'none';
      final height = f['height'] as int?;

      if (vcodec == 'none' && acodec != 'none') {
        // Audio-only format
        audioFormats.add(MediaFormat(
          formatId:     f['format_id'] as String,
          extension:    f['ext'] as String? ?? 'm4a',
          note:         f['note'] as String? ?? 'Audio',
          audioBitrate: (f['abr'] as num?)?.toInt() ?? (f['tbr'] as num?)?.toInt(),
          fileSizeBytes: f['filesize'] as int?,
          url:          f['url'] as String?,
        ));
      } else if (height != null) {
        // Video format (may or may not have audio)
        final hasAudio = acodec != 'none';
        videoFormats.add(MediaFormat(
          formatId:     f['format_id'] as String,
          extension:    f['ext'] as String? ?? 'mp4',
          note:         f['note'] as String? ?? '${height}p',
          width:        f['width'] as int?,
          height:       height,
          fileSizeBytes: f['filesize'] as int?,
          url:          hasAudio ? f['url'] as String? : null,
          videoUrl:     hasAudio ? null : f['url'] as String?,
        ));
      }
    }

    // Sort video by height descending, audio by bitrate descending
    videoFormats.sort((a, b) => (b.height ?? 0).compareTo(a.height ?? 0));
    audioFormats.sort(
        (a, b) => (b.audioBitrate ?? 0).compareTo(a.audioBitrate ?? 0));

    // For DASH videos: pair video-only with best audio URL
    final bestAudio = audioFormats.isNotEmpty ? audioFormats.first : null;
    final pairedFormats = videoFormats.map((vf) {
      if (vf.videoUrl != null && bestAudio?.url != null) {
        return MediaFormat(
          formatId:     vf.formatId,
          extension:    vf.extension,
          note:         vf.note,
          width:        vf.width,
          height:       vf.height,
          fileSizeBytes: (vf.fileSizeBytes ?? 0) + (bestAudio?.fileSizeBytes ?? 0),
          videoUrl:     vf.videoUrl,
          audioUrl:     bestAudio!.url,
        );
      }
      return vf;
    }).toList();

    final durationSec = data['duration'] as num?;

    return ExtractionResult(
      originalUrl:  url,
      title:        data['title'] as String? ?? 'Unknown',
      thumbnailUrl: data['thumbnail'] as String?,
      duration:     durationSec != null
          ? Duration(seconds: durationSec.toInt())
          : null,
      uploaderName: data['uploader'] as String?,
      videoFormats: pairedFormats,
      audioFormats: audioFormats,
      fetchedAt:    DateTime.now(),
    );
  }
}

/// Payload model for Isolate communication.
class _IsolatePayload {
  final SendPort sendPort;
  final String url;
  final RootIsolateToken token;

  _IsolatePayload({
    required this.sendPort,
    required this.url,
    required this.token,
  });
}
