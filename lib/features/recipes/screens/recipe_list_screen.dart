import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/meal_type.dart';
import '../../../models/recipe.dart';
import '../../../services/recipe_storage_service.dart';
import '../../../shared/app_constants.dart';
import '../../../shared/category_labels.dart';
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
  final _storageService = RecipeStorageService();
  var _searchQuery = '';
  var _showFavoritesOnly = false;
  var _isGridView = true;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadViewMode();
  }

  Future<void> _loadViewMode() async {
    final isGridView = await _storageService.loadRecipeGridView();
    if (!mounted) return;
    setState(() => _isGridView = isGridView);
  }

  void _toggleViewMode() {
    setState(() => _isGridView = !_isGridView);
    _storageService.saveRecipeGridView(_isGridView);
  }

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
    final l10n = AppLocalizations.of(context)!;
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.recipeDeleteDialogTitle),
        content: Text(l10n.recipeDeleteDialogContent(recipe.name)),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: Text(l10n.commonDelete)),
        ],
      ),
    );
    if (shouldDelete == true) widget.onRecipeDeleted(recipe);
  }

  void _showFilterSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                  Text(l10n.recipeFilterTitle, style: Theme.of(context).textTheme.titleLarge),
                  const Spacer(),
                  if (_activeFilterCount > 0)
                    TextButton(
                      onPressed: () {
                        _clearFilters();
                        setSheetState(() {});
                        Navigator.of(context).pop();
                      },
                      child: Text(l10n.commonClearAll),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(l10n.recipeFilterCategoryLabel, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return FilterChip(
                    label: Text(localizedRecipeCategory(l10n, cat)),
                    selected: isSelected,
                    selectedColor: AppColors.primaryDark,
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.primaryDark,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (val) {
                      setState(() => _selectedCategory = val ? cat : null);
                      setSheetState(() {});
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Text(l10n.recipeFilterShowLabel, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.recipeFilterFavoritesOnly),
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
                        ? l10n.recipeFilterApply(_activeFilterCount)
                        : l10n.recipeFilterDone,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _subtitle(BuildContext context, Recipe recipe) {
    final l10n = AppLocalizations.of(context)!;
    final parts = <String>[];
    if (recipe.calories != null) {
      parts.add(l10n.recipeKcalPerServing((recipe.calories! / recipe.servings).round()));
    }
    parts.add(l10n.recipeStepCount(recipe.instructions.length));
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
    final l10n = AppLocalizations.of(context)!;
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: _overlayCircle(Icons.more_vert, Colors.white),
      onSelected: (value) {
        if (value == 'edit') _openEditRecipeScreen(context, recipe);
        if (value == 'delete') _confirmDeleteRecipe(context, recipe);
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(children: [
            const Icon(Icons.edit_outlined, size: 18),
            const SizedBox(width: 10),
            Text(l10n.commonEdit),
          ]),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(children: [
            const Icon(Icons.delete_outline, size: 18, color: Colors.red),
            const SizedBox(width: 10),
            Text(l10n.commonDelete, style: const TextStyle(color: Colors.red)),
          ]),
        ),
      ],
    );
  }

  Widget _buildRecipeCard(BuildContext context, Recipe recipe) {
    final l10n = AppLocalizations.of(context)!;
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
                      localizedRecipeCategory(l10n, recipe.category),
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: categoryColor),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _subtitle(context, recipe),
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

  // Soft, rounded swipe action chip — a gentle pastel surface with a small
  // gap around it, instead of a hard-edged fully-saturated color block.
  // Uses CustomSlidableAction with a transparent full-bleed button so the
  // list background shows through the gap left by the inset Padding.
  Widget _buildSlideAction({
    required VoidCallback onTap,
    required IconData icon,
    required String label,
    required Color background,
    required Color foreground,
  }) {
    return CustomSlidableAction(
      onPressed: (_) => onTap(),
      backgroundColor: Colors.transparent,
      padding: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Container(
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: foreground, size: 20),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(color: foreground, fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecipeListTile(BuildContext context, Recipe recipe) {
    final l10n = AppLocalizations.of(context)!;
    final isCustom = widget.canDeleteRecipe(recipe);
    final (categoryBg, categoryColor) = _categoryColors(recipe.category);

    final card = Card(
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
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: RecipeImage(imagePath: recipe.imagePath, iconSize: 26),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.name,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: categoryBg,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Text(
                            localizedRecipeCategory(l10n, recipe.category),
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: categoryColor),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _subtitle(context, recipe),
                            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: Icon(
                  recipe.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: recipe.isFavorite ? const Color(0xFFF9A825) : Colors.grey[400],
                ),
                onPressed: () => widget.onFavoriteToggled(recipe),
              ),
            ],
          ),
        ),
      ),
    );

    if (!isCustom) return card;

    // Swipe-to-reveal Edit/Delete — list mode only (grid keeps its own
    // overlay menu); only custom recipes are editable/deletable.
    return Slidable(
      key: ValueKey(recipe.id),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.42,
        children: [
          _buildSlideAction(
            onTap: () => _openEditRecipeScreen(context, recipe),
            icon: Icons.edit_outlined,
            label: l10n.commonEdit,
            background: AppColors.surfaceSoft,
            foreground: AppColors.primaryDark,
          ),
          _buildSlideAction(
            onTap: () => _confirmDeleteRecipe(context, recipe),
            icon: Icons.delete_outline,
            label: l10n.commonDelete,
            background: const Color(0xFFFBE4E6),
            foreground: const Color(0xFFD8434F),
          ),
        ],
      ),
      child: card,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final query = _searchQuery.trim().toLowerCase();
    final totalCount = widget.recipes.length;
    final hasActiveFilters = _activeFilterCount > 0 || query.isNotEmpty;

    final sortedRecipes = [...widget.recipes]..sort((a, b) {
        if (a.isFavorite && !b.isFavorite) return -1;
        if (!a.isFavorite && b.isFavorite) return 1;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

    final filteredRecipes = sortedRecipes.where((r) {
      final matchesQuery = query.isEmpty ||
          r.name.toLowerCase().contains(query) ||
          r.category.toLowerCase().contains(query) ||
          localizedRecipeCategory(l10n, r.category).toLowerCase().contains(query) ||
          r.ingredients.any((i) =>
              i.resolvedCategory.toLowerCase().contains(query) ||
              localizedMarketCategory(l10n, i.resolvedCategory).toLowerCase().contains(query));
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
                  Text(l10n.navRecipes, style: AppTextStyles.pageHeading),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: AppTextStyles.searchInput,
                          decoration: InputDecoration(
                            hintText: l10n.recipeSearchHint,
                            hintStyle: AppTextStyles.searchHint,
                            hintMaxLines: 1,
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
                                  style: IconButton.styleFrom(
                                    backgroundColor: AppColors.primaryDark,
                                    foregroundColor: Colors.white,
                                  ),
                                )
                              : IconButton.filledTonal(
                                  onPressed: () => _showFilterSheet(context),
                                  icon: const Icon(Icons.filter_list_outlined),
                                  style: IconButton.styleFrom(
                                    backgroundColor: AppColors.surfaceSoft,
                                    foregroundColor: AppColors.primaryDark,
                                  ),
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
                      const SizedBox(width: 8),
                      IconButton.filledTonal(
                        onPressed: _toggleViewMode,
                        tooltip: _isGridView ? l10n.recipeViewToggleToList : l10n.recipeViewToggleToGrid,
                        icon: Icon(_isGridView ? Icons.view_list_outlined : Icons.grid_view_outlined),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.surfaceSoft,
                          foregroundColor: AppColors.primaryDark,
                        ),
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
                                label: Text(localizedRecipeCategory(l10n, _selectedCategory!)),
                                avatar: const Icon(Icons.category_outlined, size: 16),
                                onDeleted: () => setState(() => _selectedCategory = null),
                                deleteIcon: const Icon(Icons.close, size: 16),
                              ),
                            ),
                          if (_showFavoritesOnly)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Chip(
                                label: Text(l10n.recipeFilterFavoritesChip),
                                avatar: const Icon(Icons.star, size: 16, color: Color(0xFFF9A825)),
                                onDeleted: () => setState(() => _showFavoritesOnly = false),
                                deleteIcon: const Icon(Icons.close, size: 16),
                              ),
                            ),
                          TextButton(onPressed: _clearFilters, child: Text(l10n.commonClearAll)),
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
                              ? l10n.recipeEmptyFavoritesTitle
                              : hasActiveFilters
                                  ? l10n.recipeEmptyFilteredTitle
                                  : totalCount > 0
                                      ? l10n.recipeEmptySearchTitle
                                      : l10n.recipeEmptyNoneTitle,
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _showFavoritesOnly
                              ? l10n.recipeEmptyFavoritesMessage
                              : hasActiveFilters
                                  ? l10n.recipeEmptyFilteredMessage
                                  : totalCount > 0
                                      ? l10n.recipeEmptySearchMessage
                                      : l10n.recipeEmptyNoneMessage,
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        if (hasActiveFilters) ...[
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: _clearFilters,
                            icon: const Icon(Icons.filter_list_off_outlined),
                            label: Text(l10n.recipeClearFiltersButton),
                          ),
                        ],
                        if (totalCount == 0) ...[
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: openAddRecipeScreen,
                              icon: const Icon(Icons.add),
                              label: Text(l10n.recipeAddFirstButton),
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
              sliver: _isGridView
                  ? SliverGrid.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        mainAxisExtent: 210,
                      ),
                      itemCount: filteredRecipes.length,
                      itemBuilder: (context, index) =>
                          _buildRecipeCard(context, filteredRecipes[index]),
                    )
                  : SliverList.builder(
                      itemCount: filteredRecipes.length,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _buildRecipeListTile(context, filteredRecipes[index]),
                      ),
                    ),
            ),
        ],
      ),
    );
  }
}
