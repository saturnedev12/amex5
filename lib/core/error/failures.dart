import 'exceptions.dart';

/// Failures exposées par la couche **domain** aux BLoCs/ViewModels.
/// Elles ne dépendent pas de Dio, HttpClient ou quoi que ce soit d'externe.
sealed class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => '$runtimeType($message)';

  /// Convertit une [AppException] (couche data) en [Failure] (couche domain).
  factory Failure.fromException(AppException exception) {
    return switch (exception) {
      NetworkException() => NetworkFailure(exception.message),
      TimeoutException() => TimeoutFailure(exception.message),
      RequestCancelledException() => CancelledFailure(exception.message),
      UnauthorizedException() => UnauthorizedFailure(exception.message),
      ForbiddenException() => ForbiddenFailure(exception.message),
      NotFoundException() => NotFoundFailure(exception.message),
      BadRequestException() => BadRequestFailure(exception.message),
      ConflictException() => ConflictFailure(exception.message),
      ValidationException() => ValidationFailure(
        exception.message,
        exception.errors,
      ),
      TooManyRequestsException() => TooManyRequestsFailure(exception.message),
      ServerException() => ServerFailure(
        exception.message,
        exception.statusCode,
      ),
      ParseException() => ParseFailure(exception.message),
      CacheException() => CacheFailure(exception.message),
      UnknownException() => UnknownFailure(exception.message),
    };
  }
}

// ── Failures concrètes ────────────────────────────────────────────────────

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Pas de connexion réseau.']);
}

class TimeoutFailure extends Failure {
  const TimeoutFailure([super.message = 'La requête a expiré.']);
}

class CancelledFailure extends Failure {
  const CancelledFailure([super.message = 'Requête annulée.']);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Non autorisé.']);
}

class ForbiddenFailure extends Failure {
  const ForbiddenFailure([super.message = 'Accès interdit.']);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Ressource introuvable.']);
}

class BadRequestFailure extends Failure {
  const BadRequestFailure([super.message = 'Requête invalide.']);
}

class ConflictFailure extends Failure {
  const ConflictFailure([super.message = 'Conflit de données.']);
}

class ValidationFailure extends Failure {
  final dynamic errors;
  const ValidationFailure(super.message, [this.errors]);
}

class TooManyRequestsFailure extends Failure {
  const TooManyRequestsFailure([super.message = 'Trop de requêtes.']);
}

class ServerFailure extends Failure {
  final int statusCode;
  const ServerFailure(super.message, this.statusCode);
}

class ParseFailure extends Failure {
  const ParseFailure([super.message = 'Erreur de parsing.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Erreur de cache.']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Erreur inconnue.']);
}
