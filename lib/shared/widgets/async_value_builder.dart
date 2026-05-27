import 'package:dokomandu/core/widgets/app_empty_state.dart';
import 'package:dokomandu/core/widgets/app_error_state.dart';
import 'package:dokomandu/core/widgets/app_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AsyncValueBuilder<T> extends StatelessWidget {
  const AsyncValueBuilder({
    required this.value,
    required this.data,
    super.key,
    this.onRetry,
    this.emptyTitle,
  });

  final AsyncValue<T> value;
  final Widget Function(T value) data;
  final VoidCallback? onRetry;
  final String? emptyTitle;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: (state) {
        if (state is Iterable && state.isEmpty) {
          return AppEmptyState(title: emptyTitle ?? 'Nothing found yet');
        }
        return data(state);
      },
      loading: () => const AppLoader(),
      error: (error, stack) =>
          AppErrorState(message: error.toString(), onRetry: onRetry),
    );
  }
}
