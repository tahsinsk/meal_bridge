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
  final String? imagePath;
  // Per-step estimated duration in minutes, same length/order as
  // [instructions] — a null entry means no known duration for that step.
  // Purely additive: recipes saved before this field existed just have an
  // empty list here (equivalent to "no durations known"), no migration
  // needed since callers already index-check against [instructions].
  final List<int?> instructionDurationsMinutes;
  // Holistic estimated total time for the whole recipe, in minutes — not
  // necessarily the sum of step durations, since steps can overlap in
  // practice. Null when unknown (e.g. recipes saved before this existed).
  final int? totalTimeMinutes;

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
    this.imagePath,
    this.instructionDurationsMinutes = const [],
    this.totalTimeMinutes,
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
    String? imagePath,
    List<int?>? instructionDurationsMinutes,
    int? totalTimeMinutes,
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
      imagePath: imagePath ?? this.imagePath,
      instructionDurationsMinutes: instructionDurationsMinutes ?? this.instructionDurationsMinutes,
      totalTimeMinutes: totalTimeMinutes ?? this.totalTimeMinutes,
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
      'imagePath': imagePath,
      'instructionDurationsMinutes': instructionDurationsMinutes,
      'totalTimeMinutes': totalTimeMinutes,
    };
  }

  factory Recipe.fromJson(Map<String, dynamic> json) {
    final ingredientsJson = json['ingredients'] as List<dynamic>;
    final instructionsJson = json['instructions'] as List<dynamic>;
    final durationsJson = json['instructionDurationsMinutes'] as List<dynamic>?;

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
      imagePath: json['imagePath'] as String?,
      instructionDurationsMinutes:
          durationsJson?.map((d) => d as int?).toList() ?? const [],
      totalTimeMinutes: json['totalTimeMinutes'] as int?,
    );
  }
}