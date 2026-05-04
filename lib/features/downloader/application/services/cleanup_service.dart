import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../domain/services/storage_service.dart';

class CleanupService {
  final StorageService _storage;

  CleanupService(this._storage);

  /// Cleans up temporary files older than [olderThan] hours.
  Future<void> cleanTempFiles({int olderThan = 24}) async {
    try {
      // We need a way to get the temp directory path.
      // Since StorageService has resolveTempPath, I'll use it to get the parent dir.
      final tempFileSample = await _storage.resolveTempPath('sample.tmp');
      final tempDir = File(tempFileSample).parent;

      if (!await tempDir.exists()) return;

      final now = DateTime.now();
      final threshold = now.subtract(Duration(hours: olderThan));

      int count = 0;
      await for (final file in tempDir.list()) {
        if (file is File) {
          final stat = await file.stat();
          if (stat.modified.isBefore(threshold)) {
            await file.delete();
            count++;
          }
        }
      }
      
      if (count > 0) {
        debugPrint('[Cleanup] Deleted $count old temporary files.');
      }
    } catch (e) {
      debugPrint('[Cleanup] Error during temp cleanup: $e');
    }
  }

  /// Deletes orphaned files in the download directory that are not in Isar.
  /// (To be implemented if needed, requires access to the repository)
}
