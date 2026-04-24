import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/encrypted_file_metadata.dart';
import '../repositories/vault_repository.dart';

// ═══════════════════════════════════════════════════════════════════════════
// AUTHENTICATION
// ═══════════════════════════════════════════════════════════════════════════

/// Authenticates the user to unlock the vault.
///
/// Pass [inputPin] = null to attempt biometric-only authentication.
/// Pass a PIN string to use PIN (or as biometric fallback).
final class AuthenticateVaultUser
    implements UseCase<bool, AuthenticateVaultUserParams> {
  final VaultRepository _repository;
  const AuthenticateVaultUser(this._repository);

  @override
  Future<Either<Failure, bool>> call(AuthenticateVaultUserParams params) =>
      _repository.authenticateUser(params.inputPin);
}

final class AuthenticateVaultUserParams {
  /// Null = biometric only. Non-null = PIN (or biometric with PIN fallback).
  final String? inputPin;
  const AuthenticateVaultUserParams({this.inputPin});
}

// ─────────────────────────────────────────────────────────────────────────

/// Checks if the vault is currently in an unlocked state.
final class CheckVaultUnlocked
    implements UseCase<bool, NoParams> {
  final VaultRepository _repository;
  const CheckVaultUnlocked(this._repository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) =>
      _repository.isVaultUnlocked();
}

// ─────────────────────────────────────────────────────────────────────────

/// Locks the vault immediately.
///
/// Call when:
///   - App moves to background ([AppLifecycleState.paused])
///   - User taps "Lock Vault" explicitly
///   - Auto-lock timeout fires
final class LockVault implements UseCase<void, NoParams> {
  final VaultRepository _repository;
  const LockVault(this._repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) =>
      _repository.lockVault();
}

// ─────────────────────────────────────────────────────────────────────────

/// Returns remaining PIN attempts before lockout.
/// Returns null if no attempt counter is active.
final class GetRemainingAttempts
    implements UseCase<int?, NoParams> {
  final VaultRepository _repository;
  const GetRemainingAttempts(this._repository);

  @override
  Future<Either<Failure, int?>> call(NoParams params) =>
      _repository.getRemainingAttempts();
}

// ═══════════════════════════════════════════════════════════════════════════
// ENCRYPT & MOVE TO VAULT
// ═══════════════════════════════════════════════════════════════════════════

/// Encrypts a file and moves it into the secure vault.
///
/// The source file is securely deleted after successful encryption.
/// Shows progress via [WatchEncryptionProgress] use case if needed.
final class EncryptAndMoveToVault
    implements UseCase<EncryptedFileMetadata, EncryptAndMoveToVaultParams> {
  final VaultRepository _repository;
  const EncryptAndMoveToVault(this._repository);

  @override
  Future<Either<Failure, EncryptedFileMetadata>> call(
      EncryptAndMoveToVaultParams params) =>
      _repository.encryptAndMoveToVault(
        sourceFilePath: params.sourceFilePath,
        userPin: params.userPin,
      );
}

final class EncryptAndMoveToVaultParams {
  final String sourceFilePath;
  final String userPin;
  const EncryptAndMoveToVaultParams({
    required this.sourceFilePath,
    required this.userPin,
  });
}

// ─────────────────────────────────────────────────────────────────────────

/// Streams encryption progress for a file being moved to vault.
///
/// Emit values are 0.0 – 1.0 representing completion percentage.
/// Use this to drive a LinearProgressIndicator in the UI.
final class WatchEncryptionProgress
    implements StreamUseCase<double, WatchEncryptionProgressParams> {
  final VaultRepository _repository;
  const WatchEncryptionProgress(this._repository);

  @override
  Stream<Either<Failure, double>> call(
      WatchEncryptionProgressParams params) =>
      _repository.encryptionProgress(params.sourceFilePath);
}

final class WatchEncryptionProgressParams {
  final String sourceFilePath;
  const WatchEncryptionProgressParams({required this.sourceFilePath});
}

// ═══════════════════════════════════════════════════════════════════════════
// DECRYPT & RESTORE FROM VAULT
// ═══════════════════════════════════════════════════════════════════════════

/// Decrypts a vault file and restores it to its original storage location.
///
/// The encrypted `.enc` file is deleted after successful decryption.
final class DecryptAndRestoreFromVault
    implements UseCase<String, DecryptAndRestoreFromVaultParams> {
  final VaultRepository _repository;
  const DecryptAndRestoreFromVault(this._repository);

  @override
  Future<Either<Failure, String>> call(
      DecryptAndRestoreFromVaultParams params) =>
      _repository.decryptAndRestoreFromVault(
        metadata: params.metadata,
        userPin: params.userPin,
      );
}

final class DecryptAndRestoreFromVaultParams {
  final EncryptedFileMetadata metadata;
  final String userPin;
  const DecryptAndRestoreFromVaultParams({
    required this.metadata,
    required this.userPin,
  });
}

// ─────────────────────────────────────────────────────────────────────────

/// Streams decryption progress for a file being restored from vault.
final class WatchDecryptionProgress
    implements StreamUseCase<double, WatchDecryptionProgressParams> {
  final VaultRepository _repository;
  const WatchDecryptionProgress(this._repository);

  @override
  Stream<Either<Failure, double>> call(
      WatchDecryptionProgressParams params) =>
      _repository.decryptionProgress(params.encFileName);
}

final class WatchDecryptionProgressParams {
  final String encFileName;
  const WatchDecryptionProgressParams({required this.encFileName});
}

// ═══════════════════════════════════════════════════════════════════════════
// VAULT CONTENTS
// ═══════════════════════════════════════════════════════════════════════════

/// Returns all files currently in the vault (newest first).
final class GetVaultItems
    implements UseCase<List<EncryptedFileMetadata>, NoParams> {
  final VaultRepository _repository;
  const GetVaultItems(this._repository);

  @override
  Future<Either<Failure, List<EncryptedFileMetadata>>> call(
      NoParams params) =>
      _repository.getVaultItems();
}

// ─────────────────────────────────────────────────────────────────────────

/// Returns vault stats (item count + total encrypted size in bytes).
///
/// Combines two repository calls for use in the Settings screen.
final class GetVaultStats implements UseCase<VaultStats, NoParams> {
  final VaultRepository _repository;
  const GetVaultStats(this._repository);

  @override
  Future<Either<Failure, VaultStats>> call(NoParams params) async {
    final countResult = await _repository.getVaultItemCount();
    final sizeResult = await _repository.getVaultTotalSize();

    return countResult.fold(
      Left.new,
      (count) => sizeResult.fold(
        Left.new,
        (size) => Right(VaultStats(itemCount: count, totalBytes: size)),
      ),
    );
  }
}

/// Value object for vault statistics.
final class VaultStats {
  final int itemCount;
  final int totalBytes;
  const VaultStats({required this.itemCount, required this.totalBytes});

  String get formattedSize {
    const mb = 1024 * 1024;
    const gb = mb * 1024;
    if (totalBytes >= gb) return '${(totalBytes / gb).toStringAsFixed(1)} GB';
    return '${(totalBytes / mb).toStringAsFixed(0)} MB';
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// VAULT MANAGEMENT
// ═══════════════════════════════════════════════════════════════════════════

/// Permanently and irreversibly deletes a file from the vault.
///
/// Removes both the `.enc` file from disk and its Hive metadata entry.
/// The UI must show a confirmation dialog before calling this.
final class PermanentlyDeleteFromVault
    implements UseCase<void, PermanentlyDeleteFromVaultParams> {
  final VaultRepository _repository;
  const PermanentlyDeleteFromVault(this._repository);

  @override
  Future<Either<Failure, void>> call(
      PermanentlyDeleteFromVaultParams params) =>
      _repository.permanentlyDeleteFromVault(params.metadataId);
}

final class PermanentlyDeleteFromVaultParams {
  final String metadataId;
  const PermanentlyDeleteFromVaultParams({required this.metadataId});
}

// ─────────────────────────────────────────────────────────────────────────

/// Changes the vault PIN and re-wraps all file keys with the new PIN.
///
/// This can be slow for vaults with many files.
/// Consider running on an isolate and showing a progress indicator.
final class ChangeVaultPIN implements UseCase<void, ChangeVaultPINParams> {
  final VaultRepository _repository;
  const ChangeVaultPIN(this._repository);

  @override
  Future<Either<Failure, void>> call(ChangeVaultPINParams params) {
    // Guard: ensure new PIN meets minimum length
    if (params.newPin.length < 4) {
      return Future.value(
        const Left(
          EncryptionFailure('PIN must be at least 4 digits.'),
        ),
      );
    }
    return _repository.changePIN(
      currentPin: params.currentPin,
      newPin: params.newPin,
    );
  }
}

final class ChangeVaultPINParams {
  final String currentPin;
  final String newPin;
  const ChangeVaultPINParams({
    required this.currentPin,
    required this.newPin,
  });
}
