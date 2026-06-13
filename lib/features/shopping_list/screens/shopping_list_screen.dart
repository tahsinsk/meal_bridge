import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../data/shopping_list_generator.dart';
import '../../../models/planned_recipe.dart';
import '../../../models/recipe.dart';
import '../../../models/shopping_list_item.dart';

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
  final VoidCallback onClearCheckedItems;
  final void Function(String recipeId) onToggleQuickRecipe;
  final VoidCallback onClearQuickRecipes;
  final List<String> customQuickItems;
  final void Function(String itemName) onAddCustomItem;
  final void Function(String itemName) onRemoveCustomItem;

  const ShoppingListScreen({
    super.key,
    required this.plannedRecipes,
    required this.quickRecipes,
    required this.allRecipes,
    required this.checkedItemKeys,
    required this.onItemCheckedChanged,
    required this.onClearCheckedItems,
    required this.onToggleQuickRecipe,
    required this.onClearQuickRecipes,
    required this.customQuickItems,
    required this.onAddCustomItem,
    required this.onRemoveCustomItem,
  });

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  bool _isQuickMode = false;
  bool _checkedAtBottom = true;
  bool _groupByRecipe = false;

  final TextEditingController _customItemController = TextEditingController();

  static const List<String> _categoryOrder = [
    'Vegetables', 'Fruit', 'Meat', 'Dairy', 'Bakery',
    'Pantry', 'Frozen', 'Drinks', 'Snacks', 'Other',
  ];

  static const List<String> _dayOrder = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
  ];

  static const List<String> _mealOrder = ['breakfast', 'lunch', 'dinner'];

  @override
  void dispose() {
    _customItemController.dispose();
    super.dispose();
  }

  void _addCustomItem(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    widget.onAddCustomItem(trimmed);
    _customItemController.clear();
  }

  String _formatAmount(double amount) {
    if (amount == amount.roundToDouble()) return amount.toInt().toString();
    return amount.toString();
  }

  String _itemKey(ShoppingListItem item) =>
      '${item.name.toLowerCase()}-${item.unit.toLowerCase()}';

  String _customItemKey(String name) => '${name.toLowerCase()}-';

  String _formatPlanKey(String key) {
    final dash = key.lastIndexOf('-');
    if (dash == -1) return key;
    final day = key.substring(0, dash);
    final meal = key.substring(dash + 1);
    const mealLabels = {'breakfast': 'Breakfast', 'lunch': 'Lunch', 'dinner': 'Dinner'};
    return '$day · ${mealLabels[meal] ?? meal}';
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
    if (_isQuickMode) {
      return widget.quickRecipes.map((recipe) {
        final items = generateShoppingListFromRecipes([recipe]);
        return _RecipeSection(
          sectionKey: 'quick-${recipe.id}',
          recipeName: recipe.name,
          subtitle: '${recipe.servings} serving${recipe.servings != 1 ? 's' : ''}',
          icon: Icons.restaurant_menu_outlined,
          iconColor: const Color(0xFF2E7D32),
          iconBgColor: const Color(0xFFE8F5E9),
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
          icon = Icons.wb_sunny_outlined;
          iconColor = const Color(0xFFF57F17);
          iconBgColor = const Color(0xFFFFF8E1);
        case 'lunch':
          icon = Icons.wb_cloudy_outlined;
          iconColor = const Color(0xFF1565C0);
          iconBgColor = const Color(0xFFE3F2FD);
        case 'dinner':
          icon = Icons.nightlight_outlined;
          iconColor = const Color(0xFF4527A0);
          iconBgColor = const Color(0xFFEDE7F6);
        default:
          icon = Icons.restaurant_menu_outlined;
          iconColor = const Color(0xFF2E7D32);
          iconBgColor = const Color(0xFFE8F5E9);
      }

      return _RecipeSection(
        sectionKey: 'weekly-${entry.key}',
        recipeName: pr.recipe.name,
        subtitle: _formatPlanKey(entry.key),
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
    for (final name in widget.customQuickItems) {
      widget.onItemCheckedChanged(_customItemKey(name), true);
    }
  }

  void _uncheckAll(List<ShoppingListItem> items) {
    for (final item in items) {
      widget.onItemCheckedChanged(_itemKey(item), false);
    }
    for (final name in widget.customQuickItems) {
      widget.onItemCheckedChanged(_customItemKey(name), false);
    }
  }

  void _checkCategory(List<ShoppingListItem> items, bool check) {
    for (final item in items) {
      widget.onItemCheckedChanged(_itemKey(item), check);
    }
  }

  void _checkRecipeSection(List<ShoppingListItem> items, bool check) {
    for (final item in items) {
      widget.onItemCheckedChanged(_itemKey(item), check);
    }
  }

  Future<void> _copyShoppingList(
    BuildContext context,
    Map<String, List<ShoppingListItem>> groupedItems,
  ) async {
    final buffer = StringBuffer('MealBridge Shopping List\n\n');
    for (final entry in groupedItems.entries) {
      buffer.writeln(entry.key);
      for (final item in entry.value) {
        final isChecked = widget.checkedItemKeys.contains(_itemKey(item));
        final amountStr = item.unit.isEmpty ? '' : '${_formatAmount(item.amount)} ${item.unit} ';
        buffer.writeln('${isChecked ? '[x]' : '[ ]'} $amountStr${item.name}');
      }
      buffer.writeln();
    }
    await Clipboard.setData(ClipboardData(text: buffer.toString().trim()));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Shopping list copied.')),
    );
  }

  Future<void> _copyUncheckedShoppingList(
    BuildContext context,
    Map<String, List<ShoppingListItem>> groupedItems,
  ) async {
    final buffer = StringBuffer('MealBridge Shopping List\n\n');
    for (final entry in groupedItems.entries) {
      final unchecked = entry.value.where((i) => !widget.checkedItemKeys.contains(_itemKey(i)));
      if (unchecked.isEmpty) continue;
      buffer.writeln(entry.key);
      for (final item in unchecked) {
        final amountStr = item.unit.isEmpty ? '' : '${_formatAmount(item.amount)} ${item.unit} ';
        buffer.writeln('[ ] $amountStr${item.name}');
      }
      buffer.writeln();
    }
    final text = buffer.toString().trim();
    if (text == 'MealBridge Shopping List') {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No unchecked items to copy.')),
      );
      return;
    }
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Unchecked shopping items copied.')),
    );
  }

  Widget _buildInlineRecipeSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.restaurant_menu_outlined, size: 16, color: Color(0xFF2E7D32)),
                const SizedBox(width: 6),
                const Text('Recipes', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1C19))),
                const Spacer(),
                if (widget.quickRecipes.isNotEmpty)
                  TextButton(
                    onPressed: widget.onClearQuickRecipes,
                    style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Clear all', style: TextStyle(fontSize: 12)),
                  ),
              ],
            ),
            if (widget.allRecipes.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text('No recipes yet. Add some in the Recipes tab.',
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
                            color: isSelected ? const Color(0xFF2E7D32) : Colors.transparent,
                            border: Border.all(
                              color: isSelected ? const Color(0xFF2E7D32) : Theme.of(context).dividerColor,
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
                        Text('${recipe.category} · ${recipe.servings} srv',
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

    final displayItems = _checkedAtBottom
        ? [
            ...section.items.where((i) => !widget.checkedItemKeys.contains(_itemKey(i))),
            ...section.items.where((i) => widget.checkedItemKeys.contains(_itemKey(i))),
          ]
        : section.items;

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
                  color: allChecked ? const Color(0xFF2E7D32) : const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$checkedCount/${section.items.length}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: allChecked ? Colors.white : const Color(0xFF2E7D32),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => _checkRecipeSection(section.items, !allChecked),
                child: Icon(
                  allChecked ? Icons.check_circle : Icons.check_circle_outline,
                  size: 22,
                  color: allChecked ? const Color(0xFF2E7D32) : Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
        ...displayItems.map((item) => _buildItemRow(item)),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildCustomItemsSection() {
    final displayNames = _checkedAtBottom
        ? [
            ...widget.customQuickItems.where((n) => !widget.checkedItemKeys.contains(_customItemKey(n))),
            ...widget.customQuickItems.where((n) => widget.checkedItemKeys.contains(_customItemKey(n))),
          ]
        : widget.customQuickItems;

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
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.list_alt_outlined, size: 18, color: Color(0xFF2E7D32)),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'My Items',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1C19)),
                ),
              ),
            ],
          ),
        ),
        ...displayNames.map((name) => _buildCustomItemRow(name)),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildItemRow(ShoppingListItem item) {
    final isChecked = widget.checkedItemKeys.contains(_itemKey(item));
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => widget.onItemCheckedChanged(_itemKey(item), !isChecked),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                        : const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_formatAmount(item.amount)} ${item.unit}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isChecked ? Theme.of(context).disabledColor : const Color(0xFF2E7D32),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomItemRow(String name) {
    final key = _customItemKey(name);
    final isChecked = widget.checkedItemKeys.contains(key);
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => widget.onItemCheckedChanged(key, !isChecked),
        child: Padding(
          padding: const EdgeInsets.only(left: 12, top: 6, bottom: 6, right: 4),
          child: Row(
            children: [
              _checkbox(isChecked),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    decoration: isChecked ? TextDecoration.lineThrough : null,
                    color: isChecked ? Theme.of(context).disabledColor : null,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => widget.onRemoveCustomItem(name),
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
  }

  Widget _checkbox(bool isChecked) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: isChecked ? const Color(0xFF2E7D32) : Colors.transparent,
        border: Border.all(
          color: isChecked ? const Color(0xFF2E7D32) : Theme.of(context).dividerColor,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: isChecked ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
    );
  }

  Widget _buildCategorySection(String category, List<ShoppingListItem> items) {
    final categoryCheckedCount = items.where((i) => widget.checkedItemKeys.contains(_itemKey(i))).length;
    final allCategoryChecked = categoryCheckedCount == items.length;

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
                  category,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1C19)),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: allCategoryChecked ? const Color(0xFF2E7D32) : const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$categoryCheckedCount/${items.length}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: allCategoryChecked ? Colors.white : const Color(0xFF2E7D32),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => _checkCategory(items, !allCategoryChecked),
                child: Icon(
                  allCategoryChecked ? Icons.check_circle : Icons.check_circle_outline,
                  size: 22,
                  color: allCategoryChecked ? const Color(0xFF2E7D32) : Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
        ...items.map((item) => item.unit.isEmpty
            ? _buildCustomItemRow(item.name)
            : _buildItemRow(item)),
        const SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Recipe> activeRecipes;
    final List<double>? activeMultipliers;

    if (_isQuickMode) {
      activeRecipes = widget.quickRecipes;
      activeMultipliers = null;
    } else {
      activeRecipes = widget.plannedRecipes.values.map((pr) => pr.recipe).toList();
      activeMultipliers = widget.plannedRecipes.values.map((pr) => pr.servingsMultiplier).toList();
    }

    // Merge custom items when in quick mode
    final recipeShoppingItems = generateShoppingListFromRecipes(activeRecipes, multipliers: activeMultipliers);
    final customShoppingItems = (_isQuickMode && widget.customQuickItems.isNotEmpty)
        ? widget.customQuickItems
            .map((name) => ShoppingListItem(name: name, amount: 1, unit: '', category: 'Other'))
            .toList()
        : <ShoppingListItem>[];
    final shoppingItems = [...recipeShoppingItems, ...customShoppingItems];

    final checkedCount = shoppingItems.where((i) => widget.checkedItemKeys.contains(_itemKey(i))).length;
    final totalCount = shoppingItems.length;
    final allChecked = totalCount > 0 && checkedCount == totalCount;
    final progress = totalCount > 0 ? checkedCount / totalCount : 0.0;

    final sortedItems = _checkedAtBottom
        ? [
            ...shoppingItems.where((i) => !widget.checkedItemKeys.contains(_itemKey(i))),
            ...shoppingItems.where((i) => widget.checkedItemKeys.contains(_itemKey(i))),
          ]
        : shoppingItems;
    final groupedItems = _groupItemsByCategory(sortedItems);

    final hasContent = activeRecipes.isNotEmpty ||
        (_isQuickMode && widget.customQuickItems.isNotEmpty);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Mode toggle
        Card(
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: false,
                  icon: Icon(Icons.calendar_month_outlined),
                  label: Text('Weekly Plan'),
                ),
                ButtonSegment(
                  value: true,
                  icon: Icon(Icons.bolt_outlined),
                  label: Text('Quick List'),
                ),
              ],
              selected: {_isQuickMode},
              onSelectionChanged: (value) => setState(() => _isQuickMode = value.first),
              style: ButtonStyle(
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Sort order row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Icon(Icons.sort_outlined, size: 15, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(
                'Sort by',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
              const SizedBox(width: 2),
              Theme(
                data: Theme.of(context).copyWith(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                ),
                child: DropdownButton<bool>(
                  value: _groupByRecipe,
                  underline: const SizedBox(),
                  isDense: true,
                  onChanged: (v) => setState(() => _groupByRecipe = v!),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E7D32),
                  ),
                  items: const [
                    DropdownMenuItem(value: false, child: Text('Category')),
                    DropdownMenuItem(value: true, child: Text('Recipe')),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Quick List: custom item input + inline recipe selector
        if (_isQuickMode) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.add_shopping_cart_outlined, size: 20, color: Color(0xFF2E7D32)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _customItemController,
                      decoration: const InputDecoration(
                        hintText: 'Add custom item…',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        fillColor: Colors.transparent,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: _addCustomItem,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _addCustomItem(_customItemController.text),
                    icon: const Icon(Icons.add_circle_outlined),
                    color: const Color(0xFF2E7D32),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
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
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.shopping_basket_outlined, size: 40, color: Color(0xFF2E7D32)),
                    ),
                    const SizedBox(height: 20),
                    Text('No shopping list yet', style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    Text(
                      'Plan recipes for the week and your shopping list will appear here automatically.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 20),
                    const Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      children: [
                        Chip(
                          avatar: Icon(Icons.calendar_month_outlined, size: 16),
                          label: Text('Go to Plan tab'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ] else ...[
          // Progress card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              allChecked ? 'All done! 🎉' : '$checkedCount of $totalCount items',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              allChecked ? 'Shopping complete' : '${totalCount - checkedCount} remaining',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => allChecked ? _uncheckAll(shoppingItems) : _checkAll(shoppingItems),
                        icon: Icon(allChecked ? Icons.remove_done_outlined : Icons.done_all_outlined),
                        label: Text(allChecked ? 'Uncheck all' : 'Check all'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: const Color(0xFFE8F5E9),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        allChecked ? const Color(0xFF2E7D32) : const Color(0xFF66BB6A),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Action bar
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          TextButton.icon(
                            onPressed: () => _copyShoppingList(context, groupedItems),
                            icon: const Icon(Icons.copy_outlined, size: 18),
                            label: const Text('Copy'),
                          ),
                          TextButton.icon(
                            onPressed: () => _copyUncheckedShoppingList(context, groupedItems),
                            icon: const Icon(Icons.playlist_add_check_outlined, size: 18),
                            label: const Text('Copy unchecked'),
                          ),
                          if (widget.checkedItemKeys.isNotEmpty)
                            TextButton.icon(
                              onPressed: widget.onClearCheckedItems,
                              icon: const Icon(Icons.cleaning_services_outlined, size: 18),
                              label: const Text('Clear checked'),
                            ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _checkedAtBottom = !_checkedAtBottom),
                    icon: const Icon(Icons.sort_outlined),
                    tooltip: _checkedAtBottom ? 'Checked items at bottom' : 'Keep original order',
                    style: IconButton.styleFrom(
                      backgroundColor: _checkedAtBottom ? const Color(0xFFE8F5E9) : null,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Content
          if (_groupByRecipe) ...[
            ..._buildRecipeSections().map(_buildRecipeSectionWidget),
            if (_isQuickMode && widget.customQuickItems.isNotEmpty)
              _buildCustomItemsSection(),
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
      color: const Color(0xFF2E7D32),
    );
  }
}
