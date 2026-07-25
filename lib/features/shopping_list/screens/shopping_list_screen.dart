import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../data/shopping_list_generator.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/ingredient.dart';
import '../../../models/meal_type.dart';
import '../../../models/planned_recipe.dart';
import '../../../models/recipe.dart';
import '../../../models/shopping_list_item.dart';
import '../../../shared/app_constants.dart';
import '../../../shared/category_labels.dart';
import '../../../shared/day_labels.dart';
import '../../../shared/iso_week.dart';
import '../../../shared/meal_type_style.dart';
import '../../../shared/widgets/shop_link_sheet.dart';
import 'add_custom_item_sheet.dart';

class _RecipeSection {
  final String sectionKey;
  final String recipeName;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final List<ShoppingListItem> items;

  const _RecipeSection({
    required this.sectionKey,
    required this.recipeName,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.items,
  });
}

class ShoppingListScreen extends StatefulWidget {
  final Map<String, PlannedRecipe> plannedRecipes;
  final List<Recipe> quickRecipes;
  final List<Recipe> allRecipes;
  final Set<String> checkedItemKeys;
  final void Function(String itemKey, bool isChecked) onItemCheckedChanged;
  final Set<String> excludedItemKeys;
  final void Function(String itemKey) onExcludeItem;
  final void Function(String recipeId) onToggleQuickRecipe;
  final VoidCallback onClearQuickRecipes;
  final List<Ingredient> customQuickItems;
  final void Function(Ingredient item) onAddCustomItem;
  final void Function(String itemName) onRemoveCustomItem;
  final int weekOffset;

  const ShoppingListScreen({
    super.key,
    required this.plannedRecipes,
    required this.quickRecipes,
    required this.allRecipes,
    required this.checkedItemKeys,
    required this.onItemCheckedChanged,
    required this.excludedItemKeys,
    required this.onExcludeItem,
    required this.onToggleQuickRecipe,
    required this.onClearQuickRecipes,
    required this.customQuickItems,
    required this.onAddCustomItem,
    required this.onRemoveCustomItem,
    required this.weekOffset,
  });

  @override
  State<ShoppingListScreen> createState() => ShoppingListScreenState();
}

class ShoppingListScreenState extends State<ShoppingListScreen> {
  bool _isQuickMode = false;
  bool _groupByRecipe = false;

  static const List<String> _categoryOrder = [
    'Vegetables', 'Fruit', 'Meat', 'Dairy', 'Bakery',
    'Pantry', 'Frozen', 'Drinks', 'Snacks', 'Other',
  ];

  static const List<String> _dayOrder = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
  ];

  static const List<String> _mealOrder = ['breakfast', 'lunch', 'dinner'];

  /// Recomputes the current shopping items + whether there's anything to
  /// show, regardless of Weekly Plan / Quick List mode. Single source of
  /// truth used by both `build()` and the AppBar-triggered actions below.
  ({List<ShoppingListItem> items, bool hasContent}) _computeShoppingItems() {
    final List<Recipe> activeRecipes;
    final List<double>? activeMultipliers;

    if (_isQuickMode) {
      activeRecipes = widget.quickRecipes;
      activeMultipliers = null;
    } else {
      activeRecipes = widget.plannedRecipes.values.map((pr) => pr.recipe).toList();
      activeMultipliers = widget.plannedRecipes.values.map((pr) => pr.servingsMultiplier).toList();
    }

    final recipeShoppingItems = generateShoppingListFromRecipes(activeRecipes, multipliers: activeMultipliers)
        .where((i) => !widget.excludedItemKeys.contains(_itemKey(i)))
        .toList();
    final items = [...recipeShoppingItems, ..._customShoppingItems()];
    final hasContent = activeRecipes.isNotEmpty || widget.customQuickItems.isNotEmpty;

    return (items: items, hasContent: hasContent);
  }

  List<ShoppingListItem> _customShoppingItems() {
    return widget.customQuickItems
        .map((i) => ShoppingListItem(
              name: i.name,
              amount: i.amount,
              unit: i.unit,
              category: i.resolvedCategory,
              isCustom: true,
            ))
        .toList();
  }

  // --- Public API for MainShell's AppBar "add item" action on this tab ---

  bool get allItemsChecked {
    final items = _computeShoppingItems().items;
    if (items.isEmpty) return false;
    return items.every((i) => widget.checkedItemKeys.contains(_itemKey(i)));
  }

  void toggleCheckAll() {
    final items = _computeShoppingItems().items;
    if (items.isEmpty) return;
    if (allItemsChecked) {
      _uncheckAll(items);
    } else {
      _checkAll(items);
    }
  }

  void openAddCustomItemSheet() {
    showAddCustomItemSheet(
      context,
      existingItems: widget.customQuickItems,
      onAdd: widget.onAddCustomItem,
      onRemove: widget.onRemoveCustomItem,
    );
  }

  /// Shares the current shopping list (respecting Weekly Plan / Quick List
  /// mode) as plain text, grouped by category with amounts — mirrors what's
  /// shown on screen when sorted by category.
  void _shareShoppingList() {
    final l10n = AppLocalizations.of(context)!;
    final items = _computeShoppingItems().items;
    if (items.isEmpty) return;
    final grouped = _groupItemsByCategory(items);

    final buffer = StringBuffer('${l10n.shoppingListHeading}\n');
    for (final entry in grouped.entries) {
      buffer.writeln();
      buffer.writeln(localizedMarketCategory(l10n, entry.key));
      for (final item in entry.value) {
        final amount = item.unit.isNotEmpty
            ? ' (${_formatAmount(item.amount)} ${item.unit})'
            : '';
        buffer.writeln('- ${item.name}$amount');
      }
    }

    final screenSize = MediaQuery.of(context).size;
    SharePlus.instance.share(
      ShareParams(
        text: buffer.toString().trim(),
        subject: l10n.shoppingListHeading,
        sharePositionOrigin: Rect.fromLTWH(0, 0, screenSize.width, screenSize.height / 2),
      ),
    );
  }

  void _showSortSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.large)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(l10n.shoppingSortByTitle, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  _buildSortOptionRow(
                    context: context,
                    icon: Icons.category_outlined,
                    label: l10n.recipeFilterCategoryLabel,
                    selected: !_groupByRecipe,
                    onTap: () {
                      setState(() => _groupByRecipe = false);
                      Navigator.of(context).pop();
                    },
                  ),
                  _buildSortOptionRow(
                    context: context,
                    icon: Icons.restaurant_menu_outlined,
                    label: l10n.planRecipeFieldLabel,
                    selected: _groupByRecipe,
                    onTap: () {
                      setState(() => _groupByRecipe = true);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSortOptionRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.surfaceSoft : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primaryDark),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
            if (selected) const Icon(Icons.check, size: 20, color: AppColors.primaryDark),
          ],
        ),
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount == amount.roundToDouble()) return amount.toInt().toString();
    return amount.toString();
  }

  // "Week 30 · Aug 3 – Aug 9" for the week this Weekly Plan list is
  // currently generated from — mirrors the Plan screen's header format.
  String _weekRangeLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final monday = now
        .subtract(Duration(days: now.weekday - 1))
        .add(Duration(days: 7 * widget.weekOffset));
    final sunday = monday.add(const Duration(days: 6));
    final weekNum = isoWeekNumberForMonday(monday);
    final locale = Localizations.localeOf(context).toString();
    final shortDate = DateFormat.MMMd(locale);
    return '${l10n.planWeekNumberLabel(weekNum)} · ${shortDate.format(monday)} – ${shortDate.format(sunday)}';
  }

  String _itemKey(ShoppingListItem item) =>
      '${item.name.toLowerCase()}-${item.unit.toLowerCase()}';

  String _formatPlanKey(AppLocalizations l10n, String key) {
    final dash = key.lastIndexOf('-');
    if (dash == -1) return localizedDayName(l10n, key);
    final day = key.substring(0, dash);
    final meal = key.substring(dash + 1);
    const mealTypes = {
      'breakfast': MealType.breakfast,
      'lunch': MealType.lunch,
      'dinner': MealType.dinner,
    };
    final mealLabel = mealTypes.containsKey(meal)
        ? localizedMealTypeLabel(l10n, mealTypes[meal]!)
        : meal;
    return '${localizedDayName(l10n, day)} · $mealLabel';
  }

  Map<String, List<ShoppingListItem>> _groupItemsByCategory(List<ShoppingListItem> items) {
    final grouped = <String, List<ShoppingListItem>>{};
    for (final item in items) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }
    final sorted = grouped.entries.toList()
      ..sort((a, b) {
        final ai = _categoryOrder.indexOf(a.key);
        final bi = _categoryOrder.indexOf(b.key);
        if (ai == -1 && bi == -1) return a.key.compareTo(b.key);
        if (ai == -1) return 1;
        if (bi == -1) return -1;
        return ai.compareTo(bi);
      });
    return Map.fromEntries(sorted);
  }

  List<_RecipeSection> _buildRecipeSections() {
    final l10n = AppLocalizations.of(context)!;
    if (_isQuickMode) {
      return widget.quickRecipes.map((recipe) {
        final items = generateShoppingListFromRecipes([recipe]);
        return _RecipeSection(
          sectionKey: 'quick-${recipe.id}',
          recipeName: recipe.name,
          subtitle: l10n.shoppingServingCount(recipe.servings),
          icon: Icons.restaurant_menu_outlined,
          iconColor: AppColors.primaryDark,
          iconBgColor: AppColors.surfaceSoft,
          items: items,
        );
      }).toList();
    }

    final entries = widget.plannedRecipes.entries.toList()
      ..sort((a, b) {
        final aDash = a.key.lastIndexOf('-');
        final bDash = b.key.lastIndexOf('-');
        final aDay = aDash == -1 ? a.key : a.key.substring(0, aDash);
        final bDay = bDash == -1 ? b.key : b.key.substring(0, bDash);
        final aMeal = aDash == -1 ? '' : a.key.substring(aDash + 1);
        final bMeal = bDash == -1 ? '' : b.key.substring(bDash + 1);
        final dc = _dayOrder.indexOf(aDay).compareTo(_dayOrder.indexOf(bDay));
        if (dc != 0) return dc;
        return _mealOrder.indexOf(aMeal).compareTo(_mealOrder.indexOf(bMeal));
      });

    return entries.map((entry) {
      final pr = entry.value;
      final items = generateShoppingListFromRecipes(
        [pr.recipe],
        multipliers: [pr.servingsMultiplier],
      );
      final dash = entry.key.lastIndexOf('-');
      final meal = dash == -1 ? '' : entry.key.substring(dash + 1);

      final IconData icon;
      final Color iconColor, iconBgColor;
      switch (meal) {
        case 'breakfast':
          icon = MealType.breakfast.icon;
          iconColor = MealType.breakfast.onSurfaceColor;
          iconBgColor = MealType.breakfast.surfaceColor;
        case 'lunch':
          icon = MealType.lunch.icon;
          iconColor = MealType.lunch.onSurfaceColor;
          iconBgColor = MealType.lunch.surfaceColor;
        case 'dinner':
          icon = MealType.dinner.icon;
          iconColor = MealType.dinner.onSurfaceColor;
          iconBgColor = MealType.dinner.surfaceColor;
        default:
          icon = Icons.restaurant_menu_outlined;
          iconColor = AppColors.primaryDark;
          iconBgColor = AppColors.surfaceSoft;
      }

      return _RecipeSection(
        sectionKey: 'weekly-${entry.key}',
        recipeName: pr.recipe.name,
        subtitle: _formatPlanKey(l10n, entry.key),
        icon: icon,
        iconColor: iconColor,
        iconBgColor: iconBgColor,
        items: items,
      );
    }).toList();
  }

  void _checkAll(List<ShoppingListItem> items) {
    for (final item in items) {
      widget.onItemCheckedChanged(_itemKey(item), true);
    }
  }

  void _uncheckAll(List<ShoppingListItem> items) {
    for (final item in items) {
      widget.onItemCheckedChanged(_itemKey(item), false);
    }
  }

  void _checkRecipeSection(List<ShoppingListItem> items, bool check) {
    for (final item in items) {
      widget.onItemCheckedChanged(_itemKey(item), check);
    }
  }

  Widget _buildInlineRecipeSelector() {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.restaurant_menu_outlined, size: 16, color: AppColors.primaryDark),
                const SizedBox(width: 6),
                Text(l10n.navRecipes, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1C19))),
                const Spacer(),
                if (widget.quickRecipes.isNotEmpty)
                  TextButton(
                    onPressed: widget.onClearQuickRecipes,
                    style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(l10n.commonClearAll, style: const TextStyle(fontSize: 12)),
                  ),
              ],
            ),
            if (widget.allRecipes.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(l10n.shoppingNoRecipesYet,
                  style: TextStyle(fontSize: 13, color: Colors.grey[500])),
              )
            else
              ...widget.allRecipes.map((recipe) {
                final isSelected = widget.quickRecipes.any((r) => r.id == recipe.id);
                return InkWell(
                  onTap: () => widget.onToggleQuickRecipe(recipe.id),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primaryDark : Colors.transparent,
                            border: Border.all(
                              color: isSelected ? AppColors.primaryDark : Theme.of(context).dividerColor,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: isSelected ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(recipe.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isSelected ? const Color(0xFF1A1C19) : Colors.grey[700],
                            )),
                        ),
                        Text('${localizedRecipeCategory(l10n, recipe.category)} · ${recipe.servings} ${l10n.shoppingServingsAbbrev}',
                          style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                      ],
                    ),
                  ),
                );
              }),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeSectionWidget(_RecipeSection section) {
    final allChecked = section.items.isNotEmpty &&
        section.items.every((i) => widget.checkedItemKeys.contains(_itemKey(i)));
    final checkedCount = section.items.where((i) => widget.checkedItemKeys.contains(_itemKey(i))).length;
    final displayItems = section.items;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: section.iconBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(section.icon, size: 18, color: section.iconColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section.recipeName,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1C19)),
                    ),
                    Text(
                      section.subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: allChecked ? AppColors.primaryDark : AppColors.surfaceSoft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$checkedCount/${section.items.length}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: allChecked ? Colors.white : AppColors.primaryDark,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => _checkRecipeSection(section.items, !allChecked),
                child: Icon(
                  allChecked ? Icons.check_circle : Icons.check_circle_outline,
                  size: 22,
                  color: allChecked ? AppColors.primaryDark : Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
        ...displayItems.map((item) => _buildItemRow(item, keyPrefix: section.sectionKey)),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildCustomItemsSection() {
    final l10n = AppLocalizations.of(context)!;
    final customItems = _customShoppingItems();
    final displayItems = customItems;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.surfaceSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.list_alt_outlined, size: 18, color: AppColors.primaryDark),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.shoppingMyItemsSection,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1C19)),
                ),
              ),
            ],
          ),
        ),
        ...displayItems.map((item) => _buildItemRow(item, keyPrefix: 'custom')),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildItemRow(ShoppingListItem item, {required String keyPrefix}) {
    final isChecked = widget.checkedItemKeys.contains(_itemKey(item));
    final card = Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => widget.onItemCheckedChanged(_itemKey(item), !isChecked),
        child: Padding(
          padding: EdgeInsets.only(
            left: 12,
            top: 10,
            bottom: 10,
            right: item.isCustom ? 4 : 12,
          ),
          child: Row(
            children: [
              _checkbox(isChecked),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    decoration: isChecked ? TextDecoration.lineThrough : null,
                    color: isChecked ? Theme.of(context).disabledColor : null,
                  ),
                ),
              ),
              if (item.unit.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isChecked
                        ? Theme.of(context).disabledColor.withValues(alpha: 0.1)
                        : AppColors.surfaceSoft,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_formatAmount(item.amount)} ${item.unit}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isChecked ? Theme.of(context).disabledColor : AppColors.primaryDark,
                    ),
                  ),
                ),
              if (item.isCustom)
                IconButton(
                  onPressed: () => widget.onRemoveCustomItem(item.name),
                  icon: const Icon(Icons.close, size: 16),
                  color: Colors.grey[400],
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                ),
            ],
          ),
        ),
      ),
    );

    // Swipe-left-to-delete on every row: custom items are removed for good,
    // recipe-derived items are added to the excluded set (so they stay
    // hidden from the generated list until the plan changes/regenerates).
    return Dismissible(
      key: ValueKey('$keyPrefix-${_itemKey(item)}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: const Color(0xFFFBE4E6),
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: const Icon(Icons.delete_outline, color: Color(0xFFD8434F)),
      ),
      onDismissed: (_) {
        if (item.isCustom) {
          widget.onRemoveCustomItem(item.name);
        } else {
          widget.onExcludeItem(_itemKey(item));
        }
      },
      child: card,
    );
  }

  Widget _checkbox(bool isChecked) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: isChecked ? AppColors.primaryDark : Colors.transparent,
        border: Border.all(
          color: isChecked ? AppColors.primaryDark : Theme.of(context).dividerColor,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: isChecked ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
    );
  }

  Widget _buildCategorySection(String category, List<ShoppingListItem> items) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              _categoryIcon(category),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  localizedMarketCategory(l10n, category),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1C19)),
                ),
              ),
            ],
          ),
        ),
        ...items.map((item) => _buildItemRow(item, keyPrefix: 'category-$category')),
        const SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final computed = _computeShoppingItems();
    final shoppingItems = computed.items;
    final hasContent = computed.hasContent;
    final groupedItems = _groupItemsByCategory(shoppingItems);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Heading + share/add actions
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(
            children: [
              Expanded(
                child: Text(l10n.shoppingListHeading, style: AppTextStyles.pageHeading),
              ),
              IconButton.filledTonal(
                icon: const Icon(Icons.ios_share_outlined),
                tooltip: l10n.shoppingShareTooltip,
                onPressed: hasContent ? _shareShoppingList : null,
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surfaceSoft,
                  foregroundColor: AppColors.primaryDark,
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                icon: const Icon(Icons.add),
                tooltip: l10n.shoppingAddItemTooltip,
                onPressed: openAddCustomItemSheet,
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surfaceSoft,
                  foregroundColor: AppColors.primaryDark,
                ),
              ),
            ],
          ),
        ),

        // Mode toggle
        Card(
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: SegmentedButton<bool>(
              segments: [
                ButtonSegment(
                  value: false,
                  icon: const Icon(Icons.calendar_month_outlined),
                  label: Text(l10n.shoppingWeeklyPlanMode),
                ),
                ButtonSegment(
                  value: true,
                  icon: const Icon(Icons.bolt_outlined),
                  label: Text(l10n.shoppingQuickListMode),
                ),
              ],
              selected: {_isQuickMode},
              onSelectionChanged: (value) => setState(() => _isQuickMode = value.first),
              style: ButtonStyle(
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) return AppColors.primaryDark;
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
          ),
        ),

        const SizedBox(height: 8),

        // Week number + date range — Weekly Plan mode only, so it's clear
        // which week this generated list belongs to.
        if (!_isQuickMode) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 6),
                Text(
                  _weekRangeLabel(context),
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],

        // Select all + sort control
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              SizedBox(
                height: 24,
                width: 24,
                child: Checkbox(
                  value: hasContent && allItemsChecked,
                  onChanged: hasContent ? (_) => toggleCheckAll() : null,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.shoppingSelectAll,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[700]),
              ),
              const Spacer(),
              if (hasContent)
                IconButton(
                  icon: const Icon(Icons.storefront_outlined),
                  color: AppColors.primaryDark,
                  tooltip: l10n.shoppingOnlineTooltip,
                  onPressed: () => showShopLinksSheet(context),
                ),
              IconButton(
                icon: const Icon(Icons.swap_vert),
                color: AppColors.primaryDark,
                tooltip: l10n.shoppingSortTooltip(
                  _groupByRecipe ? l10n.planRecipeFieldLabel : l10n.recipeFilterCategoryLabel,
                ),
                onPressed: () => _showSortSheet(context),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Quick List: inline recipe selector (custom items are added via the
        // AppBar "+" button/sheet, which works in either mode)
        if (_isQuickMode) ...[
          _buildInlineRecipeSelector(),
          const SizedBox(height: 8),
        ],

        // Empty state (weekly plan mode only)
        if (!hasContent) ...[
          if (!_isQuickMode)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSoft,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.shopping_basket_outlined, size: 40, color: AppColors.primaryDark),
                    ),
                    const SizedBox(height: 20),
                    Text(l10n.shoppingEmptyTitle, style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    Text(
                      l10n.shoppingEmptyMessage,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      children: [
                        Chip(
                          avatar: const Icon(Icons.calendar_month_outlined, size: 16),
                          label: Text(l10n.shoppingGoToPlanChip),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ] else ...[
          // Content — just the list, no progress/action clutter (those live
          // in the AppBar for this tab now).
          if (_groupByRecipe) ...[
            ..._buildRecipeSections().map(_buildRecipeSectionWidget),
            if (widget.customQuickItems.isNotEmpty) _buildCustomItemsSection(),
          ] else ...[
            ...groupedItems.entries.map((entry) => _buildCategorySection(entry.key, entry.value)),
          ],
        ],
      ],
    );
  }

  Widget _categoryIcon(String category) {
    final icons = {
      'Vegetables': Icons.eco_outlined,
      'Fruit': Icons.apple_outlined,
      'Meat': Icons.set_meal_outlined,
      'Dairy': Icons.egg_outlined,
      'Bakery': Icons.breakfast_dining_outlined,
      'Pantry': Icons.kitchen_outlined,
      'Frozen': Icons.ac_unit_outlined,
      'Drinks': Icons.local_drink_outlined,
      'Snacks': Icons.cookie_outlined,
      'Other': Icons.category_outlined,
    };
    return Icon(
      icons[category] ?? Icons.category_outlined,
      size: 18,
      color: AppColors.primaryDark,
    );
  }
}
