import 'meal_type.dart';
import 'planned_recipe.dart';

class PlannedMeal {
  final String day;
  final MealType mealType;
  final PlannedRecipe plannedRecipe;

  const PlannedMeal({
    required this.day,
    required this.mealType,
    required this.plannedRecipe,
  });

  String get key => '$day-${mealType.name}';

  PlannedMeal copyWith({
    String? day,
    MealType? mealType,
    PlannedRecipe? plannedRecipe,
  }) {
    return PlannedMeal(
      day: day ?? this.day,
      mealType: mealType ?? this.mealType,
      plannedRecipe: plannedRecipe ?? this.plannedRecipe,
    );
  }
}
