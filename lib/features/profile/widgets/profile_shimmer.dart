import 'package:dokomandu/core/widgets/app_shimmer.dart';
import 'package:flutter/material.dart';

class ProfileShimmer extends StatelessWidget {
  const ProfileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ShimmerBox(height: 88, radius: 16),
          SizedBox(height: 10),
          ShimmerBox(height: 66, radius: 14),
          SizedBox(height: 8),
          ShimmerBox(height: 66, radius: 14),
          SizedBox(height: 8),
          ShimmerBox(height: 66, radius: 14),
          SizedBox(height: 8),
          ShimmerBox(height: 66, radius: 14),
        ],
      ),
    );
  }
}
