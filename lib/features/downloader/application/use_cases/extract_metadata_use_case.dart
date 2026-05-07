import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../application/services/extraction_engine_coordinator.dart';
import '../../core/downloader_log.dart';
import '../../core/link_parser.dart';
import '../../domain/entities/extraction_result.dart';
import '../../domain/repositories/extraction_cache_repository.dart';
import '../../domain/services/extraction_service.dart';

class ExtractMetadataUseCase {
  final ExtractionEngineCoordinator _coordinator;
  final ExtractionCacheRepository _cache;

  ExtractMetadataUseCase({
    required ExtractionEngineCoordinator coordinator,
    required ExtractionCacheRepository cache,
  })  : _coordinator = coordinator,
        _cache = cache;

  Future<Either<Failure, ExtractionResult>> call(String url) async {
    try {
      final cleanUrl = LinkParser.clean(url);

      // Step 1: Cache hit?
      final cached = await _cache.getCached(cleanUrl);
      if (cached != null) {
        DownloaderLog.engine('Cache hit for $cleanUrl');
        return Right(cached);
      }

      final result = await _coordinator.fetchMetadata(cleanUrl);

      // Cache the result
      await _cache.cache(cleanUrl, result);
      return Right(result);
    } on ExtractionException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(NetworkFailure('Unexpected extraction error: $e'));
    }
  }
}
