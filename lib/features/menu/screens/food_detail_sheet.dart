import 'package:dokomandu/app/routes/route_paths.dart';
import 'package:dokomandu/app/theme/app_radius.dart';
import 'package:dokomandu/app/theme/app_spacing.dart';
import 'package:dokomandu/features/cart/viewmodels/cart_viewmodel.dart';
import 'package:dokomandu/shared/models/food_item_model.dart';
import 'package:dokomandu/shared/widgets/network_image_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

Future<void> showFoodDetailSheet(
  BuildContext context,
  WidgetRef ref,
  FoodItemModel item,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _FoodDetailSheet(item: item),
  );
}

class _FoodDetailSheet extends ConsumerStatefulWidget {
  const _FoodDetailSheet({required this.item});

  final FoodItemModel item;

  @override
  ConsumerState<_FoodDetailSheet> createState() => _FoodDetailSheetState();
}

class _FoodDetailSheetState extends ConsumerState<_FoodDetailSheet> {
  FoodVariant? _selectedVariant;
  final Set<String> _selectedAddonIds = <String>{};
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    if (widget.item.variants.isNotEmpty) {
      _selectedVariant = widget.item.variants.first;
    }
  }

  List<FoodAddon> get _selectedAddons {
    return widget.item.addons
        .where((addon) => _selectedAddonIds.contains(addon.id))
        .toList();
  }

  double get _unitPrice {
    final base = widget.item.price;
    final variant = _selectedVariant?.priceDelta ?? 0;
    final addons = _selectedAddons.fold<double>(
      0,
      (sum, addon) => sum + addon.price,
    );
    return base + variant + addons;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.md,
          right: AppSpacing.md,
          bottom: AppSpacing.md + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              NetworkImageView(
                imageUrl: widget.item.imageUrl,
                height: 180,
                borderRadius: 18,
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.item.name,
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  if (widget.item.isVeg)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.tertiaryContainer,
                        borderRadius: AppRadius.brXl,
                      ),
                      child: Text(
                        'Veg',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onTertiaryContainer,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.star_rounded, color: theme.colorScheme.secondary),
                  const SizedBox(width: 4),
                  Text(widget.item.rating.toStringAsFixed(1)),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    'Base: Rs ${widget.item.price.toStringAsFixed(0)}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                widget.item.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (widget.item.variants.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                Text('Choose variant', style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: widget.item.variants.map((variant) {
                    final isSelected = _selectedVariant?.id == variant.id;
                    return ChoiceChip(
                      label: Text(
                        '${variant.name} (+Rs ${variant.priceDelta.toStringAsFixed(0)})',
                      ),
                      selected: isSelected,
                      onSelected: (_) =>
                          setState(() => _selectedVariant = variant),
                    );
                  }).toList(),
                ),
              ],
              if (widget.item.addons.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                Text('Add-ons', style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                ...widget.item.addons.map(
                  (addon) => CheckboxListTile(
                    value: _selectedAddonIds.contains(addon.id),
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selectedAddonIds.add(addon.id);
                        } else {
                          _selectedAddonIds.remove(addon.id);
                        }
                      });
                    },
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(addon.name),
                    subtitle: Text('+ Rs ${addon.price.toStringAsFixed(0)}'),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant,
                      ),
                      borderRadius: AppRadius.brXl,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_rounded),
                          onPressed: _quantity > 1
                              ? () => setState(() => _quantity--)
                              : null,
                        ),
                        Text('$_quantity', style: theme.textTheme.titleSmall),
                        IconButton(
                          icon: const Icon(Icons.add_rounded),
                          onPressed: () => setState(() => _quantity++),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: FilledButton(
                      onPressed: () async {
                        await ref
                            .read(cartViewModelProvider.notifier)
                            .addItem(
                              food: widget.item,
                              variant: _selectedVariant,
                              addons: _selectedAddons,
                              quantity: _quantity,
                            );

                        if (!context.mounted) return;
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${widget.item.name} added to cart'),
                            action: SnackBarAction(
                              label: 'View Cart',
                              onPressed: () => context.go(RoutePaths.cart),
                            ),
                          ),
                        );
                      },
                      child: Text(
                        'Add Rs ${(_unitPrice * _quantity).toStringAsFixed(0)}',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
