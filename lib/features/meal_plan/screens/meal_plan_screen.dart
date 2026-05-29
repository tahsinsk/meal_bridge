import 'package:flutter/material.dart';

import '../../../models/recipe.dart';
import '../../../models/planned_recipe.dart';
import '../../../models/meal_type.dart';

class MealPlanScreen extends StatelessWidget {
  final List<Recipe> recipes;
  final Map<String, PlannedRecipe> plannedRecipes;
  final void Function(String day, Recipe recipe) onRecipeSelected;
  final void Function(String day) onRecipeRemoved;

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

  void _selectRecipeForDay(BuildContext context, String day) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Select recipe for $day',
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
                      onRecipeSelected(day, recipe);
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

  @override
  Widget build(BuildContext context) {
    final plannedRecipeCount = plannedRecipes.length;
    final hasPlannedRecipes = plannedRecipeCount > 0;

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
                Text('$plannedRecipeCount of ${_days.length} day(s) planned'),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: plannedRecipeCount / _days.length,
                ),
                const SizedBox(height: 8),
                Text(
                  hasPlannedRecipes
                      ? 'Tap a planned day to change its recipe or remove it.'
                      : 'Start by tapping a day and selecting one of your recipes.',
                ),
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
          final plannedRecipe = plannedRecipes[day];
          final recipe = plannedRecipe?.recipe;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _selectRecipeForDay(context, day),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          plannedRecipe == null
                              ? Icons.calendar_today_outlined
                              : Icons.check_circle_outline,
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
                                plannedRecipe == null
                                    ? 'Not planned'
                                    : 'Planned',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (plannedRecipe == null)
                      Row(
                        children: [
                          const Icon(Icons.add_circle_outline, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'No recipe selected yet. Tap to choose one.',
                              style: Theme.of(context).textTheme.bodyMedium,
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
