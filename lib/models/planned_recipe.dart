import 'recipe.dart';

class PlannedRecipe {
  final Recipe recipe;
  final int targetServings;

  const PlannedRecipe({required this.recipe, required this.targetServings});

  double get servingsMultiplier {
    if (recipe.servings <= 0) {
      return 1;
    }

    return targetServings / recipe.servings;
  }

  PlannedRecipe copyWith({Recipe? recipe, int? targetServings}) {
    return PlannedRecipe(
      recipe: recipe ?? this.recipe,
      targetServings: targetServings ?? this.targetServings,
    );
  }
}
