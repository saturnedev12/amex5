import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages user session: token, login response JSON, navigation state.
@singleton
class SessionManager extends ChangeNotifier {
  static const String _tokenKey = 'session_token';
  static const String _loginResponseKey = 'session_login_response';
  static const String _deviceHeader = 'session_x_device';

  SharedPreferences? _prefs;

  String? _token;
  Map<String, dynamic>? _loginResponse;
  String _xDevice = 'web-id';

  String? get token => _token;
  Map<String, dynamic>? get loginResponse => _loginResponse;
  String get xDevice => _xDevice;
  bool get isLoggedIn => _token != null && _token!.isNotEmpty;

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
  }

  /// Save login response: persists token + full JSON.
  Future<void> saveLoginData({
    required String token,
    required Map<String, dynamic> loginResponseJson,
    String? xDevice,
  }) async {
    _token = token;
    _loginResponse = loginResponseJson;
    if (xDevice != null) _xDevice = xDevice;

    await _prefs?.setString(_tokenKey, token);
    await _prefs?.setString(_loginResponseKey, json.encode(loginResponseJson));
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
    notifyListeners();
  }
}
