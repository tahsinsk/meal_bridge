import 'package:flutter/material.dart';

import '../../../models/recipe.dart';
import 'recipe_detail_screen.dart';
import 'recipe_form_screen.dart';

class RecipeListScreen extends StatefulWidget {
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

  @override
  State<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  final _searchController = TextEditingController();
  var _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openAddRecipeScreen(BuildContext context) async {
    final newRecipe = await Navigator.of(context).push<Recipe>(
      MaterialPageRoute(builder: (context) => const RecipeFormScreen()),
    );

    if (newRecipe != null) {
      widget.onRecipeAdded(newRecipe);
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
      widget.onRecipeUpdated(updatedRecipe);
    }
  }

  Future<void> _confirmDeleteRecipe(BuildContext context, Recipe recipe) async {
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
      widget.onRecipeDeleted(recipe);
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchQuery.trim().toLowerCase();
    final filteredRecipes = widget.recipes.where((recipe) {
      if (query.isEmpty) {
        return true;
      }
      return recipe.name.toLowerCase().contains(query) ||
          recipe.category.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredRecipes.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search recipes',
                  hintText: 'Search by name or category',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: query.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                          icon: const Icon(Icons.clear),
                        ),
                  border: const OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            );
          }

          if (filteredRecipes.isEmpty) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(Icons.search_off_outlined, size: 40),
                    const SizedBox(height: 12),
                    Text(
                      'No recipes found',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Try another name or category.',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          final recipe = filteredRecipes[index - 1];
          final isCustomRecipe = widget.canDeleteRecipe(recipe);

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
                              Text(
                                '${recipe.category} • ${recipe.ingredients.length} ingredients • ${recipe.instructions.length} steps',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
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
                            onPressed: () =>
                                _openEditRecipeScreen(context, recipe),
                            icon: const Icon(Icons.edit_outlined),
                            label: const Text('Edit'),
                          ),
                          TextButton.icon(
                            onPressed: () =>
                                _confirmDeleteRecipe(context, recipe),
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddRecipeScreen(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Recipe'),
      ),
    );
  }
}
