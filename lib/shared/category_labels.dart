import '../l10n/app_localizations.dart';
import '../models/meal_type.dart';

/// Maps a [MealType] to its localized label. Reuses the recipe-category
/// strings ("Breakfast"/"Lunch"/"Dinner") since they're the same words in
/// every supported language — kept as one translation, not duplicated.
String localizedMealTypeLabel(AppLocalizations l10n, MealType type) {
  switch (type) {
    case MealType.breakfast:
      return l10n.categoryBreakfast;
    case MealType.lunch:
      return l10n.categoryLunch;
    case MealType.dinner:
      return l10n.categoryDinner;
  }
}

/// Maps a persisted recipe category value ("Breakfast"/"Lunch"/"Dinner"/
/// "Other" — this is what's stored on [Recipe.category] and must never
/// change) to its localized display label.
String localizedRecipeCategory(AppLocalizations l10n, String category) {
  switch (category) {
    case 'Breakfast':
      return l10n.categoryBreakfast;
    case 'Lunch':
      return l10n.categoryLunch;
    case 'Dinner':
      return l10n.categoryDinner;
    default:
      return l10n.categoryOther;
  }
}

/// Maps a persisted market/ingredient category value (from
/// `guessMarketCategory` or a user override — must never change) to its
/// localized display label.
String localizedMarketCategory(AppLocalizations l10n, String category) {
  switch (category) {
    case 'Vegetables':
      return l10n.marketCategoryVegetables;
    case 'Fruit':
      return l10n.marketCategoryFruit;
    case 'Meat':
      return l10n.marketCategoryMeat;
    case 'Dairy':
      return l10n.marketCategoryDairy;
    case 'Bakery':
      return l10n.marketCategoryBakery;
    case 'Spices':
      return l10n.marketCategorySpices;
    case 'Pantry':
      return l10n.marketCategoryPantry;
    case 'Drinks':
      return l10n.marketCategoryDrinks;
    case 'Frozen':
      return l10n.marketCategoryFrozen;
    case 'Snacks':
      return l10n.marketCategorySnacks;
    default:
      return l10n.marketCategoryOther;
  }
}
