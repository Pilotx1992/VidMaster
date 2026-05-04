abstract class StorageService {
  /// Returns available storage in bytes.
  Future<int>    availableBytes();

  /// Resolves the output directory path for [subDir].
  Future<String> resolveOutputPath(String subDir, String filename);

  /// Resolves a temp path for intermediate DASH files.
  Future<String> resolveTempPath(String filename);

  /// Returns true if there is enough space for [requiredBytes].
  Future<bool>   hasEnoughSpace(int requiredBytes, {double multiplier = 2.5});

  /// Deletes a file at [path] safely (no exception if missing).
  Future<void>   deleteFile(String path);
}
