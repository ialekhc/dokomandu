import 'package:dokomandu/app/theme/app_spacing.dart';
import 'package:dokomandu/core/widgets/app_empty_state.dart';
import 'package:dokomandu/core/widgets/app_error_state.dart';
import 'package:dokomandu/features/address/models/address_form_model.dart';
import 'package:dokomandu/features/address/viewmodels/address_viewmodel.dart';
import 'package:dokomandu/features/address/widgets/address_management_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddressManagementScreen extends ConsumerWidget {
  const AddressManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(addressViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Address Management')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context, ref),
        icon: const Icon(Icons.add_location_alt_outlined),
        label: const Text('Add Address'),
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => AppErrorState(
          message: error.toString(),
          onRetry: () => ref.read(addressViewModelProvider.notifier).refresh(),
        ),
        data: (addresses) {
          if (addresses.isEmpty) {
            return const AppEmptyState(
              title: 'No addresses yet',
              subtitle: 'Tap Add Address to create your first demo address.',
              icon: Icons.location_off_outlined,
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              120,
            ),
            itemCount: addresses.length,
            separatorBuilder: (_, index) =>
                const SizedBox(height: AppSpacing.xs),
            itemBuilder: (context, index) {
              final address = addresses[index];
              return AddressManagementTile(
                address: address,
                onDelete: () => ref
                    .read(addressViewModelProvider.notifier)
                    .removeAddress(address.id),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showAddDialog(BuildContext context, WidgetRef ref) async {
    final labelController = TextEditingController();
    final addressController = TextEditingController();
    final landmarkController = TextEditingController();

    final created = await showDialog<AddressFormModel>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Demo Address'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: labelController,
                decoration: const InputDecoration(
                  labelText: 'Label',
                  hintText: 'Home / Office',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Full Address',
                  hintText: 'Street, area, city',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: landmarkController,
                decoration: const InputDecoration(
                  labelText: 'Landmark (Optional)',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final label = labelController.text.trim();
              final fullAddress = addressController.text.trim();
              if (label.isEmpty || fullAddress.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Label and full address are required.'),
                  ),
                );
                return;
              }
              Navigator.of(context).pop(
                AddressFormModel(
                  label: label,
                  fullAddress: fullAddress,
                  landmark: landmarkController.text.trim().isEmpty
                      ? null
                      : landmarkController.text.trim(),
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    labelController.dispose();
    addressController.dispose();
    landmarkController.dispose();

    if (created == null) return;
    await ref.read(addressViewModelProvider.notifier).addAddress(created);
  }
}
