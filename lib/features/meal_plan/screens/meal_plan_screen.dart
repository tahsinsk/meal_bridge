import 'package:flutter/material.dart';

import '../../../models/meal_type.dart';
import '../../../models/planned_recipe.dart';
import '../../../models/recipe.dart';

class MealPlanScreen extends StatelessWidget {
  final List<Recipe> recipes;
  final Map<String, PlannedRecipe> plannedRecipes;
  final int weekOffset;
  final void Function(int) onWeekChanged;
  final void Function(String day, Recipe recipe, [MealType? mealType]) onRecipeSelected;
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

  IconData _mealIcon(MealType mealType) {
    switch (mealType) {
      case MealType.breakfast: return Icons.free_breakfast_outlined;
      case MealType.lunch:     return Icons.set_meal_outlined;
      case MealType.dinner:    return Icons.dinner_dining_outlined;
    }
  }

  Color _mealColor(MealType mealType) {
    switch (mealType) {
      case MealType.breakfast: return const Color(0xFFBF360C);
      case MealType.lunch:     return const Color(0xFF1565C0);
      case MealType.dinner:    return const Color(0xFF4527A0);
    }
  }

  Color _mealBgColor(MealType mealType) {
    switch (mealType) {
      case MealType.breakfast: return const Color(0xFFFFF3E0);
      case MealType.lunch:     return const Color(0xFFE3F2FD);
      case MealType.dinner:    return const Color(0xFFEDE7F6);
    }
  }

  void _selectRecipeForDay(BuildContext context, String day, [MealType? mealType]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      if (mealType != null) ...[
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: _mealBgColor(mealType),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(_mealIcon(mealType), color: _mealColor(mealType), size: 20),
                        ),
                        const SizedBox(width: 10),
                      ],
                      Expanded(
                        child: Text(
                          mealType == null
                              ? 'Select recipe for $day'
                              : '${mealType.label} for $day',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: recipes.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text('No recipes yet. Add a recipe first.'),
                          ),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.all(8),
                          itemCount: recipes.length,
                          itemBuilder: (context, index) {
                            final recipe = recipes[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F5E9),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.restaurant_menu_outlined,
                                      color: Color(0xFF2E7D32), size: 20),
                                ),
                                title: Text(recipe.name),
                                subtitle: Text('${recipe.category} · ${recipe.servings} servings'),
                                trailing: const Icon(Icons.add_circle_outline, color: Color(0xFF2E7D32)),
                                onTap: () {
                                  onRecipeSelected(day, recipe, mealType);
                                  Navigator.of(context).pop();
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildMiniStepper(BuildContext context, String day, MealType? mealType, PlannedRecipe pr) {
    final color = mealType != null ? _mealColor(mealType) : const Color(0xFF2E7D32);
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
    final bg = _mealBgColor(mealType);
    final iconColor = _mealColor(mealType);
    final isPlanned = pr != null;

    return GestureDetector(
      onTap: isPlanned ? null : () => _selectRecipeForDay(context, day, mealType),
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
              Icon(_mealIcon(mealType), size: 18, color: iconColor),
              const SizedBox(width: 8),
              Expanded(
                child: isPlanned
                    ? Column(
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
                            '${pr.recipe.ingredients.length} ingredients',
                            style: TextStyle(fontSize: 11, color: iconColor.withValues(alpha: 0.7)),
                          ),
                        ],
                      )
                    : Text(
                        'Add ${mealType.label}',
                        style: TextStyle(
                          fontSize: 13,
                          color: iconColor.withValues(alpha: 0.6),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
              ),
              if (isPlanned) ...[
                _buildMiniStepper(context, day, mealType, pr),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => onRecipeRemoved(day, mealType),
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close, size: 13, color: iconColor),
                  ),
                ),
              ] else
                Icon(Icons.add, size: 16, color: iconColor.withValues(alpha: 0.5)),
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
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        child: Row(
          children: [
            const Icon(Icons.restaurant_menu_outlined, size: 18, color: Color(0xFF2E7D32)),
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
                    '${pr.recipe.ingredients.length} ingredients',
                    style: TextStyle(fontSize: 11, color: const Color(0xFF2E7D32).withValues(alpha: 0.7)),
                  ),
                ],
              ),
            ),
            _buildMiniStepper(context, day, null, pr),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () => onRecipeRemoved(day),
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 13, color: Color(0xFF2E7D32)),
              ),
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
    final mealsPlanned = mealEntries.length + (legacyPr != null && mealEntries.isEmpty ? 1 : 0);
    final isDayPlanned = mealsPlanned > 0;

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
            ? const BorderSide(color: Color(0xFF2E7D32), width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day header row
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
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
                            color: isToday ? const Color(0xFF2E7D32) : null,
                          ),
                        ),
                        if (isToday) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E7D32),
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
                const Spacer(),
                if (isDayPlanned)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$mealsPlanned meal${mealsPlanned != 1 ? 's' : ''}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
    final plannedDayCount = _days.where((day) {
      return plannedRecipes.containsKey(_mealPlanKey(day)) ||
          _mealTypes.any((m) => plannedRecipes.containsKey(_mealPlanKey(day, m)));
    }).length;
    final plannedMealCount = plannedRecipes.length;
    final progress = plannedDayCount / _days.length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Week navigation
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => onWeekChanged(weekOffset - 1),
                  color: const Color(0xFF2E7D32),
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
                  color: const Color(0xFF2E7D32),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Summary card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plannedDayCount == 0
                                ? 'Nothing planned yet'
                                : plannedDayCount == 7
                                    ? 'Full week planned!'
                                    : '$plannedDayCount of 7 days planned',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          if (plannedMealCount > 0) ...[
                            const SizedBox(height: 2),
                            Text(
                              '$plannedMealCount meal${plannedMealCount != 1 ? 's' : ''} total',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ],
                      ),
                    ),
                    Row(
                      children: _days.map((day) {
                        final hasAny = plannedRecipes.containsKey(_mealPlanKey(day)) ||
                            _mealTypes.any((m) => plannedRecipes.containsKey(_mealPlanKey(day, m)));
                        return Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 4),
                          decoration: BoxDecoration(
                            color: hasAny ? const Color(0xFF2E7D32) : const Color(0xFFE8F5E9),
                            shape: BoxShape.circle,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: const Color(0xFFE8F5E9),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      plannedDayCount == 7
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFF66BB6A),
                    ),
                  ),
                ),
                if (plannedDayCount == 0) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Tap "Add breakfast/lunch/dinner" on any day to start.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
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
