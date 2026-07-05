import 'package:flutter/material.dart';

import '../app_constants.dart';

/// Small pill showing an icon + label, used for compact recipe metadata
/// (kcal/serving, step count, servings, etc).
class StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final Color? backgroundColor;

  const StatChip({
    super.key,
    required this.icon,
    required this.label,
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final fg = color ?? colorScheme.primary;
    final bg = backgroundColor ?? colorScheme.primaryContainer;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg),
          ),
        ],
      ),
    );
  }
}
