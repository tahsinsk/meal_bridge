import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/recipe.dart';

class RecipeStorageService {
  static const String _recipesKey = 'recipes';
  static const String _mealPlanKey = 'meal_plan';
  static const String _checkedShoppingItemsKey = 'checked_shopping_items';
  static const String _quickRecipeIdsKey = 'quick_recipe_ids';

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
}