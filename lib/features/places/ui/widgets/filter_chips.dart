import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

// Stateless — just renders chips, parent owns state (SRP)
class FilterChipsRow extends StatelessWidget {
  final String selected;
  final void Function(String) onSelected;

  const FilterChipsRow({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  static const _options = [
    ('all', 'All'),
    ('favorites', 'Favorites'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: _options.map((opt) {
          final isSelected = selected == opt.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: ChoiceChip(
                label: Text(opt.$2),
                selected: isSelected,
                onSelected: (_) => onSelected(opt.$1),
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : null,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
