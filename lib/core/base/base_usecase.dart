import '../utils/result.dart';

/// UseCase sans paramètre.
///
/// Usage :
/// ```dart
/// class GetUsersUseCase extends UseCase<List<User>, NoParams> {
///   final UserRepository _repository;
///   GetUsersUseCase(this._repository);
///
///   @override
///   Future<Result<List<User>>> call(NoParams params) =>
///       _repository.getUsers();
/// }
/// ```
abstract class UseCase<Type, Params> {
  Future<Result<Type>> call(Params params);
}

/// UseCase synchrone (pour les opérations locales/cache).
abstract class SyncUseCase<Type, Params> {
  Result<Type> call(Params params);
}

/// Paramètre vide — à utiliser quand le use case n'a pas besoin de paramètre.
class NoParams {
  const NoParams();
}
