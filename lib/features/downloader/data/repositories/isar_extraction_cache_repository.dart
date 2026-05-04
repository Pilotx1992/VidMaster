import 'dart:convert';

import 'package:isar/isar.dart';

import '../../core/downloader_constants.dart';
import '../../domain/entities/extraction_result.dart';
import '../../domain/repositories/extraction_cache_repository.dart';
import '../models/extraction_cache_model.dart';

class IsarExtractionCacheRepository implements ExtractionCacheRepository {
  final Isar _isar;

  IsarExtractionCacheRepository({required Isar isar}) : _isar = isar;

  IsarCollection<ExtractionCacheModel> get _box => _isar.extractionCacheModels;

  @override
  Future<void> cache(String url, ExtractionResult result) async {
    final model = ExtractionCacheModel(
      url: url,
      payload: jsonEncode(result.toJson()),
      cachedAt: DateTime.now(),
    );

    await _isar.writeTxn(() async {
      await _box.put(model);
    });
  }

  @override
  Future<void> clearExpired() async {
    final expiryThreshold = DateTime.now().subtract(
      const Duration(hours: DownloaderConstants.metadataCacheDurationHours),
    );

    await _isar.writeTxn(() async {
      await _box.filter().cachedAtLessThan(expiryThreshold).deleteAll();
    });
  }

  @override
  Future<ExtractionResult?> getCached(String url) async {
    final model = await _box.where().urlEqualTo(url).findFirst();
    if (model == null) return null;

    if (DateTime.now().difference(model.cachedAt).inHours >=
        DownloaderConstants.metadataCacheDurationHours) {
      await clearExpired();
      return null;
    }

    final json = jsonDecode(model.payload) as Map<String, dynamic>;
    return ExtractionResult.fromJson(json);
  }
}
