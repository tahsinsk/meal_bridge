import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../data/shopping_list_generator.dart';
import '../../../models/recipe.dart';
import '../../../models/shopping_list_item.dart';

class ShoppingListScreen extends StatelessWidget {
  final Map<String, Recipe> plannedRecipes;
  final Set<String> checkedItemKeys;
  final void Function(String itemKey, bool isChecked) onItemCheckedChanged;
  final VoidCallback onClearCheckedItems;

  const ShoppingListScreen({
    super.key,
    required this.plannedRecipes,
    required this.checkedItemKeys,
    required this.onItemCheckedChanged,
    required this.onClearCheckedItems,
  });

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

        if (aIndex == -1 && bIndex == -1) {
          return a.key.compareTo(b.key);
        }

        if (aIndex == -1) {
          return 1;
        }

        if (bIndex == -1) {
          return -1;
        }

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
        final isChecked = checkedItemKeys.contains(_itemKey(item));
        final checkbox = isChecked ? '[x]' : '[ ]';

        buffer.writeln(
          '$checkbox ${_formatAmount(item.amount)} ${item.unit} ${item.name}',
        );
      }

      buffer.writeln();
    }

    await Clipboard.setData(ClipboardData(text: buffer.toString().trim()));

    if (!context.mounted) {
      return;
    }

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
        (item) => !checkedItemKeys.contains(_itemKey(item)),
      );

      if (uncheckedItems.isEmpty) {
        continue;
      }

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

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Unchecked shopping items copied.')),
    );
  }

  void _toggleChecked(ShoppingListItem item, bool? value) {
    onItemCheckedChanged(_itemKey(item), value == true);
  }

  @override
  Widget build(BuildContext context) {
    final selectedRecipes = plannedRecipes.values.toList();
    final shoppingItems = generateShoppingListFromRecipes(selectedRecipes);
    final groupedItems = _groupItemsByCategory(shoppingItems);
    final checkedItemCount = shoppingItems.where(
      (item) => checkedItemKeys.contains(_itemKey(item)),
    ).length;
    final uncheckedItemCount = shoppingItems.length - checkedItemCount;

    if (selectedRecipes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.shopping_basket_outlined, size: 48),
              const SizedBox(height: 12),
              Text(
                'No shopping list yet',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text(
                'Add recipes to your weekly plan first to generate a shopping list.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
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
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(
                      avatar: const Icon(Icons.calendar_month_outlined, size: 18),
                      label: Text('${selectedRecipes.length} planned recipe(s)'),
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
                      avatar: const Icon(Icons.shopping_basket_outlined, size: 18),
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
                      onPressed: () => _copyShoppingList(context, groupedItems),
                      icon: const Icon(Icons.copy_outlined),
                      label: const Text('Copy list'),
                    ),
                    TextButton.icon(
                      onPressed: () => _copyUncheckedShoppingList(
                        context,
                        groupedItems,
                      ),
                      icon: const Icon(Icons.playlist_add_check_outlined),
                      label: const Text('Copy unchecked'),
                    ),
                    if (checkedItemKeys.isNotEmpty)
                      TextButton.icon(
                        onPressed: onClearCheckedItems,
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
        ...groupedItems.entries.map(
          (entry) {
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
                ...items.map(
                  (item) {
                    final isChecked = checkedItemKeys.contains(
                      _itemKey(item),
                    );

                    return Card(
                      child: CheckboxListTile(
                        value: isChecked,
                        onChanged: (value) => _toggleChecked(item, value),
                        title: Text(
                          item.name,
                          style: TextStyle(
                            decoration: isChecked
                                ? TextDecoration.lineThrough
                                : null,
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
                  },
                ),
                const SizedBox(height: 16),
              ],
            );
          },
        ),
      ],
    );
  }
}