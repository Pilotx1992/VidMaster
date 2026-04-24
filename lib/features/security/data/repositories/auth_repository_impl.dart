import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/auth_state.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';

/// Production implementation of [AuthRepository].
///
/// Wraps [AuthLocalDataSource] with error boundaries that convert
/// [CacheException] to [CacheFailure] and enforce business rules
/// (PIN length, lockout logic).
class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource _dataSource;

  AuthRepositoryImpl({required AuthLocalDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Future<Either<Failure, void>> setupPin(String pin) async {
    if (pin.length < 4) {
      return const Left(
        EncryptionFailure('PIN must be at least 4 digits.'),
      );
    }
    try {
      await _dataSource.saveHashedPin(pin);
      await _dataSource.resetFailedAttempts();
      return const Right(null);
    } on CacheException catch (e, st) {
      return Left(CacheFailure('PIN setup failed: ${e.message}',
          stackTrace: st));
    }
  }

  @override
  Future<Either<Failure, bool>> verifyPin(String inputPin) async {
    try {
      // Check lockout first.
      if (await _dataSource.isLockedOut()) {
        final lockUntil = await _dataSource.getLockoutUntil();
        return Left(VaultLockedFailure(
          lockDuration: lockUntil!.difference(DateTime.now()),
        ));
      }

      final isValid = await _dataSource.verifyPin(inputPin);

      if (isValid) {
        // Success: clear failed attempts.
        await _dataSource.resetFailedAttempts();
        return const Right(true);
      } else {
        // Failure: increment counter, possibly trigger lockout.
        final attempts = await _dataSource.incrementFailedAttempts();
        final remaining = AuthState.maxFailedAttempts - attempts;

        if (remaining <= 0) {
          final lockUntil = await _dataSource.getLockoutUntil();
          return Left(VaultLockedFailure(
            lockDuration: lockUntil?.difference(DateTime.now()) ??
                AuthState.lockoutDuration,
          ));
        }

        return Left(AuthenticationFailure(attemptsRemaining: remaining));
      }
    } on CacheException catch (e, st) {
      return Left(CacheFailure('PIN verification failed: ${e.message}',
          stackTrace: st));
    }
  }

  @override
  Future<Either<Failure, bool>> isPinSet() async {
    try {
      final hash = await _dataSource.getHashedPin();
      return Right(hash != null);
    } on CacheException catch (e, st) {
      return Left(CacheFailure('Failed to check PIN status: ${e.message}',
          stackTrace: st));
    }
  }

  @override
  Future<Either<Failure, void>> changePin({
    required String currentPin,
    required String newPin,
  }) async {
    if (newPin.length < 4) {
      return const Left(
        EncryptionFailure('New PIN must be at least 4 digits.'),
      );
    }

    // Verify current PIN first.
    final verifyResult = await verifyPin(currentPin);
    return verifyResult.fold(
      Left.new,
      (_) async {
        try {
          await _dataSource.saveHashedPin(newPin);
          return const Right(null);
        } on CacheException catch (e, st) {
          return Left(CacheFailure('PIN change failed: ${e.message}',
              stackTrace: st));
        }
      },
    );
  }

  @override
  Future<Either<Failure, AuthState>> getAuthState() async {
    try {
      final state = await _dataSource.getAuthState();
      return Right(state);
    } on CacheException catch (e, st) {
      return Left(CacheFailure('Failed to read auth state: ${e.message}',
          stackTrace: st));
    }
  }

  @override
  Future<Either<Failure, void>> resetFailedAttempts() async {
    try {
      await _dataSource.resetFailedAttempts();
      return const Right(null);
    } on CacheException catch (e, st) {
      return Left(CacheFailure('Failed to reset attempts: ${e.message}',
          stackTrace: st));
    }
  }
}
