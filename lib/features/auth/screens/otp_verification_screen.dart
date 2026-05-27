import 'package:dokomandu/core/widgets/app_primary_button.dart';
import 'package:dokomandu/core/widgets/app_text_field.dart';
import 'package:dokomandu/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  const OtpVerificationScreen({required this.phone, super.key});

  final String phone;

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('OTP Verification')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Enter the code sent to ${widget.phone}'),
              const SizedBox(height: 16),
              AppTextField(
                controller: _otpController,
                label: '6-digit OTP',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 18),
              AppPrimaryButton(
                label: 'Verify and Continue',
                isLoading: state.isLoading,
                onPressed: () async {
                  final otp = _otpController.text.trim();
                  if (otp.length < 4) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Enter a valid OTP.')),
                    );
                    return;
                  }

                  final success = await ref
                      .read(authViewModelProvider.notifier)
                      .verifyOtp(phone: widget.phone, otp: otp);

                  if (!context.mounted || !success) return;
                  context.pop();
                },
              ),
              if (state.error != null) ...[
                const SizedBox(height: 12),
                Text(
                  state.error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
