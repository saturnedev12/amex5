
import 'package:go_router/go_router.dart';
import 'package:amex5/app/app_shell.dart';
import 'package:amex5/features/authentification/presentation/login_page.dart';
import 'package:amex5/features/splash_screen/splash_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const AppShell(),
    ),
  ],
);
