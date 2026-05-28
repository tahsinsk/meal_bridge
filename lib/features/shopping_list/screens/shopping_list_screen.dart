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

    return groupedItems;
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

    if (selectedRecipes.isEmpty) {
      return const Center(
        child: Text('Add recipes to your weekly plan first.'),
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
                Text(
                  'Shopping summary',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text('${selectedRecipes.length} planned recipe(s)'),
                Text('${shoppingItems.length} shopping item(s)'),
                Text('$checkedItemCount checked item(s)'),
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
                Text(
                  category,
                  style: Theme.of(context).textTheme.titleLarge,
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
                          ),
                        ),
                        subtitle: Text(item.category),
                        secondary: Text(
                          '${_formatAmount(item.amount)} ${item.unit}',
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