import 'package:flutter/material.dart';

import '../../../models/recipe.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailScreen({
    super.key,
    required this.recipe,
  });

  String _formatAmount(double amount) {
    if (amount == amount.roundToDouble()) {
      return amount.toInt().toString();
    }

    return amount.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.name),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    recipe.category,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(
                        avatar: const Icon(Icons.people_outline, size: 18),
                        label: Text('${recipe.servings} servings'),
                      ),
                      Chip(
                        avatar: const Icon(Icons.list_alt, size: 18),
                        label: Text('${recipe.ingredients.length} ingredients'),
                      ),
                      Chip(
                        avatar: const Icon(Icons.format_list_numbered, size: 18),
                        label: Text('${recipe.instructions.length} steps'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Ingredients',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          ...recipe.ingredients.map(
            (ingredient) => Card(
              child: ListTile(
                leading: const Icon(Icons.shopping_basket_outlined),
                title: Text(ingredient.name),
                subtitle: Text(ingredient.category),
                trailing: Text(
                  '${_formatAmount(ingredient.amount)} ${ingredient.unit}',
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Instructions',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          ...recipe.instructions.asMap().entries.map(
            (entry) {
              final index = entry.key;
              final instruction = entry.value;

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        child: Text('${index + 1}'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(instruction),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          if (recipe.notes != null && recipe.notes!.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Notes',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(recipe.notes!),
              ),
            ),
          ],
        ],
      ),
    );
  }
}