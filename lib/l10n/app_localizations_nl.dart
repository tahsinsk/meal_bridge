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
