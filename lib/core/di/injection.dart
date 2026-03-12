import '../network/dio_client.dart';
import '../network/interceptors/auth_interceptor.dart';
import '../constants/api_constants.dart';

/// Registre de dépendances simple (pas de get_it pour rester léger).
///
/// Utilisation dans main.dart :
/// ```dart
/// await Injection.init();
/// runApp(MyApp());
/// ```
///
/// Utilisation dans le code :
/// ```dart
/// final dioClient = Injection.instance.dioClient;
/// ```
class Injection {
  Injection._();
  static Injection? _instance;

  static Injection get instance {
    assert(
      _instance != null,
      'Injection non initialisée. Appelez Injection.init() avant runApp().',
    );
    return _instance!;
  }

  // ── Singletons ───────────────────────────────────────────────────────────

  late final DioClient _dioClient;

  DioClient get dioClient => _dioClient;

  // ── Initialisation ───────────────────────────────────────────────────────

  /// Initialise toutes les dépendances.
  ///
  /// [getAccessToken] : fonction qui retourne le token courant (nullable).
  /// [getRefreshToken] : fonction qui retourne le refresh token (nullable).
  /// [onRefresh] : callback appelé pour obtenir un nouveau token.
  static Future<void> init({
    Future<String?> Function()? getAccessToken,
    Future<String?> Function()? getRefreshToken,
    Future<String?> Function(String refreshToken)? onRefresh,
    String? baseUrl,
  }) async {
    if (_instance != null) return; // déjà initialisé

    final injection = Injection._();

    // 1. Auth interceptor
    final authInterceptor = AuthInterceptor(
      getAccessToken: getAccessToken,
      getRefreshToken: getRefreshToken,
      onRefresh: onRefresh,
    );

    // 2. Dio client
    injection._dioClient = DioClient(
      baseUrl: baseUrl ?? ApiConstants.baseUrl,
      authInterceptor: authInterceptor,
    );

    _instance = injection;
  }

  /// Réinitialise le singleton (utile pour les tests).
  static void reset() => _instance = null;
}
