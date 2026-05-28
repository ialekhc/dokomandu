import 'package:dokomandu/app/routes/route_paths.dart';
import 'package:dokomandu/app/theme/app_radius.dart';
import 'package:dokomandu/app/theme/app_spacing.dart';
import 'package:dokomandu/features/auth/viewmodels/onboarding_viewmodel.dart';
import 'package:dokomandu/shared/widgets/brand_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  static const _pages = [
    _OnboardingPageData(
      title: 'Order Faster From Nearby Kitchens',
      subtitle:
          'Discover food categories, compare kitchens, and add items quickly with a clean ordering flow.',
      icon: Icons.storefront_outlined,
    ),
    _OnboardingPageData(
      title: 'Live Demo Tracking Experience',
      subtitle:
          'Follow static order status updates, use next-status controls, and demonstrate customer order visibility.',
      icon: Icons.route_outlined,
    ),
    _OnboardingPageData(
      title: 'Schedule Or Order Instantly',
      subtitle:
          'Choose order now or schedule for later, then checkout with cash on delivery in this demo app.',
      icon: Icons.schedule_outlined,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(onboardingProvider.notifier).completeOnboarding();
    if (!mounted) return;
    context.go(RoutePaths.login);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              Row(
                children: [
                  const BrandLogo(size: 34),
                  const SizedBox(width: AppSpacing.xs),
                  Text('Dokomandu', style: theme.textTheme.titleLarge),
                  const Spacer(),
                  TextButton(onPressed: _finish, child: const Text('Skip')),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (value) => setState(() => _index = value),
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    return _OnboardingPage(data: page);
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    height: 8,
                    width: _index == index ? 24 : 8,
                    decoration: BoxDecoration(
                      borderRadius: AppRadius.brXl,
                      color: _index == index
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outlineVariant,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _index == _pages.length - 1
                      ? _finish
                      : () => _controller.nextPage(
                          duration: const Duration(milliseconds: 260),
                          curve: Curves.easeOut,
                        ),
                  child: Text(
                    _index == _pages.length - 1 ? 'Get Started' : 'Next',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.data});

  final _OnboardingPageData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.xl),
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.55),
            borderRadius: AppRadius.brXl,
          ),
          alignment: Alignment.center,
          child: Icon(data.icon, size: 42, color: theme.colorScheme.primary),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          data.title,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          data.subtitle,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _OnboardingPageData {
  const _OnboardingPageData({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}
