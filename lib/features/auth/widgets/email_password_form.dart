import 'package:dokomandu/core/widgets/app_primary_button.dart';
import 'package:dokomandu/core/widgets/app_text_field.dart';
import 'package:flutter/material.dart';

class EmailPasswordForm extends StatelessWidget {
  const EmailPasswordForm({
    required this.phoneController,
    required this.passwordController,
    required this.isLoading,
    required this.obscurePassword,
    required this.onTogglePassword,
    required this.onLogin,
    super.key,
  });

  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final bool isLoading;
  final bool obscurePassword;
  final VoidCallback onTogglePassword;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          controller: phoneController,
          label: 'Phone Number',
          hint: '98XXXXXXXX',
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          prefix: const Icon(Icons.phone_android_outlined),
        ),
        const SizedBox(height: 14),
        AppTextField(
          controller: passwordController,
          label: 'Password',
          hint: 'Enter password',
          textInputAction: TextInputAction.done,
          obscureText: obscurePassword,
          prefix: const Icon(Icons.lock_outline),
          suffix: IconButton(
            onPressed: onTogglePassword,
            icon: Icon(
              obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
            ),
          ),
        ),
        const SizedBox(height: 18),
        AppPrimaryButton(
          label: 'Sign In',
          onPressed: onLogin,
          isLoading: isLoading,
        ),
      ],
    );
  }
}
