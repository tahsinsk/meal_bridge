import 'package:flutter/material.dart';

import '../../../models/meal_type.dart';
import '../../../models/planned_recipe.dart';
import '../../../models/recipe.dart';

class MealPlanScreen extends StatelessWidget {
  final List<Recipe> recipes;
  final Map<String, PlannedRecipe> plannedRecipes;
  final void Function(String day, Recipe recipe, [MealType? mealType]) onRecipeSelected;
  final void Function(String day, [MealType? mealType]) onRecipeRemoved;
  final void Function(String day, MealType? mealType, int delta) onServingsChanged;

  const MealPlanScreen({
    super.key,
    required this.recipes,
    required this.plannedRecipes,
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

  String _mealPlanKey(String day, [MealType? mealType]) {
    if (mealType == null) return day;
    return '$day-${mealType.name}';
  }

  IconData _mealIcon(MealType mealType) {
    switch (mealType) {
      case MealType.breakfast:
        return Icons.wb_sunny_outlined;
      case MealType.lunch:
        return Icons.wb_cloudy_outlined;
      case MealType.dinner:
        return Icons.nightlight_outlined;
    }
  }

  Color _mealColor(MealType mealType) {
    switch (mealType) {
      case MealType.breakfast:
        return const Color(0xFFF57F17);
      case MealType.lunch:
        return const Color(0xFF1565C0);
      case MealType.dinner:
        return const Color(0xFF4527A0);
    }
  }

  Color _mealBgColor(MealType mealType) {
    switch (mealType) {
      case MealType.breakfast:
        return const Color(0xFFFFF8E1);
      case MealType.lunch:
        return const Color(0xFFE3F2FD);
      case MealType.dinner:
        return const Color(0xFFEDE7F6);
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
                                  child: const Icon(Icons.restaurant_menu_outlined, color: Color(0xFF2E7D32), size: 20),
                                ),
                                title: Text(recipe.name),
                                subtitle: Text('${recipe.category} • ${recipe.servings} servings'),
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

  void _showMealTypePicker(BuildContext context, String day) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Plan meal for $day', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                ..._mealTypes.map((mealType) {
                  final plannedRecipe = plannedRecipes[_mealPlanKey(day, mealType)];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _mealBgColor(mealType),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(_mealIcon(mealType), color: _mealColor(mealType), size: 20),
                      ),
                      title: Text(mealType.label),
                      subtitle: Text(
                        plannedRecipe == null
                            ? 'Not planned'
                            : plannedRecipe.recipe.name,
                      ),
                      trailing: Icon(
                        plannedRecipe == null ? Icons.add_circle_outline : Icons.edit_outlined,
                        color: const Color(0xFF2E7D32),
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        _selectRecipeForDay(context, day, mealType);
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _servingsControl(BuildContext context, String day, MealType? mealType, PlannedRecipe plannedRecipe) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF4F9F1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2E7D32).withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: plannedRecipe.targetServings > 1
                ? () => onServingsChanged(day, mealType, -1)
                : null,
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Icon(
                Icons.remove,
                size: 16,
                color: plannedRecipe.targetServings > 1
                    ? const Color(0xFF2E7D32)
                    : Colors.grey,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '${plannedRecipe.targetServings}',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFF2E7D32),
              ),
            ),
          ),
          InkWell(
            onTap: plannedRecipe.targetServings < 20
                ? () => onServingsChanged(day, mealType, 1)
                : null,
            borderRadius: const BorderRadius.horizontal(right: Radius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Icon(
                Icons.add,
                size: 16,
                color: plannedRecipe.targetServings < 20
                    ? const Color(0xFF2E7D32)
                    : Colors.grey,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Text(
              'servings',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
        ],
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
        // Summary kartı — modernize edilmiş
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
                                    ? 'Full week planned! 🎉'
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
                    // Gün göstergeleri
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
                    'Tap any day below to start planning.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Gün kartları
        ..._days.map((day) {
          final plannedRecipe = plannedRecipes[_mealPlanKey(day)];
          final plannedMealEntries = _mealTypes
              .map((m) => MapEntry(m, plannedRecipes[_mealPlanKey(day, m)]))
              .where((e) => e.value != null)
              .toList();
          final isDayPlanned = plannedRecipe != null || plannedMealEntries.isNotEmpty;

          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _showMealTypePicker(context, day),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Gün başlığı
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isDayPlanned
                                ? const Color(0xFF2E7D32)
                                : const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            isDayPlanned
                                ? Icons.check_rounded
                                : Icons.calendar_today_outlined,
                            size: 18,
                            color: isDayPlanned ? Colors.white : const Color(0xFF2E7D32),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(day, style: Theme.of(context).textTheme.titleSmall),
                              Text(
                                isDayPlanned
                                    ? plannedMealEntries.isNotEmpty
                                        ? '${plannedMealEntries.length} meal${plannedMealEntries.length != 1 ? 's' : ''} planned'
                                        : 'Planned'
                                    : 'Tap to plan',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: isDayPlanned
                                      ? const Color(0xFF2E7D32)
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.add_circle_outline,
                          color: isDayPlanned
                              ? const Color(0xFF2E7D32)
                              : Colors.grey[400],
                          size: 20,
                        ),
                      ],
                    ),

                    // Planlanan öğünler
                    if (plannedMealEntries.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      const Divider(height: 1),
                      const SizedBox(height: 10),
                      ...plannedMealEntries.map((entry) {
                        final mealType = entry.key;
                        final pr = entry.value!;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: _mealBgColor(mealType),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(_mealIcon(mealType), size: 15, color: _mealColor(mealType)),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      pr.recipe.name,
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                    ),
                                    const SizedBox(height: 4),
                                    _servingsControl(context, day, mealType, pr),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () => onRecipeRemoved(day, mealType),
                                icon: const Icon(Icons.close, size: 16),
                                style: IconButton.styleFrom(
                                  backgroundColor: const Color(0xFFF5F5F5),
                                  minimumSize: const Size(28, 28),
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],

                    // Legacy planned recipe
                    if (plannedRecipe != null && plannedMealEntries.isEmpty) ...[
                      const SizedBox(height: 10),
                      const Divider(height: 1),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.restaurant_menu_outlined, size: 15, color: Color(0xFF2E7D32)),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  plannedRecipe.recipe.name,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 4),
                                _servingsControl(context, day, null, plannedRecipe),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => onRecipeRemoved(day),
                            icon: const Icon(Icons.close, size: 16),
                            style: IconButton.styleFrom(
                              backgroundColor: const Color(0xFFF5F5F5),
                              minimumSize: const Size(28, 28),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}