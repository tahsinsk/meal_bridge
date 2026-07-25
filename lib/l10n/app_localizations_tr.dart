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
  String get commonSave => 'Kaydet';

  @override
  String get commonEdit => 'Düzenle';

  @override
  String get commonDelete => 'Sil';

  @override
  String get commonClearAll => 'Tümünü temizle';

  @override
  String get categoryBreakfast => 'Kahvaltı';

  @override
  String get categoryLunch => 'Öğle Yemeği';

  @override
  String get categoryDinner => 'Akşam Yemeği';

  @override
  String get categoryOther => 'Diğer';

  @override
  String get marketCategoryVegetables => 'Sebze';

  @override
  String get marketCategoryFruit => 'Meyve';

  @override
  String get marketCategoryMeat => 'Et & Balık';

  @override
  String get marketCategoryDairy => 'Süt Ürünleri';

  @override
  String get marketCategoryBakery => 'Unlu Mamüller';

  @override
  String get marketCategorySpices => 'Baharat';

  @override
  String get marketCategoryPantry => 'Temel Gıda';

  @override
  String get marketCategoryDrinks => 'İçecek';

  @override
  String get marketCategoryFrozen => 'Dondurulmuş';

  @override
  String get marketCategorySnacks => 'Atıştırmalık';

  @override
  String get marketCategoryOther => 'Diğer';

  @override
  String get recipeFilterTitle => 'Tarifleri filtrele';

  @override
  String get recipeFilterCategoryLabel => 'Kategori';

  @override
  String get recipeFilterShowLabel => 'Göster';

  @override
  String get recipeFilterFavoritesOnly => 'Sadece favoriler';

  @override
  String get recipeFilterFavoritesChip => 'Favoriler';

  @override
  String get recipeFilterDone => 'Tamam';

  @override
  String recipeFilterApply(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count filtre',
    );
    return 'Uygula ($_temp0)';
  }

  @override
  String get recipeSearchHint => 'İsme veya kategoriye göre tarif ara';

  @override
  String get recipeViewToggleToList => 'Liste görünümüne geç';

  @override
  String get recipeViewToggleToGrid => 'Izgara görünümüne geç';

  @override
  String get recipeClearFiltersButton => 'Filtreleri temizle';

  @override
  String get recipeAddFirstButton => 'İlk tarifini ekle';

  @override
  String get recipeEmptyFavoritesTitle => 'Henüz favori yok';

  @override
  String get recipeEmptyFavoritesMessage =>
      'Favorilere eklemek için bir tarif kartındaki yıldıza dokun.';

  @override
  String get recipeEmptyFilteredTitle => 'Eşleşen tarif yok';

  @override
  String get recipeEmptyFilteredMessage =>
      'Filtrelerini veya arama sorgunu değiştirmeyi dene.';

  @override
  String get recipeEmptySearchTitle => 'Sonuç bulunamadı';

  @override
  String get recipeEmptySearchMessage => 'Aramanla eşleşen bir tarif yok.';

  @override
  String get recipeEmptyNoneTitle => 'Henüz tarif yok';

  @override
  String get recipeEmptyNoneMessage =>
      'Yemek planını oluşturmaya başlamak için ilk tarifini ekle.';

  @override
  String get recipeDeleteDialogTitle => 'Tarif silinsin mi?';

  @override
  String recipeDeleteDialogContent(String name) {
    return '\"$name\" tarifini silmek istediğinden emin misin?';
  }

  @override
  String recipeStepCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count adım',
    );
    return '$_temp0';
  }

  @override
  String recipeKcalPerServing(int value) {
    return '$value kcal';
  }

  @override
  String get recipeSectionIngredients => 'Malzemeler';

  @override
  String get recipeSectionInstructions => 'Yapılışı';

  @override
  String get recipeSectionNotes => 'Notlar';

  @override
  String get recipeStatServings => 'porsiyon';

  @override
  String get recipeStatIngredients => 'malzeme';

  @override
  String get recipeStatSteps => 'adım';

  @override
  String get recipeStatKcalPerServing => 'kcal/porsiyon';

  @override
  String get recipeFavoriteAdd => 'Favorilere ekle';

  @override
  String get recipeFavoriteRemove => 'Favorilerden çıkar';

  @override
  String get recipeEditTooltip => 'Tarifi düzenle';

  @override
  String get recipeQuickListAdd => 'Hızlı Listeye ekle';

  @override
  String get recipeQuickListRemove => 'Hızlı Listeden çıkar';

  @override
  String get recipeFormTitleAdd => 'Tarif Ekle';

  @override
  String get recipeFormTitleEdit => 'Tarifi Düzenle';

  @override
  String get recipeFormBasicInfo => 'Temel bilgiler';

  @override
  String get recipeFormNameLabel => 'Tarif adı';

  @override
  String get recipeFormNameRequired => 'Tarif adı zorunludur.';

  @override
  String get recipeFormNameTooShort => 'Tarif adı en az 2 karakter olmalı.';

  @override
  String get recipeFormCategoryLabel => 'Kategori';

  @override
  String get recipeFormServingsLabel => 'Porsiyon';

  @override
  String get recipeFormAddIngredient => 'Malzeme ekle';

  @override
  String get recipeFormIngredientNameLabel => 'Malzeme adı';

  @override
  String get recipeFormIngredientNameHint => 'örn. Domates, Tavuk, Makarna';

  @override
  String get recipeFormAmountLabel => 'Miktar';

  @override
  String get recipeFormUnitLabel => 'Birim';

  @override
  String get recipeFormAddIngredientButton => 'Malzeme Ekle';

  @override
  String recipeFormIngredientCategoryTitle(String name) {
    return '\"$name\" için kategori';
  }

  @override
  String get recipeFormResetToAuto => 'Otomatiğe sıfırla';

  @override
  String get recipeFormEditIngredientTitle => 'Malzemeyi düzenle';

  @override
  String get recipeFormInvalidIngredient => 'Lütfen geçerli bir malzeme gir.';

  @override
  String get recipeFormIngredientNameTooShort =>
      'Malzeme adı en az 2 karakter olmalı.';

  @override
  String get recipeFormIngredientAmountInvalid =>
      'Malzeme miktarı 0\'dan büyük olmalı.';

  @override
  String get recipeFormInvalidValues => 'Lütfen geçerli değerler gir.';

  @override
  String recipeFormEditStepTitle(int number) {
    return '$number. adımı düzenle';
  }

  @override
  String get recipeFormInstructionLabel => 'Yapılış adımı';

  @override
  String get recipeFormAddInstructionSection => 'Yapılış adımı ekle';

  @override
  String get recipeFormAddInstructionButton => 'Adım Ekle';

  @override
  String get recipeFormInstructionEmpty => 'Lütfen bir yapılış adımı gir.';

  @override
  String get recipeFormInstructionTooShort =>
      'Yapılış adımı en az 5 karakter olmalı.';

  @override
  String get recipeFormCaloriesSection => 'Kalori';

  @override
  String get recipeFormCaloriesLabel => 'Toplam kalori (opsiyonel)';

  @override
  String get recipeFormCaloriesHint => 'örn. 450';

  @override
  String get recipeFormKcalSuffix => 'kcal';

  @override
  String get recipeFormCaloriesHelper =>
      'Porsiyon başına değer otomatik hesaplanır.';

  @override
  String get recipeFormNotesLabel => 'Ek notlar';

  @override
  String get recipeFormNoIngredients => 'Lütfen en az bir malzeme ekle.';

  @override
  String get recipeFormSaveButton => 'Tarifi Kaydet';

  @override
  String get recipeFormUpdateButton => 'Tarifi Güncelle';

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
