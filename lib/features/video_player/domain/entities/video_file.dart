class VideoFile {
  final String path;
  final String name;
  final Duration? duration;

  const VideoFile({
    required this.path,
    required this.name,
    this.duration,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoFile &&
      runtimeType == other.runtimeType &&
      path == other.path;

  @override
  int get hashCode => path.hashCode;
}