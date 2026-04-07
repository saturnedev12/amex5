import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:amex5/core/di/injection.dart';
import 'package:amex5/core/session/session_manager.dart';
import 'package:amex5/core/theme/app_theme.dart';
import 'login_cubit.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<LoginCubit>(),
      child: const LoginView(),
    );
  }
}

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isWide = size.width > 800;

    return Scaffold(
      body: BlocListener<LoginCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            final session = getIt<SessionManager>();
            final redirect = session.pendingRedirect;
            session.pendingRedirect = null;
            context.go(redirect ?? '/home');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: Row(
          children: [
            // --- Left panel: branding ---
            if (isWide)
              Expanded(
                flex: 3,
                child: Container(
                  color: AppColors.surface,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 48),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.dashboard_rounded,
                              size: 42,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            'AMEX5',
                            style: AppTextStyles.displayLarge.copyWith(
                              fontSize: 36,
                              letterSpacing: 6,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Tableau de bord opérationnel',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontSize: 15,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 48),
                          // Status indicators
                          _StatusRow(
                            icon: Icons.cloud_done_outlined,
                            label: 'Serveur connecté',
                            color: AppColors.success,
                          ),
                          const SizedBox(height: 12),
                          _StatusRow(
                            icon: Icons.bluetooth_connected,
                            label: 'BLE disponible',
                            color: AppColors.info,
                          ),
                          const SizedBox(height: 12),
                          _StatusRow(
                            icon: Icons.storage_outlined,
                            label: 'Base locale synchronisée',
                            color: AppColors.accent,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // --- Right panel: login form ---
            Expanded(
              flex: 2,
              child: Container(
                color: AppColors.background,
                child: Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: isWide ? 48 : 32,
                      vertical: 32,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: BlocBuilder<LoginCubit, AuthState>(
                        builder: (context, state) {
                          final isLoading = state is AuthLoading;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!isWide) ...[
                                Center(
                                  child: Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.15,
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: const Icon(
                                      Icons.dashboard_rounded,
                                      size: 30,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ],
                              Text(
                                'Connexion',
                                style: AppTextStyles.displayLarge.copyWith(
                                  fontSize: 24,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Identifiez-vous pour accéder au dashboard',
                                style: AppTextStyles.bodyMedium,
                              ),
                              const SizedBox(height: 36),

                              // --- Username field ---
                              Text(
                                'IDENTIFIANT',
                                style: AppTextStyles.labelSmall,
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _usernameController,
                                enabled: !isLoading,
                                decoration: const InputDecoration(
                                  hintText: 'Entrez votre identifiant',
                                  prefixIcon: Icon(
                                    Icons.person_outline,
                                    size: 20,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                textInputAction: TextInputAction.next,
                              ),
                              const SizedBox(height: 24),

                              // --- Password field ---
                              Text(
                                'MOT DE PASSE',
                                style: AppTextStyles.labelSmall,
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _passwordController,
                                enabled: !isLoading,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  hintText: 'Entrez votre mot de passe',
                                  prefixIcon: const Icon(
                                    Icons.lock_outline,
                                    size: 20,
                                    color: AppColors.textSecondary,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      size: 20,
                                      color: AppColors.textSecondary,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                ),
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => _submit(context),
                              ),
                              const SizedBox(height: 36),

                              // --- Login button ---
                              SizedBox(
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: isLoading
                                      ? null
                                      : () => _submit(context),
                                  child: isLoading
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text('SE CONNECTER'),
                                ),
                              ),
                              const SizedBox(height: 32),

                              // --- Footer ---
                              Center(
                                child: Text(
                                  'v1.0.0',
                                  style: AppTextStyles.labelSmall,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit(BuildContext context) {
    final username = _usernameController.text.trim();
    final pwd = _passwordController.text;
    if (username.isNotEmpty && pwd.isNotEmpty) {
      context.read<LoginCubit>().login(username, pwd);
    }
  }
}

class _StatusRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatusRow({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(label, style: AppTextStyles.bodyMedium),
      ],
    );
  }
}
