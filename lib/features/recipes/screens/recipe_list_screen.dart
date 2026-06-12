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
  final Set<String> quickRecipeIds;
  final void Function(String recipeId) onToggleQuickRecipe;

  const RecipeListScreen({
    super.key,
    required this.recipes,
    required this.canDeleteRecipe,
    required this.onRecipeAdded,
    required this.onRecipeUpdated,
    required this.onRecipeDeleted,
    required this.onFavoriteToggled,
    required this.quickRecipeIds,
    required this.onToggleQuickRecipe,
  });

  @override
  State<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  final _searchController = TextEditingController();
  var _searchQuery = '';
  var _showFavoritesOnly = false;
  String? _selectedCategory;

  static const _categories = ['Breakfast', 'Lunch', 'Dinner', 'Other'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int get _activeFilterCount {
    int count = 0;
    if (_showFavoritesOnly) count++;
    if (_selectedCategory != null) count++;
    return count;
  }

  void _clearFilters() {
    setState(() {
      _showFavoritesOnly = false;
      _selectedCategory = null;
      _searchQuery = '';
      _searchController.clear();
    });
  }

  Future<void> _openAddRecipeScreen(BuildContext context) async {
    final newRecipe = await Navigator.of(context).push<Recipe>(
      MaterialPageRoute(builder: (context) => const RecipeFormScreen()),
    );
    if (newRecipe != null) widget.onRecipeAdded(newRecipe);
  }

  Future<void> _openEditRecipeScreen(BuildContext context, Recipe recipe) async {
    final updatedRecipe = await Navigator.of(context).push<Recipe>(
      MaterialPageRoute(builder: (context) => RecipeFormScreen(initialRecipe: recipe)),
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
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete')),
          ],
        );
      },
    );
    if (shouldDelete == true) widget.onRecipeDeleted(recipe);
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.filter_list_outlined),
                      const SizedBox(width: 8),
                      Text('Filter recipes', style: Theme.of(context).textTheme.titleLarge),
                      const Spacer(),
                      if (_activeFilterCount > 0)
                        TextButton(
                          onPressed: () {
                            _clearFilters();
                            setSheetState(() {});
                            Navigator.of(context).pop();
                          },
                          child: const Text('Clear all'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('Category', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _categories.map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return FilterChip(
                        label: Text(cat),
                        selected: isSelected,
                        onSelected: (val) {
                          setState(() => _selectedCategory = val ? cat : null);
                          setSheetState(() {});
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Text('Show', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Favorites only'),
                    secondary: Icon(
                      _showFavoritesOnly ? Icons.star : Icons.star_outline,
                      color: _showFavoritesOnly ? const Color(0xFFF9A825) : null,
                    ),
                    value: _showFavoritesOnly,
                    onChanged: (val) {
                      setState(() => _showFavoritesOnly = val);
                      setSheetState(() {});
                    },
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        _activeFilterCount > 0
                            ? 'Apply ($_activeFilterCount filter${_activeFilterCount > 1 ? 's' : ''})'
                            : 'Done',
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _categoryChip(String category) {
    final colors = {
      'Breakfast': (const Color(0xFFFFF8E1), const Color(0xFFF57F17)),
      'Lunch': (const Color(0xFFE3F2FD), const Color(0xFF1565C0)),
      'Dinner': (const Color(0xFFEDE7F6), const Color(0xFF4527A0)),
      'Other': (const Color(0xFFE8F5E9), const Color(0xFF2E7D32)),
    };
    final pair = colors[category] ?? (const Color(0xFFE8F5E9), const Color(0xFF2E7D32));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: pair.$1,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        category,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: pair.$2),
      ),
    );
  }

  Widget _calorieChip(Recipe recipe) {
    final perServing = (recipe.calories! / recipe.servings).round();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_fire_department_outlined, size: 12, color: Color(0xFFE65100)),
          const SizedBox(width: 3),
          Text(
            '$perServing kcal/serving',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFE65100)),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F9F1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF2E7D32).withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: const Color(0xFF558B2F)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Color(0xFF558B2F),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchQuery.trim().toLowerCase();

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
      final matchesCategory = _selectedCategory == null ||
          recipe.category.toLowerCase() == _selectedCategory!.toLowerCase();
      return matchesQuery && matchesFavorite && matchesCategory;
    }).toList();

    final hasRecipes = widget.recipes.isNotEmpty;
    final favoriteCount = widget.recipes.where((r) => r.isFavorite).length;
    final hasActiveFilters = _activeFilterCount > 0 || query.isNotEmpty;

    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredRecipes.isEmpty ? 2 : filteredRecipes.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
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
                        onChanged: (value) => setState(() => _searchQuery = value),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Stack(
                      children: [
                        IconButton.outlined(
                          onPressed: () => _showFilterSheet(context),
                          icon: const Icon(Icons.filter_list_outlined),
                          style: IconButton.styleFrom(
                            side: BorderSide(
                              color: _activeFilterCount > 0
                                  ? const Color(0xFF2E7D32)
                                  : Theme.of(context).dividerColor,
                              width: _activeFilterCount > 0 ? 2 : 1,
                            ),
                          ),
                        ),
                        if (_activeFilterCount > 0)
                          Positioned(
                            right: 6,
                            top: 6,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: const BoxDecoration(
                                color: Color(0xFF2E7D32),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '$_activeFilterCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (hasActiveFilters) ...[
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        if (_selectedCategory != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Chip(
                              label: Text(_selectedCategory!),
                              avatar: const Icon(Icons.category_outlined, size: 16),
                              onDeleted: () => setState(() => _selectedCategory = null),
                              deleteIcon: const Icon(Icons.close, size: 16),
                            ),
                          ),
                        if (_showFavoritesOnly)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Chip(
                              label: const Text('Favorites'),
                              avatar: const Icon(Icons.star, size: 16, color: Color(0xFFF9A825)),
                              onDeleted: () => setState(() => _showFavoritesOnly = false),
                              deleteIcon: const Icon(Icons.close, size: 16),
                            ),
                          ),
                        if (hasActiveFilters)
                          TextButton(onPressed: _clearFilters, child: const Text('Clear all')),
                      ],
                    ),
                  ),
                ],
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Text(
                        '${filteredRecipes.length} recipe${filteredRecipes.length != 1 ? 's' : ''}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (favoriteCount > 0) ...[
                        const Text(' • '),
                        const Icon(Icons.star, size: 13, color: Color(0xFFF9A825)),
                        const SizedBox(width: 2),
                        Text(
                          '$favoriteCount favorite${favoriteCount != 1 ? 's' : ''}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 4),
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
                          : hasActiveFilters
                              ? Icons.filter_list_off_outlined
                              : hasRecipes
                                  ? Icons.search_off_outlined
                                  : Icons.restaurant_menu_outlined,
                      size: 56,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _showFavoritesOnly
                          ? 'No favorites yet'
                          : hasActiveFilters
                              ? 'No matching recipes'
                              : hasRecipes
                                  ? 'No results found'
                                  : 'No recipes yet',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _showFavoritesOnly
                          ? 'Tap the ⭐ on any recipe to add it to favorites.'
                          : hasActiveFilters
                              ? 'Try adjusting your filters or search query.'
                              : hasRecipes
                                  ? 'No recipe matches your search.'
                                  : 'Add your first recipe to start building your weekly meal plan.',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    if (hasActiveFilters) ...[
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: _clearFilters,
                        icon: const Icon(Icons.filter_list_off_outlined),
                        label: const Text('Clear filters'),
                      ),
                    ],
                    if (!hasRecipes) ...[
                      const SizedBox(height: 16),
                      const Chip(
                        avatar: Icon(Icons.add, size: 18),
                        label: Text('Use Add Recipe'),
                      ),
                    ],
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
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => RecipeDetailScreen(
                      recipe: recipe,
                      isInQuickList: widget.quickRecipeIds.contains(recipe.id),
                      onToggleQuickList: () => widget.onToggleQuickRecipe(recipe.id),
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.restaurant_menu_outlined,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            recipe.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              _categoryChip(recipe.category),
                              _infoChip(
                                Icons.shopping_basket_outlined,
                                '${recipe.ingredients.length} ingredients',
                              ),
                              _infoChip(
                                Icons.format_list_numbered,
                                '${recipe.instructions.length} steps',
                              ),
                              if (recipe.calories != null)
                                _calorieChip(recipe),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: Icon(
                        recipe.isFavorite ? Icons.star : Icons.star_outline,
                        color: recipe.isFavorite ? const Color(0xFFF9A825) : null,
                      ),
                      tooltip: recipe.isFavorite ? 'Remove from favorites' : 'Add to favorites',
                      onPressed: () => widget.onFavoriteToggled(recipe),
                    ),
                    if (isCustomRecipe)
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        onSelected: (value) {
                          if (value == 'edit') {
                            _openEditRecipeScreen(context, recipe);
                          } else if (value == 'delete') {
                            _confirmDeleteRecipe(context, recipe);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit_outlined, size: 20),
                                SizedBox(width: 12),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline, size: 20, color: Colors.red),
                                SizedBox(width: 12),
                                Text('Delete', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      ),
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