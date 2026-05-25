import '../models/recipe.dart';
import '../models/shopping_list_item.dart';

List<ShoppingListItem> generateShoppingListFromRecipes(
  List<Recipe> recipes,
) {
  final Map<String, ShoppingListItem> mergedItems = {};

  for (final recipe in recipes) {
    for (final ingredient in recipe.ingredients) {
      final key =
          '${ingredient.name.toLowerCase()}-${ingredient.unit.toLowerCase()}';

      final existingItem = mergedItems[key];

      if (existingItem == null) {
        mergedItems[key] = ShoppingListItem(
          name: ingredient.name,
          amount: ingredient.amount,
          unit: ingredient.unit,
          category: ingredient.category,
        );
      } else {
        mergedItems[key] = existingItem.copyWith(
          amount: existingItem.amount + ingredient.amount,
        );
      }
    }
  }

  final items = mergedItems.values.toList();

  items.sort((a, b) {
    final categoryCompare = a.category.compareTo(b.category);

    if (categoryCompare != 0) {
      return categoryCompare;
    }

    return a.name.compareTo(b.name);
  });

  return items;
}