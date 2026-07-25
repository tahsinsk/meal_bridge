import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/ingredient.dart';
import '../models/recipe.dart';

class RecipeStorageService {
  static const String _recipesKey = 'recipes';
  static const String _mealPlanKey = 'meal_plan';
  static const String _checkedShoppingItemsKey = 'checked_shopping_items';
  static const String _quickRecipeIdsKey = 'quick_recipe_ids';
  static const String _customQuickItemsKey = 'custom_quick_items';
  static const String _recipeGridViewKey = 'recipe_grid_view';
  static const String _onboardingCompletedKey = 'onboarding_completed';
  static const String _localeCodeKey = 'locale_code';
  static const String _excludedShoppingItemsKey = 'excluded_shopping_items';

  Future<List<Recipe>> loadRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    final recipesJsonString = prefs.getString(_recipesKey);

    if (recipesJsonString == null || recipesJsonString.isEmpty) {
      return [];
    }

    final recipesJson = jsonDecode(recipesJsonString) as List<dynamic>;

    return recipesJson
        .map((recipeJson) => Recipe.fromJson(recipeJson as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveRecipes(List<Recipe> recipes) async {
    final prefs = await SharedPreferences.getInstance();
    final recipesJsonString = jsonEncode(
      recipes.map((recipe) => recipe.toJson()).toList(),
    );

    await prefs.setString(_recipesKey, recipesJsonString);
  }

  Future<Map<String, String>> loadMealPlan() async {
    final prefs = await SharedPreferences.getInstance();
    final mealPlanJsonString = prefs.getString(_mealPlanKey);

    if (mealPlanJsonString == null || mealPlanJsonString.isEmpty) {
      return {};
    }

    final mealPlanJson = jsonDecode(mealPlanJsonString) as Map<String, dynamic>;

    return mealPlanJson.map(
      (day, recipeId) => MapEntry(day, recipeId as String),
    );
  }

  Future<void> saveMealPlan(Map<String, String> mealPlan) async {
    final prefs = await SharedPreferences.getInstance();
    final mealPlanJsonString = jsonEncode(mealPlan);

    await prefs.setString(_mealPlanKey, mealPlanJsonString);
  }

  Future<Set<String>> loadCheckedShoppingItems() async {
    final prefs = await SharedPreferences.getInstance();
    final checkedItemsJsonString = prefs.getString(_checkedShoppingItemsKey);

    if (checkedItemsJsonString == null || checkedItemsJsonString.isEmpty) {
      return {};
    }

    final checkedItemsJson = jsonDecode(checkedItemsJsonString) as List<dynamic>;

    return checkedItemsJson.map((item) => item as String).toSet();
  }

  Future<void> saveCheckedShoppingItems(Set<String> checkedItemKeys) async {
    final prefs = await SharedPreferences.getInstance();
    final checkedItemsJsonString = jsonEncode(checkedItemKeys.toList());

    await prefs.setString(_checkedShoppingItemsKey, checkedItemsJsonString);
  }

  /// Ingredients swiped away from a generated (non-custom) shopping list —
  /// keyed the same way as [_checkedShoppingItemsKey] (name+unit), so an
  /// exclusion persists across the session until the plan changes and the
  /// list is regenerated.
  Future<Set<String>> loadExcludedShoppingItemKeys() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_excludedShoppingItemsKey);

    if (jsonString == null || jsonString.isEmpty) {
      return {};
    }

    final jsonList = jsonDecode(jsonString) as List<dynamic>;
    return jsonList.map((item) => item as String).toSet();
  }

  Future<void> saveExcludedShoppingItemKeys(Set<String> excludedItemKeys) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_excludedShoppingItemsKey, jsonEncode(excludedItemKeys.toList()));
  }

  // Quick shopping list
  Future<Set<String>> loadQuickRecipeIds() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_quickRecipeIdsKey);

    if (jsonString == null || jsonString.isEmpty) {
      return {};
    }

    final jsonList = jsonDecode(jsonString) as List<dynamic>;

    return jsonList.map((item) => item as String).toSet();
  }

  Future<void> saveQuickRecipeIds(Set<String> recipeIds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_quickRecipeIdsKey, jsonEncode(recipeIds.toList()));
  }

  Future<List<Ingredient>> loadCustomQuickItems() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_customQuickItemsKey);
    if (jsonString == null || jsonString.isEmpty) return [];
    final jsonList = jsonDecode(jsonString) as List<dynamic>;
    return jsonList.map((item) {
      // Backward compatible with the old format, which stored bare item
      // names (List<String>) with no amount/unit.
      if (item is String) return Ingredient(name: item, amount: 1, unit: '');
      return Ingredient.fromJson(item as Map<String, dynamic>);
    }).toList();
  }

  Future<void> saveCustomQuickItems(List<Ingredient> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _customQuickItemsKey,
      jsonEncode(items.map((i) => i.toJson()).toList()),
    );
  }

  Future<bool> loadRecipeGridView() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_recipeGridViewKey) ?? true;
  }

  Future<void> saveRecipeGridView(bool isGridView) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_recipeGridViewKey, isGridView);
  }

  Future<bool> loadOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingCompletedKey) ?? false;
  }

  Future<void> saveOnboardingCompleted(bool completed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompletedKey, completed);
  }

  /// 'system' (follow device locale) or a supported language code
  /// ('en'/'tr'/'nl'). Defaults to 'system' when nothing has been saved yet.
  Future<String> loadLocaleCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_localeCodeKey) ?? 'system';
  }

  Future<void> saveLocaleCode(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeCodeKey, code);
  }
}