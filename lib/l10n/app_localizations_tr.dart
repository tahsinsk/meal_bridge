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
      'Pişirdiklerini fotoğraf, malzeme, adım ve kalorileriyle kaydet — ne zaman istersen elinin altında.';

  @override
  String get onboardingPage2Title => 'Ya da yazmayı yapay zekaya bırak';

  @override
  String get onboardingPage2Body =>
      'Bir yemek tarif et, tarifi hazır bul — ya da bir fotoğrafını çek, kendiliğinden doldursun.';

  @override
  String get onboardingPage3Title => 'İstediğin haftayı planla';

  @override
  String get onboardingPage3Body =>
      'Yemekleri kahvaltı, öğle ve akşam yemeğine ekle — bu hafta ya da ileride herhangi bir hafta için.';

  @override
  String get onboardingPage4Title => 'Alışveriş listen kendi kendine oluşsun';

  @override
  String get onboardingPage4Body =>
      'Malzemeler otomatik birleşir; ekstralar için Hızlı Liste, sık kullandığın marketlere de tek dokunuşluk kısayollar var.';

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
  String get planOverwriteConfirm => 'Üzerine yaz';

  @override
  String get dayMonday => 'Pazartesi';

  @override
  String get dayTuesday => 'Salı';

  @override
  String get dayWednesday => 'Çarşamba';

  @override
  String get dayThursday => 'Perşembe';

  @override
  String get dayFriday => 'Cuma';

  @override
  String get daySaturday => 'Cumartesi';

  @override
  String get daySunday => 'Pazar';

  @override
  String get planLastWeek => 'Geçen hafta';

  @override
  String get planThisWeek => 'Bu hafta';

  @override
  String get planNextWeek => 'Gelecek hafta';

  @override
  String planWeekNumberLabel(int number) {
    return '$number. Hafta';
  }

  @override
  String planKcalPerServing(int value) {
    return '$value kcal/porsiyon';
  }

  @override
  String planIngredientCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count malzeme',
    );
    return '$_temp0';
  }

  @override
  String planCopiedDaySnackbar(String day) {
    return '$day günü kopyalandı';
  }

  @override
  String get planOverwriteDialogTitle => 'Bu günün üzerine yazılsın mı?';

  @override
  String planOverwriteDialogContent(String day) {
    return '$day için zaten planlanmış yemekler var. Yapıştırma bunların yerini alacak.';
  }

  @override
  String get planTodayBadge => 'Bugün';

  @override
  String get planCopyDay => 'Günü kopyala';

  @override
  String get planPasteDay => 'Günü yapıştır';

  @override
  String planAddMealType(String mealType) {
    return '$mealType ekle';
  }

  @override
  String get planAddToPlanTitle => 'Plana ekle';

  @override
  String get planAddToPlanButton => 'Plana Ekle';

  @override
  String get planRecipeFieldLabel => 'Tarif';

  @override
  String get planSearchRecipesHint => 'Tarif ara';

  @override
  String get planNoRecipesYet => 'Henüz tarif yok. Önce bir tarif ekle.';

  @override
  String get planNoRecipesMatch => 'Aramanla veya filtrenle eşleşen tarif yok.';

  @override
  String get shoppingListHeading => 'Alışveriş listesi';

  @override
  String get shoppingShopAtCaption => 'Favori marketini aç';

  @override
  String get shoppingOnlineTooltip => 'Online alışveriş';

  @override
  String get shoppingSortByTitle => 'Sırala';

  @override
  String get shoppingShareTooltip => 'Listeyi paylaş';

  @override
  String get shoppingAddItemTooltip => 'Öğe ekle';

  @override
  String get shoppingWeeklyPlanMode => 'Haftalık Plan';

  @override
  String get shoppingQuickListMode => 'Hızlı Liste';

  @override
  String get shoppingSelectAll => 'Tümünü seç';

  @override
  String shoppingSortTooltip(String mode) {
    return 'Sırala: $mode';
  }

  @override
  String get shoppingNoRecipesYet =>
      'Henüz tarif yok. Tarifler sekmesinden ekleyebilirsin.';

  @override
  String get shoppingServingsAbbrev => 'prs';

  @override
  String shoppingServingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count porsiyon',
    );
    return '$_temp0';
  }

  @override
  String get shoppingMyItemsSection => 'Kendi Ürünlerim';

  @override
  String get shoppingEmptyTitle => 'Henüz alışveriş listesi yok';

  @override
  String get shoppingEmptyMessage =>
      'Hafta için tarif planla, alışveriş listen otomatik olarak burada oluşsun.';

  @override
  String get shoppingGoToPlanChip => 'Plan sekmesine git';

  @override
  String get shoppingItemNameLabel => 'Öğe adı';

  @override
  String get shoppingItemNameHint => 'örn. Süt, Çöp poşeti, Peçete';

  @override
  String get shoppingAddItemButton => 'Öğe Ekle';

  @override
  String get shoppingNoExtraItems =>
      'Henüz ek ürün yok — yukarıdan ilkini ekle.';

  @override
  String get shoppingInvalidItem => 'Lütfen geçerli bir öğe gir.';

  @override
  String get shoppingItemNameTooShort => 'Öğe adı en az 2 karakter olmalı.';

  @override
  String get shoppingItemAmountInvalid => 'Öğe miktarı 0\'dan büyük olmalı.';

  @override
  String get shoppingItemDuplicate => 'Bu öğe zaten listede.';

  @override
  String get shoppingDeleteItemDialogTitle => 'Bu öğe silinsin mi?';

  @override
  String shoppingDeleteItemDialogContent(String name) {
    return '\"$name\" listeden kaldırılsın mı?';
  }

  @override
  String get shoppingBulkDeleteTooltip => 'İşaretli öğeleri sil';

  @override
  String shoppingBulkDeleteDialogTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'İşaretli $count öğe silinsin mi?',
    );
    return '$_temp0';
  }

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
  String get recipeSearchHint => 'Tarif ara';

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
  String get recipeStatMinutes => 'dk';

  @override
  String recipeStepDurationLabel(int minutes) {
    return '~$minutes dk';
  }

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
  String get recipeFormPhotoSection => 'Fotoğraf';

  @override
  String get recipeFormAddPhoto => 'Fotoğraf ekle';

  @override
  String get recipeFormChangePhoto => 'Fotoğrafı değiştir';

  @override
  String get recipeFormTakePhoto => 'Fotoğraf çek';

  @override
  String get recipeFormChooseFromGallery => 'Galeriden seç';

  @override
  String get recipeFormImagePickFailed =>
      'Fotoğraf yüklenemedi. Lütfen tekrar deneyin.';

  @override
  String get recipeFormImagePermissionDenied =>
      'Kameraya veya fotoğraflara erişim izni gerekiyor. Lütfen Ayarlar\'dan izin verin.';

  @override
  String get recipeFormBasicInfo => 'Temel bilgiler';

  @override
  String get recipeFormNameLabel => 'Tarif adı';

  @override
  String get recipeFormNameRequired => 'Tarif adı zorunludur.';

  @override
  String get recipeFormNameTooShort => 'Tarif adı en az 2 karakter olmalı.';

  @override
  String get recipeFormGenerateWithAi => 'Yapay Zeka ile Oluştur';

  @override
  String get recipeFormGenerateWithAiHint => 'Önce bir tarif adı yazın.';

  @override
  String get recipeFormAiReplaceDialogTitle =>
      'Mevcut malzemeler ve talimatlar değiştirilsin mi?';

  @override
  String get recipeFormAiReplaceDialogContent =>
      'Yapay zeka ile oluşturmak, aşağıda zaten girdiğiniz bilgilerin yerini alacak. Bu geri alınamaz.';

  @override
  String get recipeFormAiReplaceConfirm => 'Değiştir';

  @override
  String get recipeFormAiErrorGeneric =>
      'Şu anda tarif oluşturulamadı. Lütfen tekrar deneyin.';

  @override
  String get recipeFormAiErrorRateLimit =>
      'Yapay zeka şu anda yoğun. Lütfen birazdan tekrar deneyin.';

  @override
  String get recipeFormAiAssistTooltip => 'Yapay Zeka ile Oluştur';

  @override
  String get recipeFormChoiceSheetTitle => 'Nasıl başlamak istersiniz?';

  @override
  String get recipeFormFillManually => 'Elle doldur';

  @override
  String get recipeFormScanPhoto => 'Tarif fotoğrafı tara';

  @override
  String get recipeFormAiScanErrorGeneric =>
      'Bu tarif fotoğrafı okunamadı. Daha net bir fotoğraf deneyin veya elle doldurun.';

  @override
  String get recipeAiPromptQuestion => 'Ne pişirmek istersiniz?';

  @override
  String get recipeAiPromptHint => 'örn. Acılı sebze sote';

  @override
  String get recipeAiPromptButton => 'Oluştur';

  @override
  String get recipeScanPrompt => 'Bir tarifin fotoğrafını çekin veya yükleyin';

  @override
  String get recipeScanLoadingMessage => 'Tarifiniz okunuyor...';

  @override
  String get recipeScanErrorRetry => 'Başka bir fotoğraf dene';

  @override
  String get recipeFormPantrySuggest => 'Ne yapabilirim?';

  @override
  String get recipePantryQuestion => 'Hangi malzemeleriniz var?';

  @override
  String get recipePantryHint => 'örn. tavuk, krema, makarna, sarımsak';

  @override
  String get recipePantryButton => 'Tarif öner';

  @override
  String get recipePantryEmptyHint => 'Önce en az bir malzeme yazın.';

  @override
  String get recipePreferenceHighProtein => 'Yüksek protein';

  @override
  String get recipePreferenceVegetarian => 'Vejetaryen';

  @override
  String get recipePreferenceQuick => 'Hızlı';

  @override
  String get recipePreferenceBudgetFriendly => 'Ekonomik';

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
  String get recipeFormTotalTimeSection => 'Toplam süre';

  @override
  String get recipeFormTotalTimeLabel => 'Toplam süre (dakika, opsiyonel)';

  @override
  String get recipeFormTotalTimeHint => 'örn. 30';

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
