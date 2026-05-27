import 'package:dokomandu/core/widgets/app_primary_button.dart';
import 'package:dokomandu/core/widgets/app_text_field.dart';
import 'package:flutter/material.dart';

class PhoneInputForm extends StatelessWidget {
  const PhoneInputForm({
    required this.controller,
    required this.isLoading,
    required this.onContinue,
    super.key,
  });

  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          controller: controller,
          label: 'Phone Number',
          hint: '98XXXXXXXX',
          keyboardType: TextInputType.phone,
          prefix: const Icon(Icons.phone_android_outlined),
        ),
        const SizedBox(height: 16),
        AppPrimaryButton(
          label: 'Continue',
          onPressed: onContinue,
          isLoading: isLoading,
        ),
      ],
    );
  }
}
