// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navRecipes => 'Recipes';

  @override
  String get navPlan => 'Plan';

  @override
  String get navShopping => 'Shopping';

  @override
  String get navSettings => 'Settings';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingGetStarted => 'Get started';

  @override
  String get onboardingPage1Title => 'Your recipes, in one place';

  @override
  String get onboardingPage1Body =>
      'Save what you cook, with ingredients, steps and calories.';

  @override
  String get onboardingPage2Title => 'Plan your week';

  @override
  String get onboardingPage2Body =>
      'Drop meals into breakfast, lunch and dinner — for any week.';

  @override
  String get onboardingPage3Title => 'Your shopping list writes itself';

  @override
  String get onboardingPage3Body =>
      'Ingredients are combined and sorted by aisle, ready for the store.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String settingsVersionLabel(String version) {
    return 'MealBridge v$version';
  }

  @override
  String get settingsDataBackupSection => 'Data & Backup';

  @override
  String get settingsExportTitle => 'Export backup';

  @override
  String get settingsExportSubtitle =>
      'Save all your recipes and meal plan as a JSON file';

  @override
  String get settingsImportTitle => 'Import backup';

  @override
  String get settingsImportSubtitle =>
      'Restore your recipes and meal plan from a backup file';

  @override
  String get settingsBackupInfo =>
      'Export your data regularly to avoid losing your recipes if you change phones.';

  @override
  String get settingsAboutSection => 'About';

  @override
  String settingsAppVersionSubtitle(String version) {
    return 'Version $version';
  }

  @override
  String get settingsStorageTitle => 'Storage';

  @override
  String get settingsStorageSubtitle =>
      'All data stored locally on your device';

  @override
  String get settingsResetOnboardingTitle => 'Reset onboarding';

  @override
  String get settingsResetOnboardingSubtitle =>
      'Clear the flag and show the intro screens again';

  @override
  String get settingsLanguageSection => 'Language';

  @override
  String get settingsLanguageSystemDefault => 'System default';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonClearAll => 'Clear all';

  @override
  String get planOverwriteConfirm => 'Overwrite';

  @override
  String get dayMonday => 'Monday';

  @override
  String get dayTuesday => 'Tuesday';

  @override
  String get dayWednesday => 'Wednesday';

  @override
  String get dayThursday => 'Thursday';

  @override
  String get dayFriday => 'Friday';

  @override
  String get daySaturday => 'Saturday';

  @override
  String get daySunday => 'Sunday';

  @override
  String get planLastWeek => 'Last week';

  @override
  String get planThisWeek => 'This week';

  @override
  String get planNextWeek => 'Next week';

  @override
  String planKcalPerServing(int value) {
    return '$value kcal/serving';
  }

  @override
  String planIngredientCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ingredients',
      one: '$count ingredient',
    );
    return '$_temp0';
  }

  @override
  String planCopiedDaySnackbar(String day) {
    return 'Copied $day\'s meals';
  }

  @override
  String get planOverwriteDialogTitle => 'Overwrite this day?';

  @override
  String planOverwriteDialogContent(String day) {
    return '$day already has planned meals. Pasting will replace them.';
  }

  @override
  String get planTodayBadge => 'Today';

  @override
  String get planCopyDay => 'Copy day';

  @override
  String get planPasteDay => 'Paste day';

  @override
  String planAddMealType(String mealType) {
    return 'Add $mealType';
  }

  @override
  String get planAddToPlanTitle => 'Add to plan';

  @override
  String get planAddToPlanButton => 'Add to Plan';

  @override
  String get planRecipeFieldLabel => 'Recipe';

  @override
  String get planSearchRecipesHint => 'Search recipes';

  @override
  String get planNoRecipesYet => 'No recipes yet. Add a recipe first.';

  @override
  String get planNoRecipesMatch => 'No recipes match your search/filter.';

  @override
  String get shoppingListHeading => 'Shopping list';

  @override
  String get shoppingShopAtCaption => 'Open your favorite store';

  @override
  String get shoppingSortByTitle => 'Sort by';

  @override
  String get shoppingShareTooltip => 'Share list';

  @override
  String get shoppingAddItemTooltip => 'Add item';

  @override
  String get shoppingWeeklyPlanMode => 'Weekly Plan';

  @override
  String get shoppingQuickListMode => 'Quick List';

  @override
  String get shoppingSelectAll => 'Select all';

  @override
  String shoppingSortTooltip(String mode) {
    return 'Sort: $mode';
  }

  @override
  String get shoppingNoRecipesYet =>
      'No recipes yet. Add some in the Recipes tab.';

  @override
  String get shoppingServingsAbbrev => 'srv';

  @override
  String shoppingServingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count servings',
      one: '$count serving',
    );
    return '$_temp0';
  }

  @override
  String get shoppingMyItemsSection => 'My Items';

  @override
  String get shoppingEmptyTitle => 'No shopping list yet';

  @override
  String get shoppingEmptyMessage =>
      'Plan recipes for the week and your shopping list will appear here automatically.';

  @override
  String get shoppingGoToPlanChip => 'Go to Plan tab';

  @override
  String get shoppingItemNameLabel => 'Item name';

  @override
  String get shoppingItemNameHint => 'e.g. Milk, Trash bags, Napkins';

  @override
  String get shoppingAddItemButton => 'Add Item';

  @override
  String get shoppingNoExtraItems =>
      'No extra items yet — add your first one above.';

  @override
  String get shoppingInvalidItem => 'Please enter a valid item.';

  @override
  String get shoppingItemNameTooShort =>
      'Item name must be at least 2 characters.';

  @override
  String get shoppingItemAmountInvalid => 'Item amount must be greater than 0.';

  @override
  String get shoppingItemDuplicate => 'That item is already on the list.';

  @override
  String get categoryBreakfast => 'Breakfast';

  @override
  String get categoryLunch => 'Lunch';

  @override
  String get categoryDinner => 'Dinner';

  @override
  String get categoryOther => 'Other';

  @override
  String get marketCategoryVegetables => 'Vegetables';

  @override
  String get marketCategoryFruit => 'Fruit';

  @override
  String get marketCategoryMeat => 'Meat';

  @override
  String get marketCategoryDairy => 'Dairy';

  @override
  String get marketCategoryBakery => 'Bakery';

  @override
  String get marketCategorySpices => 'Spices';

  @override
  String get marketCategoryPantry => 'Pantry';

  @override
  String get marketCategoryDrinks => 'Drinks';

  @override
  String get marketCategoryFrozen => 'Frozen';

  @override
  String get marketCategorySnacks => 'Snacks';

  @override
  String get marketCategoryOther => 'Other';

  @override
  String get recipeFilterTitle => 'Filter recipes';

  @override
  String get recipeFilterCategoryLabel => 'Category';

  @override
  String get recipeFilterShowLabel => 'Show';

  @override
  String get recipeFilterFavoritesOnly => 'Favorites only';

  @override
  String get recipeFilterFavoritesChip => 'Favorites';

  @override
  String get recipeFilterDone => 'Done';

  @override
  String recipeFilterApply(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count filters',
      one: '$count filter',
    );
    return 'Apply ($_temp0)';
  }

  @override
  String get recipeSearchHint => 'Search recipes by name or category';

  @override
  String get recipeViewToggleToList => 'Switch to list view';

  @override
  String get recipeViewToggleToGrid => 'Switch to grid view';

  @override
  String get recipeClearFiltersButton => 'Clear filters';

  @override
  String get recipeAddFirstButton => 'Add your first recipe';

  @override
  String get recipeEmptyFavoritesTitle => 'No favorites yet';

  @override
  String get recipeEmptyFavoritesMessage =>
      'Tap the star on any recipe card to add to favorites.';

  @override
  String get recipeEmptyFilteredTitle => 'No matching recipes';

  @override
  String get recipeEmptyFilteredMessage =>
      'Try adjusting your filters or search query.';

  @override
  String get recipeEmptySearchTitle => 'No results found';

  @override
  String get recipeEmptySearchMessage => 'No recipe matches your search.';

  @override
  String get recipeEmptyNoneTitle => 'No recipes yet';

  @override
  String get recipeEmptyNoneMessage =>
      'Add your first recipe to start building your meal plan.';

  @override
  String get recipeDeleteDialogTitle => 'Delete recipe?';

  @override
  String recipeDeleteDialogContent(String name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String recipeStepCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count steps',
      one: '$count step',
    );
    return '$_temp0';
  }

  @override
  String recipeKcalPerServing(int value) {
    return '$value kcal';
  }

  @override
  String get recipeSectionIngredients => 'Ingredients';

  @override
  String get recipeSectionInstructions => 'Instructions';

  @override
  String get recipeSectionNotes => 'Notes';

  @override
  String get recipeStatServings => 'servings';

  @override
  String get recipeStatIngredients => 'ingredients';

  @override
  String get recipeStatSteps => 'steps';

  @override
  String get recipeStatKcalPerServing => 'kcal/serving';

  @override
  String get recipeFavoriteAdd => 'Add to favorites';

  @override
  String get recipeFavoriteRemove => 'Remove from favorites';

  @override
  String get recipeEditTooltip => 'Edit recipe';

  @override
  String get recipeQuickListAdd => 'Add to Quick List';

  @override
  String get recipeQuickListRemove => 'Remove from Quick List';

  @override
  String get recipeFormTitleAdd => 'Add Recipe';

  @override
  String get recipeFormTitleEdit => 'Edit Recipe';

  @override
  String get recipeFormBasicInfo => 'Basic info';

  @override
  String get recipeFormNameLabel => 'Recipe name';

  @override
  String get recipeFormNameRequired => 'Recipe name is required.';

  @override
  String get recipeFormNameTooShort =>
      'Recipe name must be at least 2 characters.';

  @override
  String get recipeFormCategoryLabel => 'Category';

  @override
  String get recipeFormServingsLabel => 'Servings';

  @override
  String get recipeFormAddIngredient => 'Add ingredient';

  @override
  String get recipeFormIngredientNameLabel => 'Ingredient name';

  @override
  String get recipeFormIngredientNameHint => 'e.g. Tomato, Chicken, Pasta';

  @override
  String get recipeFormAmountLabel => 'Amount';

  @override
  String get recipeFormUnitLabel => 'Unit';

  @override
  String get recipeFormAddIngredientButton => 'Add Ingredient';

  @override
  String recipeFormIngredientCategoryTitle(String name) {
    return 'Category for \"$name\"';
  }

  @override
  String get recipeFormResetToAuto => 'Reset to auto';

  @override
  String get recipeFormEditIngredientTitle => 'Edit ingredient';

  @override
  String get recipeFormInvalidIngredient => 'Please enter a valid ingredient.';

  @override
  String get recipeFormIngredientNameTooShort =>
      'Ingredient name must be at least 2 characters.';

  @override
  String get recipeFormIngredientAmountInvalid =>
      'Ingredient amount must be greater than 0.';

  @override
  String get recipeFormInvalidValues => 'Please enter valid values.';

  @override
  String recipeFormEditStepTitle(int number) {
    return 'Edit step $number';
  }

  @override
  String get recipeFormInstructionLabel => 'Instruction';

  @override
  String get recipeFormAddInstructionSection => 'Add instruction step';

  @override
  String get recipeFormAddInstructionButton => 'Add Instruction';

  @override
  String get recipeFormInstructionEmpty => 'Please enter an instruction step.';

  @override
  String get recipeFormInstructionTooShort =>
      'Instruction must be at least 5 characters.';

  @override
  String get recipeFormCaloriesSection => 'Calories';

  @override
  String get recipeFormCaloriesLabel => 'Total calories (optional)';

  @override
  String get recipeFormCaloriesHint => 'e.g. 450';

  @override
  String get recipeFormKcalSuffix => 'kcal';

  @override
  String get recipeFormCaloriesHelper =>
      'Per serving will be calculated automatically.';

  @override
  String get recipeFormNotesLabel => 'Optional notes';

  @override
  String get recipeFormNoIngredients => 'Please add at least one ingredient.';

  @override
  String get recipeFormSaveButton => 'Save Recipe';

  @override
  String get recipeFormUpdateButton => 'Update Recipe';

  @override
  String get backupExportSubject => 'MealBridge Backup';

  @override
  String backupExportFailed(String error) {
    return 'Export failed: $error';
  }

  @override
  String get backupImportNewerVersion =>
      'This backup was created with a newer version of MealBridge.';

  @override
  String get backupImportDialogTitle => 'Import backup?';

  @override
  String get backupImportDialogIntro => 'This will restore:';

  @override
  String backupImportRecipeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recipes',
      one: '$count recipe',
      zero: 'No recipes',
    );
    return '$_temp0';
  }

  @override
  String backupImportExportedOn(String date) {
    return 'Exported on $date';
  }

  @override
  String get backupImportWarning =>
      'Your existing custom recipes will be replaced.';

  @override
  String get backupImportConfirm => 'Import';

  @override
  String get backupImportSuccess => 'Backup imported successfully!';

  @override
  String backupImportFailed(String error) {
    return 'Import failed: $error';
  }
}
