import 'package:injectable/injectable.dart';

import '../../router/app_router.dart';
import '../api_response_parser.dart';
import '../dialogs/token_expired_dialog.dart';

@singleton
class TokenProvider {
  Future<String?> Function()? getAccessToken;
  Future<String?> Function()? getRefreshToken;
  Future<String?> Function(String)? onRefresh;

  bool _isShowingExpiredDialog = false;

  bool isExpiredTokenResponse(dynamic data) =>
      ApiResponseParser.isExpiredTokenBody(data);

  Future<String?> accessToken() async => getAccessToken?.call();

  Future<void> showExpiredTokenDialog() async {
    if (_isShowingExpiredDialog) return;

    final context = appNavigatorKey.currentContext;
    if (context == null || !context.mounted) return;

    _isShowingExpiredDialog = true;
    try {
      await showTokenExpiredDialog(context);
    } finally {
      _isShowingExpiredDialog = false;
    }
  }
}
