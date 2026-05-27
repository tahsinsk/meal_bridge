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
    var searchQuery = '';
    return Scaffold(
      body: StatefulBuilder(
        builder: (context, setSearchState) {
          final filteredRecipes = recipes.where((recipe) {
            final query = searchQuery.trim().toLowerCase();

            if (query.isEmpty) {
              return true;
            }

            return recipe.name.toLowerCase().contains(query) ||
                recipe.category.toLowerCase().contains(query);
          }).toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredRecipes.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Search recipes',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setSearchState(() {
                        searchQuery = value;
                      });
                    },
                  ),
                );
              }

              if (filteredRecipes.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No recipes found.'),
                  ),
                );
              }

              final recipe = filteredRecipes[index - 1];
              final isCustomRecipe = canDeleteRecipe(recipe);

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => RecipeDetailScreen(recipe: recipe),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.restaurant_menu),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                recipe.name,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(recipe.category),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Chip(
                          avatar: const Icon(Icons.people_outline, size: 18),
                          label: Text('${recipe.servings} servings'),
                        ),
                        Chip(
                          avatar: const Icon(Icons.list_alt, size: 18),
                          label: Text('${recipe.ingredients.length} ingredients'),
                        ),
                        Chip(
                          avatar: Icon(
                            isCustomRecipe
                                ? Icons.edit_note
                                : Icons.verified_outlined,
                            size: 18,
                          ),
                          label: Text(isCustomRecipe ? 'Custom' : 'Sample'),
                        ),
                      ],
                    ),
                    if (isCustomRecipe) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () => _openEditRecipeScreen(context, recipe),
                            icon: const Icon(Icons.edit_outlined),
                            label: const Text('Edit'),
                          ),
                          TextButton.icon(
                            onPressed: () => _confirmDeleteRecipe(context, recipe),
                            icon: const Icon(Icons.delete_outline),
                            label: const Text('Delete'),
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
