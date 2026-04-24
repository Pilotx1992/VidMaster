import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:bcrypt/bcrypt.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/auth_state.dart';

/// Keys used in [FlutterSecureStorage] for vault auth data.
abstract final class _Keys {
  static const pinHash = 'vault_pin_hash';
  static const failedAttempts = 'vault_failed_attempts';
  static const lockoutUntil = 'vault_lockout_until';
}

/// Local data source for vault PIN authentication.
///
/// Uses [FlutterSecureStorage] (backed by Android Keystore / iOS Keychain)
/// to persist the bcrypt-hashed PIN, failed-attempt count, and lockout
/// timestamp. No plaintext PIN is ever stored.
///
/// Throws [CacheException] on any storage failure.
class AuthLocalDataSource {
  final FlutterSecureStorage _storage;

  /// Bcrypt cost factor. 12 provides ~250 ms on modern devices —
  /// strong enough without noticeable UI lag.
  static const int _bcryptCost = 12;

  AuthLocalDataSource({required FlutterSecureStorage storage})
      : _storage = storage;

  // ─── PIN Management ──────────────────────────────────────────────────

  /// Hashes [pin] with bcrypt and persists the hash.
  Future<void> saveHashedPin(String pin) async {
    try {
      final hash = BCrypt.hashpw(pin, BCrypt.gensalt(logRounds: _bcryptCost));
      await _storage.write(key: _Keys.pinHash, value: hash);
    } catch (e) {
      throw CacheException(message: 'Failed to save PIN hash: $e');
    }
  }

  /// Returns the stored bcrypt hash, or `null` if no PIN is set.
  Future<String?> getHashedPin() async {
    try {
      return await _storage.read(key: _Keys.pinHash);
    } catch (e) {
      throw CacheException(message: 'Failed to read PIN hash: $e');
    }
  }

  /// Verifies [inputPin] against the stored bcrypt hash.
  ///
  /// Returns `true` if the PIN matches; `false` otherwise.
  /// Throws [CacheException] if no PIN hash is stored.
  Future<bool> verifyPin(String inputPin) async {
    final storedHash = await getHashedPin();
    if (storedHash == null) {
      throw const CacheException(message: 'No PIN hash found. Setup PIN first.');
    }
    try {
      return BCrypt.checkpw(inputPin, storedHash);
    } catch (e) {
      throw CacheException(message: 'PIN verification error: $e');
    }
  }

  /// Deletes the stored PIN hash (used during PIN change flow).
  Future<void> deletePin() async {
    try {
      await _storage.delete(key: _Keys.pinHash);
    } catch (e) {
      throw CacheException(message: 'Failed to delete PIN hash: $e');
    }
  }

  // ─── Failed Attempts ─────────────────────────────────────────────────

  /// Returns the current number of consecutive failed PIN attempts.
  Future<int> getFailedAttempts() async {
    try {
      final raw = await _storage.read(key: _Keys.failedAttempts);
      return int.tryParse(raw ?? '') ?? 0;
    } catch (e) {
      throw CacheException(message: 'Failed to read attempt count: $e');
    }
  }

  /// Increments the failed-attempt counter by one.
  ///
  /// If the counter reaches [AuthState.maxFailedAttempts], a lockout
  /// timestamp is also written.
  Future<int> incrementFailedAttempts() async {
    try {
      final current = await getFailedAttempts();
      final next = current + 1;
      await _storage.write(key: _Keys.failedAttempts, value: next.toString());

      // Trigger lockout when max attempts are reached.
      if (next >= AuthState.maxFailedAttempts) {
        final lockUntil = DateTime.now().add(AuthState.lockoutDuration);
        await _storage.write(
          key: _Keys.lockoutUntil,
          value: lockUntil.toIso8601String(),
        );
      }

      return next;
    } catch (e) {
      throw CacheException(message: 'Failed to increment attempts: $e');
    }
  }

  /// Resets the failed-attempt counter and clears any lockout.
  Future<void> resetFailedAttempts() async {
    try {
      await _storage.delete(key: _Keys.failedAttempts);
      await _storage.delete(key: _Keys.lockoutUntil);
    } catch (e) {
      throw CacheException(message: 'Failed to reset attempts: $e');
    }
  }

  // ─── Lockout ─────────────────────────────────────────────────────────

  /// Returns the lockout expiry time, or `null` if not locked.
  Future<DateTime?> getLockoutUntil() async {
    try {
      final raw = await _storage.read(key: _Keys.lockoutUntil);
      if (raw == null) return null;
      return DateTime.tryParse(raw);
    } catch (e) {
      throw CacheException(message: 'Failed to read lockout time: $e');
    }
  }

  /// Returns `true` if the vault is currently locked out.
  Future<bool> isLockedOut() async {
    final lockUntil = await getLockoutUntil();
    if (lockUntil == null) return false;
    return DateTime.now().isBefore(lockUntil);
  }

  // ─── Auth State Snapshot ─────────────────────────────────────────────

  /// Builds a full [AuthState] snapshot from persisted data.
  Future<AuthState> getAuthState() async {
    final hasPin = (await getHashedPin()) != null;
    final failedAttempts = await getFailedAttempts();
    final lockoutUntil = await getLockoutUntil();
    final locked = lockoutUntil != null && DateTime.now().isBefore(lockoutUntil);

    return AuthState(
      status: locked
          ? AuthStatus.locked
          : AuthStatus.unauthenticated,
      isPinSet: hasPin,
      failedAttempts: failedAttempts,
      lockoutUntil: lockoutUntil,
    );
  }
}
