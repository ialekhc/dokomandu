import 'package:dokomandu/app/theme/app_radius.dart';
import 'package:dokomandu/app/theme/app_spacing.dart';
import 'package:dokomandu/features/home/models/home_feed_model.dart';
import 'package:flutter/material.dart';

class CategoryChips extends StatelessWidget {
  const CategoryChips({required this.categories, super.key});

  final List<FoodCategory> categories;

  static const _priceByKeyword = {
    'momo': 39,
    'biryani': 199,
    'pizza': 169,
    'healthy': 129,
    'snacks': 69,
    'dessert': 89,
    'coffee': 99,
    'shake': 139,
    'juice': 79,
    'chaat': 65,
    'fries': 59,
    'finger': 59,
    'party': 299,
    'desk': 79,
    'cooler': 49,
  };

  int _resolvePrice(String categoryName) {
    final keyword = categoryName.toLowerCase();
    for (final mapEntry in _priceByKeyword.entries) {
      if (keyword.contains(mapEntry.key)) {
        return mapEntry.value;
      }
    }
    return 49;
  }

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 108,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final category = categories[index];
          return _MindCategoryItem(
            title: category.name,
            startsFrom: _resolvePrice(category.name),
          );
        },
      ),
    );
  }
}

class _MindCategoryItem extends StatelessWidget {
  const _MindCategoryItem({required this.title, required this.startsFrom});

  final String title;
  final int startsFrom;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 154,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.45,
        ),
        borderRadius: AppRadius.brLg,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.7),
              borderRadius: AppRadius.brXl,
            ),
            child: Text(
              'Starts at Rs $startsFrom',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
