import 'package:dokomandu/core/widgets/app_shimmer.dart';
import 'package:flutter/material.dart';

class KitchenListShimmer extends StatelessWidget {
  const KitchenListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ShimmerBox(height: 54, radius: 16),
          SizedBox(height: 14),
          ShimmerBox(height: 220, radius: 16),
          SizedBox(height: 10),
          ShimmerBox(height: 220, radius: 16),
          SizedBox(height: 10),
          ShimmerBox(height: 220, radius: 16),
        ],
      ),
    );
  }
}

class KitchenDetailShimmer extends StatelessWidget {
  const KitchenDetailShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ShimmerBox(height: 200, radius: 16),
          SizedBox(height: 12),
          ShimmerBox(height: 24, width: 220),
          SizedBox(height: 8),
          ShimmerBox(height: 16, width: 260),
          SizedBox(height: 16),
          ShimmerBox(height: 22, width: 90),
          SizedBox(height: 10),
          ShimmerBox(height: 110, radius: 14),
          SizedBox(height: 10),
          ShimmerBox(height: 110, radius: 14),
          SizedBox(height: 10),
          ShimmerBox(height: 110, radius: 14),
        ],
      ),
    );
  }
}

class MenuSectionShimmer extends StatelessWidget {
  const MenuSectionShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppShimmer(
      child: Column(
        children: [
          ShimmerBox(height: 110, radius: 14),
          SizedBox(height: 10),
          ShimmerBox(height: 110, radius: 14),
          SizedBox(height: 10),
          ShimmerBox(height: 110, radius: 14),
        ],
      ),
    );
  }
}
