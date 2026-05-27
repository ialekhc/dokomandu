import 'package:flutter/material.dart';

class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.isLoading = false,
    this.leading,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final disabled = isLoading ? null : onPressed;

    return SizedBox(
      width: double.infinity,
      child: (isLoading || leading != null)
          ? FilledButton.icon(
              onPressed: disabled,
              icon: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : leading!,
              label: Text(label),
            )
          : FilledButton(onPressed: disabled, child: Text(label)),
    );
  }
}
