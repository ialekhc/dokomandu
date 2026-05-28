import 'package:dokomandu/app/theme/app_spacing.dart';
import 'package:dokomandu/shared/models/food_item_model.dart';
import 'package:dokomandu/shared/widgets/network_image_view.dart';
import 'package:flutter/material.dart';

class PopularFoodList extends StatelessWidget {
  const PopularFoodList({
    required this.items,
    required this.onTap,
    this.onQuickAdd,
    super.key,
  });

  final List<FoodItemModel> items;
  final ValueChanged<FoodItemModel> onTap;
  final ValueChanged<FoodItemModel>? onQuickAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 232,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, index) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final item = items[index];

          return SizedBox(
            width: 184,
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => onTap(item),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        NetworkImageView(
                          imageUrl: item.imageUrl,
                          height: 118,
                          width: 184,
                          borderRadius: 0,
                        ),
                        Positioned(
                          left: AppSpacing.xs,
                          top: AppSpacing.xs,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.55),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  color: Colors.amber,
                                  size: 14,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  item.rating.toStringAsFixed(1),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                Text(
                                  'Rs ${item.price.toStringAsFixed(0)}',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const Spacer(),
                                IconButton.filledTonal(
                                  onPressed: () =>
                                      (onQuickAdd ?? onTap).call(item),
                                  icon: const Icon(Icons.add_rounded),
                                  visualDensity: VisualDensity.compact,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
