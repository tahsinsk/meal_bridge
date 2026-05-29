import '../models/recipe.dart';
import '../models/shopping_list_item.dart';

String _normalizeText(String value) {
  return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}

String _cleanDisplayText(String value) {
  return value.trim().replaceAll(RegExp(r'\s+'), ' ');
}

String _resolveMergedCategory({
  required String currentCategory,
  required String newCategory,
}) {
  final cleanedNewCategory = _cleanDisplayText(newCategory);

  if (cleanedNewCategory.isEmpty) {
    return currentCategory;
  }

  if (currentCategory.trim().toLowerCase() == 'other') {
    return cleanedNewCategory;
  }

  return currentCategory;
}

List<ShoppingListItem> generateShoppingListFromRecipes(List<Recipe> recipes) {
  final Map<String, ShoppingListItem> mergedItems = {};

  for (final recipe in recipes) {
    for (final ingredient in recipe.ingredients) {
      final normalizedName = _normalizeText(ingredient.name);
      final normalizedUnit = _normalizeText(ingredient.unit);
      final key = '$normalizedName-$normalizedUnit';

      final existingItem = mergedItems[key];

      if (existingItem == null) {
        mergedItems[key] = ShoppingListItem(
          name: _cleanDisplayText(ingredient.name),
          amount: ingredient.amount,
          unit: _cleanDisplayText(ingredient.unit),
          category: _cleanDisplayText(ingredient.category).isEmpty
              ? 'Other'
              : _cleanDisplayText(ingredient.category),
        );
      } else {
        mergedItems[key] = existingItem.copyWith(
          amount: existingItem.amount + ingredient.amount,
          category: _resolveMergedCategory(
            currentCategory: existingItem.category,
            newCategory: ingredient.category,
          ),
        );
      }
    }
  }

  final items = mergedItems.values.toList();

  items.sort((a, b) {
    final categoryCompare = a.category.toLowerCase().compareTo(
      b.category.toLowerCase(),
    );

    if (categoryCompare != 0) {
      return categoryCompare;
    }

    return a.name.toLowerCase().compareTo(b.name.toLowerCase());
  });

  return items;
}
