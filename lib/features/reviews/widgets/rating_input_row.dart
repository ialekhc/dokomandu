import 'package:flutter/material.dart';

class RatingInputRow extends StatelessWidget {
  const RatingInputRow({
    required this.title,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final String title;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleSmall),
        const SizedBox(height: 6),
        Wrap(
          spacing: 4,
          children: List.generate(5, (index) {
            final star = index + 1;
            return IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: () => onChanged(star),
              icon: Icon(
                star <= value ? Icons.star_rounded : Icons.star_border_rounded,
                color: star <= value
                    ? theme.colorScheme.secondary
                    : theme.colorScheme.outline,
              ),
            );
          }),
        ),
      ],
    );
  }
}
