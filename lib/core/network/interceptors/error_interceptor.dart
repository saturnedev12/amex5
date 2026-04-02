import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../error/exceptions.dart';

/// Intercepteur d'erreurs — transforme les [DioException] en [AppException]
/// exploitables dans les couches métier (domain / data).
@lazySingleton
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final exception = _mapDioException(err);
    // On attache l'exception à l'erreur pour la récupérer plus haut
    handler.next(err.copyWith(error: exception, message: exception.message));
  }

  AppException _mapDioException(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException();

      case DioExceptionType.connectionError:
        return const NetworkException();

      case DioExceptionType.badResponse:
        return _mapStatusCode(err.response);

      case DioExceptionType.cancel:
        return const RequestCancelledException();

      default:
        return UnknownException(
          err.message ?? 'Une erreur inconnue est survenue',
        );
    }
  }

  AppException _mapStatusCode(Response? response) {
    final statusCode = response?.statusCode ?? 0;
    final message = _extractMessage(response);

    switch (statusCode) {
      case 400:
        return BadRequestException(message);
      case 401:
        return const UnauthorizedException();
      case 403:
        return const ForbiddenException();
      case 404:
        return NotFoundException(message);
      case 409:
        return ConflictException(message);
      case 422:
        return ValidationException(message, response?.data);
      case 429:
        return const TooManyRequestsException();
      case >= 500:
        return ServerException(message, statusCode);
      default:
        return UnknownException(message);
    }
  }

  String _extractMessage(Response? response) {
    if (response?.data is Map) {
      final data = response!.data as Map;
      return (data['message'] ?? data['error'] ?? 'Erreur serveur').toString();
    }
    return 'Erreur ${response?.statusCode ?? 'inconnue'}';
  }
}
