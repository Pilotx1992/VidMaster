import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../di.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/security_entities.dart';
import '../../domain/usecases/security_usecases.dart';

// ── State ──────────────────────────────────────────────────────────────────

enum AuthScreenStatus { checking, locked, authenticated, settingUp }

class AppAuthState {
  final AuthScreenStatus screenStatus;
  final AuthState? authState;
  final bool isPinSet;
  final bool isBiometricAvailable;
  final String? errorMessage;
  final bool isLoading;

  const AppAuthState({
    this.screenStatus = AuthScreenStatus.checking,
    this.authState,
    this.isPinSet = false,
    this.isBiometricAvailable = false,
    this.errorMessage,
    this.isLoading = false,
  });

  AppAuthState copyWith({
    AuthScreenStatus? screenStatus,
    AuthState? authState,
    bool? isPinSet,
    bool? isBiometricAvailable,
    String? errorMessage,
    bool? isLoading,
    bool clearError = false,
  }) =>
      AppAuthState(
        screenStatus: screenStatus ?? this.screenStatus,
        authState: authState ?? this.authState,
        isPinSet: isPinSet ?? this.isPinSet,
        isBiometricAvailable: isBiometricAvailable ?? this.isBiometricAvailable,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
        isLoading: isLoading ?? this.isLoading,
      );
}

// ── Notifier ───────────────────────────────────────────────────────────────

class AppAuthNotifier extends StateNotifier<AppAuthState> {
  final IsPinSet _isPinSet;
  final SetupPin _setupPin;
  final ValidatePin _validatePin;
  final AuthenticateWithBiometric _biometric;
  final GetAuthState _getAuthState;

  AppAuthNotifier({
    required IsPinSet isPinSet,
    required SetupPin setupPin,
    required ValidatePin validatePin,
    required AuthenticateWithBiometric biometric,
    required GetAuthState getAuthState,
  })  : _isPinSet = isPinSet,
        _setupPin = setupPin,
        _validatePin = validatePin,
        _biometric = biometric,
        _getAuthState = getAuthState,
        super(const AppAuthState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    final results = await Future.wait([
      _isPinSet(const NoParams()),
      _getAuthState(const NoParams()),
    ]);

    final pinSet = results[0].getOrElse(() => false) as bool;
    final authState = results[1].getOrElse(() => const AuthState(
          status: AuthStatus.unauthenticated,
          isPinSet: false,
        )) as AuthState;

    if (!pinSet) {
      state = state.copyWith(
        screenStatus: AuthScreenStatus.settingUp,
        isPinSet: false,
        authState: authState,
      );
      return;
    }

    state = state.copyWith(
      screenStatus: authState.status == AuthStatus.authenticated
          ? AuthScreenStatus.authenticated
          : AuthScreenStatus.locked, // Always require auth on launch
      isPinSet: true,
      authState: authState,
    );
  }

  Future<void> setupPin(String pin) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _setupPin(SetupPinParams(pin));
    result.fold(
      (f) => state = state.copyWith(isLoading: false, errorMessage: f.message),
      (_) => state = state.copyWith(
        isLoading: false,
        isPinSet: true,
        screenStatus: AuthScreenStatus.locked,
      ),
    );
  }

  Future<void> authenticateWithPin(String pin) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _validatePin(ValidatePinParams(pin));
    result.fold(
      (f) => state = state.copyWith(isLoading: false, errorMessage: f.message),
      (_) => state = state.copyWith(
        isLoading: false,
        screenStatus: AuthScreenStatus.authenticated,
      ),
    );
  }

  Future<void> authenticateWithBiometric() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _biometric(const NoParams());
    result.fold(
      (f) => state = state.copyWith(isLoading: false, errorMessage: f.message),
      (success) {
        if (success) {
          state = state.copyWith(
            isLoading: false,
            screenStatus: AuthScreenStatus.authenticated,
          );
        } else {
          state = state.copyWith(
            isLoading: false,
            errorMessage: 'Biometric authentication failed.',
          );
        }
      },
    );
  }

  void lock() => state = state.copyWith(
        screenStatus: AuthScreenStatus.locked,
      );

  void clearError() => state = state.copyWith(clearError: true);
}

final appAuthProvider =
    StateNotifierProvider<AppAuthNotifier, AppAuthState>((ref) {
  return AppAuthNotifier(
    isPinSet: ref.watch(isPinSetProvider),
    setupPin: ref.watch(setupPinProvider),
    validatePin: ref.watch(validatePinProvider),
    biometric: ref.watch(authenticateWithBiometricProvider),
    getAuthState: ref.watch(getAuthStateProvider),
  );
});
