/// Hiérarchie d'exceptions réseau/data.
/// Ces exceptions sont levées dans la couche **data** et
/// converties en [Failure] dans la couche **domain** via le repository.
sealed class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => '$runtimeType: $message';
}

// ── Réseau ────────────────────────────────────────────────────────────────

/// Pas de connexion réseau.
class NetworkException extends AppException {
  const NetworkException()
    : super('Impossible de se connecter au réseau. Vérifiez votre connexion.');
}

/// Délai d'attente dépassé.
class TimeoutException extends AppException {
  const TimeoutException() : super('La requête a expiré. Veuillez réessayer.');
}

/// Requête annulée par l'utilisateur.
class RequestCancelledException extends AppException {
  const RequestCancelledException() : super('Requête annulée.');
}

// ── HTTP ──────────────────────────────────────────────────────────────────

/// 400 Bad Request
class BadRequestException extends AppException {
  const BadRequestException([super.message = 'Requête invalide.']);
}

/// 401 Unauthorized
class UnauthorizedException extends AppException {
  const UnauthorizedException()
    : super('Non autorisé. Veuillez vous connecter.');
}

/// 403 Forbidden
class ForbiddenException extends AppException {
  const ForbiddenException()
    : super('Accès interdit. Vous n\'avez pas les droits nécessaires.');
}

/// 404 Not Found
class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Ressource introuvable.']);
}

/// 409 Conflict
class ConflictException extends AppException {
  const ConflictException([super.message = 'Conflit de données.']);
}

/// 422 Unprocessable Entity — validation côté serveur
class ValidationException extends AppException {
  final dynamic errors;
  const ValidationException(super.message, [this.errors]);
}

/// 429 Too Many Requests
class TooManyRequestsException extends AppException {
  const TooManyRequestsException()
    : super('Trop de requêtes. Veuillez patienter.');
}

/// 5xx Server Error
class ServerException extends AppException {
  final int statusCode;
  const ServerException(super.message, this.statusCode);
}

/// Erreur inconnue / catch-all
class UnknownException extends AppException {
  const UnknownException([
    super.message = 'Une erreur inattendue est survenue.',
  ]);
}

/// Erreur de parsing / désérialisation JSON
class ParseException extends AppException {
  const ParseException([
    super.message = 'Erreur lors du traitement des données.',
  ]);
}

/// Erreur de cache local
class CacheException extends AppException {
  const CacheException([super.message = 'Erreur de cache.']);
}
