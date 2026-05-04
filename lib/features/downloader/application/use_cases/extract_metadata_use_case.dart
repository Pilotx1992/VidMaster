import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../core/link_parser.dart';
import '../../domain/entities/extraction_result.dart';
import '../../domain/repositories/extraction_cache_repository.dart';
import '../../domain/services/extraction_service.dart';

class ExtractMetadataUseCase {
  final ExtractionService          _ytdlp;
  final ExtractionService          _ytExplode;
  final ExtractionCacheRepository  _cache;

  ExtractMetadataUseCase({
    required ExtractionService         ytdlp,
    required ExtractionService         ytExplode,
    required ExtractionCacheRepository cache,
  })  : _ytdlp     = ytdlp,
        _ytExplode = ytExplode,
        _cache     = cache;

  Future<Either<Failure, ExtractionResult>> call(String url) async {
    try {
      final cleanUrl = LinkParser.clean(url);
      final platform = LinkParser.identify(cleanUrl);

      // Step 1: Cache hit?
      final cached = await _cache.getCached(cleanUrl);
      if (cached != null) {
        debugPrint('[Extractor] Cache hit for $cleanUrl');
        return Right(cached);
      }

      // Step 2: Try yt-dlp (primary)
      ExtractionResult? result;
      try {
        result = await _ytdlp.fetchMetadata(cleanUrl);
        debugPrint('[Extractor] yt-dlp success for $cleanUrl');
      } on ExtractionException catch (e) {
        debugPrint('[Extractor] yt-dlp failed: $e');
      }

      // Step 3: Fallback to youtube_explode (YouTube only)
      if (result == null && platform == VideoPlatform.youtube) {
        try {
          result = await _ytExplode.fetchMetadata(cleanUrl);
          debugPrint('[Extractor] youtube_explode fallback success');
        } on ExtractionException catch (e) {
          debugPrint('[Extractor] youtube_explode also failed: $e');
        }
      }

      if (result == null) {
        return const Left(NetworkFailure('All extraction engines failed for this URL'));
      }

      // Cache the result
      await _cache.cache(cleanUrl, result);
      return Right(result);
    } catch (e) {
      return Left(NetworkFailure('Unexpected extraction error: $e'));
    }
  }
}
