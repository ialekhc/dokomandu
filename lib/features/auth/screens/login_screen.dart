import 'package:dokomandu/app/routes/route_paths.dart';
import 'package:dokomandu/core/utils/auth_validators.dart';
import 'package:dokomandu/core/widgets/app_error_state.dart';
import 'package:dokomandu/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:dokomandu/features/auth/widgets/email_password_form.dart';
import 'package:dokomandu/shared/widgets/brand_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
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
                'Sign in with your phone number and password to continue.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              EmailPasswordForm(
                phoneController: _phoneController,
                passwordController: _passwordController,
                isLoading: state.isLoading,
                obscurePassword: _obscurePassword,
                onTogglePassword: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
                onLogin: () async {
                  final phone = _phoneController.text.trim();
                  final password = _passwordController.text.trim();

                  if (!AuthValidators.isValidPhone(phone)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Enter a valid phone number.'),
                      ),
                    );
                    return;
                  }

                  if (!AuthValidators.isValidPassword(password)) {
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
                      .loginWithPhonePassword(phone: phone, password: password);
                },
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.push(RoutePaths.forgotPassword),
                  child: const Text('Forgot Password?'),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  TextButton(
                    onPressed: () => context.push(RoutePaths.register),
                    child: const Text('Register'),
                  ),
                ],
              ),
              if (state.error != null) ...[
                const SizedBox(height: 16),
                AppErrorState(message: state.error!),
              ],
              const SizedBox(height: 8),
              Text(
                'Demo user: 9800000000 / 123456',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
