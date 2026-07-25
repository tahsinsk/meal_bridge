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
