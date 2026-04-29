import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:amex5/core/di/injection.dart';
import 'package:amex5/core/theme/app_theme.dart';
import 'package:amex5/features/authentification/presentation/login_cubit.dart';

/// Dialog simplifié pour re-login quand le token expire.
Future<void> showTokenExpiredDialog(BuildContext context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) => BlocProvider(
      create: (context) => getIt<LoginCubit>(),
      child: const _TokenExpiredDialogContent(),
    ),
  );
}

class _TokenExpiredDialogContent extends StatefulWidget {
  const _TokenExpiredDialogContent();

  @override
  State<_TokenExpiredDialogContent> createState() =>
      _TokenExpiredDialogContentState();
}

class _TokenExpiredDialogContentState extends State<_TokenExpiredDialogContent> {
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
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      backgroundColor: AppColors.surface,
      child: BlocListener<LoginCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            // Fermer le dialog et rester sur la page actuelle
            Navigator.of(context).pop();
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: BlocBuilder<LoginCubit, AuthState>(
            builder: (context, state) {
              final isLoading = state is AuthLoading;
              return SizedBox(
                width: 380,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // — Icon + Title —
                      Center(
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.warning.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.lock_clock_outlined,
                            color: AppColors.warning,
                            size: 28,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Session expirée',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Veuillez vous reconnecter pour continuer',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // — Username field —
                      TextField(
                        controller: _usernameController,
                        enabled: !isLoading,
                        decoration: const InputDecoration(
                          hintText: 'Identifiant',
                          prefixIcon: Icon(
                            Icons.person_outline,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 12),

                      // — Password field —
                      TextField(
                        controller: _passwordController,
                        enabled: !isLoading,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: 'Mot de passe',
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 18,
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
                        onSubmitted: (_) => _submit(context, isLoading),
                      ),
                      const SizedBox(height: 24),

                      // — Login button —
                      SizedBox(
                        height: 44,
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () => _submit(context, isLoading),
                          child: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('SE RECONNECTER'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _submit(BuildContext context, bool isLoading) {
    final username = _usernameController.text.trim();
    final pwd = _passwordController.text;
    if (username.isNotEmpty && pwd.isNotEmpty && !isLoading) {
      context.read<LoginCubit>().login(username, pwd);
    }
  }
}
