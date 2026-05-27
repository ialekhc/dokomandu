import 'package:dokomandu/core/widgets/app_error_state.dart';
import 'package:dokomandu/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:dokomandu/features/auth/widgets/email_password_form.dart';
import 'package:dokomandu/shared/widgets/brand_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isEmailValid(String value) {
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return emailRegex.hasMatch(value);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authViewModelProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 18),
              const Align(
                alignment: Alignment.center,
                child: BrandLogo(size: 92, showShadow: true),
              ),
              const SizedBox(height: 20),
              Text(
                'Welcome back',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in with your email and password to continue ordering from nearby kitchens.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              EmailPasswordForm(
                emailController: _emailController,
                passwordController: _passwordController,
                isLoading: state.isLoading,
                obscurePassword: _obscurePassword,
                onTogglePassword: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
                onLogin: () async {
                  final email = _emailController.text.trim();
                  final password = _passwordController.text.trim();

                  if (!_isEmailValid(email)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Enter a valid email address.'),
                      ),
                    );
                    return;
                  }

                  if (password.length < 6) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Password must be at least 6 characters long.',
                        ),
                      ),
                    );
                    return;
                  }

                  await ref
                      .read(authViewModelProvider.notifier)
                      .loginWithEmailPassword(email: email, password: password);
                },
              ),
              if (state.error != null) ...[
                const SizedBox(height: 16),
                AppErrorState(message: state.error!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
