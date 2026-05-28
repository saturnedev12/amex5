import 'package:dio/dio.dart';
import '../error/exceptions.dart';
import '../error/failures.dart';
import '../utils/result.dart';

/// Mixin utilitaire pour les repositories.
///
/// Encapsule le try/catch dans une méthode [safeCall] qui convertit
/// automatiquement les [AppException] et [DioException] en [Failure].
mixin SafeCallMixin {
  /// Exécute [call] et retourne un [Result<T>].
  /// Intercepte [AppException], [DioException] et tout autre [Exception].
  Future<Result<T>> safeCall<T>(Future<T> Function() call) async {
    try {
      final data = await call();
      return success(data);
    } on AppException catch (e) {
      return failure(Failure.fromException(e));
    } on DioException catch (e) {
      return failure(Failure.fromException(exceptionFromDio(e)));
    } catch (e) {
      return failure(UnknownFailure(e.toString()));
    }
  }
}

AppException exceptionFromDio(DioException error) {
  if (error.error is AppException) return error.error as AppException;

  return switch (error.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout => const TimeoutException(),
    DioExceptionType.connectionError => const NetworkException(),
    DioExceptionType.cancel => const RequestCancelledException(),
    _ => UnknownException(error.message ?? 'Erreur réseau inconnue'),
  };
}
