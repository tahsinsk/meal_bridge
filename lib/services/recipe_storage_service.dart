import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/recipe.dart';

class RecipeStorageService {
  static const String _recipesKey = 'recipes';
  static const String _mealPlanKey = 'meal_plan';

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
    final recipesJson = recipes.map((recipe) => recipe.toJson()).toList();
    final recipesJsonString = jsonEncode(recipesJson);

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
}
