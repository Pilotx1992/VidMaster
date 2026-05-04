import '../entities/extraction_result.dart';

abstract class ExtractionCacheRepository {
  /// Returns cached result if it exists and is younger than 24 hours.
  Future<ExtractionResult?> getCached(String url);
  Future<void>              cache(String url, ExtractionResult result);
  Future<void>              clearExpired();
}
