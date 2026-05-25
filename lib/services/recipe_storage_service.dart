import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/recipe.dart';

class RecipeStorageService {
  static const String _recipesKey = 'recipes';

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
}
