import 'dart:convert';
import 'package:bcrypt/bcrypt.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages user session: token, login response JSON, navigation state.
@singleton
class SessionManager extends ChangeNotifier {
  static const String _tokenKey = 'session_token';
  static const String _loginResponseKey = 'session_login_response';
  static const String _deviceHeader = 'session_x_device';
  static const String _passwordKey = 'session_password';

  SharedPreferences? _prefs;

  String? _token;
  String? _passwordHash;
  Map<String, dynamic>? _loginResponse;
  String _xDevice = 'web-id';

  String? get token => _token;
  Map<String, dynamic>? get loginResponse => _loginResponse;
  String get xDevice => _xDevice;
  bool get isLoggedIn => _token != null && _token!.isNotEmpty;
  String? get passwordHash => _passwordHash;

  // ── User Information Getters ──
  bool get pwdToChange => _loginResponse?['pwdToChange'] as bool? ?? false;
  String? get userGroup => _loginResponse?['userGroup'] as String?;
  String? get profile => _loginResponse?['profile'] as String?;
  bool get globalAdmin => _loginResponse?['globalAdmin'] as bool? ?? false;
  String? get systemToken => _loginResponse?['systemToken'] as String?;
  List<dynamic>? get auths => _loginResponse?['auths'] as List<dynamic>?;
  Map<String, dynamic>? get appData =>
      _loginResponse?['appData'] as Map<String, dynamic>?;

  // ── userData shortcuts (premier élément de appData.userData) ──
  Map<String, dynamic>? get _userData {
    final list = appData?['dataUnitMap']?['userData'] as List<dynamic>?;
    if (list != null && list.isNotEmpty) {
      return list.first as Map<String, dynamic>?;
    }
    return null;
  }

  String? get name => _userData?['name'] as String?;
  String? get employeeCode => _userData?['employeeCode'] as String?;
  String? get userCode => _userData?['code'] as String?;

  /// Path to redirect to after re-login (when token expires).
  String? pendingRedirect;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _token = _prefs?.getString(_tokenKey);
    _xDevice = _prefs?.getString(_deviceHeader) ?? 'web-id';
    final raw = _prefs?.getString(_loginResponseKey);
    if (raw != null) {
      _loginResponse = json.decode(raw) as Map<String, dynamic>;
    }
    _passwordHash = _prefs?.getString(_passwordKey);
  }

  /// Save login response: persists token + full JSON.
  Future<void> saveLoginData({
    required String token,
    required Map<String, dynamic> loginResponseJson,
    required String password,
    String? xDevice,
  }) async {
    _token = token;
    // Deep-convert to plain Maps (nested model objects → raw JSON maps)
    final encoded = json.encode(loginResponseJson);
    _loginResponse = json.decode(encoded) as Map<String, dynamic>;
    if (xDevice != null) _xDevice = xDevice;

    await _prefs?.setString(_tokenKey, token);
    await _prefs?.setString(_loginResponseKey, encoded);
    final salt = dotenv.env['BCRYPT_SALT']!;
    _passwordHash = BCrypt.hashpw(password, salt);
    await _prefs?.setString(_passwordKey, _passwordHash!);
    if (xDevice != null) {
      await _prefs?.setString(_deviceHeader, xDevice);
    }
    notifyListeners();
  }

  /// Clear session on logout or forced expiry.
  Future<void> clear() async {
    _token = null;
    _loginResponse = null;
    await _prefs?.remove(_tokenKey);
    await _prefs?.remove(_loginResponseKey);
    await _prefs?.remove(_passwordKey);
    notifyListeners();
  }
}
