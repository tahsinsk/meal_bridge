import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('nl'),
    Locale('tr'),
  ];

  /// No description provided for @navRecipes.
  ///
  /// In en, this message translates to:
  /// **'Recipes'**
  String get navRecipes;

  /// No description provided for @navPlan.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get navPlan;

  /// No description provided for @navShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get navShopping;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onboardingGetStarted;

  /// No description provided for @onboardingPage1Title.
  ///
  /// In en, this message translates to:
  /// **'Your recipes, in one place'**
  String get onboardingPage1Title;

  /// No description provided for @onboardingPage1Body.
  ///
  /// In en, this message translates to:
  /// **'Save what you cook, with ingredients, steps and calories.'**
  String get onboardingPage1Body;

  /// No description provided for @onboardingPage2Title.
  ///
  /// In en, this message translates to:
  /// **'Plan your week'**
  String get onboardingPage2Title;

  /// No description provided for @onboardingPage2Body.
  ///
  /// In en, this message translates to:
  /// **'Drop meals into breakfast, lunch and dinner — for any week.'**
  String get onboardingPage2Body;

  /// No description provided for @onboardingPage3Title.
  ///
  /// In en, this message translates to:
  /// **'Your shopping list writes itself'**
  String get onboardingPage3Title;

  /// No description provided for @onboardingPage3Body.
  ///
  /// In en, this message translates to:
  /// **'Ingredients are combined and sorted by aisle for the week you\'re viewing, ready for the store.'**
  String get onboardingPage3Body;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'MealBridge v{version}'**
  String settingsVersionLabel(String version);

  /// No description provided for @settingsDataBackupSection.
  ///
  /// In en, this message translates to:
  /// **'Data & Backup'**
  String get settingsDataBackupSection;

  /// No description provided for @settingsExportTitle.
  ///
  /// In en, this message translates to:
  /// **'Export backup'**
  String get settingsExportTitle;

  /// No description provided for @settingsExportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save all your recipes and meal plan as a JSON file'**
  String get settingsExportSubtitle;

  /// No description provided for @settingsImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Import backup'**
  String get settingsImportTitle;

  /// No description provided for @settingsImportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Restore your recipes and meal plan from a backup file'**
  String get settingsImportSubtitle;

  /// No description provided for @settingsBackupInfo.
  ///
  /// In en, this message translates to:
  /// **'Export your data regularly to avoid losing your recipes if you change phones.'**
  String get settingsBackupInfo;

  /// No description provided for @settingsAboutSection.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAboutSection;

  /// No description provided for @settingsAppVersionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String settingsAppVersionSubtitle(String version);

  /// No description provided for @settingsStorageTitle.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get settingsStorageTitle;

  /// No description provided for @settingsStorageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'All data stored locally on your device'**
  String get settingsStorageSubtitle;

  /// No description provided for @settingsResetOnboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset onboarding'**
  String get settingsResetOnboardingTitle;

  /// No description provided for @settingsResetOnboardingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Clear the flag and show the intro screens again'**
  String get settingsResetOnboardingSubtitle;

  /// No description provided for @settingsLanguageSection.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageSection;

  /// No description provided for @settingsLanguageSystemDefault.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get settingsLanguageSystemDefault;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get commonClearAll;

  /// No description provided for @planOverwriteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Overwrite'**
  String get planOverwriteConfirm;

  /// No description provided for @dayMonday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get dayMonday;

  /// No description provided for @dayTuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get dayTuesday;

  /// No description provided for @dayWednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get dayWednesday;

  /// No description provided for @dayThursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get dayThursday;

  /// No description provided for @dayFriday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get dayFriday;

  /// No description provided for @daySaturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get daySaturday;

  /// No description provided for @daySunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get daySunday;

  /// No description provided for @planLastWeek.
  ///
  /// In en, this message translates to:
  /// **'Last week'**
  String get planLastWeek;

  /// No description provided for @planThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get planThisWeek;

  /// No description provided for @planNextWeek.
  ///
  /// In en, this message translates to:
  /// **'Next week'**
  String get planNextWeek;

  /// No description provided for @planWeekNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Week {number}'**
  String planWeekNumberLabel(int number);

  /// No description provided for @planKcalPerServing.
  ///
  /// In en, this message translates to:
  /// **'{value} kcal/serving'**
  String planKcalPerServing(int value);

  /// No description provided for @planIngredientCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} ingredient} other{{count} ingredients}}'**
  String planIngredientCount(int count);

  /// No description provided for @planCopiedDaySnackbar.
  ///
  /// In en, this message translates to:
  /// **'Copied {day}\'s meals'**
  String planCopiedDaySnackbar(String day);

  /// No description provided for @planOverwriteDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Overwrite this day?'**
  String get planOverwriteDialogTitle;

  /// No description provided for @planOverwriteDialogContent.
  ///
  /// In en, this message translates to:
  /// **'{day} already has planned meals. Pasting will replace them.'**
  String planOverwriteDialogContent(String day);

  /// No description provided for @planTodayBadge.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get planTodayBadge;

  /// No description provided for @planCopyDay.
  ///
  /// In en, this message translates to:
  /// **'Copy day'**
  String get planCopyDay;

  /// No description provided for @planPasteDay.
  ///
  /// In en, this message translates to:
  /// **'Paste day'**
  String get planPasteDay;

  /// No description provided for @planAddMealType.
  ///
  /// In en, this message translates to:
  /// **'Add {mealType}'**
  String planAddMealType(String mealType);

  /// No description provided for @planAddToPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Add to plan'**
  String get planAddToPlanTitle;

  /// No description provided for @planAddToPlanButton.
  ///
  /// In en, this message translates to:
  /// **'Add to Plan'**
  String get planAddToPlanButton;

  /// No description provided for @planRecipeFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Recipe'**
  String get planRecipeFieldLabel;

  /// No description provided for @planSearchRecipesHint.
  ///
  /// In en, this message translates to:
  /// **'Search recipes'**
  String get planSearchRecipesHint;

  /// No description provided for @planNoRecipesYet.
  ///
  /// In en, this message translates to:
  /// **'No recipes yet. Add a recipe first.'**
  String get planNoRecipesYet;

  /// No description provided for @planNoRecipesMatch.
  ///
  /// In en, this message translates to:
  /// **'No recipes match your search/filter.'**
  String get planNoRecipesMatch;

  /// No description provided for @shoppingListHeading.
  ///
  /// In en, this message translates to:
  /// **'Shopping list'**
  String get shoppingListHeading;

  /// No description provided for @shoppingShopAtCaption.
  ///
  /// In en, this message translates to:
  /// **'Open your favorite store'**
  String get shoppingShopAtCaption;

  /// No description provided for @shoppingOnlineTooltip.
  ///
  /// In en, this message translates to:
  /// **'Shop online'**
  String get shoppingOnlineTooltip;

  /// No description provided for @shoppingSortByTitle.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get shoppingSortByTitle;

  /// No description provided for @shoppingShareTooltip.
  ///
  /// In en, this message translates to:
  /// **'Share list'**
  String get shoppingShareTooltip;

  /// No description provided for @shoppingAddItemTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add item'**
  String get shoppingAddItemTooltip;

  /// No description provided for @shoppingWeeklyPlanMode.
  ///
  /// In en, this message translates to:
  /// **'Weekly Plan'**
  String get shoppingWeeklyPlanMode;

  /// No description provided for @shoppingQuickListMode.
  ///
  /// In en, this message translates to:
  /// **'Quick List'**
  String get shoppingQuickListMode;

  /// No description provided for @shoppingSelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get shoppingSelectAll;

  /// No description provided for @shoppingSortTooltip.
  ///
  /// In en, this message translates to:
  /// **'Sort: {mode}'**
  String shoppingSortTooltip(String mode);

  /// No description provided for @shoppingNoRecipesYet.
  ///
  /// In en, this message translates to:
  /// **'No recipes yet. Add some in the Recipes tab.'**
  String get shoppingNoRecipesYet;

  /// No description provided for @shoppingServingsAbbrev.
  ///
  /// In en, this message translates to:
  /// **'srv'**
  String get shoppingServingsAbbrev;

  /// No description provided for @shoppingServingCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} serving} other{{count} servings}}'**
  String shoppingServingCount(int count);

  /// No description provided for @shoppingMyItemsSection.
  ///
  /// In en, this message translates to:
  /// **'My Items'**
  String get shoppingMyItemsSection;

  /// No description provided for @shoppingEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No shopping list yet'**
  String get shoppingEmptyTitle;

  /// No description provided for @shoppingEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Plan recipes for the week and your shopping list will appear here automatically.'**
  String get shoppingEmptyMessage;

  /// No description provided for @shoppingGoToPlanChip.
  ///
  /// In en, this message translates to:
  /// **'Go to Plan tab'**
  String get shoppingGoToPlanChip;

  /// No description provided for @shoppingItemNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Item name'**
  String get shoppingItemNameLabel;

  /// No description provided for @shoppingItemNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Milk, Trash bags, Napkins'**
  String get shoppingItemNameHint;

  /// No description provided for @shoppingAddItemButton.
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get shoppingAddItemButton;

  /// No description provided for @shoppingNoExtraItems.
  ///
  /// In en, this message translates to:
  /// **'No extra items yet — add your first one above.'**
  String get shoppingNoExtraItems;

  /// No description provided for @shoppingInvalidItem.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid item.'**
  String get shoppingInvalidItem;

  /// No description provided for @shoppingItemNameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Item name must be at least 2 characters.'**
  String get shoppingItemNameTooShort;

  /// No description provided for @shoppingItemAmountInvalid.
  ///
  /// In en, this message translates to:
  /// **'Item amount must be greater than 0.'**
  String get shoppingItemAmountInvalid;

  /// No description provided for @shoppingItemDuplicate.
  ///
  /// In en, this message translates to:
  /// **'That item is already on the list.'**
  String get shoppingItemDuplicate;

  /// No description provided for @shoppingDeleteItemDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this item?'**
  String get shoppingDeleteItemDialogTitle;

  /// No description provided for @shoppingDeleteItemDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Remove \"{name}\" from your list?'**
  String shoppingDeleteItemDialogContent(String name);

  /// No description provided for @shoppingBulkDeleteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete checked items'**
  String get shoppingBulkDeleteTooltip;

  /// No description provided for @shoppingBulkDeleteDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Delete 1 checked item?} other{Delete {count} checked items?}}'**
  String shoppingBulkDeleteDialogTitle(int count);

  /// No description provided for @categoryBreakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get categoryBreakfast;

  /// No description provided for @categoryLunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get categoryLunch;

  /// No description provided for @categoryDinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get categoryDinner;

  /// No description provided for @categoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;

  /// No description provided for @marketCategoryVegetables.
  ///
  /// In en, this message translates to:
  /// **'Vegetables'**
  String get marketCategoryVegetables;

  /// No description provided for @marketCategoryFruit.
  ///
  /// In en, this message translates to:
  /// **'Fruit'**
  String get marketCategoryFruit;

  /// No description provided for @marketCategoryMeat.
  ///
  /// In en, this message translates to:
  /// **'Meat'**
  String get marketCategoryMeat;

  /// No description provided for @marketCategoryDairy.
  ///
  /// In en, this message translates to:
  /// **'Dairy'**
  String get marketCategoryDairy;

  /// No description provided for @marketCategoryBakery.
  ///
  /// In en, this message translates to:
  /// **'Bakery'**
  String get marketCategoryBakery;

  /// No description provided for @marketCategorySpices.
  ///
  /// In en, this message translates to:
  /// **'Spices'**
  String get marketCategorySpices;

  /// No description provided for @marketCategoryPantry.
  ///
  /// In en, this message translates to:
  /// **'Pantry'**
  String get marketCategoryPantry;

  /// No description provided for @marketCategoryDrinks.
  ///
  /// In en, this message translates to:
  /// **'Drinks'**
  String get marketCategoryDrinks;

  /// No description provided for @marketCategoryFrozen.
  ///
  /// In en, this message translates to:
  /// **'Frozen'**
  String get marketCategoryFrozen;

  /// No description provided for @marketCategorySnacks.
  ///
  /// In en, this message translates to:
  /// **'Snacks'**
  String get marketCategorySnacks;

  /// No description provided for @marketCategoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get marketCategoryOther;

  /// No description provided for @recipeFilterTitle.
  ///
  /// In en, this message translates to:
  /// **'Filter recipes'**
  String get recipeFilterTitle;

  /// No description provided for @recipeFilterCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get recipeFilterCategoryLabel;

  /// No description provided for @recipeFilterShowLabel.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get recipeFilterShowLabel;

  /// No description provided for @recipeFilterFavoritesOnly.
  ///
  /// In en, this message translates to:
  /// **'Favorites only'**
  String get recipeFilterFavoritesOnly;

  /// No description provided for @recipeFilterFavoritesChip.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get recipeFilterFavoritesChip;

  /// No description provided for @recipeFilterDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get recipeFilterDone;

  /// No description provided for @recipeFilterApply.
  ///
  /// In en, this message translates to:
  /// **'Apply ({count, plural, one{{count} filter} other{{count} filters}})'**
  String recipeFilterApply(int count);

  /// No description provided for @recipeSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search recipes'**
  String get recipeSearchHint;

  /// No description provided for @recipeViewToggleToList.
  ///
  /// In en, this message translates to:
  /// **'Switch to list view'**
  String get recipeViewToggleToList;

  /// No description provided for @recipeViewToggleToGrid.
  ///
  /// In en, this message translates to:
  /// **'Switch to grid view'**
  String get recipeViewToggleToGrid;

  /// No description provided for @recipeClearFiltersButton.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get recipeClearFiltersButton;

  /// No description provided for @recipeAddFirstButton.
  ///
  /// In en, this message translates to:
  /// **'Add your first recipe'**
  String get recipeAddFirstButton;

  /// No description provided for @recipeEmptyFavoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get recipeEmptyFavoritesTitle;

  /// No description provided for @recipeEmptyFavoritesMessage.
  ///
  /// In en, this message translates to:
  /// **'Tap the star on any recipe card to add to favorites.'**
  String get recipeEmptyFavoritesMessage;

  /// No description provided for @recipeEmptyFilteredTitle.
  ///
  /// In en, this message translates to:
  /// **'No matching recipes'**
  String get recipeEmptyFilteredTitle;

  /// No description provided for @recipeEmptyFilteredMessage.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your filters or search query.'**
  String get recipeEmptyFilteredMessage;

  /// No description provided for @recipeEmptySearchTitle.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get recipeEmptySearchTitle;

  /// No description provided for @recipeEmptySearchMessage.
  ///
  /// In en, this message translates to:
  /// **'No recipe matches your search.'**
  String get recipeEmptySearchMessage;

  /// No description provided for @recipeEmptyNoneTitle.
  ///
  /// In en, this message translates to:
  /// **'No recipes yet'**
  String get recipeEmptyNoneTitle;

  /// No description provided for @recipeEmptyNoneMessage.
  ///
  /// In en, this message translates to:
  /// **'Add your first recipe to start building your meal plan.'**
  String get recipeEmptyNoneMessage;

  /// No description provided for @recipeDeleteDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete recipe?'**
  String get recipeDeleteDialogTitle;

  /// No description provided for @recipeDeleteDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"?'**
  String recipeDeleteDialogContent(String name);

  /// No description provided for @recipeStepCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} step} other{{count} steps}}'**
  String recipeStepCount(int count);

  /// No description provided for @recipeKcalPerServing.
  ///
  /// In en, this message translates to:
  /// **'{value} kcal'**
  String recipeKcalPerServing(int value);

  /// No description provided for @recipeSectionIngredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get recipeSectionIngredients;

  /// No description provided for @recipeSectionInstructions.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get recipeSectionInstructions;

  /// No description provided for @recipeSectionNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get recipeSectionNotes;

  /// No description provided for @recipeStatServings.
  ///
  /// In en, this message translates to:
  /// **'servings'**
  String get recipeStatServings;

  /// No description provided for @recipeStatIngredients.
  ///
  /// In en, this message translates to:
  /// **'ingredients'**
  String get recipeStatIngredients;

  /// No description provided for @recipeStatSteps.
  ///
  /// In en, this message translates to:
  /// **'steps'**
  String get recipeStatSteps;

  /// No description provided for @recipeStatKcalPerServing.
  ///
  /// In en, this message translates to:
  /// **'kcal/serving'**
  String get recipeStatKcalPerServing;

  /// No description provided for @recipeFavoriteAdd.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get recipeFavoriteAdd;

  /// No description provided for @recipeFavoriteRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get recipeFavoriteRemove;

  /// No description provided for @recipeEditTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit recipe'**
  String get recipeEditTooltip;

  /// No description provided for @recipeQuickListAdd.
  ///
  /// In en, this message translates to:
  /// **'Add to Quick List'**
  String get recipeQuickListAdd;

  /// No description provided for @recipeQuickListRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove from Quick List'**
  String get recipeQuickListRemove;

  /// No description provided for @recipeFormTitleAdd.
  ///
  /// In en, this message translates to:
  /// **'Add Recipe'**
  String get recipeFormTitleAdd;

  /// No description provided for @recipeFormTitleEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Recipe'**
  String get recipeFormTitleEdit;

  /// No description provided for @recipeFormPhotoSection.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get recipeFormPhotoSection;

  /// No description provided for @recipeFormAddPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get recipeFormAddPhoto;

  /// No description provided for @recipeFormChangePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get recipeFormChangePhoto;

  /// No description provided for @recipeFormTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get recipeFormTakePhoto;

  /// No description provided for @recipeFormChooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get recipeFormChooseFromGallery;

  /// No description provided for @recipeFormImagePickFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load that photo. Please try again.'**
  String get recipeFormImagePickFailed;

  /// No description provided for @recipeFormImagePermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission needed to access the camera or photos. Please enable it in Settings.'**
  String get recipeFormImagePermissionDenied;

  /// No description provided for @recipeFormBasicInfo.
  ///
  /// In en, this message translates to:
  /// **'Basic info'**
  String get recipeFormBasicInfo;

  /// No description provided for @recipeFormNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Recipe name'**
  String get recipeFormNameLabel;

  /// No description provided for @recipeFormNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Recipe name is required.'**
  String get recipeFormNameRequired;

  /// No description provided for @recipeFormNameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Recipe name must be at least 2 characters.'**
  String get recipeFormNameTooShort;

  /// No description provided for @recipeFormGenerateWithAi.
  ///
  /// In en, this message translates to:
  /// **'Generate with AI'**
  String get recipeFormGenerateWithAi;

  /// No description provided for @recipeFormGenerateWithAiHint.
  ///
  /// In en, this message translates to:
  /// **'Type a recipe name first.'**
  String get recipeFormGenerateWithAiHint;

  /// No description provided for @recipeFormAiReplaceDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Replace current ingredients and instructions?'**
  String get recipeFormAiReplaceDialogTitle;

  /// No description provided for @recipeFormAiReplaceDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Generating with AI will replace what you\'ve already entered below. This can\'t be undone.'**
  String get recipeFormAiReplaceDialogContent;

  /// No description provided for @recipeFormAiReplaceConfirm.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get recipeFormAiReplaceConfirm;

  /// No description provided for @recipeFormAiErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t generate a recipe right now. Please try again.'**
  String get recipeFormAiErrorGeneric;

  /// No description provided for @recipeFormAiErrorRateLimit.
  ///
  /// In en, this message translates to:
  /// **'AI is busy right now. Please try again in a moment.'**
  String get recipeFormAiErrorRateLimit;

  /// No description provided for @recipeFormCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get recipeFormCategoryLabel;

  /// No description provided for @recipeFormServingsLabel.
  ///
  /// In en, this message translates to:
  /// **'Servings'**
  String get recipeFormServingsLabel;

  /// No description provided for @recipeFormAddIngredient.
  ///
  /// In en, this message translates to:
  /// **'Add ingredient'**
  String get recipeFormAddIngredient;

  /// No description provided for @recipeFormIngredientNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Ingredient name'**
  String get recipeFormIngredientNameLabel;

  /// No description provided for @recipeFormIngredientNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Tomato, Chicken, Pasta'**
  String get recipeFormIngredientNameHint;

  /// No description provided for @recipeFormAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get recipeFormAmountLabel;

  /// No description provided for @recipeFormUnitLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get recipeFormUnitLabel;

  /// No description provided for @recipeFormAddIngredientButton.
  ///
  /// In en, this message translates to:
  /// **'Add Ingredient'**
  String get recipeFormAddIngredientButton;

  /// No description provided for @recipeFormIngredientCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Category for \"{name}\"'**
  String recipeFormIngredientCategoryTitle(String name);

  /// No description provided for @recipeFormResetToAuto.
  ///
  /// In en, this message translates to:
  /// **'Reset to auto'**
  String get recipeFormResetToAuto;

  /// No description provided for @recipeFormEditIngredientTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit ingredient'**
  String get recipeFormEditIngredientTitle;

  /// No description provided for @recipeFormInvalidIngredient.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid ingredient.'**
  String get recipeFormInvalidIngredient;

  /// No description provided for @recipeFormIngredientNameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Ingredient name must be at least 2 characters.'**
  String get recipeFormIngredientNameTooShort;

  /// No description provided for @recipeFormIngredientAmountInvalid.
  ///
  /// In en, this message translates to:
  /// **'Ingredient amount must be greater than 0.'**
  String get recipeFormIngredientAmountInvalid;

  /// No description provided for @recipeFormInvalidValues.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid values.'**
  String get recipeFormInvalidValues;

  /// No description provided for @recipeFormEditStepTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit step {number}'**
  String recipeFormEditStepTitle(int number);

  /// No description provided for @recipeFormInstructionLabel.
  ///
  /// In en, this message translates to:
  /// **'Instruction'**
  String get recipeFormInstructionLabel;

  /// No description provided for @recipeFormAddInstructionSection.
  ///
  /// In en, this message translates to:
  /// **'Add instruction step'**
  String get recipeFormAddInstructionSection;

  /// No description provided for @recipeFormAddInstructionButton.
  ///
  /// In en, this message translates to:
  /// **'Add Instruction'**
  String get recipeFormAddInstructionButton;

  /// No description provided for @recipeFormInstructionEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter an instruction step.'**
  String get recipeFormInstructionEmpty;

  /// No description provided for @recipeFormInstructionTooShort.
  ///
  /// In en, this message translates to:
  /// **'Instruction must be at least 5 characters.'**
  String get recipeFormInstructionTooShort;

  /// No description provided for @recipeFormCaloriesSection.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get recipeFormCaloriesSection;

  /// No description provided for @recipeFormCaloriesLabel.
  ///
  /// In en, this message translates to:
  /// **'Total calories (optional)'**
  String get recipeFormCaloriesLabel;

  /// No description provided for @recipeFormCaloriesHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 450'**
  String get recipeFormCaloriesHint;

  /// No description provided for @recipeFormKcalSuffix.
  ///
  /// In en, this message translates to:
  /// **'kcal'**
  String get recipeFormKcalSuffix;

  /// No description provided for @recipeFormCaloriesHelper.
  ///
  /// In en, this message translates to:
  /// **'Per serving will be calculated automatically.'**
  String get recipeFormCaloriesHelper;

  /// No description provided for @recipeFormNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Optional notes'**
  String get recipeFormNotesLabel;

  /// No description provided for @recipeFormNoIngredients.
  ///
  /// In en, this message translates to:
  /// **'Please add at least one ingredient.'**
  String get recipeFormNoIngredients;

  /// No description provided for @recipeFormSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save Recipe'**
  String get recipeFormSaveButton;

  /// No description provided for @recipeFormUpdateButton.
  ///
  /// In en, this message translates to:
  /// **'Update Recipe'**
  String get recipeFormUpdateButton;

  /// No description provided for @backupExportSubject.
  ///
  /// In en, this message translates to:
  /// **'MealBridge Backup'**
  String get backupExportSubject;

  /// No description provided for @backupExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String backupExportFailed(String error);

  /// No description provided for @backupImportNewerVersion.
  ///
  /// In en, this message translates to:
  /// **'This backup was created with a newer version of MealBridge.'**
  String get backupImportNewerVersion;

  /// No description provided for @backupImportDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Import backup?'**
  String get backupImportDialogTitle;

  /// No description provided for @backupImportDialogIntro.
  ///
  /// In en, this message translates to:
  /// **'This will restore:'**
  String get backupImportDialogIntro;

  /// No description provided for @backupImportRecipeCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No recipes} one{{count} recipe} other{{count} recipes}}'**
  String backupImportRecipeCount(int count);

  /// No description provided for @backupImportExportedOn.
  ///
  /// In en, this message translates to:
  /// **'Exported on {date}'**
  String backupImportExportedOn(String date);

  /// No description provided for @backupImportWarning.
  ///
  /// In en, this message translates to:
  /// **'Your existing custom recipes will be replaced.'**
  String get backupImportWarning;

  /// No description provided for @backupImportConfirm.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get backupImportConfirm;

  /// No description provided for @backupImportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Backup imported successfully!'**
  String get backupImportSuccess;

  /// No description provided for @backupImportFailed.
  ///
  /// In en, this message translates to:
  /// **'Import failed: {error}'**
  String backupImportFailed(String error);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'nl', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'nl':
      return AppLocalizationsNl();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
