import 'downloader_constants.dart';

/// Supported social media platforms.
enum VideoPlatform {
  youtube,
  instagram,
  facebook,
  tiktok,
  twitter,
  vimeo,
  dailymotion,
  twitch,
  unknown,
}

/// Parses and classifies video URLs.
class LinkParser {
  LinkParser._();

  /// Returns true if [url] is a recognisable video URL.
  static bool isVideoUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return DownloaderConstants.supportedDomains
          .any((domain) => uri.host.contains(domain));
    } catch (_) {
      return false;
    }
  }

  /// Identifies the platform of [url].
  static VideoPlatform identify(String url) {
    final lower = url.toLowerCase();
    if (lower.contains('youtube.com') || lower.contains('youtu.be')) {
      return VideoPlatform.youtube;
    }
    if (lower.contains('instagram.com')) return VideoPlatform.instagram;
    if (lower.contains('facebook.com') || lower.contains('fb.watch')) {
      return VideoPlatform.facebook;
    }
    if (lower.contains('tiktok.com')) return VideoPlatform.tiktok;
    if (lower.contains('twitter.com') || lower.contains('x.com')) {
      return VideoPlatform.twitter;
    }
    if (lower.contains('vimeo.com')) return VideoPlatform.vimeo;
    if (lower.contains('dailymotion.com')) return VideoPlatform.dailymotion;
    return VideoPlatform.unknown;
  }

  /// Returns a cleaned canonical URL (removes tracking params).
  static String clean(String url) {
    try {
      final uri = Uri.parse(url);
      // YouTube: keep only 'v' query param
      if (uri.host.contains('youtu')) {
        final v = uri.queryParameters['v'];
        if (v != null) {
          return 'https://www.youtube.com/watch?v=$v';
        }
      }
      return url;
    } catch (_) {
      return url;
    }
  }

  static const videoExtensions = {
    'mp4',
    'm4v',
    'mkv',
    'webm',
    'mov',
    'avi',
  };

  static const audioExtensions = {
    'mp3',
    'm4a',
    'aac',
    'ogg',
    'opus',
    'flac',
    'wav',
  };

  static bool isDirectMediaUrl(String url) {
    try {
      final uri = Uri.parse(url);
      if (!uri.hasScheme || uri.host.isEmpty) return false;
      return extensionFromUrl(url) != null;
    } catch (_) {
      return false;
    }
  }

  static String? extensionFromUrl(String url) {
    final path = Uri.parse(url).path.toLowerCase();
    final segment = path.split('/').last;
    final dot = segment.lastIndexOf('.');
    if (dot < 0 || dot == segment.length - 1) return null;
    final ext = segment.substring(dot + 1);
    if (videoExtensions.contains(ext) || audioExtensions.contains(ext)) {
      return ext;
    }
    return null;
  }
}
