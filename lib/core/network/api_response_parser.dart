import 'dart:convert';

import 'package:dio/dio.dart';

import '../error/exceptions.dart';

class ApiResponseParser {
  const ApiResponseParser._();

  static const expiredTokenBody = 'EXPIRED_TOKEN';

  static bool isExpiredTokenBody(dynamic data) {
    if (data is String) return data.trim() == expiredTokenBody;
    if (data is Map) {
      return data.values.any((value) => isExpiredTokenBody(value));
    }
    return false;
  }

  static T parseModel<T>(
    Response<dynamic> response,
    T Function(Map<String, dynamic> json) fromJson, {
    required String operation,
  }) {
    final map = parseMap(response, operation: operation);
    try {
      return fromJson(map);
    } catch (error) {
      throw InvalidResponseException(
        '$operation: la réponse ne correspond pas au modèle attendu ($error).',
      );
    }
  }

  static Map<String, dynamic> parseMap(
    Response<dynamic> response, {
    required String operation,
    bool allowEmpty = false,
  }) {
    ensureSuccess(response, operation: operation);

    final data = _decodeData(response.data, operation);
    if (data == null && allowEmpty) return <String, dynamic>{};
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);

    throw InvalidResponseException(
      '$operation: format de réponse inattendu, objet JSON attendu.',
    );
  }

  static Response<dynamic> ensureSuccess(
    Response<dynamic> response, {
    required String operation,
  }) {
    final statusCode = response.statusCode;
    final data = response.data;

    if (isExpiredTokenBody(data)) throw const TokenExpiredException();

    if (statusCode == null) {
      throw UnknownException('$operation: statut HTTP absent.');
    }

    if (statusCode >= 200 && statusCode < 300) return response;

    final message = _extractMessage(response);
    switch (statusCode) {
      case 400:
        throw BadRequestException(message);
      case 401:
        throw const UnauthorizedException();
      case 403:
        throw const ForbiddenException();
      case 404:
        throw NotFoundException(message);
      case 409:
        throw ConflictException(message);
      case 422:
        throw ValidationException(message, data);
      case 429:
        throw const TooManyRequestsException();
      case >= 500:
        throw ServerException(message, statusCode);
      default:
        throw UnknownException(message);
    }
  }

  static dynamic _decodeData(dynamic data, String operation) {
    if (data == null) return null;
    if (data is! String) return data;

    final raw = data.trim();
    if (raw.isEmpty) return null;
    if (raw == expiredTokenBody) throw const TokenExpiredException();

    try {
      return jsonDecode(raw);
    } on FormatException catch (error) {
      throw InvalidResponseException(
        '$operation: JSON invalide dans la réponse (${error.message}).',
      );
    }
  }

  static String _extractMessage(Response<dynamic> response) {
    final data = response.data;
    if (data is String) {
      final raw = data.trim();
      if (raw.isEmpty) return 'Erreur ${response.statusCode ?? 'inconnue'}';
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map) return _messageFromMap(decoded);
      } catch (_) {
        return raw;
      }
      return raw;
    }

    if (data is Map) return _messageFromMap(data);
    return 'Erreur ${response.statusCode ?? 'inconnue'}';
  }

  static String _messageFromMap(Map<dynamic, dynamic> data) {
    return (data['message'] ?? data['error'] ?? 'Erreur serveur').toString();
  }
}
