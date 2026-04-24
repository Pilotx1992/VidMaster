import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/encrypted_file_metadata.dart';

/// Contract for all vault (encrypted secure storage) operations.
///
/// Implementation responsibilities:
///   - AES-256-GCM streaming encryption/decryption of files on disk
///   - PBKDF2 key derivation from user PIN (200,000 iterations, SHA-256)
///   - Storing/retrieving [EncryptedFileMetadata] in a Hive encrypted box
///   - Biometric + PIN authentication via `local_auth`
///
/// Vault directory: `<app private storage>/vault/` — inaccessible without root.
/// Hive box: `vault_metadata` — itself AES-256 encrypted with a master key
/// stored in Android Keystore via `flutter_secure_storage`.
abstract interface class VaultRepository {
  // ─── Authentication ───────────────────────────────────────────────────

  /// Authenticates the user before any vault operation.
  ///
  /// The auth method is determined by what's enabled:
  ///   - If biometrics are enrolled and available → attempt biometric first.
  ///   - [inputPin] is used as fallback or primary if no biometrics.
  ///
  /// Returns [true] on success.
  /// Returns [AuthenticationFailure] if credentials don't match.
  /// Returns [VaultLockedFailure] if too many failed attempts.
  Future<Either<Failure, bool>> authenticateUser(String? inputPin);

  /// Returns true if the vault is currently accessible (user is authenticated
  /// and the lock timeout has not expired).
  Future<Either<Failure, bool>> isVaultUnlocked();

  /// Locks the vault immediately (e.g. when app goes to background).
  Future<Either<Failure, void>> lockVault();

  /// Returns the number of remaining PIN attempts before lockout.
  /// Returns null if no lockout mechanism is active.
  Future<Either<Failure, int?>> getRemainingAttempts();

  // ─── Encryption / Move to Vault ───────────────────────────────────────

  /// Encrypts a file and moves it into the vault.
  ///
  /// Process:
  ///   1. Validate [sourceFilePath] exists and is not already in vault.
  ///   2. Check available storage (encrypted file ≈ same size as original).
  ///   3. Derive a unique AES-256 key from [userPin] + random PBKDF2 salt.
  ///   4. Encrypt the file with AES-256-GCM in 4 MB streaming chunks.
  ///   5. Write the `.enc` file to `<vault_dir>/<uuid>.enc`.
  ///   6. Store [EncryptedFileMetadata] in Hive.
  ///   7. Securely delete the original file (overwrite then delete).
  ///
  /// Returns the [EncryptedFileMetadata] for the newly vaulted file.
  Future<Either<Failure, EncryptedFileMetadata>> encryptAndMoveToVault({
    required String sourceFilePath,
    required String userPin,
  });

  /// Reports encryption progress (0.0 – 1.0) as the file is being
  /// written in chunks. Useful for showing a progress bar in the UI.
  ///
  /// The stream completes when encryption is done or emits an error.
  Stream<Either<Failure, double>> encryptionProgress(String sourceFilePath);

  // ─── Decryption / Restore from Vault ─────────────────────────────────

  /// Decrypts a vault file and restores it to its original location.
  ///
  /// Process:
  ///   1. Verify the user is authenticated ([isVaultUnlocked]).
  ///   2. Locate the `.enc` file using [metadata.encFileName].
  ///   3. Derive the decryption key from [userPin] + [metadata.pbkdf2Salt].
  ///   4. Unwrap the per-file key using the derived key.
  ///   5. Decrypt the file in 4 MB streaming chunks.
  ///   6. Write the output to [metadata.originalFilePath].
  ///   7. Delete the `.enc` file and remove metadata from Hive.
  ///
  /// Returns the restored file's absolute path on success.
  Future<Either<Failure, String>> decryptAndRestoreFromVault({
    required EncryptedFileMetadata metadata,
    required String userPin,
  });

  /// Reports decryption progress (0.0 – 1.0).
  Stream<Either<Failure, double>> decryptionProgress(String encFileName);

  // ─── Vault Contents ───────────────────────────────────────────────────

  /// Returns all items currently stored in the vault, ordered by
  /// [encryptedAt] descending (newest first).
  Future<Either<Failure, List<EncryptedFileMetadata>>> getVaultItems();

  /// Returns a single vault item by its [id].
  Future<Either<Failure, EncryptedFileMetadata?>> getVaultItemById(String id);

  /// Returns the total number of files currently in the vault.
  Future<Either<Failure, int>> getVaultItemCount();

  /// Returns the total encrypted size of all vault files in bytes.
  Future<Either<Failure, int>> getVaultTotalSize();

  // ─── Vault Management ─────────────────────────────────────────────────

  /// Permanently deletes a vault file (no restore).
  ///
  /// Deletes the `.enc` file from disk and removes metadata from Hive.
  /// This operation is irreversible.
  Future<Either<Failure, void>> permanentlyDeleteFromVault(String metadataId);

  /// Changes the vault PIN.
  ///
  /// Because each file's key is wrapped with the PIN-derived key, this
  /// operation must re-wrap every file's key with the new PIN.
  /// This can be slow for large vaults.
  ///
  /// [currentPin] is verified before making any changes.
  Future<Either<Failure, void>> changePIN({
    required String currentPin,
    required String newPin,
  });
}
