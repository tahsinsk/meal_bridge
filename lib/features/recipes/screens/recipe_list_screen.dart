import 'package:flutter/material.dart';

import '../../../models/meal_type.dart';
import '../../../models/recipe.dart';
import '../../../shared/app_constants.dart';
import '../../../shared/meal_type_style.dart';
import '../../../shared/widgets/recipe_image.dart';
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
  State<RecipeListScreen> createState() => RecipeListScreenState();
}

class RecipeListScreenState extends State<RecipeListScreen> {
  final _searchController = TextEditingController();
  var _searchQuery = '';
  var _showFavoritesOnly = false;
  String? _selectedCategory;

  static const _categories = ['Breakfast', 'Lunch', 'Dinner', 'Other'];

  // Same green-family treatment as the Weekly Plan / Shopping List meal
  // slots, so a category reads the same color everywhere in the app.
  (Color bg, Color fg) _categoryColors(String category) {
    switch (category.toLowerCase()) {
      case 'breakfast':
        return (MealType.breakfast.surfaceColor, MealType.breakfast.onSurfaceColor);
      case 'lunch':
        return (MealType.lunch.surfaceColor, MealType.lunch.onSurfaceColor);
      case 'dinner':
        return (MealType.dinner.surfaceColor, MealType.dinner.onSurfaceColor);
      default:
        return (AppColors.surfaceSoft, AppColors.primaryDark);
    }
  }

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

  /// Public so [MainShell]'s AppBar "+" action can trigger it via a GlobalKey.
  Future<void> openAddRecipeScreen() async {
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
      builder: (context) => AlertDialog(
        title: const Text('Delete recipe?'),
        content: Text('Are you sure you want to delete "${recipe.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete')),
        ],
      ),
    );
    if (shouldDelete == true) widget.onRecipeDeleted(recipe);
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
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
        ),
      ),
    );
  }

  String _subtitle(Recipe recipe) {
    final parts = <String>[];
    if (recipe.calories != null) {
      parts.add('${(recipe.calories! / recipe.servings).round()} kcal');
    }
    parts.add('${recipe.instructions.length} step${recipe.instructions.length != 1 ? 's' : ''}');
    return parts.join(' · ');
  }

  // Shared 32x32 circular glyph used by both overlay buttons, so the star
  // and the 3-dot menu line up pixel-for-pixel instead of each button
  // centering its icon through slightly different internal machinery.
  Widget _overlayCircle(IconData icon, Color color) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.28),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }

  Widget _overlayIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: _overlayCircle(icon, color),
      ),
    );
  }

  Widget _buildCardMenu(BuildContext context, Recipe recipe) {
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: _overlayCircle(Icons.more_vert, Colors.white),
      onSelected: (value) {
        if (value == 'edit') _openEditRecipeScreen(context, recipe);
        if (value == 'delete') _confirmDeleteRecipe(context, recipe);
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(children: [
            Icon(Icons.edit_outlined, size: 18),
            SizedBox(width: 10),
            Text('Edit'),
          ]),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(children: [
            Icon(Icons.delete_outline, size: 18, color: Colors.red),
            SizedBox(width: 10),
            Text('Delete', style: TextStyle(color: Colors.red)),
          ]),
        ),
      ],
    );
  }

  Widget _buildRecipeCard(BuildContext context, Recipe recipe) {
    final isCustom = widget.canDeleteRecipe(recipe);
    final (categoryBg, categoryColor) = _categoryColors(recipe.category);

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => RecipeDetailScreen(
              recipe: recipe,
              isInQuickList: widget.quickRecipeIds.contains(recipe.id),
              onToggleQuickList: () => widget.onToggleQuickRecipe(recipe.id),
              onFavoriteToggled: widget.onFavoriteToggled,
              canEdit: isCustom,
              onRecipeUpdated: widget.onRecipeUpdated,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo area — favorite + (for custom recipes) edit/delete float on top,
            // keeping the text content below free of a fragile bottom action row.
            SizedBox(
              height: 104,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  RecipeImage(imagePath: recipe.imagePath, iconSize: 34),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: _overlayIconButton(
                      icon: recipe.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: recipe.isFavorite ? const Color(0xFFF9A825) : Colors.white,
                      onPressed: () => widget.onFavoriteToggled(recipe),
                    ),
                  ),
                  if (isCustom)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: _buildCardMenu(context, recipe),
                    ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.name,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, height: 1.25),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: categoryBg,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      recipe.category,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: categoryColor),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _subtitle(recipe),
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchQuery.trim().toLowerCase();
    final totalCount = widget.recipes.length;
    final favoriteCount = widget.recipes.where((r) => r.isFavorite).length;
    final hasActiveFilters = _activeFilterCount > 0 || query.isNotEmpty;

    final sortedRecipes = [...widget.recipes]..sort((a, b) {
        if (a.isFavorite && !b.isFavorite) return -1;
        if (!a.isFavorite && b.isFavorite) return 1;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

    final filteredRecipes = sortedRecipes.where((r) {
      final matchesQuery = query.isEmpty ||
          r.name.toLowerCase().contains(query) ||
          r.category.toLowerCase().contains(query);
      final matchesFav = !_showFavoritesOnly || r.isFavorite;
      final matchesCat = _selectedCategory == null ||
          r.category.toLowerCase() == _selectedCategory!.toLowerCase();
      return matchesQuery && matchesFav && matchesCat;
    }).toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header + search
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Your recipes', style: AppTextStyles.pageHeading),
                  const SizedBox(height: 2),
                  Text(
                    favoriteCount > 0
                        ? '$totalCount recipe${totalCount != 1 ? 's' : ''} · $favoriteCount favorite${favoriteCount != 1 ? 's' : ''}'
                        : '$totalCount recipe${totalCount != 1 ? 's' : ''}',
                    style: AppTextStyles.pageSubtitle,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search recipes by name or category',
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
                          ),
                          onChanged: (v) => setState(() => _searchQuery = v),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Stack(
                        children: [
                          _activeFilterCount > 0
                              ? IconButton.filled(
                                  onPressed: () => _showFilterSheet(context),
                                  icon: const Icon(Icons.filter_list),
                                )
                              : IconButton.filledTonal(
                                  onPressed: () => _showFilterSheet(context),
                                  icon: const Icon(Icons.filter_list_outlined),
                                ),
                          if (_activeFilterCount > 0)
                            Positioned(
                              right: 6, top: 6,
                              child: Container(
                                width: 16, height: 16,
                                decoration: const BoxDecoration(
                                  color: AppColors.primaryDark, shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '$_activeFilterCount',
                                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  if (hasActiveFilters) ...[
                    const SizedBox(height: 8),
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
                          TextButton(onPressed: _clearFilters, child: const Text('Clear all')),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // Empty state
          if (filteredRecipes.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          _showFavoritesOnly
                              ? Icons.star_outline
                              : hasActiveFilters
                                  ? Icons.filter_list_off_outlined
                                  : totalCount > 0
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
                                  : totalCount > 0
                                      ? 'No results found'
                                      : 'No recipes yet',
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _showFavoritesOnly
                              ? 'Tap the star on any recipe card to add to favorites.'
                              : hasActiveFilters
                                  ? 'Try adjusting your filters or search query.'
                                  : totalCount > 0
                                      ? 'No recipe matches your search.'
                                      : 'Add your first recipe to start building your meal plan.',
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
                        if (totalCount == 0) ...[
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: openAddRecipeScreen,
                              icon: const Icon(Icons.add),
                              label: const Text('Add your first recipe'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverGrid.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  mainAxisExtent: 210,
                ),
                itemCount: filteredRecipes.length,
                itemBuilder: (context, index) =>
                    _buildRecipeCard(context, filteredRecipes[index]),
              ),
            ),
        ],
      ),
    );
  }
}
