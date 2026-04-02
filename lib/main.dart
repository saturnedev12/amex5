import 'package:flutter/material.dart';


import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/di/injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await configureDependencies();

  await AppConfig.init(
    // TODO : branchez vos callbacks de token ici :
    // getAccessToken: () async => await SecureStorage.read('access_token'),
    // getRefreshToken: () async => await SecureStorage.read('refresh_token'),
    // onRefresh: (rt) async => await AuthService.refreshToken(rt),
  );

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
    );
  }
}
