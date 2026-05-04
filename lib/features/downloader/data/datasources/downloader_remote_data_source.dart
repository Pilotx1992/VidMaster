import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/download_url_info.dart';

/// Remote data source that validates download URLs via HTTP HEAD requests.
///
/// Extracts metadata (size, MIME type, resume support, suggested file name)
/// without downloading the actual file body.
///
/// Throws [ServerException] on any network or HTTP error.
class DownloaderRemoteDataSource {
  final Dio _dio;

  DownloaderRemoteDataSource({required Dio dio}) : _dio = dio;

  /// Sends a HEAD request to [url] and extracts download metadata.
  ///
  /// Parses the following response headers:
  ///   - `Content-Length` → file size in bytes
  ///   - `Content-Type` → MIME type
  ///   - `Accept-Ranges` → resume support
  ///   - `Content-Disposition` → suggested file name
  ///
  /// Falls back to extracting the file name from the URL path if
  /// `Content-Disposition` is absent.
  Future<DownloadUrlInfo> validateUrl(String url) async {
    try {
      final response = await _dio.head<void>(
        url,
        options: Options(
          // Follow redirects to reach the final resource.
          followRedirects: true,
          maxRedirects: 5,
          // Short timeout for a HEAD — we only need headers.
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 10),
        ),
      );

      final headers = response.headers;

      // ── Content-Length ──────────────────────────────────────────────
      final contentLength = int.tryParse(
        headers.value('content-length') ?? '',
      );

      // ── Content-Type ───────────────────────────────────────────────
      final contentType = headers.value('content-type');

      // ── Accept-Ranges ──────────────────────────────────────────────
      final acceptRanges = headers.value('accept-ranges') ?? '';
      final supportsResume = acceptRanges.toLowerCase() == 'bytes';

      // ── File name ──────────────────────────────────────────────────
      final suggestedFileName = _extractFileName(
        headers.value('content-disposition'),
        url,
      );

      // ── Determine Engine (Hybrid Router) ───────────────────────────
      final engine = _determineEngine(contentType, url);

      return DownloadUrlInfo(
        url: url,
        suggestedFileName: suggestedFileName,
        supportsResume: supportsResume,
        engine: engine,
        fileSizeBytes: contentLength,
        mimeType: contentType,
      );
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? 'HEAD request failed for $url',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException(message: 'Unexpected error validating URL: $e');
    }
  }

  /// The "Hybrid Router" logic.
  /// Classifies the URL as [DownloadEngineType.ffmpeg] if it's an HLS/M3U8 stream,
  /// otherwise defaults to [DownloadEngineType.native].
  DownloadEngineType _determineEngine(String? contentType, String url) {
    final mime = contentType?.toLowerCase() ?? '';
    final path = url.toLowerCase();

    // 1. Check MIME types
    if (mime.contains('mpegurl') ||
        mime.contains('apple.mpegurl') ||
        mime.contains('x-mpegurl')) {
      return DownloadEngineType.ffmpeg;
    }

    // 2. Check extension as fallback
    if (path.endsWith('.m3u8') ||
        path.contains('.m3u8?') ||
        path.endsWith('.m3u')) {
      return DownloadEngineType.ffmpeg;
    }

    return DownloadEngineType.native;
  }

  /// Extracts a reasonable file name from [contentDisposition] or the [url].
  ///
  /// Content-Disposition examples:
  ///   `attachment; filename="movie.mp4"`
  ///   `attachment; filename*=UTF-8''movie%20file.mp4`
  String _extractFileName(String? contentDisposition, String url) {
    // Try Content-Disposition header first.
    if (contentDisposition != null) {
      final filenameMatch = RegExp(
        r'''filename\*?=(?:UTF-8''|"?)([^";\s]+)"?''',
        caseSensitive: false,
      ).firstMatch(contentDisposition);
      if (filenameMatch != null) {
        final raw = filenameMatch.group(1)!;
        return Uri.decodeComponent(raw);
      }
    }

    // Fall back to the last path segment of the URL.
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
      if (segments.isNotEmpty) {
        return Uri.decodeComponent(segments.last);
      }
    } catch (_) {
      // URL parsing failed — use a generic fallback.
    }

    return 'download_${DateTime.now().millisecondsSinceEpoch}';
  }
}
