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
    if (lower.contains('instagram.com'))   return VideoPlatform.instagram;
    if (lower.contains('facebook.com') || lower.contains('fb.watch')) {
      return VideoPlatform.facebook;
    }
    if (lower.contains('tiktok.com'))      return VideoPlatform.tiktok;
    if (lower.contains('twitter.com') || lower.contains('x.com')) {
      return VideoPlatform.twitter;
    }
    if (lower.contains('vimeo.com'))       return VideoPlatform.vimeo;
    if (lower.contains('dailymotion.com')) return VideoPlatform.dailymotion;
    if (lower.contains('twitch.tv'))       return VideoPlatform.twitch;
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
}
