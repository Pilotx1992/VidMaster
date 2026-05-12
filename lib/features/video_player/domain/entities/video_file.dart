import '../utils/video_mime_utils.dart';

class VideoFile {
  final String path;
  final String name;
  final Duration? duration;

  const VideoFile({
    required this.path,
    required this.name,
    this.duration,
  });

  String get extension => VideoMimeUtils.extensionForPath(path);

  String get mimeType => VideoMimeUtils.mimeTypeForPath(path);

  bool get isLikelyChromecastCompatible =>
      VideoMimeUtils.isLikelyChromecastCompatiblePath(path);

  String? get chromecastCompatibilityWarning =>
      VideoMimeUtils.chromecastCompatibilityWarningForPath(path);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoFile &&
          runtimeType == other.runtimeType &&
          path == other.path;

  @override
  int get hashCode => path.hashCode;
}
