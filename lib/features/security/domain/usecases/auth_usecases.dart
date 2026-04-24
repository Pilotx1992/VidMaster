import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/auth_state.dart';
import '../repositories/auth_repository.dart';
import '../repositories/vault_repository.dart';

final class IsPinSet implements UseCase<bool, NoParams> {
  final AuthRepository _repository;
  const IsPinSet(this._repository);
  @override
  Future<Either<Failure, bool>> call(NoParams params) => _repository.isPinSet();
}

final class SetupPinParams {
  final String pin;
  const SetupPinParams(this.pin);
}

final class SetupPin implements UseCase<void, SetupPinParams> {
  final AuthRepository _repository;
  const SetupPin(this._repository);
  @override
  Future<Either<Failure, void>> call(SetupPinParams params) => _repository.setupPin(params.pin);
}

final class ValidatePinParams {
  final String pin;
  const ValidatePinParams(this.pin);
}

final class ValidatePin implements UseCase<bool, ValidatePinParams> {
  final AuthRepository _repository;
  const ValidatePin(this._repository);
  @override
  Future<Either<Failure, bool>> call(ValidatePinParams params) => _repository.verifyPin(params.pin);
}

final class AuthenticateWithBiometric implements UseCase<bool, NoParams> {
  final VaultRepository _repository;
  const AuthenticateWithBiometric(this._repository);
  @override
  Future<Either<Failure, bool>> call(NoParams params) => _repository.authenticateUser(null);
}

final class GetAuthState implements UseCase<AuthState, NoParams> {
  final AuthRepository _repository;
  const GetAuthState(this._repository);
  @override
  Future<Either<Failure, AuthState>> call(NoParams params) => _repository.getAuthState();
}
