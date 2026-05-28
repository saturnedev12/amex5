import 'package:amex5/core/network/interceptors/token_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
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
  String _baseUrl = _defaultBaseUrl();

  String get baseUrl => _baseUrl;

  static Future<AppConfig> init({
    Future<String?> Function()? getAccessToken,
    Future<String?> Function()? getRefreshToken,
    Future<String?> Function(String)? onRefresh,
  }) async {
    if (_instance != null) return _instance!;

    final config = AppConfig._();
    config._prefs = await SharedPreferences.getInstance();

    // BASE_URL du .env reste la source de vérité au démarrage.
    // Si absent, on garde l'URL modifiée depuis l'écran paramètres.
    config._baseUrl =
        _envBaseUrl() ??
        config._prefs.getString(_baseUrlKey) ??
        _defaultBaseUrl();

    // Mise à jour de Dio via GetIt
    getIt<Dio>().options.baseUrl = config._baseUrl;
    config._configureTokenProvider(
      getAccessToken: getAccessToken,
      getRefreshToken: getRefreshToken,
      onRefresh: onRefresh,
    );

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

    _configureTokenProvider(
      getAccessToken: getAccessToken,
      getRefreshToken: getRefreshToken,
      onRefresh: onRefresh,
    );

    notifyListeners();
  }

  void _configureTokenProvider({
    Future<String?> Function()? getAccessToken,
    Future<String?> Function()? getRefreshToken,
    Future<String?> Function(String)? onRefresh,
  }) {
    if (getAccessToken == null &&
        getRefreshToken == null &&
        onRefresh == null) {
      return;
    }

    final tokenProvider = getIt<TokenProvider>();
    if (getAccessToken != null) tokenProvider.getAccessToken = getAccessToken;
    if (getRefreshToken != null) {
      tokenProvider.getRefreshToken = getRefreshToken;
    }
    if (onRefresh != null) tokenProvider.onRefresh = onRefresh;
  }

  static void reset() => _instance = null;

  static String _defaultBaseUrl() => ApiConstants.baseUrl;

  static String? _envBaseUrl() {
    final value = dotenv.isInitialized ? dotenv.env['BASE_URL']?.trim() : null;
    if (value == null || value.isEmpty) return null;
    return value.replaceAll(RegExp(r'/$'), '');
  }
}
