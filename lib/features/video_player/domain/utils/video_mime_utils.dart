import 'package:mime/mime.dart';

/// Container-level metadata used before deeper codec inspection exists.
///
/// This intentionally stays lightweight: extension and MIME are deterministic
/// from the path, while Chromecast compatibility is only a best-effort
/// container heuristic. It does not inspect embedded video/audio codecs.
final class VideoMimeMetadata {
  final String extension;
  final String mimeType;
  final bool isLikelyChromecastCompatible;
  final String? chromecastCompatibilityWarning;

  const VideoMimeMetadata({
    required this.extension,
    required this.mimeType,
    required this.isLikelyChromecastCompatible,
    required this.chromecastCompatibilityWarning,
  });
}

abstract final class VideoMimeUtils {
  static const fallbackMimeType = 'application/octet-stream';

  static const Map<String, String> _videoMimeByExtension = {
    'mp4': 'video/mp4',
    'm4v': 'video/mp4',
    'webm': 'video/webm',
    'ts': 'video/mp2t',
    'm2ts': 'video/mp2t',
    'mts': 'video/mp2t',
    'mov': 'video/quicktime',
    'qt': 'video/quicktime',
    'mkv': 'video/x-matroska',
    'mk3d': 'video/x-matroska',
    'avi': 'video/x-msvideo',
    'divx': 'video/x-msvideo',
    'wmv': 'video/x-ms-wmv',
    'asf': 'video/x-ms-asf',
    'flv': 'video/x-flv',
    'mpeg': 'video/mpeg',
    'mpg': 'video/mpeg',
    'mpe': 'video/mpeg',
    'mpv': 'video/mpeg',
    'ogv': 'video/ogg',
    'ogg': 'video/ogg',
    'ogm': 'video/ogg',
    '3gp': 'video/3gpp',
    '3g2': 'video/3gpp2',
    'm3u8': 'application/vnd.apple.mpegurl',
  };

  // Google Cast's documented container support includes MP4, WebM, and MP2T.
  // Extension-only checks cannot guarantee codec support inside the container.
  static const Set<String> _likelyChromecastExtensions = {
    'mp4',
    'm4v',
    'webm',
    'ts',
    'm2ts',
    'mts',
  };

  static VideoMimeMetadata metadataForPath(String filePath) {
    final extension = extensionForPath(filePath);
    final mimeType = mimeTypeForExtension(extension, filePath: filePath);
    return VideoMimeMetadata(
      extension: extension,
      mimeType: mimeType,
      isLikelyChromecastCompatible:
          isLikelyChromecastCompatibleExtension(extension),
      chromecastCompatibilityWarning:
          chromecastCompatibilityWarningForExtension(
        extension,
        mimeType: mimeType,
      ),
    );
  }

  static String extensionForPath(String filePath) {
    final normalizedPath = filePath.replaceAll(r'\', '/');
    final fileName = normalizedPath.split('/').last;
    final dot = fileName.lastIndexOf('.');
    if (dot <= 0 || dot == fileName.length - 1) {
      return '';
    }
    return fileName.substring(dot + 1).toLowerCase();
  }

  static String mimeTypeForPath(String filePath) {
    final extension = extensionForPath(filePath);
    return mimeTypeForExtension(extension, filePath: filePath);
  }

  static String mimeTypeForExtension(String extension, {String? filePath}) {
    final normalized = _normalizeExtension(extension);
    return _videoMimeByExtension[normalized] ??
        (filePath == null ? null : lookupMimeType(filePath)) ??
        fallbackMimeType;
  }

  static bool isLikelyChromecastCompatiblePath(String filePath) {
    return isLikelyChromecastCompatibleExtension(extensionForPath(filePath));
  }

  static bool isLikelyChromecastCompatibleExtension(String extension) {
    return _likelyChromecastExtensions.contains(_normalizeExtension(extension));
  }

  static String? chromecastCompatibilityWarningForPath(String filePath) {
    final metadata = metadataForPath(filePath);
    return metadata.chromecastCompatibilityWarning;
  }

  static String? chromecastCompatibilityWarningForExtension(
    String extension, {
    String? mimeType,
  }) {
    final normalized = _normalizeExtension(extension);
    if (isLikelyChromecastCompatibleExtension(normalized)) {
      return null;
    }

    if (normalized.isEmpty) {
      return 'Chromecast compatibility is unknown because this file has no extension.';
    }

    final resolvedMimeType = mimeType ?? mimeTypeForExtension(normalized);
    if (resolvedMimeType == fallbackMimeType) {
      return 'Chromecast compatibility is unknown because .$normalized is not a recognized video type.';
    }

    return 'Chromecast Default Media Receiver is unlikely to play .$normalized files ($resolvedMimeType). Use MP4, WebM, or MPEG-TS with Chromecast-supported codecs.';
  }

  static String _normalizeExtension(String extension) {
    var normalized = extension.trim().toLowerCase();
    while (normalized.startsWith('.')) {
      normalized = normalized.substring(1);
    }
    return normalized;
  }
}
