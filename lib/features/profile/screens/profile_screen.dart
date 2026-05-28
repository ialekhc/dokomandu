import 'package:dokomandu/app/routes/route_paths.dart';
import 'package:dokomandu/app/theme/app_radius.dart';
import 'package:dokomandu/app/theme/app_spacing.dart';
import 'package:dokomandu/app/theme/theme_provider.dart';
import 'package:dokomandu/core/widgets/app_error_state.dart';
import 'package:dokomandu/features/profile/viewmodels/profile_viewmodel.dart';
import 'package:dokomandu/features/profile/widgets/profile_menu_tile.dart';
import 'package:dokomandu/features/profile/widgets/profile_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileViewModelProvider);
    final themeSettings = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: profile.when(
        loading: () => const ProfileShimmer(),
        error: (error, stack) => AppErrorState(
          message: error.toString(),
          onRetry: () => ref.read(profileViewModelProvider.notifier).refresh(),
        ),
        data: (user) {
          final theme = Theme.of(context);
          final displayName = (user?.name ?? 'Guest User').trim();
          final safeName = displayName.isEmpty ? 'Guest User' : displayName;
          final initial = safeName.substring(0, 1).toUpperCase();

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              120,
            ),
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(
                    alpha: 0.42,
                  ),
                  borderRadius: AppRadius.brLg,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: theme.colorScheme.primary,
                      child: Text(
                        initial,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(safeName, style: theme.textTheme.titleLarge),
                          const SizedBox(height: 2),
                          Text(
                            user?.email ?? user?.phone ?? 'No contact info',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton.filledTonal(
                      onPressed: () => context.push(RoutePaths.editProfile),
                      icon: const Icon(Icons.edit_outlined),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Account', style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.xs),
              ProfileMenuTile(
                title: 'Edit Profile',
                icon: Icons.person_outline,
                onTap: () => context.push(RoutePaths.editProfile),
              ),
              ProfileMenuTile(
                title: 'Manage Addresses',
                icon: Icons.location_on_outlined,
                onTap: () => context.push(RoutePaths.addressManagement),
              ),
              ProfileMenuTile(
                title: 'Appearance',
                subtitle: _themeModeLabel(themeSettings.themeMode),
                icon: Icons.palette_outlined,
                onTap: () => _openThemeSelector(context, ref),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text('Support', style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.xs),
              ProfileMenuTile(
                title: 'Help & Support',
                icon: Icons.support_agent_outlined,
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'Dokomandu',
                    children: const [
                      Text('Contact support@dokomandu.com for assistance.'),
                    ],
                  );
                },
              ),
              ProfileMenuTile(
                title: 'Terms & Privacy',
                icon: Icons.description_outlined,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Terms & privacy page placeholder.'),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              Text('Security', style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.xs),
              ProfileMenuTile(
                title: 'Logout',
                icon: Icons.logout,
                isDanger: true,
                onTap: () =>
                    ref.read(profileViewModelProvider.notifier).logout(),
              ),
              ProfileMenuTile(
                title: 'Delete Account',
                icon: Icons.delete_forever_outlined,
                isDanger: true,
                subtitle: 'This action is permanent.',
                onTap: () async {
                  final shouldDelete =
                      await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete account?'),
                          content: const Text('This action cannot be undone.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      ) ??
                      false;

                  if (!shouldDelete) return;
                  await ref
                      .read(profileViewModelProvider.notifier)
                      .deleteAccount();
                },
              ),
            ],
          );
        },
      ),
    );
  }

  String _themeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light mode';
      case ThemeMode.dark:
        return 'Dark mode';
      case ThemeMode.system:
        return 'System default';
    }
  }

  Future<void> _openThemeSelector(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final settings = ref.watch(themeProvider);
        final notifier = ref.read(themeProvider.notifier);

        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Theme', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              SegmentedButton<ThemeMode>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.system,
                    label: Text('System'),
                    icon: Icon(Icons.phone_android_outlined),
                  ),
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.light,
                    label: Text('Light'),
                    icon: Icon(Icons.light_mode_outlined),
                  ),
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.dark,
                    label: Text('Dark'),
                    icon: Icon(Icons.dark_mode_outlined),
                  ),
                ],
                selected: {settings.themeMode},
                onSelectionChanged: (value) =>
                    notifier.setThemeMode(value.first),
              ),
              const SizedBox(height: AppSpacing.md),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: settings.useDynamicTheming,
                onChanged: notifier.setDynamicTheming,
                title: const Text('Dynamic Theming (Structure Ready)'),
                subtitle: const Text(
                  'Reserved for system color extraction support.',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
