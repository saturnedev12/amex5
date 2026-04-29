
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:amex5/app/app_shell.dart';
import 'package:amex5/features/authentification/presentation/login_page.dart';
import 'package:amex5/features/splash_screen/splash_screen.dart';

/// GlobalKey pour accéder au navigateur depuis n'importe où (ex: interceptors).
final appNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: appNavigatorKey,
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
