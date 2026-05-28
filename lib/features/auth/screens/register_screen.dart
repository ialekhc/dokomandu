import 'package:dokomandu/core/widgets/app_error_state.dart';
import 'package:dokomandu/core/widgets/app_primary_button.dart';
import 'package:dokomandu/core/widgets/app_text_field.dart';
import 'package:dokomandu/core/utils/auth_validators.dart';
import 'package:dokomandu/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();

    if (name.length < 2) {
      _show('Please enter your full name.');
      return;
    }

    if (!AuthValidators.isValidPhone(phone)) {
      _show('Please enter a valid phone number.');
      return;
    }

    if (!AuthValidators.isValidPassword(password)) {
      _show('Password must be at least 6 characters.');
      return;
    }

    if (confirm != password) {
      _show('Confirm password does not match.');
      return;
    }

    if (!_acceptedTerms) {
      _show('Please accept terms and conditions.');
      return;
    }

    await ref
        .read(authViewModelProvider.notifier)
        .registerDemoUser(fullName: name, phone: phone, password: password);
  }

  void _show(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Demo Account')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            AppTextField(
              controller: _nameController,
              label: 'Full Name',
              hint: 'Your full name',
              textInputAction: TextInputAction.next,
              prefix: const Icon(Icons.person_outline),
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _phoneController,
              label: 'Phone Number',
              hint: '98XXXXXXXX',
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              prefix: const Icon(Icons.phone_android_outlined),
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _passwordController,
              label: 'Password',
              hint: 'Minimum 6 characters',
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.next,
              prefix: const Icon(Icons.lock_outline),
              suffix: IconButton(
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _confirmController,
              label: 'Confirm Password',
              hint: 'Retype password',
              obscureText: _obscureConfirm,
              textInputAction: TextInputAction.done,
              prefix: const Icon(Icons.lock_reset_outlined),
              suffix: IconButton(
                onPressed: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
                icon: Icon(
                  _obscureConfirm
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
            const SizedBox(height: 10),
            CheckboxListTile(
              value: _acceptedTerms,
              contentPadding: EdgeInsets.zero,
              onChanged: (value) =>
                  setState(() => _acceptedTerms = value ?? false),
              title: const Text('I accept terms and conditions'),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: 14),
            AppPrimaryButton(
              label: 'Register & Continue',
              onPressed: _submit,
              isLoading: authState.isLoading,
            ),
            if (authState.error != null) ...[
              const SizedBox(height: 12),
              AppErrorState(message: authState.error!),
            ],
          ],
        ),
      ),
    );
  }
}
