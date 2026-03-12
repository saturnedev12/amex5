import '../error/failures.dart';
import '../utils/either.dart';

/// Alias de type — toutes les couches utilisent [Result<T>]
/// plutôt que [Either<Failure, T>] pour plus de lisibilité.
typedef Result<T> = Either<Failure, T>;

/// Constructeurs de commodité.
Result<T> success<T>(T value) => Right(value);
Result<T> failure<T>(Failure f) => Left(f);
