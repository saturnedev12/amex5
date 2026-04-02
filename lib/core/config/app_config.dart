import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../network/interceptors/token_provider.dart';
import '../di/injection.dart';

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
  String _baseUrl = ApiConstants.baseUrl;

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

    // Mise à jour de Dio et TokenProvider via GetIt
    getIt<Dio>().options.baseUrl = config._baseUrl;
    final tokenProvider = getIt<TokenProvider>();
    tokenProvider.getAccessToken = getAccessToken;
    tokenProvider.getRefreshToken = getRefreshToken;
    tokenProvider.onRefresh = onRefresh;

    _instance = config;
    return config;
  }

  /// Met à jour le baseUrl, modifie Dio injecté et notifie les listeners.
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

    getIt<Dio>().options.baseUrl = _baseUrl;

    if (getAccessToken != null || getRefreshToken != null || onRefresh != null) {
      final tokenProvider = getIt<TokenProvider>();
      if (getAccessToken != null) tokenProvider.getAccessToken = getAccessToken;
      if (getRefreshToken != null) tokenProvider.getRefreshToken = getRefreshToken;
      if (onRefresh != null) tokenProvider.onRefresh = onRefresh;
    }

    notifyListeners();
  }

  static void reset() => _instance = null;
}
