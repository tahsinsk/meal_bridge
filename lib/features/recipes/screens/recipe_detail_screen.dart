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
          Text(
            recipe.name,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '${recipe.category} • ${recipe.servings} servings',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
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
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text('${index + 1}'),
                  ),
                  title: Text(instruction),
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