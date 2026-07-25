// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get navRecipes => 'Tarifler';

  @override
  String get navPlan => 'Plan';

  @override
  String get navShopping => 'Market';

  @override
  String get navSettings => 'Ayarlar';

  @override
  String get onboardingSkip => 'Geç';

  @override
  String get onboardingNext => 'İleri';

  @override
  String get onboardingGetStarted => 'Başlayalım';

  @override
  String get onboardingPage1Title => 'Tariflerin tek bir yerde';

  @override
  String get onboardingPage1Body =>
      'Pişirdiklerini malzeme, adım ve kalorileriyle kaydet.';

  @override
  String get onboardingPage2Title => 'Haftanı planla';

  @override
  String get onboardingPage2Body =>
      'Yemekleri kahvaltı, öğle ve akşam yemeğine ekle — istediğin hafta için.';

  @override
  String get onboardingPage3Title => 'Alışveriş listen kendi kendine oluşsun';

  @override
  String get onboardingPage3Body =>
      'Malzemeler birleştirilip reyona göre sıralanır, markete hazır.';

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String settingsVersionLabel(String version) {
    return 'MealBridge v$version';
  }

  @override
  String get settingsDataBackupSection => 'Veri ve Yedekleme';

  @override
  String get settingsExportTitle => 'Yedek dışa aktar';

  @override
  String get settingsExportSubtitle =>
      'Tüm tariflerini ve yemek planını JSON dosyası olarak kaydet';

  @override
  String get settingsImportTitle => 'Yedek içe aktar';

  @override
  String get settingsImportSubtitle =>
      'Tariflerini ve yemek planını bir yedek dosyasından geri yükle';

  @override
  String get settingsBackupInfo =>
      'Telefon değiştirdiğinde tariflerini kaybetmemek için verilerini düzenli olarak dışa aktar.';

  @override
  String get settingsAboutSection => 'Hakkında';

  @override
  String settingsAppVersionSubtitle(String version) {
    return 'Sürüm $version';
  }

  @override
  String get settingsStorageTitle => 'Depolama';

  @override
  String get settingsStorageSubtitle =>
      'Tüm veriler cihazında yerel olarak saklanır';

  @override
  String get settingsResetOnboardingTitle => 'Tanıtımı sıfırla';

  @override
  String get settingsResetOnboardingSubtitle =>
      'Bayrağı temizle ve tanıtım ekranlarını tekrar göster';

  @override
  String get settingsLanguageSection => 'Dil';

  @override
  String get settingsLanguageSystemDefault => 'Sistem varsayılanı';

  @override
  String get commonCancel => 'İptal';

  @override
  String get backupExportSubject => 'MealBridge Yedeği';

  @override
  String backupExportFailed(String error) {
    return 'Dışa aktarma başarısız: $error';
  }

  @override
  String get backupImportNewerVersion =>
      'Bu yedek, MealBridge\'in daha yeni bir sürümüyle oluşturulmuş.';

  @override
  String get backupImportDialogTitle => 'Yedek içe aktarılsın mı?';

  @override
  String get backupImportDialogIntro => 'Bu işlem şunları geri yükleyecek:';

  @override
  String backupImportRecipeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tarif',
      zero: 'Tarif yok',
    );
    return '$_temp0';
  }

  @override
  String backupImportExportedOn(String date) {
    return '$date tarihinde dışa aktarıldı';
  }

  @override
  String get backupImportWarning => 'Mevcut özel tariflerin değiştirilecek.';

  @override
  String get backupImportConfirm => 'İçe aktar';

  @override
  String get backupImportSuccess => 'Yedek başarıyla içe aktarıldı!';

  @override
  String backupImportFailed(String error) {
    return 'İçe aktarma başarısız: $error';
  }
}
