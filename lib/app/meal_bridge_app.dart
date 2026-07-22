import 'package:flutter/material.dart';

import '../data/sample_recipes.dart';
import '../features/meal_plan/screens/meal_plan_screen.dart';
import '../features/recipes/screens/recipe_list_screen.dart';
import '../features/shopping_list/screens/shopping_list_screen.dart';
import '../models/ingredient.dart';
import '../models/recipe.dart';
import '../models/meal_type.dart';
import '../models/planned_recipe.dart';
import '../services/recipe_storage_service.dart';
import '../features/settings/screens/settings_screen.dart';
import '../shared/app_constants.dart';
import '../shared/widgets/brand_logo.dart';


class MealBridgeApp extends StatelessWidget {
  const MealBridgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MealBridge',
      debugShowCheckedModeBanner: false,
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
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: AppColors.surfaceSoft,
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: AppColors.primaryDark);
            }
            return const IconThemeData(color: Color(0xFF888888));
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryDark,
              );
            }
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF888888),
            );
          }),
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.black12,
          elevation: 8,
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
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final RecipeStorageService _recipeStorageService = RecipeStorageService();
  final _recipeListKey = GlobalKey<RecipeListScreenState>();
  final _shoppingListKey = GlobalKey<ShoppingListScreenState>();

  int _selectedIndex = 0;
  bool _isLoadingData = true;
  int _weekOffset = 0;

  List<Recipe> _recipes = List<Recipe>.from(sampleRecipes);
  Map<String, PlannedRecipe> _allPlannedRecipes = {};
  Set<String> _checkedShoppingItemKeys = {};
  Set<String> _quickRecipeIds = {};
  List<Ingredient> _customQuickItems = [];

  // ISO week key for a given offset from today's week (0 = this week)
  String _isoWeekKeyForOffset(int offset) {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final targetMonday = monday.add(Duration(days: 7 * offset));
    final thursday = targetMonday.add(const Duration(days: 3));
    final year = thursday.year;
    final jan4 = DateTime(year, 1, 4);
    final mondayOfWeek1 = jan4.subtract(Duration(days: jan4.weekday - 1));
    final weekNum = (targetMonday.difference(mondayOfWeek1).inDays ~/ 7) + 1;
    return '$year-W${weekNum.toString().padLeft(2, '0')}';
  }

  // Current week's recipes with week prefix stripped (keys like "Monday-breakfast")
  Map<String, PlannedRecipe> get _currentWeekPlannedRecipes {
    final prefix = '${_isoWeekKeyForOffset(_weekOffset)}-';
    return {
      for (final e in _allPlannedRecipes.entries)
        if (e.key.startsWith(prefix)) e.key.substring(prefix.length): e.value,
    };
  }

  String _fullMealPlanKey(String day, [MealType? mealType]) {
    final weekKey = _isoWeekKeyForOffset(_weekOffset);
    if (mealType == null) return '$weekKey-$day';
    return '$weekKey-$day-${mealType.name}';
  }

  void _setWeekOffset(int offset) => setState(() => _weekOffset = offset);

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final savedRecipes = await _recipeStorageService.loadRecipes();
    final savedMealPlan = await _recipeStorageService.loadMealPlan();
    final savedCheckedShoppingItems =
        await _recipeStorageService.loadCheckedShoppingItems();
    final savedQuickRecipeIds =
        await _recipeStorageService.loadQuickRecipeIds();
    final savedCustomQuickItems =
        await _recipeStorageService.loadCustomQuickItems();

    final allRecipes = [...sampleRecipes, ...savedRecipes];

    // Migrate old-format keys (e.g. "Monday-breakfast") to week-prefixed keys
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final currentWeekKey = _isoWeekKeyForOffset(0);
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
          targetServings: match.first.servings,
        );
      }
    }

    if (!mounted) return;

    setState(() {
      _recipes = allRecipes;
      _allPlannedRecipes = allPlannedRecipes;
      _checkedShoppingItemKeys = savedCheckedShoppingItems;
      _quickRecipeIds = savedQuickRecipeIds;
      _customQuickItems = savedCustomQuickItems;
      _isLoadingData = false;
    });
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
    await _recipeStorageService.saveMealPlan(mealPlan);
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
    setState(() {
      _recipes.removeWhere((r) => r.id == recipe.id);
      _allPlannedRecipes.removeWhere((_, pr) => pr.recipe.id == recipe.id);
      _quickRecipeIds.remove(recipe.id);
    });
    _saveCustomRecipes();
    _saveMealPlan();
    _recipeStorageService.saveQuickRecipeIds(_quickRecipeIds);
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
    setState(() {
      _allPlannedRecipes[key] = PlannedRecipe(recipe: recipe, targetServings: servings);
    });
    _saveMealPlan();
  }

  void _removeRecipeFromDay(String day, [MealType? mealType]) {
    final key = _fullMealPlanKey(day, mealType);
    setState(() => _allPlannedRecipes.remove(key));
    _saveMealPlan();
  }

  void _updateServings(String day, MealType? mealType, int delta) {
    final key = _fullMealPlanKey(day, mealType);
    final current = _allPlannedRecipes[key];
    if (current == null) return;
    final newServings = (current.targetServings + delta).clamp(1, 20);
    setState(() {
      _allPlannedRecipes[key] = current.copyWith(targetServings: newServings);
    });
    _saveMealPlan();
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

  void _toggleQuickRecipe(String recipeId) {
    setState(() {
      if (_quickRecipeIds.contains(recipeId)) {
        _quickRecipeIds.remove(recipeId);
      } else {
        _quickRecipeIds.add(recipeId);
      }
    });
    _recipeStorageService.saveQuickRecipeIds(_quickRecipeIds);
  }

  void _clearQuickRecipes() {
    setState(() => _quickRecipeIds.clear());
    _recipeStorageService.saveQuickRecipeIds(_quickRecipeIds);
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

  /// Per-tab AppBar actions. Recipes gets a single "add recipe" action;
  /// Shopping List gets a single "add item" action — check-all now lives as
  /// a checkbox in that screen's own body, right by the sort control.
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

    if (_selectedIndex == 2) {
      return [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: IconButton.filledTonal(
            icon: const Icon(Icons.add),
            tooltip: 'Add item',
            onPressed: () => _shoppingListKey.currentState?.openAddCustomItemSheet(),
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
    final quickRecipes =
        _recipes.where((r) => _quickRecipeIds.contains(r.id)).toList();



    final screens = [
      RecipeListScreen(
        key: _recipeListKey,
        recipes: _recipes,
        canDeleteRecipe: _isCustomRecipe,
        onRecipeAdded: _addRecipe,
        onRecipeUpdated: _updateRecipe,
        onRecipeDeleted: _deleteRecipe,
        onFavoriteToggled: _toggleFavorite,
        quickRecipeIds: _quickRecipeIds,
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
      ),
      ShoppingListScreen(
        key: _shoppingListKey,
        plannedRecipes: _currentWeekPlannedRecipes,
        quickRecipes: quickRecipes,
        allRecipes: _recipes,
        checkedItemKeys: _checkedShoppingItemKeys,
        onItemCheckedChanged: _setShoppingItemChecked,
        onToggleQuickRecipe: _toggleQuickRecipe,
        onClearQuickRecipes: _clearQuickRecipes,
        customQuickItems: _customQuickItems,
        onAddCustomItem: _addCustomQuickItem,
        onRemoveCustomItem: _removeCustomQuickItem,
      ),
      SettingsScreen(
        onImportSuccess: () => _loadSavedData(),
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
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : (showAppBar ? screens[_selectedIndex] : SafeArea(child: screens[_selectedIndex])),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
     destinations: const [
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu),
            label: 'Recipes',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Plan',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            selectedIcon: Icon(Icons.shopping_cart),
            label: 'Shopping',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}