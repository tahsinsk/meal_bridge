import 'package:flutter/material.dart';

import '../../../models/meal_type.dart';
import '../../../shared/app_constants.dart';
import '../../../shared/meal_type_style.dart';

/// Small "preview of the real app" mock-ups used on each onboarding page —
/// built from the same cards/colors/radii as the actual screens instead of
/// a plain icon, so onboarding reads as a glimpse of the product itself.

class RecipeCardIllustration extends StatelessWidget {
  const RecipeCardIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: 190,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 96,
              width: double.infinity,
              color: AppColors.surfaceSoft,
              child: const Center(
                child: Icon(Icons.restaurant_menu_outlined, size: 32, color: AppColors.primaryDark),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 10,
                    width: 110,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3E7E1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: MealType.dinner.surfaceColor,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      'Dinner',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: MealType.dinner.onSurfaceColor),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 8,
                    width: 70,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF1EE),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WeekStripIllustration extends StatelessWidget {
  const WeekStripIllustration({super.key});

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu'];

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final day in _days) ...[
              Column(
                children: [
                  Text(
                    day,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
                  ),
                  const SizedBox(height: 10),
                  _mealDot(MealType.breakfast),
                  const SizedBox(height: 5),
                  _mealDot(MealType.lunch),
                  const SizedBox(height: 5),
                  _mealDot(MealType.dinner),
                ],
              ),
              if (day != _days.last) const SizedBox(width: 12),
            ],
          ],
        ),
      ),
    );
  }

  Widget _mealDot(MealType type) {
    return Container(
      width: 28,
      height: 18,
      decoration: BoxDecoration(
        color: type.surfaceColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: Icon(type.icon, size: 11, color: type.onSurfaceColor),
      ),
    );
  }
}

class _MockShoppingItem {
  final String name;
  final String amount;
  final bool checked;
  const _MockShoppingItem(this.name, this.amount, this.checked);
}

class ShoppingListIllustration extends StatelessWidget {
  const ShoppingListIllustration({super.key});

  static const _items = [
    _MockShoppingItem('Tomato', '500 g', true),
    _MockShoppingItem('Chicken breast', '600 g', true),
    _MockShoppingItem('Milk', '1 l', false),
    _MockShoppingItem('Rice', '1 kg', false),
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: 210,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final item in _items) ...[
                Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: item.checked ? AppColors.primaryDark : Colors.transparent,
                        border: Border.all(
                          color: item.checked ? AppColors.primaryDark : Colors.grey[400]!,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: item.checked ? const Icon(Icons.check, size: 11, color: Colors.white) : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          decoration: item.checked ? TextDecoration.lineThrough : null,
                          color: item.checked ? Colors.grey[400] : const Color(0xFF1A1C19),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: item.checked ? Colors.grey[100] : AppColors.surfaceSoft,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item.amount,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: item.checked ? Colors.grey[400] : AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
                if (item != _items.last) const SizedBox(height: 10),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
