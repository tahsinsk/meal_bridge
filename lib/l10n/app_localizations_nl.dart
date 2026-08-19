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
      'Bewaar wat je kookt — foto\'s, ingrediënten, stappen en calorieën, altijd binnen handbereik.';

  @override
  String get onboardingPage2Title => 'Of laat AI het typen doen';

  @override
  String get onboardingPage2Body =>
      'Beschrijf een gerecht en krijg een compleet recept terug — of maak een foto en het vult zichzelf in.';

  @override
  String get onboardingPage3Title => 'Plan elke week vooruit';

  @override
  String get onboardingPage3Body =>
      'Zet maaltijden bij ontbijt, lunch en diner — voor deze week of voor elke week die nog komt.';

  @override
  String get onboardingPage4Title => 'Je boodschappenlijst schrijft zichzelf';

  @override
  String get onboardingPage4Body =>
      'Ingrediënten worden automatisch gecombineerd, plus een Snellijst voor extra\'s en snelkoppelingen naar je vaste winkels.';

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
  String get planOverwriteConfirm => 'Overschrijven';

  @override
  String get dayMonday => 'Maandag';

  @override
  String get dayTuesday => 'Dinsdag';

  @override
  String get dayWednesday => 'Woensdag';

  @override
  String get dayThursday => 'Donderdag';

  @override
  String get dayFriday => 'Vrijdag';

  @override
  String get daySaturday => 'Zaterdag';

  @override
  String get daySunday => 'Zondag';

  @override
  String get planLastWeek => 'Vorige week';

  @override
  String get planThisWeek => 'Deze week';

  @override
  String get planNextWeek => 'Volgende week';

  @override
  String planWeekNumberLabel(int number) {
    return 'Week $number';
  }

  @override
  String planKcalPerServing(int value) {
    return '$value kcal/portie';
  }

  @override
  String planIngredientCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ingrediënten',
      one: '$count ingrediënt',
    );
    return '$_temp0';
  }

  @override
  String planCopiedDaySnackbar(String day) {
    return '$day gekopieerd';
  }

  @override
  String get planOverwriteDialogTitle => 'Deze dag overschrijven?';

  @override
  String planOverwriteDialogContent(String day) {
    return '$day heeft al geplande maaltijden. Plakken vervangt deze.';
  }

  @override
  String get planTodayBadge => 'Vandaag';

  @override
  String get planCopyDay => 'Dag kopiëren';

  @override
  String get planPasteDay => 'Dag plakken';

  @override
  String planAddMealType(String mealType) {
    return '$mealType toevoegen';
  }

  @override
  String get planAddToPlanTitle => 'Toevoegen aan plan';

  @override
  String get planAddToPlanButton => 'Toevoegen aan plan';

  @override
  String get planRecipeFieldLabel => 'Recept';

  @override
  String get planSearchRecipesHint => 'Recepten zoeken';

  @override
  String get planNoRecipesYet =>
      'Nog geen recepten. Voeg eerst een recept toe.';

  @override
  String get planNoRecipesMatch =>
      'Geen recepten komen overeen met je zoekopdracht of filter.';

  @override
  String get shoppingListHeading => 'Boodschappenlijst';

  @override
  String get shoppingShopAtCaption => 'Open je favoriete winkel';

  @override
  String get shoppingOnlineTooltip => 'Online winkelen';

  @override
  String get shoppingSortByTitle => 'Sorteren op';

  @override
  String get shoppingShareTooltip => 'Lijst delen';

  @override
  String get shoppingAddItemTooltip => 'Item toevoegen';

  @override
  String get shoppingWeeklyPlanMode => 'Weekplan';

  @override
  String get shoppingQuickListMode => 'Snellijst';

  @override
  String get shoppingSelectAll => 'Alles selecteren';

  @override
  String shoppingSortTooltip(String mode) {
    return 'Sorteren: $mode';
  }

  @override
  String get shoppingNoRecipesYet =>
      'Nog geen recepten. Voeg ze toe via het tabblad Recepten.';

  @override
  String get shoppingServingsAbbrev => 'port';

  @override
  String shoppingServingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count porties',
      one: '$count portie',
    );
    return '$_temp0';
  }

  @override
  String get shoppingMyItemsSection => 'Mijn items';

  @override
  String get shoppingEmptyTitle => 'Nog geen boodschappenlijst';

  @override
  String get shoppingEmptyMessage =>
      'Plan recepten voor de week en je boodschappenlijst verschijnt hier automatisch.';

  @override
  String get shoppingGoToPlanChip => 'Ga naar tabblad Plan';

  @override
  String get shoppingItemNameLabel => 'Naam item';

  @override
  String get shoppingItemNameHint => 'bijv. Melk, Vuilniszakken, Servetten';

  @override
  String get shoppingAddItemButton => 'Item toevoegen';

  @override
  String get shoppingNoExtraItems =>
      'Nog geen extra items — voeg er hierboven een toe.';

  @override
  String get shoppingInvalidItem => 'Voer een geldig item in.';

  @override
  String get shoppingItemNameTooShort =>
      'Naam van het item moet minstens 2 tekens bevatten.';

  @override
  String get shoppingItemAmountInvalid => 'Hoeveelheid moet groter zijn dan 0.';

  @override
  String get shoppingItemDuplicate => 'Dat item staat al op de lijst.';

  @override
  String get shoppingDeleteItemDialogTitle => 'Dit item verwijderen?';

  @override
  String shoppingDeleteItemDialogContent(String name) {
    return '\"$name\" van je lijst verwijderen?';
  }

  @override
  String get shoppingBulkDeleteTooltip => 'Aangevinkte items verwijderen';

  @override
  String shoppingBulkDeleteDialogTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count aangevinkte items verwijderen?',
      one: '1 aangevinkt item verwijderen?',
    );
    return '$_temp0';
  }

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
  String get recipeSearchHint => 'Zoek recepten';

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
  String get recipeStatMinutes => 'min';

  @override
  String recipeStepDurationLabel(int minutes) {
    return '~$minutes min';
  }

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
  String get recipeFormPhotoSection => 'Foto';

  @override
  String get recipeFormAddPhoto => 'Foto toevoegen';

  @override
  String get recipeFormChangePhoto => 'Foto wijzigen';

  @override
  String get recipeFormTakePhoto => 'Foto maken';

  @override
  String get recipeFormChooseFromGallery => 'Kiezen uit galerij';

  @override
  String get recipeFormImagePickFailed =>
      'Deze foto kon niet worden geladen. Probeer het opnieuw.';

  @override
  String get recipeFormImagePermissionDenied =>
      'Toegang tot camera of foto\'s is nodig. Schakel dit in bij Instellingen.';

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
  String get recipeFormGenerateWithAi => 'Genereren met AI';

  @override
  String get recipeFormGenerateWithAiHint => 'Voer eerst een receptnaam in.';

  @override
  String get recipeFormAiReplaceDialogTitle =>
      'Huidige ingrediënten en instructies vervangen?';

  @override
  String get recipeFormAiReplaceDialogContent =>
      'Genereren met AI vervangt wat je hieronder al hebt ingevoerd. Dit kan niet ongedaan worden gemaakt.';

  @override
  String get recipeFormAiReplaceConfirm => 'Vervangen';

  @override
  String get recipeFormAiErrorGeneric =>
      'Kon nu geen recept genereren. Probeer het opnieuw.';

  @override
  String get recipeFormAiErrorRateLimit =>
      'AI heeft het nu druk. Probeer het straks opnieuw.';

  @override
  String get recipeFormAiAssistTooltip => 'Maken met AI';

  @override
  String get recipeFormChoiceSheetTitle => 'Hoe wil je beginnen?';

  @override
  String get recipeFormFillManually => 'Handmatig invullen';

  @override
  String get recipeFormScanPhoto => 'Receptfoto scannen';

  @override
  String get recipeFormAiScanErrorGeneric =>
      'Kon die receptfoto niet lezen. Probeer een duidelijkere foto, of vul handmatig in.';

  @override
  String get recipeAiPromptQuestion => 'Wat wil je koken?';

  @override
  String get recipeAiPromptHint => 'bijv. Pittige groente-roerbak';

  @override
  String get recipeAiPromptButton => 'Genereren';

  @override
  String get recipeScanPrompt => 'Maak of upload een foto van een recept';

  @override
  String get recipeScanLoadingMessage => 'Je recept wordt gelezen...';

  @override
  String get recipeScanErrorRetry => 'Probeer een andere foto';

  @override
  String get recipeFormPantrySuggest => 'Wat kan ik maken?';

  @override
  String get recipePantryQuestion => 'Welke ingrediënten heb je?';

  @override
  String get recipePantryHint => 'bijv. kip, room, pasta, knoflook';

  @override
  String get recipePantryButton => 'Stel een recept voor';

  @override
  String get recipePantryEmptyHint => 'Voer eerst minstens één ingrediënt in.';

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
