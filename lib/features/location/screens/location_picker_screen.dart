import 'package:dokomandu/app/theme/app_radius.dart';
import 'package:dokomandu/app/theme/app_spacing.dart';
import 'package:dokomandu/core/widgets/app_error_state.dart';
import 'package:dokomandu/core/widgets/app_loader.dart';
import 'package:dokomandu/core/widgets/app_primary_button.dart';
import 'package:dokomandu/features/location/viewmodels/location_viewmodel.dart';
import 'package:dokomandu/features/location/widgets/address_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LocationPickerScreen extends ConsumerWidget {
  const LocationPickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationState = ref.watch(locationViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Select Delivery Location')),
      body: locationState.when(
        loading: () => const AppLoader(),
        error: (error, stack) => AppErrorState(
          message: error.toString(),
          onRetry: () =>
              ref.read(locationViewModelProvider.notifier).refreshLocation(),
        ),
        data: (state) {
          if (state.selectedPoint == null) {
            return AppErrorState(
              message: state.message ?? 'Could not determine current location.',
              onRetry: () => ref
                  .read(locationViewModelProvider.notifier)
                  .refreshLocation(),
            );
          }

          final theme = Theme.of(context);

          return Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    FlutterMap(
                      options: MapOptions(
                        initialCenter: state.selectedPoint!,
                        initialZoom: 15,
                        onTap: (_, point) => ref
                            .read(locationViewModelProvider.notifier)
                            .updateSelectedPoint(point),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.dokomandu',
                          maxZoom: 19,
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              width: 46,
                              height: 46,
                              point: state.selectedPoint!,
                              child: Icon(
                                Icons.location_pin,
                                size: 40,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        RichAttributionWidget(
                          attributions: [
                            TextSourceAttribution(
                              'OpenStreetMap contributors',
                              onTap: () {},
                            ),
                          ],
                        ),
                      ],
                    ),
                    Positioned(
                      left: AppSpacing.md,
                      right: AppSpacing.md,
                      top: AppSpacing.md,
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: AppRadius.brLg,
                          border: Border.all(
                            color: theme.colorScheme.outlineVariant,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              state.withinServiceRadius
                                  ? Icons.check_circle_outline_rounded
                                  : Icons.error_outline_rounded,
                              color: state.withinServiceRadius
                                  ? theme.colorScheme.tertiary
                                  : theme.colorScheme.error,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Expanded(
                              child: Text(
                                state.withinServiceRadius
                                    ? 'Great! We deliver to this location.'
                                    : 'Outside 3 km service radius. Pick a nearby point.',
                                style: theme.textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: const BorderRadius.only(
                    topLeft: AppRadius.xl,
                    topRight: AppRadius.xl,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 14,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.sm,
                      AppSpacing.md,
                      AppSpacing.md,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Saved Addresses',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        if (state.savedAddresses.isEmpty)
                          Text(
                            'No saved addresses yet. Tap on map to choose a location.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          )
                        else
                          SizedBox(
                            height: 170,
                            child: ListView.separated(
                              itemCount: state.savedAddresses.length,
                              separatorBuilder: (_, index) =>
                                  const SizedBox(height: AppSpacing.xs),
                              itemBuilder: (context, index) {
                                final address = state.savedAddresses[index];
                                return AddressTile(
                                  address: address,
                                  onTap: () => ref
                                      .read(locationViewModelProvider.notifier)
                                      .selectSavedAddress(address),
                                );
                              },
                            ),
                          ),
                        if (state.message != null)
                          Padding(
                            padding: const EdgeInsets.only(top: AppSpacing.xs),
                            child: Text(
                              state.message!,
                              style: TextStyle(color: theme.colorScheme.error),
                            ),
                          ),
                        const SizedBox(height: AppSpacing.sm),
                        AppPrimaryButton(
                          label: 'Use This Location',
                          onPressed: state.withinServiceRadius
                              ? () => Navigator.of(
                                  context,
                                ).pop(state.selectedPoint)
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
