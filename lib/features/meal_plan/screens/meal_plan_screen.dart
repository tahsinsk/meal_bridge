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
                    leading: const Icon(Icons.restaurant),
                    title: Text(recipe.name),
                    subtitle: Text(
                      '${recipe.category} • ${recipe.servings} servings',
                    ),
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
          child: ListTile(
            leading: const Icon(Icons.calendar_today),
            title: Text(day),
            subtitle: Text(
              plannedRecipe == null ? 'No recipe selected' : plannedRecipe.name,
            ),
            trailing: plannedRecipe == null
                ? IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _selectRecipeForDay(context, day),
                  )
                : IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => onRecipeRemoved(day),
                  ),
            onTap: () => _selectRecipeForDay(context, day),
          ),
        );
      },
    );
  }
}
