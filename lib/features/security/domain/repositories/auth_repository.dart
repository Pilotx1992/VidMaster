import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/auth_state.dart';

/// Contract for vault PIN authentication operations.
///
/// Implementation uses [FlutterSecureStorage] for PIN hash persistence
/// and bcrypt for secure hashing. No biometric logic here — biometrics
/// are handled at the [VaultRepository] level via `local_auth`.
abstract interface class AuthRepository {
  /// Sets up a new vault PIN.
  ///
  /// The PIN is bcrypt-hashed before storage. Returns [EncryptionFailure]
  /// if the PIN is too short (< 4 digits).
  Future<Either<Failure, void>> setupPin(String pin);

  /// Verifies the user's PIN against the stored bcrypt hash.
  ///
  /// On success: resets failed-attempt counter, returns `true`.
  /// On failure: increments counter, may trigger lockout.
  /// Returns [AuthenticationFailure] if PIN doesn't match.
  /// Returns [VaultLockedFailure] if too many failed attempts.
  Future<Either<Failure, bool>> verifyPin(String inputPin);

  /// Returns `true` if a vault PIN has been set up.
  Future<Either<Failure, bool>> isPinSet();

  /// Changes the vault PIN.
  ///
  /// Verifies [currentPin] first, then hashes and stores [newPin].
  Future<Either<Failure, void>> changePin({
    required String currentPin,
    required String newPin,
  });

  /// Returns the current authentication state snapshot.
  Future<Either<Failure, AuthState>> getAuthState();

  /// Resets the failed-attempt counter and clears any active lockout.
  Future<Either<Failure, void>> resetFailedAttempts();
}
