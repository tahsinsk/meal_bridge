import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../data/shopping_list_generator.dart';
import '../../../models/planned_recipe.dart';
import '../../../models/recipe.dart';
import '../../../models/shopping_list_item.dart';

class ShoppingListScreen extends StatefulWidget {
  final Map<String, PlannedRecipe> plannedRecipes;
  final List<Recipe> quickRecipes;
  final List<Recipe> allRecipes;
  final Set<String> checkedItemKeys;
  final void Function(String itemKey, bool isChecked) onItemCheckedChanged;
  final VoidCallback onClearCheckedItems;
  final void Function(String recipeId) onToggleQuickRecipe;
  final VoidCallback onClearQuickRecipes;

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
  });

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  bool _isQuickMode = false;
  bool _checkedAtBottom = true;

  static const List<String> _categoryOrder = [
    'Vegetables',
    'Fruit',
    'Meat',
    'Dairy',
    'Bakery',
    'Pantry',
    'Frozen',
    'Drinks',
    'Snacks',
    'Other',
  ];

  String _formatAmount(double amount) {
    if (amount == amount.roundToDouble()) {
      return amount.toInt().toString();
    }
    return amount.toString();
  }

  String _itemKey(ShoppingListItem item) {
    return '${item.name.toLowerCase()}-${item.unit.toLowerCase()}';
  }

  Map<String, List<ShoppingListItem>> _groupItemsByCategory(
    List<ShoppingListItem> items,
  ) {
    final groupedItems = <String, List<ShoppingListItem>>{};

    for (final item in items) {
      groupedItems.putIfAbsent(item.category, () => []);
      groupedItems[item.category]!.add(item);
    }

    final sortedEntries = groupedItems.entries.toList()
      ..sort((a, b) {
        final aIndex = _categoryOrder.indexOf(a.key);
        final bIndex = _categoryOrder.indexOf(b.key);
        if (aIndex == -1 && bIndex == -1) return a.key.compareTo(b.key);
        if (aIndex == -1) return 1;
        if (bIndex == -1) return -1;
        return aIndex.compareTo(bIndex);
      });

    return Map.fromEntries(sortedEntries);
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

  void _checkCategory(List<ShoppingListItem> items, bool check) {
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
        final checkbox = isChecked ? '[x]' : '[ ]';
        buffer.writeln(
          '$checkbox ${_formatAmount(item.amount)} ${item.unit} ${item.name}',
        );
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
      final uncheckedItems = entry.value.where(
        (item) => !widget.checkedItemKeys.contains(_itemKey(item)),
      );
      if (uncheckedItems.isEmpty) continue;
      buffer.writeln(entry.key);
      for (final item in uncheckedItems) {
        buffer.writeln(
          '[ ] ${_formatAmount(item.amount)} ${item.unit} ${item.name}',
        );
      }
      buffer.writeln();
    }
    final copiedText = buffer.toString().trim();
    if (copiedText == 'MealBridge Shopping List') {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No unchecked items to copy.')),
      );
      return;
    }
    await Clipboard.setData(ClipboardData(text: copiedText));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Unchecked shopping items copied.')),
    );
  }

  void _showRecipePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.6,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              expand: false,
              builder: (context, scrollController) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Row(
                        children: [
                          const Icon(Icons.shopping_basket_outlined),
                          const SizedBox(width: 8),
                          Text(
                            'Select recipes',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const Spacer(),
                          if (widget.quickRecipes.isNotEmpty)
                            TextButton(
                              onPressed: () {
                                widget.onClearQuickRecipes();
                                setModalState(() {});
                              },
                              child: const Text('Clear all'),
                            ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: widget.allRecipes.isEmpty
                          ? const Center(
                              child: Text('No recipes yet. Add some first!'),
                            )
                          : ListView.builder(
                              controller: scrollController,
                              padding: const EdgeInsets.all(8),
                              itemCount: widget.allRecipes.length,
                              itemBuilder: (context, index) {
                                final recipe = widget.allRecipes[index];
                                final isSelected = widget.quickRecipes
                                    .any((r) => r.id == recipe.id);
                                return Card(
                                  child: CheckboxListTile(
                                    value: isSelected,
                                    onChanged: (_) {
                                      widget.onToggleQuickRecipe(recipe.id);
                                      setModalState(() {});
                                    },
                                    title: Text(recipe.name),
                                    subtitle: Text(
                                      '${recipe.category} • ${recipe.servings} servings',
                                    ),
                                    secondary: const Icon(
                                      Icons.restaurant_menu_outlined,
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            widget.quickRecipes.isEmpty
                                ? 'Done'
                                : 'Done (${widget.quickRecipes.length} selected)',
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
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
      activeRecipes =
          widget.plannedRecipes.values.map((pr) => pr.recipe).toList();
      activeMultipliers = widget.plannedRecipes.values
          .map((pr) => pr.servingsMultiplier)
          .toList();
    }

    final shoppingItems = generateShoppingListFromRecipes(
      activeRecipes,
      multipliers: activeMultipliers,
    );

    // İşaretlenenleri alta it
    final sortedItems = _checkedAtBottom
        ? [
            ...shoppingItems.where(
              (i) => !widget.checkedItemKeys.contains(_itemKey(i)),
            ),
            ...shoppingItems.where(
              (i) => widget.checkedItemKeys.contains(_itemKey(i)),
            ),
          ]
        : shoppingItems;

    final groupedItems = _groupItemsByCategory(sortedItems);
    final checkedCount = shoppingItems
        .where((i) => widget.checkedItemKeys.contains(_itemKey(i)))
        .length;
    final totalCount = shoppingItems.length;
    final allChecked = totalCount > 0 && checkedCount == totalCount;
    final progress = totalCount > 0 ? checkedCount / totalCount : 0.0;

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
              onSelectionChanged: (value) =>
                  setState(() => _isQuickMode = value.first),
              style: ButtonStyle(
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Empty state
        if (activeRecipes.isEmpty) ...[
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
                    child: Icon(
                      _isQuickMode
                          ? Icons.bolt_outlined
                          : Icons.shopping_basket_outlined,
                      size: 40,
                      color: const Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _isQuickMode
                        ? 'No recipes selected'
                        : 'No shopping list yet',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isQuickMode
                        ? 'Pick recipes below to generate a shopping list instantly.'
                        : 'Plan recipes for the week and your shopping list will appear here automatically.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  if (_isQuickMode)
                    FilledButton.icon(
                      onPressed: () => _showRecipePicker(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Select recipes'),
                    )
                  else
                    const Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      children: [
                        Chip(
                          avatar: Icon(
                            Icons.calendar_month_outlined,
                            size: 16,
                          ),
                          label: Text('Go to Plan tab'),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ] else ...[
          // Progress kartı
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
                              allChecked
                                  ? 'All done! 🎉'
                                  : '$checkedCount of $totalCount items',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              allChecked
                                  ? 'Shopping complete'
                                  : '${totalCount - checkedCount} remaining',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      // Tümünü işaretle / kaldır
                      TextButton.icon(
                        onPressed: () => allChecked
                            ? _uncheckAll(shoppingItems)
                            : _checkAll(shoppingItems),
                        icon: Icon(
                          allChecked
                              ? Icons.remove_done_outlined
                              : Icons.done_all_outlined,
                        ),
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
                        allChecked
                            ? const Color(0xFF2E7D32)
                            : const Color(0xFF66BB6A),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Aksiyon butonları
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  if (_isQuickMode) ...[
                    IconButton(
                      onPressed: () => _showRecipePicker(context),
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: 'Edit recipes',
                    ),
                    const VerticalDivider(width: 1),
                  ],
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          TextButton.icon(
                            onPressed: () =>
                                _copyShoppingList(context, groupedItems),
                            icon: const Icon(Icons.copy_outlined, size: 18),
                            label: const Text('Copy'),
                          ),
                          TextButton.icon(
                            onPressed: () => _copyUncheckedShoppingList(
                              context,
                              groupedItems,
                            ),
                            icon: const Icon(
                              Icons.playlist_add_check_outlined,
                              size: 18,
                            ),
                            label: const Text('Copy unchecked'),
                          ),
                          if (widget.checkedItemKeys.isNotEmpty)
                            TextButton.icon(
                              onPressed: widget.onClearCheckedItems,
                              icon: const Icon(
                                Icons.cleaning_services_outlined,
                                size: 18,
                              ),
                              label: const Text('Clear checked'),
                            ),
                        ],
                      ),
                    ),
                  ),
                  // İşaretlenenleri alta it toggle
                  IconButton(
                    onPressed: () =>
                        setState(() => _checkedAtBottom = !_checkedAtBottom),
                    icon: Icon(
                      _checkedAtBottom
                          ? Icons.sort_outlined
                          : Icons.sort_outlined,
                    ),
                    tooltip: _checkedAtBottom
                        ? 'Checked items at bottom'
                        : 'Keep original order',
                    style: IconButton.styleFrom(
                      backgroundColor: _checkedAtBottom
                          ? const Color(0xFFE8F5E9)
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Kategoriler
          ...groupedItems.entries.map((entry) {
            final category = entry.key;
            final items = entry.value;
            final categoryCheckedCount = items
                .where(
                  (i) => widget.checkedItemKeys.contains(_itemKey(i)),
                )
                .length;
            final allCategoryChecked = categoryCheckedCount == items.length;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kategori başlığı
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      _categoryIcon(category),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          category,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                            color: const Color(0xFF2E7D32),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        '$categoryCheckedCount/${items.length}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () =>
                            _checkCategory(items, !allCategoryChecked),
                        child: Icon(
                          allCategoryChecked
                              ? Icons.check_circle
                              : Icons.check_circle_outline,
                          size: 20,
                          color: allCategoryChecked
                              ? const Color(0xFF2E7D32)
                              : Theme.of(context).disabledColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // Ürünler
                ...items.map((item) {
                  final isChecked =
                      widget.checkedItemKeys.contains(_itemKey(item));
                  return Card(
                    margin: const EdgeInsets.only(bottom: 6),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => widget.onItemCheckedChanged(
                        _itemKey(item),
                        !isChecked,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: isChecked
                                    ? const Color(0xFF2E7D32)
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isChecked
                                      ? const Color(0xFF2E7D32)
                                      : Theme.of(context).dividerColor,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: isChecked
                                  ? const Icon(
                                      Icons.check,
                                      size: 16,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                item.name,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  decoration: isChecked
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: isChecked
                                      ? Theme.of(context).disabledColor
                                      : null,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isChecked
                                    ? Theme.of(context)
                                        .disabledColor
                                        .withValues(alpha: 0.1)
                                    : const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${_formatAmount(item.amount)} ${item.unit}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isChecked
                                      ? Theme.of(context).disabledColor
                                      : const Color(0xFF2E7D32),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 12),
              ],
            );
          }),
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