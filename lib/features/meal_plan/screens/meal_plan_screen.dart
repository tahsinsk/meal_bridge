import 'package:flutter/material.dart';

import '../../../models/recipe.dart';
import '../../../models/planned_recipe.dart';
import '../../../models/meal_type.dart';

class MealPlanScreen extends StatelessWidget {
  final List<Recipe> recipes;
  final Map<String, PlannedRecipe> plannedRecipes;
  final void Function(String day, Recipe recipe, [MealType? mealType])
  onRecipeSelected;
  final void Function(String day, [MealType? mealType]) onRecipeRemoved;

  const MealPlanScreen({
    super.key,
    required this.recipes,
    required this.plannedRecipes,
    required this.onRecipeSelected,
    required this.onRecipeRemoved,
  });

  static const List<String> _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static const List<MealType> _mealTypes = [
    MealType.breakfast,
    MealType.lunch,
    MealType.dinner,
  ];

  String _mealPlanKey(String day, [MealType? mealType]) {
    if (mealType == null) {
      return day;
    }

    return '$day-${mealType.name}';
  }

  void _selectRecipeForDay(
    BuildContext context,
    String day, [
    MealType? mealType,
  ]) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                mealType == null
                    ? 'Select recipe for $day'
                    : 'Select ${mealType.label.toLowerCase()} for $day',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              if (recipes.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'No recipes yet. Add a recipe first, then come back to plan your week.',
                    ),
                  ),
                ),
              ...recipes.map(
                (recipe) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.restaurant_menu),
                    title: Text(recipe.name),
                    subtitle: Text(
                      '${recipe.category} • ${recipe.servings} servings • ${recipe.ingredients.length} ingredients',
                    ),
                    trailing: const Icon(Icons.add_circle_outline),
                    onTap: () {
                      onRecipeSelected(day, recipe, mealType);
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showMealTypePicker(BuildContext context, String day) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Plan meal for $day',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              ..._mealTypes.map((mealType) {
                final plannedRecipe = plannedRecipes[_mealPlanKey(
                  day,
                  mealType,
                )];

                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.schedule_outlined),
                    title: Text(mealType.label),
                    subtitle: Text(
                      plannedRecipe == null
                          ? 'Choose a recipe for this meal'
                          : 'Current: ${plannedRecipe.recipe.name}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).pop();
                      _selectRecipeForDay(context, day, mealType);
                    },
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final plannedDayCount = _days.where((day) {
      final hasLegacyPlan = plannedRecipes.containsKey(_mealPlanKey(day));
      final hasMealSlotPlan = _mealTypes.any(
        (mealType) => plannedRecipes.containsKey(_mealPlanKey(day, mealType)),
      );

      return hasLegacyPlan || hasMealSlotPlan;
    }).length;
    final plannedMealCount = plannedRecipes.length;
    final hasPlannedRecipes = plannedDayCount > 0;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_month_outlined),
                    const SizedBox(width: 8),
                    Text(
                      'Weekly plan summary',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('$plannedDayCount of ${_days.length} day(s) planned'),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: plannedDayCount / _days.length,
                ),
                const SizedBox(height: 8),
                Text(
                  hasPlannedRecipes
                      ? 'Tap a day to add breakfast, lunch, or dinner.'
                      : 'Start by tapping a day and planning a meal.',
                ),
                if (hasPlannedRecipes) ...[
                  const SizedBox(height: 8),
                  Text(
                    '$plannedMealCount meal slot(s) planned in total',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _mealTypes
                      .map(
                        (mealType) => Chip(
                          avatar: const Icon(Icons.schedule_outlined, size: 18),
                          label: Text(mealType.label),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ..._days.map((day) {
          final plannedRecipe = plannedRecipes[_mealPlanKey(day)];
          final recipe = plannedRecipe?.recipe;
          final plannedMealEntries = _mealTypes
              .map(
                (mealType) => MapEntry(
                  mealType,
                  plannedRecipes[_mealPlanKey(day, mealType)],
                ),
              )
              .where((entry) => entry.value != null)
              .toList();
          final isDayPlanned =
              plannedRecipe != null || plannedMealEntries.isNotEmpty;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _showMealTypePicker(context, day),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isDayPlanned
                              ? Icons.check_circle_outline
                              : Icons.calendar_today_outlined,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                day,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isDayPlanned
                                    ? plannedRecipe == null
                                          ? '${plannedMealEntries.length} meal(s) planned'
                                          : 'Planned'
                                    : 'Not planned',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (plannedRecipe == null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (plannedMealEntries.isEmpty)
                            Row(
                              children: [
                                const Icon(Icons.add_circle_outline, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'No meals planned yet. Tap to plan breakfast, lunch, or dinner.',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                ),
                              ],
                            )
                          else
                            ...plannedMealEntries.map((entry) {
                              final mealType = entry.key;
                              final plannedMealRecipe = entry.value!.recipe;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.schedule_outlined,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        '${mealType.label}: ${plannedMealRecipe.name}',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () =>
                                          onRecipeRemoved(day, mealType),
                                      icon: const Icon(Icons.close),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  _showMealTypePicker(context, day),
                              icon: const Icon(Icons.schedule_outlined),
                              label: Text(
                                plannedMealEntries.isEmpty
                                    ? 'Plan meal'
                                    : plannedMealEntries.length ==
                                          _mealTypes.length
                                    ? 'Edit meals'
                                    : 'Add another meal',
                              ),
                            ),
                          ),
                        ],
                      )
                    else ...[
                      Text(
                        recipe!.name,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Chip(
                            avatar: const Icon(Icons.restaurant_menu, size: 18),
                            label: Text(recipe.category),
                          ),
                          Chip(
                            avatar: const Icon(Icons.people_outline, size: 18),
                            label: Text('${recipe.servings} base servings'),
                          ),
                          Chip(
                            avatar: const Icon(Icons.scale_outlined, size: 18),
                            label: Text(
                              '${plannedRecipe.targetServings} target servings',
                            ),
                          ),
                          Chip(
                            avatar: const Icon(Icons.list_alt, size: 18),
                            label: Text(
                              '${recipe.ingredients.length} ingredients',
                            ),
                          ),
                          Chip(
                            avatar: const Icon(
                              Icons.format_list_numbered,
                              size: 18,
                            ),
                            label: Text('${recipe.instructions.length} steps'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () => onRecipeRemoved(day),
                          icon: const Icon(Icons.close),
                          label: const Text('Remove'),
                        ),
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
