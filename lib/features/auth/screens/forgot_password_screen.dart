import 'package:dokomandu/core/widgets/app_error_state.dart';
import 'package:dokomandu/core/widgets/app_primary_button.dart';
import 'package:dokomandu/core/widgets/app_text_field.dart';
import 'package:dokomandu/core/utils/auth_validators.dart';
import 'package:dokomandu/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final phone = _phoneController.text.trim();
    if (!AuthValidators.isValidPhone(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid phone number.')),
      );
      return;
    }

    final ok = await ref
        .read(authViewModelProvider.notifier)
        .forgotPasswordDemo(phone: phone);
    if (!mounted || !ok) return;

    final info = ref.read(authViewModelProvider).info;
    if (info != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(info)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Enter your registered phone number to run a demo reset flow.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _phoneController,
              label: 'Phone Number',
              hint: '98XXXXXXXX',
              keyboardType: TextInputType.phone,
              prefix: const Icon(Icons.phone_android_outlined),
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 14),
            AppPrimaryButton(
              label: 'Send Demo Reset',
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
