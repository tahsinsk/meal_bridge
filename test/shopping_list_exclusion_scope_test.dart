import 'package:flutter_test/flutter_test.dart';
import 'package:meal_bridge/data/shopping_list_generator.dart';
import 'package:meal_bridge/models/ingredient.dart';
import 'package:meal_bridge/models/recipe.dart';
import 'package:meal_bridge/services/recipe_storage_service.dart';
import 'package:meal_bridge/shared/ingredient_key.dart';
import 'package:meal_bridge/shared/iso_week.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const tomatoRecipe = Recipe(
    id: 'r1',
    name: 'Tomato Sauce Pasta',
    servings: 2,
    category: 'Dinner',
    ingredients: [
      Ingredient(name: 'Tomato', amount: 500, unit: 'g'),
      Ingredient(name: 'Pasta', amount: 300, unit: 'g'),
    ],
    instructions: ['Cook.'],
  );

  test('isoWeekKeyForOffset produces distinct keys for different weeks', () {
    final week0 = isoWeekKeyForOffset(0);
    final week1 = isoWeekKeyForOffset(1);
    final weekMinus1 = isoWeekKeyForOffset(-1);

    expect(week0, isNot(equals(week1)));
    expect(week0, isNot(equals(weekMinus1)));
  });

  group('RecipeStorageService per-week exclusion storage', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('round-trips exclusions scoped to their own week key', () async {
      final service = RecipeStorageService();
      final tomatoKey = ingredientKey('Tomato', 'g');

      await service.saveExcludedShoppingItemsByWeek({
        '2026-W30': {tomatoKey},
      });

      final loaded = await service.loadExcludedShoppingItemsByWeek('2026-W30');
      expect(loaded['2026-W30'], contains(tomatoKey));
      expect(loaded['2026-W31'], isNull); // week 31 was never touched
    });

    test('migrates the old flat/global set into the current week once', () async {
      final tomatoKey = ingredientKey('Tomato', 'g');
      SharedPreferences.setMockInitialValues({
        'excluded_shopping_items': '["$tomatoKey"]',
      });

      final service = RecipeStorageService();
      final migrated = await service.loadExcludedShoppingItemsByWeek('2026-W30');
      expect(migrated['2026-W30'], contains(tomatoKey));

      // Loading again must not re-migrate or duplicate/lose data — the new
      // format now exists and always takes priority.
      final loadedAgain = await service.loadExcludedShoppingItemsByWeek('2026-W99');
      expect(loadedAgain['2026-W30'], contains(tomatoKey));
      expect(loadedAgain.containsKey('2026-W99'), isFalse);
    });
  });

  group('exclusions are cleared when that week\'s meal plan is mutated', () {
    test('excluding Tomato for a week, then adding a meal to that same week, brings Tomato back', () {
      final tomatoKey = ingredientKey('Tomato', 'g');

      // Mirrors MainShell._excludedShoppingItemsByWeek before any mutation:
      // Tomato was excluded for week 30.
      var excludedByWeek = <String, Set<String>>{
        '2026-W30': {tomatoKey},
      };

      // Mirrors MainShell._clearWeeklyExclusionsForWeek(weekKey), called from
      // inside every meal-plan mutation (_selectRecipeForDay,
      // _removeRecipeFromDay, _updateServings, _pasteDay) for the week being
      // edited.
      bool clearWeeklyExclusionsForWeek(String weekKey) {
        if (!excludedByWeek.containsKey(weekKey)) return false;
        excludedByWeek = {...excludedByWeek}..remove(weekKey);
        return true;
      }

      List<String> namesFor(String weekKey, List<Recipe> plannedRecipes) {
        final items = generateShoppingListFromRecipes(plannedRecipes);
        final excluded = excludedByWeek[weekKey] ?? const <String>{};
        return items
            .where((i) => !excluded.contains(ingredientKey(i.name, i.unit)))
            .map((i) => i.name)
            .toList();
      }

      // Before the mutation: Tomato is hidden for week 30.
      expect(namesFor('2026-W30', [tomatoRecipe]), isNot(contains('Tomato')));

      // A new meal (containing Tomato again) is added to week 30 — this
      // must clear week 30's exclusions, same as Quick List does on
      // selection change.
      clearWeeklyExclusionsForWeek('2026-W30');
      expect(excludedByWeek.containsKey('2026-W30'), isFalse);

      // Tomato reappears because the current plan actually needs it again.
      expect(namesFor('2026-W30', [tomatoRecipe]), contains('Tomato'));
    });

    test('week navigation alone does not clear another week\'s exclusions', () {
      final tomatoKey = ingredientKey('Tomato', 'g');
      var excludedByWeek = <String, Set<String>>{
        '2026-W30': {tomatoKey},
      };

      bool clearWeeklyExclusionsForWeek(String weekKey) {
        if (!excludedByWeek.containsKey(weekKey)) return false;
        excludedByWeek = {...excludedByWeek}..remove(weekKey);
        return true;
      }

      // Simulates navigating to week 31 and mutating ITS plan — week 30's
      // exclusions must remain untouched.
      clearWeeklyExclusionsForWeek('2026-W31');

      expect(excludedByWeek['2026-W30'], contains(tomatoKey));
    });
  });

  group('reported scenario: exclude Tomato in one week, unaffected in another', () {
    test('excluding an ingredient for week 30 does not hide it in week 31', () {
      final items = generateShoppingListFromRecipes([tomatoRecipe]);
      final tomatoKey = ingredientKey('Tomato', 'g');

      // Simulates ShoppingListScreenState._computeShoppingItems()'s filter,
      // scoped per week.
      final excludedByWeek = <String, Set<String>>{
        '2026-W30': {tomatoKey},
      };

      List<String> namesFor(String weekKey) {
        final excluded = excludedByWeek[weekKey] ?? const <String>{};
        return items
            .where((i) => !excluded.contains(ingredientKey(i.name, i.unit)))
            .map((i) => i.name)
            .toList();
      }

      expect(namesFor('2026-W30'), isNot(contains('Tomato')));
      expect(namesFor('2026-W30'), contains('Pasta'));

      // A different week was never excluded from — Tomato shows normally.
      expect(namesFor('2026-W31'), contains('Tomato'));
      expect(namesFor('2026-W31'), contains('Pasta'));

      // Navigating back to week 30 still excludes it (not restored).
      expect(namesFor('2026-W30'), isNot(contains('Tomato')));
    });
  });
}
