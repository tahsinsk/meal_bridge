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
  if (cleanedNewCategory.isEmpty) return currentCategory;
  if (currentCategory.trim().toLowerCase() == 'other') return cleanedNewCategory;
  return currentCategory;
}

String _baseUnitFor(String unit) {
  final normalizedUnit = _normalizeText(unit);
  if (normalizedUnit == 'kg' || normalizedUnit == 'g') return 'g';
  if (normalizedUnit == 'l' || normalizedUnit == 'ml') return 'ml';
  return normalizedUnit;
}

double _amountToBaseUnit({required double amount, required String unit}) {
  final normalizedUnit = _normalizeText(unit);
  if (normalizedUnit == 'kg') return amount * 1000;
  if (normalizedUnit == 'l') return amount * 1000;
  return amount;
}

List<ShoppingListItem> generateShoppingListFromRecipes(
  List<Recipe> recipes, {
  List<double>? multipliers,
}) {
  final Map<String, ShoppingListItem> mergedItems = {};

  for (int i = 0; i < recipes.length; i++) {
    final recipe = recipes[i];
    final multiplier =
        (multipliers != null && i < multipliers.length) ? multipliers[i] : 1.0;

    for (final ingredient in recipe.ingredients) {
      final normalizedName = _normalizeText(ingredient.name);
      final normalizedUnit = _normalizeText(ingredient.unit);
      final baseUnit = _baseUnitFor(normalizedUnit);
      final baseAmount = _amountToBaseUnit(
        amount: ingredient.amount * multiplier,
        unit: normalizedUnit,
      );
      final key = '$normalizedName-$baseUnit';

      final existingItem = mergedItems[key];

      if (existingItem == null) {
        mergedItems[key] = ShoppingListItem(
          name: _cleanDisplayText(ingredient.name),
          amount: baseAmount,
          unit: baseUnit,
          category: _cleanDisplayText(ingredient.resolvedCategory).isEmpty
              ? 'Other'
              : _cleanDisplayText(ingredient.resolvedCategory),
        );
      } else {
        mergedItems[key] = existingItem.copyWith(
          amount: existingItem.amount + baseAmount,
          category: _resolveMergedCategory(
            currentCategory: existingItem.category,
            newCategory: ingredient.resolvedCategory,
          ),
        );
      }
    }
  }

  final items = mergedItems.values.toList();

  items.sort((a, b) {
    final categoryCompare =
        a.category.toLowerCase().compareTo(b.category.toLowerCase());
    if (categoryCompare != 0) return categoryCompare;
    return a.name.toLowerCase().compareTo(b.name.toLowerCase());
  });

  return items;
}