import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import '../network/dio_client.dart';
import '../network/interceptors/auth_interceptor.dart';

/// Gestion de la configuration runtime de l'application.
///
/// Permet de modifier le baseUrl à chaud sans redémarrer l'app.
/// La valeur est persistée dans SharedPreferences.
class AppConfig extends ChangeNotifier {
  static const String _baseUrlKey = 'app_config_base_url';

  AppConfig._();
  static AppConfig? _instance;

  static AppConfig get instance {
    assert(
      _instance != null,
      'AppConfig non initialisé. Appelez AppConfig.init().',
    );
    return _instance!;
  }

  late SharedPreferences _prefs;
  late DioClient _dioClient;
  String _baseUrl = ApiConstants.baseUrl;

  DioClient get dioClient => _dioClient;
  String get baseUrl => _baseUrl;

  static Future<AppConfig> init({
    Future<String?> Function()? getAccessToken,
    Future<String?> Function()? getRefreshToken,
    Future<String?> Function(String)? onRefresh,
  }) async {
    if (_instance != null) return _instance!;

    final config = AppConfig._();
    config._prefs = await SharedPreferences.getInstance();

    // Chargement de l'URL persistée
    config._baseUrl =
        config._prefs.getString(_baseUrlKey) ?? ApiConstants.baseUrl;

    // Création initiale du DioClient
    config._dioClient = config._buildClient(
      getAccessToken: getAccessToken,
      getRefreshToken: getRefreshToken,
      onRefresh: onRefresh,
    );

    _instance = config;
    return config;
  }

  /// Met à jour le baseUrl, recrée le DioClient et notifie les listeners.
  Future<void> setBaseUrl(
    String url, {
    Future<String?> Function()? getAccessToken,
    Future<String?> Function()? getRefreshToken,
    Future<String?> Function(String)? onRefresh,
  }) async {
    final trimmed = url.trim().replaceAll(
      RegExp(r'/$'),
      '',
    ); // retire le /  final
    if (trimmed == _baseUrl) return;

    _baseUrl = trimmed;
    await _prefs.setString(_baseUrlKey, _baseUrl);

    _dioClient = _buildClient(
      getAccessToken: getAccessToken,
      getRefreshToken: getRefreshToken,
      onRefresh: onRefresh,
    );

    notifyListeners();
  }

  DioClient _buildClient({
    Future<String?> Function()? getAccessToken,
    Future<String?> Function()? getRefreshToken,
    Future<String?> Function(String)? onRefresh,
  }) => DioClient(
    baseUrl: _baseUrl,
    authInterceptor: AuthInterceptor(
      getAccessToken: getAccessToken,
      getRefreshToken: getRefreshToken,
      onRefresh: onRefresh,
    ),
  );

  static void reset() => _instance = null;
}
