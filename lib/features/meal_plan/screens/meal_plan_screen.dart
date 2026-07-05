import 'package:flutter/material.dart';

import '../../../models/meal_type.dart';
import '../../../models/planned_recipe.dart';
import '../../../models/recipe.dart';
import '../../../shared/app_constants.dart';
import '../../../shared/meal_type_style.dart';
import 'add_to_plan_sheet.dart';

class MealPlanScreen extends StatelessWidget {
  final List<Recipe> recipes;
  final Map<String, PlannedRecipe> plannedRecipes;
  final int weekOffset;
  final void Function(int) onWeekChanged;
  final void Function(String day, Recipe recipe, int servings, [MealType? mealType]) onRecipeSelected;
  final void Function(String day, [MealType? mealType]) onRecipeRemoved;
  final void Function(String day, MealType? mealType, int delta) onServingsChanged;

  const MealPlanScreen({
    super.key,
    required this.recipes,
    required this.plannedRecipes,
    required this.weekOffset,
    required this.onWeekChanged,
    required this.onRecipeSelected,
    required this.onRecipeRemoved,
    required this.onServingsChanged,
  });

  static const List<String> _days = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
  ];

  static const List<MealType> _mealTypes = [
    MealType.breakfast, MealType.lunch, MealType.dinner,
  ];

  static DateTime _mondayForOffset(int offset) {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return monday.add(Duration(days: 7 * offset));
  }

  static String _shortDate(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[d.month - 1]} ${d.day}';
  }

  static String _weekLabel(int offset) {
    switch (offset) {
      case -1: return 'Last week';
      case 0:  return 'This week';
      case 1:  return 'Next week';
      default:
        final monday = _mondayForOffset(offset);
        final sunday = monday.add(const Duration(days: 6));
        return '${_shortDate(monday)} – ${_shortDate(sunday)}';
    }
  }

  static String _weekDateRange(int offset) {
    final monday = _mondayForOffset(offset);
    final sunday = monday.add(const Duration(days: 6));
    return '${_shortDate(monday)} – ${_shortDate(sunday)}';
  }

  String _dayDate(String day) {
    final monday = _mondayForOffset(weekOffset);
    final date = monday.add(Duration(days: _days.indexOf(day)));
    return _shortDate(date);
  }

  String _mealPlanKey(String day, [MealType? mealType]) {
    if (mealType == null) return day;
    return '$day-${mealType.name}';
  }

  String _recipeMetaInfo(Recipe recipe) {
    if (recipe.calories != null) {
      return '${(recipe.calories! / recipe.servings).round()} kcal/serving';
    }
    return '${recipe.ingredients.length} ingredients';
  }

  void _openAddToPlanSheet(BuildContext context, String day, MealType mealType) {
    showAddToPlanSheet(
      context,
      recipes: recipes,
      day: day,
      mealType: mealType,
      onAdd: (recipe, servings) => onRecipeSelected(day, recipe, servings, mealType),
    );
  }

  Widget _buildMiniStepper(BuildContext context, String day, MealType? mealType, PlannedRecipe pr, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: pr.targetServings > 1
              ? () => onServingsChanged(day, mealType, -1)
              : null,
          child: Icon(
            Icons.remove_circle_outline,
            size: 18,
            color: pr.targetServings > 1 ? color : Colors.grey[300],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(
            '${pr.targetServings}',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color),
          ),
        ),
        GestureDetector(
          onTap: pr.targetServings < 20
              ? () => onServingsChanged(day, mealType, 1)
              : null,
          child: Icon(
            Icons.add_circle_outline,
            size: 18,
            color: pr.targetServings < 20 ? color : Colors.grey[300],
          ),
        ),
      ],
    );
  }

  Widget _buildMealRow(BuildContext context, String day, MealType mealType) {
    final pr = plannedRecipes[_mealPlanKey(day, mealType)];
    final bg = mealType.surfaceColor;
    final onBg = mealType.onSurfaceColor;
    final isPlanned = pr != null;

    return GestureDetector(
      onTap: isPlanned ? null : () => _openAddToPlanSheet(context, day, mealType),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          child: Row(
            children: [
              Icon(mealType.icon, size: 18, color: onBg),
              const SizedBox(width: 8),
              Expanded(
                child: isPlanned
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pr.recipe.name,
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: onBg),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 1),
                          Text(
                            _recipeMetaInfo(pr.recipe),
                            style: TextStyle(fontSize: 11, color: onBg.withValues(alpha: 0.75)),
                          ),
                        ],
                      )
                    : Text(
                        'Add ${mealType.label}',
                        style: TextStyle(
                          fontSize: 13,
                          color: onBg.withValues(alpha: 0.7),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
              ),
              if (isPlanned) ...[
                _buildMiniStepper(context, day, mealType, pr, onBg),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => onRecipeRemoved(day, mealType),
                  child: Icon(Icons.close, size: 16, color: onBg.withValues(alpha: 0.45)),
                ),
              ] else
                Icon(Icons.add, size: 16, color: onBg.withValues(alpha: 0.5)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegacyMealRow(BuildContext context, String day, PlannedRecipe pr) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        child: Row(
          children: [
            const Icon(Icons.restaurant_menu_outlined, size: 18, color: AppColors.primaryDark),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pr.recipe.name,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),
                  Text(
                    _recipeMetaInfo(pr.recipe),
                    style: TextStyle(fontSize: 11, color: AppColors.primaryDark.withValues(alpha: 0.7)),
                  ),
                ],
              ),
            ),
            _buildMiniStepper(context, day, null, pr, AppColors.primaryDark),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => onRecipeRemoved(day),
              child: Icon(Icons.close, size: 16, color: AppColors.primaryDark.withValues(alpha: 0.45)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayCard(BuildContext context, String day) {
    final legacyPr = plannedRecipes[_mealPlanKey(day)];
    final mealEntries = _mealTypes
        .map((m) => MapEntry(m, plannedRecipes[_mealPlanKey(day, m)]))
        .where((e) => e.value != null)
        .toList();

    // Highlight today's card
    final monday = _mondayForOffset(weekOffset);
    final dayDate = monday.add(Duration(days: _days.indexOf(day)));
    final today = DateTime.now();
    final isToday = weekOffset == 0 &&
        dayDate.year == today.year &&
        dayDate.month == today.month &&
        dayDate.day == today.day;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isToday
            ? const BorderSide(color: AppColors.primaryDark, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day header
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      day,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: isToday ? AppColors.primaryDark : null,
                      ),
                    ),
                    if (isToday) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryDark,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Today',
                          style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  _dayDate(day),
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Meal rows
            ..._mealTypes.map((mealType) => _buildMealRow(context, day, mealType)),

            // Legacy planned recipe (no mealType) — only shown if no typed meals
            if (legacyPr != null && mealEntries.isEmpty)
              _buildLegacyMealRow(context, day, legacyPr),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Week navigation + general add
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => onWeekChanged(weekOffset - 1),
                  color: AppColors.primaryDark,
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _weekLabel(weekOffset),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                      if (weekOffset.abs() <= 1)
                        Text(
                          _weekDateRange(weekOffset),
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => onWeekChanged(weekOffset + 1),
                  color: AppColors.primaryDark,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Day cards
        ..._days.map((day) => _buildDayCard(context, day)),
      ],
    );
  }
}
