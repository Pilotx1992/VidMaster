/// Base sealed class for all domain-layer failures.
///
/// Using a sealed class ensures every failure type is handled exhaustively
/// in switch expressions — the compiler will warn if a case is missing.
///
/// Usage:
/// ```dart
/// result.fold(
///   (failure) => switch (failure) {
///     StoragePermissionFailure() => showPermissionDialog(),
///     FileNotFoundFailure(:final path) => showError('File not found: $path'),
///     ...
///   },
///   (data) => handleSuccess(data),
/// );
/// ```
sealed class Failure {
  final String message;
  final StackTrace? stackTrace;

  const Failure(this.message, {this.stackTrace});

  @override
  String toString() => '$runtimeType: $message';
}

// ─── Storage & File System ────────────────────────────────────────────────

/// User has not granted storage read/write permission.
final class StoragePermissionFailure extends Failure {
  const StoragePermissionFailure()
      : super('Storage permission denied. Grant access in app settings.');
}

/// The requested file does not exist at the given path.
final class FileNotFoundFailure extends Failure {
  final String path;
  const FileNotFoundFailure(this.path)
      : super('File not found: $path');
}

/// A file system I/O operation failed (read, write, delete, rename).
final class FileSystemFailure extends Failure {
  const FileSystemFailure(super.message, {super.stackTrace});
}

/// The directory scan found no media files.
final class EmptyLibraryFailure extends Failure {
  const EmptyLibraryFailure()
      : super('No media files found on device storage.');
}

// ─── Encryption / Vault ───────────────────────────────────────────────────

/// The provided PIN or biometric does not match stored credentials.
final class AuthenticationFailure extends Failure {
  final int attemptsRemaining;
  const AuthenticationFailure({required this.attemptsRemaining})
      : super('Authentication failed. $attemptsRemaining attempts remaining.');
}

/// Too many failed PIN attempts — vault is temporarily locked.
final class VaultLockedFailure extends Failure {
  final Duration lockDuration;
  VaultLockedFailure({required this.lockDuration})
      : super(
            'Vault locked for ${lockDuration.inMinutes} minutes after too many failed attempts.');
}

/// AES encryption or decryption operation failed.
final class EncryptionFailure extends Failure {
  const EncryptionFailure(super.message, {super.stackTrace});
}

/// The file is already inside the vault.
final class AlreadyInVaultFailure extends Failure {
  const AlreadyInVaultFailure(String fileName)
      : super('$fileName is already in the vault.');
}

/// Vault metadata is corrupted or could not be read from Hive.
final class VaultCorruptedFailure extends Failure {
  const VaultCorruptedFailure()
      : super(
            'Vault data is corrupted. Please contact support or clear vault data.');
}

// ─── Playback ─────────────────────────────────────────────────────────────

/// The video/audio format is not supported by the playback engine.
final class UnsupportedFormatFailure extends Failure {
  final String format;
  const UnsupportedFormatFailure(this.format)
      : super('Unsupported media format: $format');
}

/// Playback engine failed to initialise (e.g. media_kit setup error).
final class PlaybackInitFailure extends Failure {
  const PlaybackInitFailure(super.message, {super.stackTrace});
}

/// Hardware decoder is unavailable; falling back to software.
/// This is a non-fatal warning — surface it to the user as a notice only.
final class HardwareDecoderUnavailableFailure extends Failure {
  const HardwareDecoderUnavailableFailure()
      : super(
            'Hardware decoder unavailable. Using software decoding (may impact performance).');
}

// ─── Thumbnail ────────────────────────────────────────────────────────────

/// Thumbnail generation failed for a video file.
final class ThumbnailFailure extends Failure {
  final String videoPath;
  const ThumbnailFailure(this.videoPath)
      : super('Could not generate thumbnail for: $videoPath');
}

// ─── Downloads ────────────────────────────────────────────────────────────

/// The provided download URL is malformed or unreachable.
final class InvalidUrlFailure extends Failure {
  final String url;
  const InvalidUrlFailure(this.url) : super('Invalid or unreachable URL: $url');
}

/// Network request failed (timeout, no internet, etc.).
final class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.stackTrace});
}

/// The download was cancelled by the user.
final class DownloadCancelledFailure extends Failure {
  const DownloadCancelledFailure() : super('Download was cancelled.');
}

/// Not enough storage space to complete the download.
final class InsufficientStorageFailure extends Failure {
  final int requiredBytes;
  final int availableBytes;
  const InsufficientStorageFailure({
    required this.requiredBytes,
    required this.availableBytes,
  }) : super(
            'Insufficient storage: need ${requiredBytes}B, have ${availableBytes}B available.');
}

// ─── Cache ────────────────────────────────────────────────────────────────

/// Local database operation failed.
final class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.stackTrace});
}
