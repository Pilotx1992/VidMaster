/// Metadata stored in Hive for a single vault-encrypted file.
///
/// ⚠️  This entity contains NO actual file content — only the keys and
/// metadata needed to locate and decrypt the corresponding `.enc` file
/// on disk. This is by design: storing video bytes in Hive would cause
/// OOM crashes for files larger than ~100 MB.
///
/// Encryption scheme:
///   - Algorithm  : AES-256-GCM (authenticated encryption)
///   - Key wrap   : PBKDF2-HMAC-SHA256 (200,000 iterations)
///   - IV / nonce : 96-bit random, unique per file
///   - Chunk size : 4 MB (streaming cipher — constant RAM usage)
final class EncryptedFileMetadata {
  /// Unique identifier for this vault entry (UUID v4).
  final String id;

  /// Original file name with extension. Example: `vacation.mp4`
  /// Shown in the vault UI. Never stored on disk in plain text.
  final String originalFileName;

  /// MIME type of the original file. Example: `video/mp4`
  final String mimeType;

  /// Original file size in bytes (before encryption).
  /// Encryption adds minimal overhead (~16 bytes GCM tag per chunk).
  final int originalFileSizeBytes;

  /// Name of the encrypted file on disk. Example: `a3f9c2b1.enc`
  /// The actual file lives at: `<app_private_dir>/vault/<encFileName>`
  final String encFileName;

  /// The AES-256 file encryption key, wrapped (encrypted) with the
  /// user's PIN-derived key (PBKDF2).
  ///
  /// To decrypt: derive key from PIN + [pbkdf2Salt], then unwrap this.
  /// Never store the unwrapped key on disk or in memory longer than needed.
  final List<int> wrappedKey;

  /// 96-bit (12-byte) GCM nonce / IV used for AES-GCM encryption.
  /// Unique per file. Never reuse.
  final List<int> iv;

  /// PBKDF2 salt used to derive the key-wrapping key from the user's PIN.
  /// 32 bytes, cryptographically random, unique per vault entry.
  final List<int> pbkdf2Salt;

  /// When the file was moved into the vault.
  final DateTime encryptedAt;

  /// Original absolute path before moving to vault.
  /// Used for "restore to original location" logic.
  final String originalFilePath;

  const EncryptedFileMetadata({
    required this.id,
    required this.originalFileName,
    required this.mimeType,
    required this.originalFileSizeBytes,
    required this.encFileName,
    required this.wrappedKey,
    required this.iv,
    required this.pbkdf2Salt,
    required this.encryptedAt,
    required this.originalFilePath,
  });

  // ─── Computed Properties ───────────────────────────────────────────────

  /// Absolute path to the encrypted file on disk.
  /// Requires the app's private directory prefix (injected at runtime).
  String encFilePath(String vaultDir) => '$vaultDir/$encFileName';

  /// Human-readable file size of the original file.
  String get formattedSize {
    const kb = 1024;
    const mb = kb * 1024;
    const gb = mb * 1024;
    if (originalFileSizeBytes >= gb) {
      return '${(originalFileSizeBytes / gb).toStringAsFixed(1)} GB';
    } else if (originalFileSizeBytes >= mb) {
      return '${(originalFileSizeBytes / mb).toStringAsFixed(0)} MB';
    }
    return '${(originalFileSizeBytes / kb).toStringAsFixed(0)} KB';
  }

  /// File extension in lowercase. Example: `mp4`
  String get extension => originalFileName.contains('.')
      ? originalFileName.split('.').last.toLowerCase()
      : '';

  // ─── Value Equality ───────────────────────────────────────────────────

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EncryptedFileMetadata &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'EncryptedFileMetadata(id: $id, file: $originalFileName, size: $formattedSize)';
}
