import 'package:flutter/material.dart';
import 'recipe_detail_screen.dart';

import '../../../data/sample_recipes.dart';

class RecipeListScreen extends StatelessWidget {
  const RecipeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final recipes = sampleRecipes;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const Icon(Icons.restaurant),
            title: Text(recipe.name),
            subtitle: Text(
              '${recipe.category} • ${recipe.servings} servings • ${recipe.ingredients.length} ingredients',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => RecipeDetailScreen(recipe: recipe),
    ),
  );
},
          ),
        );
      },
    );
  }
}