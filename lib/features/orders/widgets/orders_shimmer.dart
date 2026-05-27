import 'package:dokomandu/core/widgets/app_shimmer.dart';
import 'package:flutter/material.dart';

class OrdersShimmer extends StatelessWidget {
  const OrdersShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ShimmerBox(height: 84, radius: 14),
          SizedBox(height: 10),
          ShimmerBox(height: 84, radius: 14),
          SizedBox(height: 10),
          ShimmerBox(height: 84, radius: 14),
        ],
      ),
    );
  }
}
