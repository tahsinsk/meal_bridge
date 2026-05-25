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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'servings': servings,
      'category': category,
      'ingredients': ingredients
          .map((ingredient) => ingredient.toJson())
          .toList(),
      'instructions': instructions,
      'notes': notes,
    };
  }

  factory Recipe.fromJson(Map<String, dynamic> json) {
    final ingredientsJson = json['ingredients'] as List<dynamic>;
    final instructionsJson = json['instructions'] as List<dynamic>;

    return Recipe(
      id: json['id'] as String,
      name: json['name'] as String,
      servings: json['servings'] as int,
      category: json['category'] as String,
      ingredients: ingredientsJson
          .map(
            (ingredientJson) => Ingredient.fromJson(
              ingredientJson as Map<String, dynamic>,
            ),
          )
          .toList(),
      instructions: instructionsJson
          .map((instruction) => instruction as String)
          .toList(),
      notes: json['notes'] as String?,
    );
  }
}
