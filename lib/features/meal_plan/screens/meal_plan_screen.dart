import 'package:flutter/material.dart';

import '../../../models/recipe.dart';

class MealPlanScreen extends StatelessWidget {
  final List<Recipe> recipes;
  final Map<String, Recipe> plannedRecipes;
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
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _days.length,
      itemBuilder: (context, index) {
        final day = _days[index];
        final plannedRecipe = plannedRecipes[day];

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
                      const Icon(Icons.calendar_today_outlined),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          day,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      if (plannedRecipe == null)
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          tooltip: 'Select recipe',
                          onPressed: () => _selectRecipeForDay(context, day),
                        )
                      else
                        IconButton(
                          icon: const Icon(Icons.close),
                          tooltip: 'Remove recipe',
                          onPressed: () => onRecipeRemoved(day),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (plannedRecipe == null)
                    Text(
                      'No recipe selected yet. Tap to choose one.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    )
                  else ...[
                    Text(
                      plannedRecipe.name,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Chip(
                          avatar: const Icon(Icons.restaurant_menu, size: 18),
                          label: Text(plannedRecipe.category),
                        ),
                        Chip(
                          avatar: const Icon(Icons.people_outline, size: 18),
                          label: Text('${plannedRecipe.servings} servings'),
                        ),
                        Chip(
                          avatar: const Icon(Icons.list_alt, size: 18),
                          label: Text(
                            '${plannedRecipe.ingredients.length} ingredients',
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
      },
    );
  }
}
