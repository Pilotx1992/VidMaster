/// Application-wide constants for the downloader feature.
class DownloaderConstants {
  DownloaderConstants._();

  // ── Extraction ─────────────────────────────────────────────
  static const int  extractionTimeoutSeconds  = 30;
  static const int  metadataCacheDurationHours = 24;
  static const int  maxConcurrentDownloads     = 3;

  // ── Storage ────────────────────────────────────────────────
  /// Minimum free space multiplier before starting a DASH download.
  static const double storageBufferMultiplier = 2.5;

  /// Minimum free space multiplier for single-stream downloads.
  static const double storageBufferSingle     = 1.5;

  // ── Download directory names ───────────────────────────────
  static const String videoSubDir  = 'VidMaster/Videos';
  static const String audioSubDir  = 'VidMaster/Music';
  static const String tempSubDir   = 'VidMaster/.temp';

  // ── FFmpeg ─────────────────────────────────────────────────
  static const int  ffmpegTimeoutSeconds = 120;

  // ── Clipboard polling ──────────────────────────────────────
  static const int  clipboardPollIntervalMs = 1500;

  // ── Supported platforms ────────────────────────────────────
  static const List<String> supportedDomains = [
    'youtube.com', 'youtu.be',
    'instagram.com',
    'facebook.com', 'fb.watch',
    'tiktok.com',
    'twitter.com', 'x.com',
    'vimeo.com',
    'dailymotion.com',
    'twitch.tv',
  ];
}
