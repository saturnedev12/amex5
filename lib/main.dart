import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/di/injection.dart';
import 'core/network/interceptors/auth_interceptor.dart';
import 'core/network/dialogs/token_expired_dialog.dart';
import 'package:flutter_easyloading_plus/flutter_easyloading_plus.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  await configureDependencies();
  
  // Wire token expiry → show re-login dialog
  AuthInterceptor.onTokenExpired = (context) async {
    await showTokenExpiredDialog(context);
  };

  await AppConfig.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Amex5',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: appRouter,
      builder: EasyLoading.init(),
    );
  }
}
