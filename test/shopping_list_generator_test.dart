import 'package:flutter_test/flutter_test.dart';
import 'package:meal_bridge/data/shopping_list_generator.dart';
import 'package:meal_bridge/models/ingredient.dart';
import 'package:meal_bridge/models/recipe.dart';
import 'package:meal_bridge/shared/ingredient_key.dart';

void main() {
  group('ingredientKey normalization', () {
    test('trims and collapses whitespace so incidental spacing still matches', () {
      expect(ingredientKey('Domates ', 'g'), ingredientKey('Domates', 'g'));
      expect(ingredientKey('Domates  Sosu', 'g'), ingredientKey('Domates Sosu', 'g'));
    });

    test('folds interchangeable units (kg/g, l/ml) onto the same key', () {
      expect(ingredientKey('Domates', 'kg'), ingredientKey('Domates', 'g'));
      expect(ingredientKey('Su', 'l'), ingredientKey('Su', 'ml'));
    });

    test('is case-insensitive', () {
      expect(ingredientKey('DOMATES', 'G'), ingredientKey('domates', 'g'));
    });
  });

  group('generateShoppingListFromRecipes key consistency (regression)', () {
    // Reproduces the reported bug: an ingredient stored with a trailing
    // space and/or a "kg" unit must still be found under the exact key
    // Quick List selection computes via ingredientKey(), or it silently
    // vanishes from the generated list even when "selected".
    test('an ingredient with trailing whitespace in its name is generated under the same key selection would use', () {
      const recipe = Recipe(
        id: 'r1',
        name: 'Domates Soslu Makarna',
        servings: 2,
        category: 'Dinner',
        ingredients: [
          Ingredient(name: 'Domates ', amount: 0.5, unit: 'kg'), // trailing space + kg
          Ingredient(name: 'Makarna', amount: 300, unit: 'g'),
          Ingredient(name: 'Su', amount: 500, unit: 'ml'),
        ],
        instructions: ['Cook.'],
      );

      // What Quick List selection would compute when the user selects
      // "Domates" (as read from the same raw Ingredient object).
      final selectedKey = ingredientKey(
        recipe.ingredients[0].name,
        recipe.ingredients[0].unit,
      );

      final items = generateShoppingListFromRecipes([recipe]);

      // The generated item for "Domates" must be reachable using the
      // exact same key selection produced — this is what was broken.
      final tomatoItem = items.firstWhere(
        (i) => ingredientKey(i.name, i.unit) == selectedKey,
        orElse: () => throw StateError('Tomato item missing from generated list'),
      );

      expect(tomatoItem.name.trim(), 'Domates');
      expect(tomatoItem.unit, 'g');
      expect(tomatoItem.amount, 500); // 0.5 kg -> 500 g
    });

    test('merges the same ingredient across kg and g units under one key', () {
      const recipe = Recipe(
        id: 'r2',
        name: 'Two tomato uses',
        servings: 1,
        category: 'Dinner',
        ingredients: [
          Ingredient(name: 'Domates', amount: 0.2, unit: 'kg'),
          Ingredient(name: 'Domates', amount: 100, unit: 'g'),
        ],
        instructions: ['Cook.'],
      );

      final items = generateShoppingListFromRecipes([recipe]);

      expect(items.length, 1);
      expect(items.first.amount, 300); // 200g + 100g
    });
  });
}
