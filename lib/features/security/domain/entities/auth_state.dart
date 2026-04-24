/// Authentication status for the vault.
enum AuthStatus {
  /// User has not authenticated yet in this session.
  unauthenticated,

  /// User has successfully authenticated; vault is accessible.
  authenticated,

  /// Too many failed attempts; vault is temporarily locked.
  locked,
}

/// Represents the current authentication state of the vault.
///
/// This is a read-only snapshot — not persisted directly. It is
/// reconstructed from the data stored in [FlutterSecureStorage] by
/// the [AuthLocalDataSource].
final class AuthState {
  /// Current authentication status.
  final AuthStatus status;

  /// Whether a PIN has been set up for the vault.
  final bool isPinSet;

  /// Number of consecutive failed PIN attempts (0 = none).
  final int failedAttempts;

  /// If [status] is [AuthStatus.locked], the time when the lockout expires.
  /// Null when not locked.
  final DateTime? lockoutUntil;

  const AuthState({
    required this.status,
    required this.isPinSet,
    this.failedAttempts = 0,
    this.lockoutUntil,
  });

  /// Convenience: initial state before any interaction.
  static const initial = AuthState(
    status: AuthStatus.unauthenticated,
    isPinSet: false,
  );

  /// Maximum allowed failed attempts before lockout.
  static const maxFailedAttempts = 5;

  /// Duration of the lockout after max failed attempts.
  static const lockoutDuration = Duration(minutes: 15);

  /// Whether the vault is currently accessible.
  bool get isUnlocked => status == AuthStatus.authenticated;

  /// Whether the vault is currently locked out due to failed attempts.
  bool get isLockedOut =>
      status == AuthStatus.locked &&
      lockoutUntil != null &&
      DateTime.now().isBefore(lockoutUntil!);

  /// Remaining attempts before lockout (never negative).
  int get remainingAttempts =>
      (maxFailedAttempts - failedAttempts).clamp(0, maxFailedAttempts);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          isPinSet == other.isPinSet &&
          failedAttempts == other.failedAttempts &&
          lockoutUntil == other.lockoutUntil;

  @override
  int get hashCode => Object.hash(status, isPinSet, failedAttempts, lockoutUntil);

  @override
  String toString() =>
      'AuthState(status: $status, isPinSet: $isPinSet, failed: $failedAttempts)';
}
