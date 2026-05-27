import 'package:flutter/material.dart';

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

  void _toggleChecked(ShoppingListItem item, bool? value) {
    onItemCheckedChanged(_itemKey(item), value == true);
  }

  @override
  Widget build(BuildContext context) {
    final selectedRecipes = plannedRecipes.values.toList();
    final shoppingItems = generateShoppingListFromRecipes(selectedRecipes);
    final groupedItems = _groupItemsByCategory(shoppingItems);

    if (selectedRecipes.isEmpty) {
      return const Center(
        child: Text('Add recipes to your weekly plan first.'),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '${selectedRecipes.length} planned recipe(s)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            if (checkedItemKeys.isNotEmpty)
              TextButton.icon(
                onPressed: onClearCheckedItems,
                icon: const Icon(Icons.cleaning_services_outlined),
                label: const Text('Clear checked'),
              ),
          ],
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
