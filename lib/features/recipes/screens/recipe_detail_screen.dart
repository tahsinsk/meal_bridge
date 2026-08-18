import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/meal_type.dart';
import '../../../models/recipe.dart';
import '../../../shared/app_constants.dart';
import '../../../shared/category_labels.dart';
import '../../../shared/meal_type_style.dart';
import '../../../shared/widgets/recipe_image.dart';
import 'recipe_form_screen.dart';

enum _DetailTab { ingredients, instructions }

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;
  final bool isInQuickList;
  final VoidCallback? onToggleQuickList;
  final ValueChanged<Recipe>? onFavoriteToggled;
  final bool canEdit;
  final ValueChanged<Recipe>? onRecipeUpdated;

  const RecipeDetailScreen({
    super.key,
    required this.recipe,
    this.isInQuickList = false,
    this.onToggleQuickList,
    this.onFavoriteToggled,
    this.canEdit = false,
    this.onRecipeUpdated,
  });

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  late bool _isInQuickList;
  late Recipe _recipe;
  _DetailTab _activeTab = _DetailTab.ingredients;

  @override
  void initState() {
    super.initState();
    _isInQuickList = widget.isInQuickList;
    _recipe = widget.recipe;
  }

  Recipe get recipe => _recipe;

  String _formatAmount(double amount) {
    if (amount == amount.roundToDouble()) {
      return amount.toInt().toString();
    }
    return amount.toString();
  }

  // Same green-family treatment as the Weekly Plan / Shopping List meal
  // slots and the Recipes grid's category pill, so a category reads the
  // same color everywhere in the app.
  Color _categoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'breakfast':
        return MealType.breakfast.onSurfaceColor;
      case 'lunch':
        return MealType.lunch.onSurfaceColor;
      case 'dinner':
        return MealType.dinner.onSurfaceColor;
      default:
        return AppColors.primaryDark;
    }
  }

  Color _categoryBgColor(String category) {
    switch (category.toLowerCase()) {
      case 'breakfast':
        return MealType.breakfast.surfaceColor;
      case 'lunch':
        return MealType.lunch.surfaceColor;
      case 'dinner':
        return MealType.dinner.surfaceColor;
      default:
        return AppColors.surfaceSoft;
    }
  }

  void _handleFavoriteToggle() {
    final current = _recipe;
    setState(() => _recipe = _recipe.copyWith(isFavorite: !_recipe.isFavorite));
    widget.onFavoriteToggled?.call(current);
  }

  Future<void> _handleEdit() async {
    final updated = await Navigator.of(context).push<Recipe>(
      MaterialPageRoute(builder: (context) => RecipeFormScreen(initialRecipe: _recipe)),
    );
    if (updated == null) return;
    setState(() => _recipe = updated);
    widget.onRecipeUpdated?.call(updated);
  }

  void _handleQuickListToggle() {
    setState(() => _isInQuickList = !_isInQuickList);
    widget.onToggleQuickList!();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.name),
        actions: [
          // Favorite/Edit/Quick List all live in one overflow menu instead
          // of separate always-visible icons, so the AppBar stays down to
          // just the back arrow and this one button.
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'favorite':
                  _handleFavoriteToggle();
                case 'edit':
                  _handleEdit();
                case 'quick_list':
                  _handleQuickListToggle();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'favorite',
                child: Row(
                  children: [
                    Icon(
                      recipe.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                      size: 18,
                      color: recipe.isFavorite ? const Color(0xFFF9A825) : null,
                    ),
                    const SizedBox(width: 10),
                    Text(recipe.isFavorite ? l10n.recipeFavoriteRemove : l10n.recipeFavoriteAdd),
                  ],
                ),
              ),
              if (widget.canEdit)
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      const Icon(Icons.edit_outlined, size: 18),
                      const SizedBox(width: 10),
                      Text(l10n.recipeEditTooltip),
                    ],
                  ),
                ),
              if (widget.onToggleQuickList != null)
                PopupMenuItem(
                  value: 'quick_list',
                  child: Row(
                    children: [
                      Icon(
                        _isInQuickList
                            ? Icons.remove_shopping_cart_outlined
                            : Icons.add_shopping_cart_outlined,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Text(_isInQuickList ? l10n.recipeQuickListRemove : l10n.recipeQuickListAdd),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Hero photo — full width, same RecipeImage widget (and gradient
          // placeholder fallback) used on the Recipes list/grid cards, so
          // the detail screen actually shows the photo once one is set.
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.card),
            child: SizedBox(
              height: 220,
              width: double.infinity,
              child: RecipeImage(imagePath: recipe.imagePath, iconSize: 56),
            ),
          ),

          const SizedBox(height: 16),

          // Hero kart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: _categoryBgColor(recipe.category),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          localizedRecipeCategory(l10n, recipe.category),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _categoryColor(recipe.category),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  // Stats — steps is dropped from this row once a total-
                  // time estimate exists (its own count is already visible
                  // in the "Instructions (N)" tab label below), so the row
                  // stays at 4 stats instead of 5 and never wraps.
                  Row(
                    children: [
                      _statItem(
                        context,
                        Icons.people_outline,
                        '${recipe.servings}',
                        l10n.recipeStatServings,
                      ),
                      _divider(),
                      _statItem(
                        context,
                        Icons.shopping_basket_outlined,
                        '${recipe.ingredients.length}',
                        l10n.recipeStatIngredients,
                      ),
                      if (recipe.totalTimeMinutes == null) ...[
                        _divider(),
                        _statItem(
                          context,
                          Icons.format_list_numbered,
                          '${recipe.instructions.length}',
                          l10n.recipeStatSteps,
                        ),
                      ],
                      if (recipe.calories != null) ...[
                        _divider(),
                        _statItem(
                          context,
                          Icons.local_fire_department_outlined,
                          '${(recipe.calories! / recipe.servings).round()}',
                          l10n.recipeStatKcalPerServing,
                        ),
                      ],
                      if (recipe.totalTimeMinutes != null) ...[
                        _divider(),
                        _statItem(
                          context,
                          Icons.schedule_outlined,
                          '${recipe.totalTimeMinutes}',
                          l10n.recipeStatMinutes,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Ingredients / Instructions toggle — same segmented-pill pattern
          // as the Shopping List screen's Weekly Plan/Quick List toggle.
          // Read-only view, so only the active tab's list is shown; nothing
          // here is editable.
          SegmentedButton<_DetailTab>(
            segments: [
              ButtonSegment(
                value: _DetailTab.ingredients,
                icon: const Icon(Icons.shopping_basket_outlined),
                label: Text(recipe.ingredients.isEmpty
                    ? l10n.recipeSectionIngredients
                    : '${l10n.recipeSectionIngredients} (${recipe.ingredients.length})'),
              ),
              ButtonSegment(
                value: _DetailTab.instructions,
                icon: const Icon(Icons.format_list_numbered),
                label: Text(recipe.instructions.isEmpty
                    ? l10n.recipeSectionInstructions
                    : '${l10n.recipeSectionInstructions} (${recipe.instructions.length})'),
              ),
            ],
            selected: {_activeTab},
            onSelectionChanged: (value) => setState(() => _activeTab = value.first),
            style: ButtonStyle(
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) return AppColors.primary;
                return AppColors.surfaceSoft;
              }),
              foregroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) return Colors.white;
                return AppColors.primaryDark;
              }),
              iconColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) return Colors.white;
                return AppColors.primaryDark;
              }),
              side: const WidgetStatePropertyAll(BorderSide.none),
            ),
          ),

          const SizedBox(height: 12),

          if (_activeTab == _DetailTab.ingredients)
          ...recipe.ingredients.map(
            (ingredient) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSoft,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.eco_outlined,
                        size: 18,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ingredient.name,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          Text(
                            localizedMarketCategory(l10n, ingredient.resolvedCategory),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSoft,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_formatAmount(ingredient.amount)} ${ingredient.unit}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          else
          ...recipe.instructions.asMap().entries.map((entry) {
            final index = entry.key;
            final instruction = entry.value;
            final duration = index < recipe.instructionDurationsMinutes.length
                ? recipe.instructionDurationsMinutes[index]
                : null;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primaryDark,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              instruction,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            if (duration != null) ...[
                              const SizedBox(height: 4),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.schedule_outlined, size: 13, color: Colors.grey[500]),
                                  const SizedBox(width: 3),
                                  Text(
                                    l10n.recipeStepDurationLabel(duration),
                                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          // Notes
          if (recipe.notes != null && recipe.notes!.isNotEmpty) ...[
            const SizedBox(height: 20),
            _sectionHeader(context, Icons.notes_outlined, l10n.recipeSectionNotes),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.lightbulb_outline,
                      color: Color(0xFFF9A825),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        recipe.notes!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _statItem(
    BuildContext context,
    IconData icon,
    String value,
    String label,
  ) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppColors.primaryDark, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDark,
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 40,
      color: AppColors.surfaceSoft,
    );
  }

  Widget _sectionHeader(
    BuildContext context,
    IconData icon,
    String title,
  ) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.surfaceSoft,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: AppColors.primaryDark),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ],
    );
  }
}
