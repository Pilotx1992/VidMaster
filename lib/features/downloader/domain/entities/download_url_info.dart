/// Result of a URL pre-flight check before starting a download.
final class DownloadUrlInfo {
  final String url;
  final String suggestedFileName;
  final int? fileSizeBytes;

  /// Server has `Accept-Ranges: bytes` — supports resume.
  final bool supportsResume;
  final String? mimeType;

  const DownloadUrlInfo({
    required this.url,
    required this.suggestedFileName,
    required this.supportsResume,
    this.fileSizeBytes,
    this.mimeType,
  });

  String get formattedSize {
    if (fileSizeBytes == null) return 'Unknown size';
    const mb = 1024 * 1024;
    const gb = mb * 1024;
    if (fileSizeBytes! >= gb) {
      return '${(fileSizeBytes! / gb).toStringAsFixed(1)} GB';
    }
    return '${(fileSizeBytes! / mb).toStringAsFixed(0)} MB';
  }
}
