import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:google_fonts/google_fonts.dart';

import '../data/sample_recipes.dart';
import '../features/meal_plan/screens/meal_plan_screen.dart';
import '../features/onboarding/screens/onboarding_screen.dart';
import '../features/recipes/screens/recipe_list_screen.dart';
import '../features/shopping_list/screens/shopping_list_screen.dart';
import '../models/ingredient.dart';
import '../models/recipe.dart';
import '../models/meal_type.dart';
import '../models/planned_recipe.dart';
import '../services/recipe_storage_service.dart';
import '../features/settings/screens/settings_screen.dart';
import '../l10n/app_localizations.dart';
import '../shared/app_constants.dart';
import '../shared/ingredient_key.dart';
import '../shared/iso_week.dart';
import '../shared/widgets/brand_logo.dart';
import '../shared/widgets/floating_nav_bar.dart';


class MealBridgeApp extends StatefulWidget {
  const MealBridgeApp({super.key});

  @override
  State<MealBridgeApp> createState() => _MealBridgeAppState();
}

class _MealBridgeAppState extends State<MealBridgeApp> {
  final _storageService = RecipeStorageService();

  // 'system' (follow device locale) or a supported language code.
  String _localeCode = 'system';

  @override
  void initState() {
    super.initState();
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final code = await _storageService.loadLocaleCode();
    if (!mounted) return;
    setState(() => _localeCode = code);
  }

  /// Applies immediately (no restart) since it just rebuilds MaterialApp
  /// with a new `locale`, which the framework propagates to every
  /// Localizations-dependent widget below it.
  void _setLocaleCode(String code) {
    setState(() => _localeCode = code);
    _storageService.saveLocaleCode(code);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MealBridge',
      debugShowCheckedModeBanner: false,
      // Explicit pick forces that locale; 'system' leaves `locale` null so
      // localeResolutionCallback below follows the device, falling back to
      // English when the device locale isn't one we support.
      locale: _localeCode == 'system' ? null : Locale(_localeCode),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      localeResolutionCallback: (deviceLocale, supportedLocales) {
        if (deviceLocale != null) {
          for (final supported in supportedLocales) {
            if (supported.languageCode == deviceLocale.languageCode) {
              return supported;
            }
          }
        }
        return const Locale('en');
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryDark,
          brightness: Brightness.light,
        ).copyWith(
          primary: AppColors.primaryDark,
          onPrimary: Colors.white,
          secondary: AppColors.accentMid,
          onSecondary: Colors.white,
          primaryContainer: AppColors.surfaceSoft,
          onPrimaryContainer: const Color(0xFF1B5E20),
          surface: AppColors.creamBackground,
          onSurface: const Color(0xFF1A1C19),
          surfaceContainerHighest: AppColors.surfaceSoft,
        ),
        useMaterial3: true,
        // Global body/heading font. BrandLogo sets its own explicit
        // GoogleFonts.quicksand style, which overrides this fallback.
        textTheme: GoogleFonts.plusJakartaSansTextTheme(ThemeData.light().textTheme),
        scaffoldBackgroundColor: AppColors.creamBackground,
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: AppColors.creamBackground,
          foregroundColor: Color(0xFF1A1C19),
          iconTheme: IconThemeData(color: Color(0xFF1A1C19)),
          actionsIconTheme: IconThemeData(color: Color(0xFF1A1C19)),
          titleTextStyle: TextStyle(
            color: Color(0xFF1A1C19),
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 1.5,
          shadowColor: Colors.black.withValues(alpha: 0.06),
          surfaceTintColor: Colors.transparent,
          margin: EdgeInsets.zero,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceSoft,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: AppColors.primaryDark,
              width: 1.5,
            ),
          ),
          labelStyle: const TextStyle(color: AppColors.primaryDark),
          prefixIconColor: AppColors.primaryDark,
          suffixIconColor: AppColors.primaryDark,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primaryDark,
            foregroundColor: Colors.white,
            minimumSize: const Size(0, 48),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primaryDark,
            minimumSize: const Size(0, 40),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryDark,
            side: const BorderSide(color: AppColors.primaryDark, width: 1.5),
            minimumSize: const Size(0, 48),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.surfaceSoft,
          labelStyle: const TextStyle(
            color: Color(0xFF1B5E20),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          side: BorderSide.none,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          elevation: 3,
          backgroundColor: AppColors.primaryDark,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
        dividerTheme: DividerThemeData(
          color: AppColors.primaryDark.withValues(alpha: 0.1),
          thickness: 1,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: const Color(0xFF1B5E20),
          contentTextStyle: const TextStyle(color: Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          behavior: SnackBarBehavior.floating,
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppColors.primaryDark,
          linearTrackColor: AppColors.surfaceSoft,
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primaryDark;
            }
            return Colors.transparent;
          }),
          checkColor: WidgetStateProperty.all(Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          side: const BorderSide(color: AppColors.primaryDark, width: 1.5),
        ),
      ),
      home: MainShell(
        localeCode: _localeCode,
        onLocaleCodeChanged: _setLocaleCode,
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  final String localeCode;
  final ValueChanged<String> onLocaleCodeChanged;

  const MainShell({
    super.key,
    required this.localeCode,
    required this.onLocaleCodeChanged,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final RecipeStorageService _recipeStorageService = RecipeStorageService();
  final _recipeListKey = GlobalKey<RecipeListScreenState>();
  final _shoppingListKey = GlobalKey<ShoppingListScreenState>();

  int _selectedIndex = 0;
  bool _isLoadingData = true;
  bool _onboardingCompleted = false;
  int _weekOffset = 0;
  // Instagram-style scroll-driven visibility for the floating bottom nav
  // bar: scrolling content down (finger moving up) hides it, scrolling up
  // brings it back. Reset to visible on every tab switch so a new screen
  // never opens with the bar already hidden from a previous scroll position.
  bool _navBarVisible = true;

  List<Recipe> _recipes = List<Recipe>.from(sampleRecipes);
  Map<String, PlannedRecipe> _allPlannedRecipes = {};
  Set<String> _checkedShoppingItemKeys = {};
  // Weekly Plan mode: ISO week key -> excluded ingredient keys for that
  // week only. Quick List mode has no week concept, so it gets its own
  // flat set that's cleared whenever the Quick List selection changes.
  Map<String, Set<String>> _excludedShoppingItemsByWeek = {};
  Set<String> _quickListExcludedItemKeys = {};
  // recipeId -> selected ingredient keys (name+unit) for that recipe.
  Map<String, Set<String>> _quickSelectedIngredients = {};
  List<Ingredient> _customQuickItems = [];
  List<Ingredient> _customWeeklyItems = [];

  // "Copy day" clipboard — lives here (not in the stateless MealPlanScreen)
  // so it survives week navigation and screen rebuilds.
  Map<MealType, PlannedRecipe>? _copiedDayMeals;
  bool get _hasCopiedDay => _copiedDayMeals != null && _copiedDayMeals!.isNotEmpty;

  // Current week's recipes with week prefix stripped (keys like "Monday-breakfast")
  Map<String, PlannedRecipe> get _currentWeekPlannedRecipes {
    final prefix = '${isoWeekKeyForOffset(_weekOffset)}-';
    return {
      for (final e in _allPlannedRecipes.entries)
        if (e.key.startsWith(prefix)) e.key.substring(prefix.length): e.value,
    };
  }

  String _fullMealPlanKey(String day, [MealType? mealType]) {
    final weekKey = isoWeekKeyForOffset(_weekOffset);
    if (mealType == null) return '$weekKey-$day';
    return '$weekKey-$day-${mealType.name}';
  }

  /// Clears a week's Weekly Plan exclusions whenever that week's meal plan
  /// is actually mutated (recipe added/removed/servings changed), mirroring
  /// how Quick List already clears its exclusions on selection change — an
  /// excluded ingredient should never outlive the plan that made it
  /// excludable. Returns whether anything was actually cleared, so callers
  /// only persist when needed. Must be called from inside the same
  /// setState() as the plan mutation, and must NOT be called for week
  /// navigation or app-load — only for genuine plan edits.
  bool _clearWeeklyExclusionsForWeek(String weekKey) {
    if (!_excludedShoppingItemsByWeek.containsKey(weekKey)) return false;
    _excludedShoppingItemsByWeek = {..._excludedShoppingItemsByWeek}..remove(weekKey);
    return true;
  }

  void _setWeekOffset(int offset) => setState(() => _weekOffset = offset);

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final savedRecipes = await _recipeStorageService.loadRecipes();
    final allRecipes = [...sampleRecipes, ...savedRecipes];

    final savedMealPlan = await _recipeStorageService.loadMealPlan();
    final savedMealPlanServings = await _recipeStorageService.loadMealPlanServings();
    final savedCheckedShoppingItems =
        await _recipeStorageService.loadCheckedShoppingItems();
    // Migrates the old flat/global exclusion set (if any) into the
    // *current* week at migration time — the best available approximation,
    // since the old data had no week concept at all.
    final currentWeekKey = isoWeekKeyForOffset(0);
    final savedExcludedShoppingItemsByWeek =
        await _recipeStorageService.loadExcludedShoppingItemsByWeek(currentWeekKey);
    final savedQuickListExcludedItems =
        await _recipeStorageService.loadQuickListExcludedItemKeys();
    // Needs allRecipes to migrate the old whole-recipe-id format, if found.
    final savedQuickSelectedIngredients =
        await _recipeStorageService.loadQuickSelectedIngredients(allRecipes);
    final savedCustomQuickItems =
        await _recipeStorageService.loadCustomQuickItems();
    final savedCustomWeeklyItems =
        await _recipeStorageService.loadCustomWeeklyItems();
    final onboardingCompleted =
        await _recipeStorageService.loadOnboardingCompleted();

    // Migrate old-format keys (e.g. "Monday-breakfast") to week-prefixed keys
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    bool needsMigration = false;
    final migratedPlan = <String, String>{};
    for (final entry in savedMealPlan.entries) {
      if (days.any((d) => entry.key.startsWith(d))) {
        migratedPlan['$currentWeekKey-${entry.key}'] = entry.value;
        needsMigration = true;
      } else {
        migratedPlan[entry.key] = entry.value;
      }
    }
    if (needsMigration) {
      await _recipeStorageService.saveMealPlan(migratedPlan);
    }

    final allPlannedRecipes = <String, PlannedRecipe>{};
    for (final entry in migratedPlan.entries) {
      final match = allRecipes.where((r) => r.id == entry.value);
      if (match.isNotEmpty) {
        allPlannedRecipes[entry.key] = PlannedRecipe(
          recipe: match.first,
          targetServings: savedMealPlanServings[entry.key] ?? match.first.servings,
        );
      }
    }

    if (!mounted) return;

    setState(() {
      _recipes = allRecipes;
      _allPlannedRecipes = allPlannedRecipes;
      _checkedShoppingItemKeys = savedCheckedShoppingItems;
      _excludedShoppingItemsByWeek = savedExcludedShoppingItemsByWeek;
      _quickListExcludedItemKeys = savedQuickListExcludedItems;
      _quickSelectedIngredients = savedQuickSelectedIngredients;
      _customQuickItems = savedCustomQuickItems;
      _customWeeklyItems = savedCustomWeeklyItems;
      _onboardingCompleted = onboardingCompleted;
      _isLoadingData = false;
    });
  }

  Future<void> _completeOnboarding() async {
    setState(() {
      _onboardingCompleted = true;
      _selectedIndex = 0;
    });
    await _recipeStorageService.saveOnboardingCompleted(true);
  }

  Future<void> _resetOnboarding() async {
    setState(() => _onboardingCompleted = false);
    await _recipeStorageService.saveOnboardingCompleted(false);
  }

  bool _isCustomRecipe(Recipe recipe) {
    return !sampleRecipes.any((s) => s.id == recipe.id);
  }

  Future<void> _saveCustomRecipes() async {
    final customRecipes = _recipes.where(_isCustomRecipe).toList();
    await _recipeStorageService.saveRecipes(customRecipes);
  }

  Future<void> _saveMealPlan() async {
    final mealPlan = _allPlannedRecipes.map((k, v) => MapEntry(k, v.recipe.id));
    final mealPlanServings = _allPlannedRecipes.map((k, v) => MapEntry(k, v.targetServings));
    await _recipeStorageService.saveMealPlan(mealPlan);
    await _recipeStorageService.saveMealPlanServings(mealPlanServings);
  }

  void _addRecipe(Recipe recipe) {
    setState(() => _recipes.add(recipe));
    _saveCustomRecipes();
  }

  void _updateRecipe(Recipe updatedRecipe) {
    setState(() {
      final idx = _recipes.indexWhere((r) => r.id == updatedRecipe.id);
      if (idx != -1) _recipes[idx] = updatedRecipe;
      _allPlannedRecipes.updateAll((_, pr) {
        if (pr.recipe.id == updatedRecipe.id) return pr.copyWith(recipe: updatedRecipe);
        return pr;
      });
    });
    _saveCustomRecipes();
    _saveMealPlan();
  }

  void _deleteRecipe(Recipe recipe) {
    // Deleting a recipe can remove its planned entries from several weeks at
    // once (not just the one currently being viewed), so every affected
    // week's key ("YYYY-Wnn", the first two '-'-separated segments of a
    // planned-recipe key) needs its exclusions cleared — not just
    // isoWeekKeyForOffset(_weekOffset).
    final affectedWeekKeys = _allPlannedRecipes.entries
        .where((e) => e.value.recipe.id == recipe.id)
        .map((e) => e.key.split('-').take(2).join('-'))
        .toSet();
    var exclusionsChanged = false;
    setState(() {
      _recipes.removeWhere((r) => r.id == recipe.id);
      _allPlannedRecipes.removeWhere((_, pr) => pr.recipe.id == recipe.id);
      _quickSelectedIngredients.remove(recipe.id);
      _quickListExcludedItemKeys.clear();
      for (final weekKey in affectedWeekKeys) {
        if (_clearWeeklyExclusionsForWeek(weekKey)) exclusionsChanged = true;
      }
    });
    _saveCustomRecipes();
    _saveMealPlan();
    _recipeStorageService.saveQuickSelectedIngredients(_quickSelectedIngredients);
    _recipeStorageService.saveQuickListExcludedItemKeys(_quickListExcludedItemKeys);
    if (exclusionsChanged) {
      _recipeStorageService.saveExcludedShoppingItemsByWeek(_excludedShoppingItemsByWeek);
    }
  }
  void _toggleFavorite(Recipe recipe) {
    setState(() {
      final idx = _recipes.indexWhere((r) => r.id == recipe.id);
      if (idx != -1) {
        _recipes[idx] = recipe.copyWith(isFavorite: !recipe.isFavorite);
      }
    });
    _saveCustomRecipes();
  }

  void _selectRecipeForDay(String day, Recipe recipe, int servings, [MealType? mealType]) {
    final key = _fullMealPlanKey(day, mealType);
    final weekKey = isoWeekKeyForOffset(_weekOffset);
    var exclusionsChanged = false;
    setState(() {
      _allPlannedRecipes[key] = PlannedRecipe(recipe: recipe, targetServings: servings);
      exclusionsChanged = _clearWeeklyExclusionsForWeek(weekKey);
    });
    _saveMealPlan();
    if (exclusionsChanged) {
      _recipeStorageService.saveExcludedShoppingItemsByWeek(_excludedShoppingItemsByWeek);
    }
  }

  void _removeRecipeFromDay(String day, [MealType? mealType]) {
    final key = _fullMealPlanKey(day, mealType);
    final weekKey = isoWeekKeyForOffset(_weekOffset);
    var exclusionsChanged = false;
    setState(() {
      _allPlannedRecipes.remove(key);
      exclusionsChanged = _clearWeeklyExclusionsForWeek(weekKey);
    });
    _saveMealPlan();
    if (exclusionsChanged) {
      _recipeStorageService.saveExcludedShoppingItemsByWeek(_excludedShoppingItemsByWeek);
    }
  }

  void _updateServings(String day, MealType? mealType, int delta) {
    final key = _fullMealPlanKey(day, mealType);
    final current = _allPlannedRecipes[key];
    if (current == null) return;
    final newServings = (current.targetServings + delta).clamp(1, 20);
    final weekKey = isoWeekKeyForOffset(_weekOffset);
    var exclusionsChanged = false;
    setState(() {
      _allPlannedRecipes[key] = current.copyWith(targetServings: newServings);
      exclusionsChanged = _clearWeeklyExclusionsForWeek(weekKey);
    });
    _saveMealPlan();
    if (exclusionsChanged) {
      _recipeStorageService.saveExcludedShoppingItemsByWeek(_excludedShoppingItemsByWeek);
    }
  }

  void _copyDay(String day) {
    final weekMeals = _currentWeekPlannedRecipes;
    final copied = <MealType, PlannedRecipe>{};
    for (final mealType in MealType.values) {
      final pr = weekMeals['$day-${mealType.name}'];
      if (pr != null) copied[mealType] = pr;
    }
    setState(() => _copiedDayMeals = copied);
  }

  void _pasteDay(String day) {
    final copied = _copiedDayMeals;
    if (copied == null) return;
    final weekKey = isoWeekKeyForOffset(_weekOffset);
    var exclusionsChanged = false;
    setState(() {
      for (final mealType in MealType.values) {
        final key = _fullMealPlanKey(day, mealType);
        final pr = copied[mealType];
        if (pr != null) {
          _allPlannedRecipes[key] = pr;
        } else {
          _allPlannedRecipes.remove(key);
        }
      }
      exclusionsChanged = _clearWeeklyExclusionsForWeek(weekKey);
    });
    _saveMealPlan();
    if (exclusionsChanged) {
      _recipeStorageService.saveExcludedShoppingItemsByWeek(_excludedShoppingItemsByWeek);
    }
  }

  void _setShoppingItemChecked(String itemKey, bool isChecked) {
    setState(() {
      if (isChecked) {
        _checkedShoppingItemKeys.add(itemKey);
      } else {
        _checkedShoppingItemKeys.remove(itemKey);
      }
    });
    _recipeStorageService.saveCheckedShoppingItems(_checkedShoppingItemKeys);
  }

  /// Excludes an ingredient from Weekly Plan mode's generated list for the
  /// week currently being viewed only — other weeks (past or future) are
  /// unaffected, since this is scoped by ISO week key.
  void _excludeWeeklyShoppingItem(String itemKey) {
    final weekKey = isoWeekKeyForOffset(_weekOffset);
    setState(() {
      final current = Set<String>.from(_excludedShoppingItemsByWeek[weekKey] ?? {});
      current.add(itemKey);
      _excludedShoppingItemsByWeek = {
        ..._excludedShoppingItemsByWeek,
        weekKey: current,
      };
    });
    _recipeStorageService.saveExcludedShoppingItemsByWeek(_excludedShoppingItemsByWeek);
  }

  void _excludeQuickListItem(String itemKey) {
    setState(() => _quickListExcludedItemKeys.add(itemKey));
    _recipeStorageService.saveQuickListExcludedItemKeys(_quickListExcludedItemKeys);
  }

  bool _isRecipeFullySelected(Recipe recipe) {
    final selected = _quickSelectedIngredients[recipe.id];
    if (selected == null || selected.isEmpty || recipe.ingredients.isEmpty) return false;
    return recipe.ingredients.every((i) => selected.contains(ingredientKey(i.name, i.unit)));
  }

  /// All-or-nothing toggle for a whole recipe — used by the Quick List
  /// picker's recipe-level checkbox AND by RecipeDetailScreen's "Add to
  /// Quick List" star/menu action, which is meant to mean the same thing.
  void _toggleQuickRecipe(String recipeId) {
    final matches = _recipes.where((r) => r.id == recipeId);
    if (matches.isEmpty) return;
    final recipe = matches.first;
    final isFullySelected = _isRecipeFullySelected(recipe);
    setState(() {
      if (isFullySelected) {
        _quickSelectedIngredients.remove(recipeId);
      } else {
        _quickSelectedIngredients[recipeId] =
            recipe.ingredients.map((i) => ingredientKey(i.name, i.unit)).toSet();
      }
      // The selection changed, so any Quick List exclusions no longer
      // reflect what's actually on the list — drop them rather than let
      // them silently keep hiding items forever.
      _quickListExcludedItemKeys.clear();
    });
    _recipeStorageService.saveQuickSelectedIngredients(_quickSelectedIngredients);
    _recipeStorageService.saveQuickListExcludedItemKeys(_quickListExcludedItemKeys);
  }

  /// Per-ingredient toggle for partial recipe selection in the Quick List
  /// picker's expanded ingredient list.
  void _toggleQuickIngredient(String recipeId, String key) {
    setState(() {
      final current = Set<String>.from(_quickSelectedIngredients[recipeId] ?? {});
      if (current.contains(key)) {
        current.remove(key);
      } else {
        current.add(key);
      }
      if (current.isEmpty) {
        _quickSelectedIngredients.remove(recipeId);
      } else {
        _quickSelectedIngredients[recipeId] = current;
      }
      _quickListExcludedItemKeys.clear();
    });
    _recipeStorageService.saveQuickSelectedIngredients(_quickSelectedIngredients);
    _recipeStorageService.saveQuickListExcludedItemKeys(_quickListExcludedItemKeys);
  }

  void _clearQuickRecipes() {
    setState(() {
      _quickSelectedIngredients.clear();
      _quickListExcludedItemKeys.clear();
    });
    _recipeStorageService.saveQuickSelectedIngredients(_quickSelectedIngredients);
    _recipeStorageService.saveQuickListExcludedItemKeys(_quickListExcludedItemKeys);
  }

  void _addCustomQuickItem(Ingredient item) {
    if (_customQuickItems.any((i) => i.name.toLowerCase() == item.name.toLowerCase())) return;
    setState(() => _customQuickItems = [..._customQuickItems, item]);
    _recipeStorageService.saveCustomQuickItems(_customQuickItems);
  }

  void _removeCustomQuickItem(String name) {
    setState(() => _customQuickItems = _customQuickItems.where((i) => i.name != name).toList());
    _recipeStorageService.saveCustomQuickItems(_customQuickItems);
  }

  void _addCustomWeeklyItem(Ingredient item) {
    if (_customWeeklyItems.any((i) => i.name.toLowerCase() == item.name.toLowerCase())) return;
    setState(() => _customWeeklyItems = [..._customWeeklyItems, item]);
    _recipeStorageService.saveCustomWeeklyItems(_customWeeklyItems);
  }

  void _removeCustomWeeklyItem(String name) {
    setState(() => _customWeeklyItems = _customWeeklyItems.where((i) => i.name != name).toList());
    _recipeStorageService.saveCustomWeeklyItems(_customWeeklyItems);
  }

  /// Per-tab AppBar actions. Only Recipes needs one (its "add recipe"
  /// action) — Shopping List now shows its own "add item"/"share" actions
  /// in its in-content heading instead of the AppBar.
  List<Widget>? _buildAppBarActions() {
    if (_selectedIndex == 0) {
      return [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: IconButton.filledTonal(
            icon: const Icon(Icons.add),
            tooltip: 'Add recipe',
            onPressed: () => _recipeListKey.currentState?.openAddRecipeScreen(),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surfaceSoft,
              foregroundColor: AppColors.primaryDark,
            ),
          ),
        ),
      ];
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingData) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Onboarding decision is made from the same load that just finished,
    // so there's no frame where the main app flashes before this appears.
    if (!_onboardingCompleted) {
      return OnboardingScreen(onFinished: _completeOnboarding);
    }

    final l10n = AppLocalizations.of(context)!;
    // Recipes with *any* ingredient selected (used for Quick List content);
    // RecipeListScreen/RecipeDetailScreen instead need the *fully* selected
    // set, since their single star/menu toggle is all-or-nothing.
    final quickRecipes = _recipes
        .where((r) => _quickSelectedIngredients[r.id]?.isNotEmpty ?? false)
        .toList();
    final fullySelectedQuickRecipeIds =
        _recipes.where(_isRecipeFullySelected).map((r) => r.id).toSet();

    final screens = [
      RecipeListScreen(
        key: _recipeListKey,
        recipes: _recipes,
        canDeleteRecipe: _isCustomRecipe,
        onRecipeAdded: _addRecipe,
        onRecipeUpdated: _updateRecipe,
        onRecipeDeleted: _deleteRecipe,
        onFavoriteToggled: _toggleFavorite,
        quickRecipeIds: fullySelectedQuickRecipeIds,
        onToggleQuickRecipe: _toggleQuickRecipe,
      ),
      MealPlanScreen(
        recipes: _recipes,
        plannedRecipes: _currentWeekPlannedRecipes,
        weekOffset: _weekOffset,
        onWeekChanged: _setWeekOffset,
        onRecipeSelected: _selectRecipeForDay,
        onRecipeRemoved: _removeRecipeFromDay,
        onServingsChanged: _updateServings,
        hasCopiedDay: _hasCopiedDay,
        onCopyDay: _copyDay,
        onPasteDay: _pasteDay,
      ),
      ShoppingListScreen(
        key: _shoppingListKey,
        plannedRecipes: _currentWeekPlannedRecipes,
        quickRecipes: quickRecipes,
        allRecipes: _recipes,
        checkedItemKeys: _checkedShoppingItemKeys,
        onItemCheckedChanged: _setShoppingItemChecked,
        excludedItemKeysByWeek: _excludedShoppingItemsByWeek,
        onExcludeWeeklyItem: _excludeWeeklyShoppingItem,
        quickListExcludedItemKeys: _quickListExcludedItemKeys,
        onExcludeQuickListItem: _excludeQuickListItem,
        quickSelectedIngredientKeys: _quickSelectedIngredients,
        onToggleQuickRecipe: _toggleQuickRecipe,
        onToggleQuickIngredient: _toggleQuickIngredient,
        onClearQuickRecipes: _clearQuickRecipes,
        customQuickItems: _customQuickItems,
        onAddQuickItem: _addCustomQuickItem,
        onRemoveQuickItem: _removeCustomQuickItem,
        customWeeklyItems: _customWeeklyItems,
        onAddWeeklyItem: _addCustomWeeklyItem,
        onRemoveWeeklyItem: _removeCustomWeeklyItem,
        weekOffset: _weekOffset,
      ),
      SettingsScreen(
        onImportSuccess: () => _loadSavedData(),
        onResetOnboarding: _resetOnboarding,
        localeCode: widget.localeCode,
        onLocaleCodeChanged: widget.onLocaleCodeChanged,
      ),
    ];

    final appBarActions = _buildAppBarActions();
    // Only reserve an AppBar when there's a logo (Recipes) or actions
    // (Shopping) to show in it — otherwise it's just a blank bar pushing
    // content down for no reason, so we skip it and let the body sit at
    // the top (behind a SafeArea, since there's no AppBar to clear the
    // status bar for us).
    final showAppBar = _selectedIndex == 0 || (appBarActions?.isNotEmpty ?? false);

    return Scaffold(
      // Each screen keeps its own large in-content heading as the real
      // title ("Your recipes", the week title, etc.); the AppBar only shows
      // the brand logo on the Recipes tab, and stays title-less elsewhere.
      appBar: showAppBar
          ? AppBar(
              title: _selectedIndex == 0 ? const BrandLogo(size: 34) : null,
              centerTitle: false,
              actions: appBarActions,
            )
          : null,
      body: NotificationListener<UserScrollNotification>(
        onNotification: (notification) {
          switch (notification.direction) {
            case ScrollDirection.reverse:
              if (_navBarVisible) setState(() => _navBarVisible = false);
            case ScrollDirection.forward:
              if (!_navBarVisible) setState(() => _navBarVisible = true);
            case ScrollDirection.idle:
              break;
          }
          return false;
        },
        child: showAppBar ? screens[_selectedIndex] : SafeArea(child: screens[_selectedIndex]),
      ),
      // Instagram-style show/hide: a small slide + scale-down + fade, all on
      // the same short duration/curve, so the bar visually shrinks and
      // fades away rather than sliding far enough to get clipped by the
      // bottomNavigationBar slot's fixed bounds (which would read as an
      // abrupt pop instead of a smooth transition).
      bottomNavigationBar: AnimatedSlide(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        offset: _navBarVisible ? Offset.zero : const Offset(0, 0.35),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          scale: _navBarVisible ? 1.0 : 0.85,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            opacity: _navBarVisible ? 1 : 0,
            child: IgnorePointer(
              ignoring: !_navBarVisible,
              child: FloatingNavBar(
                selectedIndex: _selectedIndex,
                onDestinationSelected: (index) {
                  setState(() {
                    _selectedIndex = index;
                    _navBarVisible = true;
                  });
                },
                destinations: [
                  FloatingNavDestination(
                    icon: Icons.restaurant_menu_outlined,
                    selectedIcon: Icons.restaurant_menu,
                    label: l10n.navRecipes,
                  ),
                  FloatingNavDestination(
                    icon: Icons.calendar_month_outlined,
                    selectedIcon: Icons.calendar_month,
                    label: l10n.navPlan,
                  ),
                  FloatingNavDestination(
                    icon: Icons.shopping_cart_outlined,
                    selectedIcon: Icons.shopping_cart,
                    label: l10n.navShopping,
                  ),
                  FloatingNavDestination(
                    icon: Icons.settings_outlined,
                    selectedIcon: Icons.settings,
                    label: l10n.navSettings,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}