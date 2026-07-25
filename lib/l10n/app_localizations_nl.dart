// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get navRecipes => 'Recepten';

  @override
  String get navPlan => 'Plan';

  @override
  String get navShopping => 'Boodschappen';

  @override
  String get navSettings => 'Instellingen';

  @override
  String get onboardingSkip => 'Overslaan';

  @override
  String get onboardingNext => 'Volgende';

  @override
  String get onboardingGetStarted => 'Aan de slag';

  @override
  String get onboardingPage1Title => 'Al je recepten op één plek';

  @override
  String get onboardingPage1Body =>
      'Bewaar wat je kookt, met ingrediënten, stappen en calorieën.';

  @override
  String get onboardingPage2Title => 'Plan je week';

  @override
  String get onboardingPage2Body =>
      'Zet maaltijden bij ontbijt, lunch en diner — voor elke week.';

  @override
  String get onboardingPage3Title => 'Je boodschappenlijst schrijft zichzelf';

  @override
  String get onboardingPage3Body =>
      'Ingrediënten worden gecombineerd en gesorteerd per gangpad, klaar voor de winkel.';

  @override
  String get settingsTitle => 'Instellingen';

  @override
  String settingsVersionLabel(String version) {
    return 'MealBridge v$version';
  }

  @override
  String get settingsDataBackupSection => 'Gegevens en back-up';

  @override
  String get settingsExportTitle => 'Back-up exporteren';

  @override
  String get settingsExportSubtitle =>
      'Sla al je recepten en maaltijdplan op als JSON-bestand';

  @override
  String get settingsImportTitle => 'Back-up importeren';

  @override
  String get settingsImportSubtitle =>
      'Herstel je recepten en maaltijdplan vanuit een back-upbestand';

  @override
  String get settingsBackupInfo =>
      'Exporteer je gegevens regelmatig, zodat je niets kwijtraakt als je van telefoon wisselt.';

  @override
  String get settingsAboutSection => 'Over';

  @override
  String settingsAppVersionSubtitle(String version) {
    return 'Versie $version';
  }

  @override
  String get settingsStorageTitle => 'Opslag';

  @override
  String get settingsStorageSubtitle =>
      'Alle gegevens worden lokaal op je toestel opgeslagen';

  @override
  String get settingsResetOnboardingTitle => 'Introductie resetten';

  @override
  String get settingsResetOnboardingSubtitle =>
      'Wis de status en toon de introductieschermen opnieuw';

  @override
  String get settingsLanguageSection => 'Taal';

  @override
  String get settingsLanguageSystemDefault => 'Systeemstandaard';

  @override
  String get commonCancel => 'Annuleren';

  @override
  String get commonSave => 'Opslaan';

  @override
  String get commonEdit => 'Bewerken';

  @override
  String get commonDelete => 'Verwijderen';

  @override
  String get commonClearAll => 'Alles wissen';

  @override
  String get categoryBreakfast => 'Ontbijt';

  @override
  String get categoryLunch => 'Lunch';

  @override
  String get categoryDinner => 'Diner';

  @override
  String get categoryOther => 'Overig';

  @override
  String get marketCategoryVegetables => 'Groenten';

  @override
  String get marketCategoryFruit => 'Fruit';

  @override
  String get marketCategoryMeat => 'Vlees';

  @override
  String get marketCategoryDairy => 'Zuivel';

  @override
  String get marketCategoryBakery => 'Bakkerij';

  @override
  String get marketCategorySpices => 'Kruiden';

  @override
  String get marketCategoryPantry => 'Voorraadkast';

  @override
  String get marketCategoryDrinks => 'Dranken';

  @override
  String get marketCategoryFrozen => 'Diepvries';

  @override
  String get marketCategorySnacks => 'Snacks';

  @override
  String get marketCategoryOther => 'Overig';

  @override
  String get recipeFilterTitle => 'Recepten filteren';

  @override
  String get recipeFilterCategoryLabel => 'Categorie';

  @override
  String get recipeFilterShowLabel => 'Tonen';

  @override
  String get recipeFilterFavoritesOnly => 'Alleen favorieten';

  @override
  String get recipeFilterFavoritesChip => 'Favorieten';

  @override
  String get recipeFilterDone => 'Klaar';

  @override
  String recipeFilterApply(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count filters',
      one: '$count filter',
    );
    return 'Toepassen ($_temp0)';
  }

  @override
  String get recipeSearchHint => 'Zoek recepten op naam of categorie';

  @override
  String get recipeViewToggleToList => 'Naar lijstweergave';

  @override
  String get recipeViewToggleToGrid => 'Naar rasterweergave';

  @override
  String get recipeClearFiltersButton => 'Filters wissen';

  @override
  String get recipeAddFirstButton => 'Voeg je eerste recept toe';

  @override
  String get recipeEmptyFavoritesTitle => 'Nog geen favorieten';

  @override
  String get recipeEmptyFavoritesMessage =>
      'Tik op de ster bij een recept om het aan je favorieten toe te voegen.';

  @override
  String get recipeEmptyFilteredTitle => 'Geen recepten gevonden';

  @override
  String get recipeEmptyFilteredMessage =>
      'Pas je filters of zoekopdracht aan.';

  @override
  String get recipeEmptySearchTitle => 'Geen resultaten';

  @override
  String get recipeEmptySearchMessage =>
      'Geen recept komt overeen met je zoekopdracht.';

  @override
  String get recipeEmptyNoneTitle => 'Nog geen recepten';

  @override
  String get recipeEmptyNoneMessage =>
      'Voeg je eerste recept toe om je maaltijdplan op te bouwen.';

  @override
  String get recipeDeleteDialogTitle => 'Recept verwijderen?';

  @override
  String recipeDeleteDialogContent(String name) {
    return 'Weet je zeker dat je \"$name\" wilt verwijderen?';
  }

  @override
  String recipeStepCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stappen',
      one: '$count stap',
    );
    return '$_temp0';
  }

  @override
  String recipeKcalPerServing(int value) {
    return '$value kcal';
  }

  @override
  String get recipeSectionIngredients => 'Ingrediënten';

  @override
  String get recipeSectionInstructions => 'Bereidingswijze';

  @override
  String get recipeSectionNotes => 'Notities';

  @override
  String get recipeStatServings => 'porties';

  @override
  String get recipeStatIngredients => 'ingrediënten';

  @override
  String get recipeStatSteps => 'stappen';

  @override
  String get recipeStatKcalPerServing => 'kcal/portie';

  @override
  String get recipeFavoriteAdd => 'Toevoegen aan favorieten';

  @override
  String get recipeFavoriteRemove => 'Verwijderen uit favorieten';

  @override
  String get recipeEditTooltip => 'Recept bewerken';

  @override
  String get recipeQuickListAdd => 'Toevoegen aan snellijst';

  @override
  String get recipeQuickListRemove => 'Verwijderen uit snellijst';

  @override
  String get recipeFormTitleAdd => 'Recept toevoegen';

  @override
  String get recipeFormTitleEdit => 'Recept bewerken';

  @override
  String get recipeFormBasicInfo => 'Basisgegevens';

  @override
  String get recipeFormNameLabel => 'Naam recept';

  @override
  String get recipeFormNameRequired => 'Naam van het recept is verplicht.';

  @override
  String get recipeFormNameTooShort =>
      'Naam van het recept moet minstens 2 tekens bevatten.';

  @override
  String get recipeFormCategoryLabel => 'Categorie';

  @override
  String get recipeFormServingsLabel => 'Porties';

  @override
  String get recipeFormAddIngredient => 'Ingrediënt toevoegen';

  @override
  String get recipeFormIngredientNameLabel => 'Naam ingrediënt';

  @override
  String get recipeFormIngredientNameHint => 'bijv. Tomaat, Kip, Pasta';

  @override
  String get recipeFormAmountLabel => 'Hoeveelheid';

  @override
  String get recipeFormUnitLabel => 'Eenheid';

  @override
  String get recipeFormAddIngredientButton => 'Ingrediënt toevoegen';

  @override
  String recipeFormIngredientCategoryTitle(String name) {
    return 'Categorie voor \"$name\"';
  }

  @override
  String get recipeFormResetToAuto => 'Terug naar automatisch';

  @override
  String get recipeFormEditIngredientTitle => 'Ingrediënt bewerken';

  @override
  String get recipeFormInvalidIngredient => 'Voer een geldig ingrediënt in.';

  @override
  String get recipeFormIngredientNameTooShort =>
      'Naam van het ingrediënt moet minstens 2 tekens bevatten.';

  @override
  String get recipeFormIngredientAmountInvalid =>
      'Hoeveelheid moet groter zijn dan 0.';

  @override
  String get recipeFormInvalidValues => 'Voer geldige waarden in.';

  @override
  String recipeFormEditStepTitle(int number) {
    return 'Stap $number bewerken';
  }

  @override
  String get recipeFormInstructionLabel => 'Stap';

  @override
  String get recipeFormAddInstructionSection => 'Bereidingsstap toevoegen';

  @override
  String get recipeFormAddInstructionButton => 'Stap toevoegen';

  @override
  String get recipeFormInstructionEmpty => 'Voer een bereidingsstap in.';

  @override
  String get recipeFormInstructionTooShort =>
      'Bereidingsstap moet minstens 5 tekens bevatten.';

  @override
  String get recipeFormCaloriesSection => 'Calorieën';

  @override
  String get recipeFormCaloriesLabel => 'Totaal aantal calorieën (optioneel)';

  @override
  String get recipeFormCaloriesHint => 'bijv. 450';

  @override
  String get recipeFormKcalSuffix => 'kcal';

  @override
  String get recipeFormCaloriesHelper =>
      'Per portie wordt automatisch berekend.';

  @override
  String get recipeFormNotesLabel => 'Optionele notities';

  @override
  String get recipeFormNoIngredients => 'Voeg minstens één ingrediënt toe.';

  @override
  String get recipeFormSaveButton => 'Recept opslaan';

  @override
  String get recipeFormUpdateButton => 'Recept bijwerken';

  @override
  String get backupExportSubject => 'MealBridge-back-up';

  @override
  String backupExportFailed(String error) {
    return 'Exporteren mislukt: $error';
  }

  @override
  String get backupImportNewerVersion =>
      'Deze back-up is gemaakt met een nieuwere versie van MealBridge.';

  @override
  String get backupImportDialogTitle => 'Back-up importeren?';

  @override
  String get backupImportDialogIntro => 'Dit herstelt:';

  @override
  String backupImportRecipeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recepten',
      one: '$count recept',
      zero: 'Geen recepten',
    );
    return '$_temp0';
  }

  @override
  String backupImportExportedOn(String date) {
    return 'Geëxporteerd op $date';
  }

  @override
  String get backupImportWarning =>
      'Je bestaande eigen recepten worden vervangen.';

  @override
  String get backupImportConfirm => 'Importeren';

  @override
  String get backupImportSuccess => 'Back-up succesvol geïmporteerd!';

  @override
  String backupImportFailed(String error) {
    return 'Importeren mislukt: $error';
  }
}
