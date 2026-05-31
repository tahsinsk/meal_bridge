import 'ingredient.dart';

class Recipe {
  final String id;
  final String name;
  final int servings;
  final String category;
  final List<Ingredient> ingredients;
  final List<String> instructions;
  final String? notes;
  final bool isFavorite;
  final int? calories;

  const Recipe({
    required this.id,
    required this.name,
    required this.servings,
    required this.category,
    required this.ingredients,
    required this.instructions,
    this.notes,
    this.isFavorite = false,
    this.calories,
  });

  Recipe copyWith({
    String? id,
    String? name,
    int? servings,
    String? category,
    List<Ingredient>? ingredients,
    List<String>? instructions,
    String? notes,
    bool? isFavorite,
    int? calories,
  }) {
    return Recipe(
      id: id ?? this.id,
      name: name ?? this.name,
      servings: servings ?? this.servings,
      category: category ?? this.category,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      notes: notes ?? this.notes,
      isFavorite: isFavorite ?? this.isFavorite,
      calories: calories ?? this.calories,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'servings': servings,
      'category': category,
      'ingredients': ingredients.map((i) => i.toJson()).toList(),
      'instructions': instructions,
      'notes': notes,
      'isFavorite': isFavorite,
      'calories': calories,
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
          .map((i) => Ingredient.fromJson(i as Map<String, dynamic>))
          .toList(),
      instructions: instructionsJson.map((i) => i as String).toList(),
      notes: json['notes'] as String?,
      isFavorite: json['isFavorite'] as bool? ?? false,
      calories: json['calories'] as int?,
    );
  }
}