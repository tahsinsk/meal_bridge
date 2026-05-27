import 'package:flutter/material.dart';

import '../../../models/recipe.dart';
import 'recipe_detail_screen.dart';
import 'recipe_form_screen.dart';

class RecipeListScreen extends StatelessWidget {
  final List<Recipe> recipes;
  final bool Function(Recipe recipe) canDeleteRecipe;
  final ValueChanged<Recipe> onRecipeAdded;
  final ValueChanged<Recipe> onRecipeUpdated;
  final ValueChanged<Recipe> onRecipeDeleted;

  const RecipeListScreen({
    super.key,
    required this.recipes,
    required this.canDeleteRecipe,
    required this.onRecipeAdded,
    required this.onRecipeUpdated,
    required this.onRecipeDeleted,
  });

  Future<void> _openAddRecipeScreen(BuildContext context) async {
    final newRecipe = await Navigator.of(context).push<Recipe>(
      MaterialPageRoute(
        builder: (context) => const RecipeFormScreen(),
      ),
    );

    if (newRecipe != null) {
      onRecipeAdded(newRecipe);
    }
  }

  Future<void> _openEditRecipeScreen(
    BuildContext context,
    Recipe recipe,
  ) async {
    final updatedRecipe = await Navigator.of(context).push<Recipe>(
      MaterialPageRoute(
        builder: (context) => RecipeFormScreen(initialRecipe: recipe),
      ),
    );

    if (updatedRecipe != null) {
      onRecipeUpdated(updatedRecipe);
    }
  }

  Future<void> _confirmDeleteRecipe(
    BuildContext context,
    Recipe recipe,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete recipe?'),
          content: Text('Are you sure you want to delete "${recipe.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      onRecipeDeleted(recipe);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
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
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (canDeleteRecipe(recipe))
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: 'Edit recipe',
                      onPressed: () => _openEditRecipeScreen(context, recipe),
                    ),
                  if (canDeleteRecipe(recipe))
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      tooltip: 'Delete recipe',
                      onPressed: () => _confirmDeleteRecipe(context, recipe),
                    ),
                  const Icon(Icons.chevron_right),
                ],
              ),
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddRecipeScreen(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Recipe'),
      ),
    );
  }
}
