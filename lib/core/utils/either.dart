/// Implémentation légère du type Either<Left, Right>
/// sans dépendance externe (pas de `dartz`).
///
/// Convention :  Left  = erreur (Failure)
///               Right = succès (data)
sealed class Either<L, R> {
  const Either();

  bool get isLeft => this is Left<L, R>;
  bool get isRight => this is Right<L, R>;

  L get left => (this as Left<L, R>).value;
  R get right => (this as Right<L, R>).value;

  /// Transforme la valeur de droite.
  Either<L, T> map<T>(T Function(R value) transform) {
    return switch (this) {
      Left<L, R>(value: final l) => Left(l),
      Right<L, R>(value: final r) => Right(transform(r)),
    };
  }

  /// Transforme la valeur de gauche.
  Either<T, R> mapLeft<T>(T Function(L value) transform) {
    return switch (this) {
      Left<L, R>(value: final l) => Left(transform(l)),
      Right<L, R>(value: final r) => Right(r),
    };
  }

  /// Chaîne une opération qui peut elle-même échouer.
  Either<L, T> flatMap<T>(Either<L, T> Function(R value) transform) {
    return switch (this) {
      Left<L, R>(value: final l) => Left(l),
      Right<L, R>(value: final r) => transform(r),
    };
  }

  /// Pattern matching sur les deux branches.
  T fold<T>(T Function(L left) onLeft, T Function(R right) onRight) {
    return switch (this) {
      Left<L, R>(value: final l) => onLeft(l),
      Right<L, R>(value: final r) => onRight(r),
    };
  }

  /// Exécute [action] uniquement si c'est un succès.
  void ifRight(void Function(R value) action) {
    if (this is Right<L, R>) action((this as Right<L, R>).value);
  }

  /// Exécute [action] uniquement si c'est une erreur.
  void ifLeft(void Function(L value) action) {
    if (this is Left<L, R>) action((this as Left<L, R>).value);
  }

  @override
  String toString() => switch (this) {
    Left<L, R>(value: final l) => 'Left($l)',
    Right<L, R>(value: final r) => 'Right($r)',
  };
}

/// Représente une erreur / la branche gauche.
final class Left<L, R> extends Either<L, R> {
  final L value;
  const Left(this.value);
}

/// Représente un succès / la branche droite.
final class Right<L, R> extends Either<L, R> {
  final R value;
  const Right(this.value);
}
