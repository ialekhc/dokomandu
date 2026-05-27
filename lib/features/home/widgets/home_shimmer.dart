import 'package:dokomandu/core/widgets/app_shimmer.dart';
import 'package:flutter/material.dart';

class HomeShimmer extends StatelessWidget {
  const HomeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ShimmerBox(height: 54, radius: 16),
          SizedBox(height: 14),
          ShimmerBox(height: 56, radius: 14),
          SizedBox(height: 12),
          ShimmerBox(height: 150, radius: 16),
          SizedBox(height: 16),
          ShimmerBox(height: 18, width: 170),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: ShimmerBox(height: 36, radius: 18)),
              SizedBox(width: 8),
              Expanded(child: ShimmerBox(height: 36, radius: 18)),
              SizedBox(width: 8),
              Expanded(child: ShimmerBox(height: 36, radius: 18)),
            ],
          ),
          SizedBox(height: 16),
          ShimmerBox(height: 18, width: 150),
          SizedBox(height: 10),
          SizedBox(
            height: 200,
            child: Row(
              children: [
                Expanded(child: ShimmerBox(height: 200, radius: 16)),
                SizedBox(width: 12),
                Expanded(child: ShimmerBox(height: 200, radius: 16)),
              ],
            ),
          ),
          SizedBox(height: 16),
          ShimmerBox(height: 18, width: 160),
          SizedBox(height: 10),
          ShimmerBox(height: 220, radius: 16),
          SizedBox(height: 10),
          ShimmerBox(height: 220, radius: 16),
        ],
      ),
    );
  }
}
