import 'package:flutter/material.dart';

import '../models/meal_type.dart';

/// Visual styling (icon + green-family surface/accent colors) for each meal
/// type, shared between the Weekly Plan screen and its add-to-plan sheet so
/// the three meals stay distinguishable without leaving the brand palette.
extension MealTypeStyle on MealType {
  IconData get icon {
    switch (this) {
      case MealType.breakfast:
        return Icons.egg_outlined;
      case MealType.lunch:
        return Icons.lunch_dining;
      case MealType.dinner:
        return Icons.restaurant;
    }
  }

  /// Soft, green-family surface color for the meal's slot background —
  /// lightest for breakfast, soft mid-green for lunch, a slightly deeper
  /// (but still pastel) green for dinner, so all three stay in the same
  /// gentle family instead of dinner reading as a hard, saturated block.
  Color get surfaceColor {
    switch (this) {
      case MealType.breakfast:
        return const Color(0xFFEEF7EA);
      case MealType.lunch:
        return const Color(0xFFCFE8D1);
      case MealType.dinner:
        return const Color(0xFFB7DDBB);
    }
  }

  /// Icon/text tone with enough contrast against [surfaceColor].
  Color get onSurfaceColor {
    switch (this) {
      case MealType.breakfast:
        return const Color(0xFF2E7D32);
      case MealType.lunch:
        return const Color(0xFF1B5E20);
      case MealType.dinner:
        return const Color(0xFF1B5E20);
    }
  }

  /// A readable green tone for icons/text placed on a neutral (white/cream)
  /// background instead of [surfaceColor] — e.g. in the add-to-plan sheet.
  Color get accentColor {
    switch (this) {
      case MealType.breakfast:
        return const Color(0xFF2E7D32);
      case MealType.lunch:
        return const Color(0xFF1B5E20);
      case MealType.dinner:
        return const Color(0xFF386641);
    }
  }
}
