import 'package:injectable/injectable.dart';

@singleton
class TokenProvider {
  Future<String?> Function()? getAccessToken;
  Future<String?> Function()? getRefreshToken;
  Future<String?> Function(String)? onRefresh;
}
