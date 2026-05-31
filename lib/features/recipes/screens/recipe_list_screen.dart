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
  final ValueChanged<Recipe> onFavoriteToggled;

  const RecipeListScreen({
    super.key,
    required this.recipes,
    required this.canDeleteRecipe,
    required this.onRecipeAdded,
    required this.onRecipeUpdated,
    required this.onRecipeDeleted,
    required this.onFavoriteToggled,
  });

  @override
  State<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  final _searchController = TextEditingController();
  var _searchQuery = '';
  var _showFavoritesOnly = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openAddRecipeScreen(BuildContext context) async {
    final newRecipe = await Navigator.of(context).push<Recipe>(
      MaterialPageRoute(builder: (context) => const RecipeFormScreen()),
    );
    if (newRecipe != null) widget.onRecipeAdded(newRecipe);
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
    if (updatedRecipe != null) widget.onRecipeUpdated(updatedRecipe);
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
    if (shouldDelete == true) widget.onRecipeDeleted(recipe);
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchQuery.trim().toLowerCase();

    // Favoriler önce, sonra alfabetik
    final sortedRecipes = [...widget.recipes]..sort((a, b) {
        if (a.isFavorite && !b.isFavorite) return -1;
        if (!a.isFavorite && b.isFavorite) return 1;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

    final filteredRecipes = sortedRecipes.where((recipe) {
      final matchesQuery = query.isEmpty ||
          recipe.name.toLowerCase().contains(query) ||
          recipe.category.toLowerCase().contains(query);
      final matchesFavorite = !_showFavoritesOnly || recipe.isFavorite;
      return matchesQuery && matchesFavorite;
    }).toList();

    final hasRecipes = widget.recipes.isNotEmpty;
    final favoriteCount = widget.recipes.where((r) => r.isFavorite).length;

    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredRecipes.isEmpty ? 2 : filteredRecipes.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
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
                                setState(() => _searchQuery = '');
                              },
                              icon: const Icon(Icons.clear),
                            ),
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) =>
                        setState(() => _searchQuery = value),
                  ),
                ),
                // Filtre satırı
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      FilterChip(
                        avatar: Icon(
                          _showFavoritesOnly
                              ? Icons.star
                              : Icons.star_outline,
                          size: 18,
                          color: _showFavoritesOnly
                              ? const Color(0xFF2E7D32)
                              : null,
                        ),
                        label: Text(
                          favoriteCount > 0
                              ? 'Favorites ($favoriteCount)'
                              : 'Favorites',
                        ),
                        selected: _showFavoritesOnly,
                        onSelected: (value) =>
                            setState(() => _showFavoritesOnly = value),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          if (filteredRecipes.isEmpty) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      _showFavoritesOnly
                          ? Icons.star_outline
                          : hasRecipes
                              ? Icons.search_off_outlined
                              : Icons.restaurant_menu_outlined,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _showFavoritesOnly
                          ? 'No favorites yet'
                          : hasRecipes
                              ? 'No matching recipes'
                              : 'No recipes yet',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _showFavoritesOnly
                          ? 'Tap the ⭐ on any recipe to add it to favorites.'
                          : hasRecipes
                              ? 'No recipe matches your search.'
                              : 'Add your first recipe to start building your weekly meal plan.',
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
                                style:
                                    Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${recipe.category} • ${recipe.ingredients.length} ingredients • ${recipe.instructions.length} steps',
                                style:
                                    Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        // Favori butonu
                        IconButton(
                          icon: Icon(
                            recipe.isFavorite
                                ? Icons.star
                                : Icons.star_outline,
                            color: recipe.isFavorite
                                ? const Color(0xFFF9A825)
                                : null,
                          ),
                          tooltip: recipe.isFavorite
                              ? 'Remove from favorites'
                              : 'Add to favorites',
                          onPressed: () =>
                              widget.onFavoriteToggled(recipe),
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