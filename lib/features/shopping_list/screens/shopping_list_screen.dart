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

  void _toggleChecked(ShoppingListItem item, bool? value) {
    widget.onItemCheckedChanged(_itemKey(item), value == true);
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
                                      '${recipe.category} • ${recipe.servings} servings • ${recipe.ingredients.length} ingredients',
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
    final groupedItems = _groupItemsByCategory(shoppingItems);
    final checkedItemCount = shoppingItems
        .where((item) => widget.checkedItemKeys.contains(_itemKey(item)))
        .length;
    final uncheckedItemCount = shoppingItems.length - checkedItemCount;

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
              onSelectionChanged: (value) {
                setState(() => _isQuickMode = value.first);
              },
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
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isQuickMode
                        ? Icons.bolt_outlined
                        : Icons.shopping_basket_outlined,
                    size: 56,
                  ),
                  const SizedBox(height: 16),
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
                        ? 'Tap the button below to pick recipes and generate a shopping list instantly.'
                        : 'Plan one or more recipes for the week and MealBridge will generate a combined shopping list for you.',
                    textAlign: TextAlign.center,
                  ),
                  if (_isQuickMode) ...[
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => _showRecipePicker(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Select recipes'),
                    ),
                  ] else ...[
                    const SizedBox(height: 16),
                    const Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Chip(
                          avatar: Icon(Icons.calendar_month_outlined, size: 18),
                          label: Text('Go to Plan'),
                        ),
                        Chip(
                          avatar: Icon(Icons.restaurant_menu, size: 18),
                          label: Text('Select recipes'),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ] else ...[
          // Summary card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.shopping_basket_outlined),
                      const SizedBox(width: 8),
                      Text(
                        'Shopping summary',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (_isQuickMode) ...[
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () => _showRecipePicker(context),
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          label: const Text('Edit'),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(
                        avatar: Icon(
                          _isQuickMode
                              ? Icons.bolt_outlined
                              : Icons.calendar_month_outlined,
                          size: 18,
                        ),
                        label: Text('${activeRecipes.length} recipe(s)'),
                      ),
                      Chip(
                        avatar: const Icon(Icons.list_alt, size: 18),
                        label: Text('${shoppingItems.length} item(s)'),
                      ),
                      Chip(
                        avatar: const Icon(Icons.check_circle_outline, size: 18),
                        label: Text('$checkedItemCount checked'),
                      ),
                      Chip(
                        avatar: const Icon(
                          Icons.shopping_basket_outlined,
                          size: 18,
                        ),
                        label: Text('$uncheckedItemCount remaining'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      TextButton.icon(
                        onPressed: () =>
                            _copyShoppingList(context, groupedItems),
                        icon: const Icon(Icons.copy_outlined),
                        label: const Text('Copy list'),
                      ),
                      TextButton.icon(
                        onPressed: () =>
                            _copyUncheckedShoppingList(context, groupedItems),
                        icon: const Icon(Icons.playlist_add_check_outlined),
                        label: const Text('Copy unchecked'),
                      ),
                      if (widget.checkedItemKeys.isNotEmpty)
                        TextButton.icon(
                          onPressed: widget.onClearCheckedItems,
                          icon: const Icon(Icons.cleaning_services_outlined),
                          label: const Text('Clear checked'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Items by category
          ...groupedItems.entries.map((entry) {
            final category = entry.key;
            final items = entry.value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.category_outlined, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      category,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(width: 8),
                    Chip(label: Text('${items.length} item(s)')),
                  ],
                ),
                const SizedBox(height: 8),
                ...items.map((item) {
                  final isChecked =
                      widget.checkedItemKeys.contains(_itemKey(item));
                  return Card(
                    child: CheckboxListTile(
                      value: isChecked,
                      onChanged: (value) => _toggleChecked(item, value),
                      title: Text(
                        item.name,
                        style: TextStyle(
                          decoration:
                              isChecked ? TextDecoration.lineThrough : null,
                          color: isChecked
                              ? Theme.of(context).disabledColor
                              : null,
                        ),
                      ),
                      subtitle: Text(
                        item.category,
                        style: TextStyle(
                          color: isChecked
                              ? Theme.of(context).disabledColor
                              : null,
                        ),
                      ),
                      secondary: Chip(
                        label: Text(
                          '${_formatAmount(item.amount)} ${item.unit}',
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 16),
              ],
            );
          }),
        ],
      ],
    );
  }
}