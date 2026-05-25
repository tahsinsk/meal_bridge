import 'ingredient.dart';

class Recipe {
  final String id;
  final String name;
  final int servings;
  final String category;
  final List<Ingredient> ingredients;
  final List<String> instructions;
  final String? notes;

  const Recipe({
    required this.id,
    required this.name,
    required this.servings,
    required this.category,
    required this.ingredients,
    required this.instructions,
    this.notes,
  });
}