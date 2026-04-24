/// Custom exception classes for VidMaster.
///
/// Exceptions are thrown in the data layer and caught by repository
/// implementations, which convert them into [Failure] objects.
library;

/// Thrown when a remote server / API call fails.
class ServerException implements Exception {
  const ServerException({required this.message, this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'ServerException($message, statusCode: $statusCode)';
}

/// Thrown when a local cache / database operation fails.
class CacheException implements Exception {
  const CacheException({required this.message});

  final String message;

  @override
  String toString() => 'CacheException($message)';
}

/// Thrown when a file-system / storage operation fails.
class StorageException implements Exception {
  const StorageException({required this.message});

  final String message;

  @override
  String toString() => 'StorageException($message)';
}

/// Thrown when an encryption / decryption operation fails.
class EncryptionException implements Exception {
  const EncryptionException({required this.message});

  final String message;

  @override
  String toString() => 'EncryptionException($message)';
}
