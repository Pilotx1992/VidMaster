import '../entities/extraction_result.dart';

/// Contract for fetching video metadata from a URL.
abstract class ExtractionService {
  /// Fetches all available formats for [url].
  ///
  /// Throws [ExtractionException] on failure.
  Future<ExtractionResult> fetchMetadata(String url);
}

class ExtractionException implements Exception {
  final String message;
  final String? url;
  const ExtractionException(this.message, {this.url});

  @override
  String toString() => 'ExtractionException: $message (url: $url)';
}
