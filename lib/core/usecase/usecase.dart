import 'package:dartz/dartz.dart';
import '../error/failures.dart';

/// Base interface for a synchronous-style async use case.
///
/// [T]      — the success return type
/// [Params] — the input parameters object (use [NoParams] if none needed)
///
/// Example:
/// ```dart
/// class GetAllVideos implements UseCase<List<VideoEntity>, NoParams> {
///   @override
///   Future<Either<Failure, List<VideoEntity>>> call(NoParams params) { ... }
/// }
/// ```
abstract interface class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

/// Base interface for a use case that returns a continuous stream of events.
///
/// Use this for playback state updates, download progress, etc.
///
/// [T]      — the event type emitted on the stream
/// [Params] — the input parameters object
abstract interface class StreamUseCase<T, Params> {
  Stream<Either<Failure, T>> call(Params params);
}

/// Sentinel params type for use cases that require no input.
///
/// Usage: `useCase(NoParams())`
final class NoParams {
  const NoParams();
}
