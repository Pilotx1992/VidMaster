import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/encrypted_file_metadata.dart';
import '../models/encrypted_file_metadata_model.dart';

/// Hive-backed data source for vault file metadata.
class VaultMetadataDataSource {
  final Box<EncryptedFileMetadataModel> _box;

  /// The Hive box name used for vault metadata.
  static const String boxName = 'vault_metadata';

  VaultMetadataDataSource(this._box);

  // ─── CRUD ────────────────────────────────────────────────────────────

  Future<void> saveMetadata(EncryptedFileMetadata metadata) async {
    try {
      final model = EncryptedFileMetadataModel.fromDomain(metadata);
      await _box.put(metadata.id, model);
    } catch (e) {
      throw CacheException(message: 'Failed to save vault metadata: $e');
    }
  }

  EncryptedFileMetadata? getMetadata(String id) {
    try {
      return _box.get(id)?.toDomain();
    } catch (e) {
      throw CacheException(message: 'Failed to read vault metadata: $e');
    }
  }

  List<EncryptedFileMetadata> getAllMetadata() {
    try {
      final entries = _box.values.map((e) => e.toDomain()).toList();
      entries.sort((a, b) => b.encryptedAt.compareTo(a.encryptedAt));
      return entries;
    } catch (e) {
      throw CacheException(message: 'Failed to read all vault metadata: $e');
    }
  }

  Future<void> deleteMetadata(String id) async {
    try {
      await _box.delete(id);
    } catch (e) {
      throw CacheException(message: 'Failed to delete vault metadata: $e');
    }
  }

  int getItemCount() => _box.length;

  // ─── Batch Operations ────────────────────────────────────────────────

  Future<void> updateMetadata(EncryptedFileMetadata metadata) async {
    await saveMetadata(metadata);
  }
}
