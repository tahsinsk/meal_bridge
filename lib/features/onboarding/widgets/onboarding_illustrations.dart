import 'package:flutter/material.dart';

import '../../../models/meal_type.dart';
import '../../../shared/app_constants.dart';
import '../../../shared/meal_type_style.dart';

/// Small "preview of the real app" mock-ups used on each onboarding page —
/// built from the same cards/colors/radii/icons as the actual screens
/// instead of a plain icon, so onboarding reads as a glimpse of the product
/// itself rather than generic marketing art.

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
                child: Icon(Icons.photo_camera_outlined, size: 32, color: AppColors.primaryDark),
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
                  Row(
                    children: [
                      const Icon(Icons.local_fire_department, size: 11, color: Color(0xFFFF7043)),
                      const SizedBox(width: 3),
                      Container(
                        height: 8,
                        width: 56,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF1EE),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
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

/// AI generation + photo scan — the two "skip the typing" entry points,
/// shown as a pair of option chips (mirroring the app's real add-recipe
/// choice sheet) feeding into the same kind of recipe card as page one.
class AiRecipeIllustration extends StatelessWidget {
  const AiRecipeIllustration({super.key});

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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const _ModeBadge(icon: Icons.auto_awesome_outlined),
                  const SizedBox(width: 10),
                  Text('or', style: TextStyle(fontSize: 11, color: Colors.grey[500], fontStyle: FontStyle.italic)),
                  const SizedBox(width: 10),
                  const _ModeBadge(icon: Icons.document_scanner_outlined),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 10,
                    width: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3E7E1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 8,
                    width: 96,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF1EE),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
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

class _ModeBadge extends StatelessWidget {
  final IconData icon;
  const _ModeBadge({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6)],
      ),
      child: Icon(icon, size: 19, color: AppColors.primaryDark),
    );
  }
}

/// Week navigator + meal slots — mirrors the real Plan screen's week-nav
/// row (chevrons either side of the current week) above a strip of days,
/// each slot colored by plan STATE (filled = darker "dinner" tone, still
/// empty = lighter "lunch" tone) exactly like the real app, not by which
/// meal it is — so this doubles as an accurate preview of that behavior.
class WeekStripIllustration extends StatelessWidget {
  const WeekStripIllustration({super.key});

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu'];
  // Which meal types are already planned per day, left to right — a
  // plausible, partially-filled week so the "state, not meal type" color
  // rule is visible at a glance (Monday fully planned, Thursday untouched).
  static const _plannedByDay = [
    {MealType.breakfast, MealType.lunch, MealType.dinner},
    {MealType.breakfast, MealType.lunch},
    {MealType.breakfast},
    <MealType>{},
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 14, 10, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chevron_left, size: 18, color: Colors.grey[400]),
                const SizedBox(width: 10),
                const Text(
                  'This week',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
                ),
                const SizedBox(width: 10),
                Icon(Icons.chevron_right, size: 18, color: Colors.grey[400]),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < _days.length; i++) ...[
                  Column(
                    children: [
                      Text(
                        _days[i],
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey[500]),
                      ),
                      const SizedBox(height: 8),
                      _mealDot(MealType.breakfast, _plannedByDay[i].contains(MealType.breakfast)),
                      const SizedBox(height: 5),
                      _mealDot(MealType.lunch, _plannedByDay[i].contains(MealType.lunch)),
                      const SizedBox(height: 5),
                      _mealDot(MealType.dinner, _plannedByDay[i].contains(MealType.dinner)),
                    ],
                  ),
                  if (i != _days.length - 1) const SizedBox(width: 12),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _mealDot(MealType type, bool planned) {
    final bg = planned ? MealType.dinner.surfaceColor : MealType.lunch.surfaceColor;
    final fg = planned ? MealType.dinner.onSurfaceColor : MealType.lunch.onSurfaceColor;
    return Container(
      width: 28,
      height: 18,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: Icon(type.icon, size: 11, color: fg),
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

/// Combined shopping checklist plus a row of store shortcuts — neutral
/// send/shortcut badges (not any real store's branding) so the preview
/// covers both the auto-built list and the one-tap store links in one card.
class ShoppingListIllustration extends StatelessWidget {
  const ShoppingListIllustration({super.key});

  static const _items = [
    _MockShoppingItem('Tomato', '500 g', true),
    _MockShoppingItem('Chicken breast', '600 g', true),
    _MockShoppingItem('Milk', '1 l', false),
  ];

  static const _shortcutCount = 3;

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
                const SizedBox(height: 10),
              ],
              const Divider(height: 1),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.storefront_outlined, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 6),
                  Text(
                    'Shop at',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey[500]),
                  ),
                  const Spacer(),
                  for (var i = 0; i < _shortcutCount; i++) ...[
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSoft,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Center(
                        child: Icon(Icons.send_rounded, size: 12, color: AppColors.primaryDark),
                      ),
                    ),
                    if (i != _shortcutCount - 1) const SizedBox(width: 5),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
