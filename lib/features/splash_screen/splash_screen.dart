import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:amex5/features/authentification/data/models/user_isar_model.dart';
import 'package:amex5/core/di/injection.dart';
import 'package:amex5/core/database/isar_config.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      // 1. AppConfig and getIt dependencies are already initialized in main.dart
      
      // 2. Vérifier s'il y a un utilisateur connecté dans Isar
      final userCount = await getIt<IsarConfig>().instance.userIsarModels.count();
      
      // Simulation d'un délai pour montrer le splash
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      if (userCount > 0) {
        // Redirection vers Accueil (si utilisateur connecté)
        context.go('/home');
      } else {
        // Redirection vers Connexion
        context.go('/login');
      }
    } catch (e) {
      debugPrint("Erreur Initialization: $e");
      if (mounted) context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0F1117), // AppColors.background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bolt, size: 80, color: Color(0xFF2D7DD2)), // AppColors.primary
            SizedBox(height: 24),
            Text(
              'AMEX5',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 4,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Industrial Control Suite',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                letterSpacing: 2,
              ),
            ),
            SizedBox(height: 48),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2D7DD2)),
            ),
            SizedBox(height: 16),
            Text(
              'Chargement...',
              style: TextStyle(color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }
}
