import 'package:dokomandu/app/theme/app_radius.dart';
import 'package:dokomandu/app/theme/app_spacing.dart';
import 'package:dokomandu/features/home/models/home_feed_model.dart';
import 'package:dokomandu/shared/widgets/network_image_view.dart';
import 'package:flutter/material.dart';

class CategoryChips extends StatelessWidget {
  const CategoryChips({required this.categories, super.key});

  final List<FoodCategory> categories;

  static const _fallbackImages = [
    'https://images.unsplash.com/photo-1626776876729-bab4369a5a5a?auto=format&fit=crop&w=700&q=80',
    'https://images.unsplash.com/photo-1563379091339-03246963d51a?auto=format&fit=crop&w=700&q=80',
    'https://images.unsplash.com/photo-1515003197210-e0cd71810b5f?auto=format&fit=crop&w=700&q=80',
    'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?auto=format&fit=crop&w=700&q=80',
    'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=700&q=80',
    'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?auto=format&fit=crop&w=700&q=80',
    'https://images.unsplash.com/photo-1498837167922-ddd27525d352?auto=format&fit=crop&w=700&q=80',
    'https://images.unsplash.com/photo-1490645935967-10de6ba17061?auto=format&fit=crop&w=700&q=80',
  ];

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

  @override
  Widget build(BuildContext context) {
    final items = categories.asMap().entries.map((entry) {
      final index = entry.key;
      final category = entry.value;
      final keyword = category.name.toLowerCase();

      int price = 49;
      for (final mapEntry in _priceByKeyword.entries) {
        if (keyword.contains(mapEntry.key)) {
          price = mapEntry.value;
          break;
        }
      }

      return _MindCategoryItem(
        title: category.name,
        startsFrom: price,
        imageUrl:
            category.imageUrl ??
            _fallbackImages[index % _fallbackImages.length],
      );
    }).toList();

    return SizedBox(
      height: 382,
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: AppSpacing.sm,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: 0.58,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) => items[index],
      ),
    );
  }
}

class _MindCategoryItem extends StatelessWidget {
  const _MindCategoryItem({
    required this.title,
    required this.startsFrom,
    required this.imageUrl,
  });

  final String title;
  final int startsFrom;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFDFF9EC),
              borderRadius: AppRadius.brLg,
              border: Border.all(color: const Color(0xFFC9EFDB)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Starts At Rs $startsFrom',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: const Color(0xFF00875A),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Expanded(
                    child: NetworkImageView(
                      imageUrl: imageUrl,
                      height: double.infinity,
                      width: double.infinity,
                      borderRadius: 14,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          title,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}
