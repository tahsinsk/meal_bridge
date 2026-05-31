import 'package:flutter/material.dart';

import '../data/sample_recipes.dart';
import '../features/meal_plan/screens/meal_plan_screen.dart';
import '../features/recipes/screens/recipe_list_screen.dart';
import '../features/shopping_list/screens/shopping_list_screen.dart';
import '../models/recipe.dart';
import '../models/meal_type.dart';
import '../models/planned_recipe.dart';
import '../services/recipe_storage_service.dart';
import '../features/settings/screens/settings_screen.dart';


class MealBridgeApp extends StatelessWidget {
  const MealBridgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MealBridge',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          brightness: Brightness.light,
        ).copyWith(
          primary: const Color(0xFF2E7D32),
          onPrimary: Colors.white,
          primaryContainer: const Color(0xFFE8F5E9),
          onPrimaryContainer: const Color(0xFF1B5E20),
          surface: const Color(0xFFFAFDF7),
          onSurface: const Color(0xFF1A1C19),
          surfaceContainerHighest: const Color(0xFFE8F5E9),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF4F9F1),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.white),
          actionsIconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          margin: EdgeInsets.zero,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: const Color(0xFF2E7D32).withValues(alpha: 0.12),
              width: 1,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: const Color(0xFF2E7D32).withValues(alpha: 0.3),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: const Color(0xFF2E7D32).withValues(alpha: 0.25),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFF2E7D32),
              width: 2,
            ),
          ),
          labelStyle: const TextStyle(color: Color(0xFF388E3C)),
          prefixIconColor: const Color(0xFF388E3C),
          suffixIconColor: const Color(0xFF388E3C),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF2E7D32),
            foregroundColor: Colors.white,
            minimumSize: const Size(0, 48),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
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
            foregroundColor: const Color(0xFF2E7D32),
            minimumSize: const Size(0, 40),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF2E7D32),
            side: const BorderSide(color: Color(0xFF2E7D32), width: 1.5),
            minimumSize: const Size(0, 48),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: const Color(0xFFE8F5E9),
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
          backgroundColor: Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFFE8F5E9),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: Color(0xFF2E7D32));
            }
            return const IconThemeData(color: Color(0xFF888888));
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E7D32),
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
          color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
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
          color: Color(0xFF2E7D32),
          linearTrackColor: Color(0xFFE8F5E9),
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const Color(0xFF2E7D32);
            }
            return Colors.transparent;
          }),
          checkColor: WidgetStateProperty.all(Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          side: const BorderSide(color: Color(0xFF2E7D32), width: 1.5),
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

  int _selectedIndex = 0;
  bool _isLoadingData = true;

  List<Recipe> _recipes = List<Recipe>.from(sampleRecipes);
  Map<String, PlannedRecipe> _plannedRecipes = {};
  Set<String> _checkedShoppingItemKeys = {};
  Set<String> _quickRecipeIds = {};

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

    final allRecipes = [...sampleRecipes, ...savedRecipes];
    final plannedRecipes = <String, PlannedRecipe>{};

    for (final entry in savedMealPlan.entries) {
      final matchingRecipe =
          allRecipes.where((recipe) => recipe.id == entry.value);
      if (matchingRecipe.isNotEmpty) {
        final recipe = matchingRecipe.first;
        plannedRecipes[entry.key] = PlannedRecipe(
          recipe: recipe,
          targetServings: recipe.servings,
        );
      }
    }

    if (!mounted) return;

    setState(() {
      _recipes = allRecipes;
      _plannedRecipes = plannedRecipes;
      _checkedShoppingItemKeys = savedCheckedShoppingItems;
      _quickRecipeIds = savedQuickRecipeIds;
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

  String _mealPlanKey(String day, [MealType? mealType]) {
    if (mealType == null) return day;
    return '$day-${mealType.name}';
  }

  Future<void> _saveMealPlan() async {
    final mealPlan = _plannedRecipes.map(
      (key, pr) => MapEntry(key, pr.recipe.id),
    );
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
      _plannedRecipes.updateAll((_, pr) {
        if (pr.recipe.id == updatedRecipe.id) {
          return pr.copyWith(recipe: updatedRecipe);
        }
        return pr;
      });
    });
    _saveCustomRecipes();
    _saveMealPlan();
  }

  void _deleteRecipe(Recipe recipe) {
    setState(() {
      _recipes.removeWhere((r) => r.id == recipe.id);
      _plannedRecipes.removeWhere((_, pr) => pr.recipe.id == recipe.id);
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

  void _selectRecipeForDay(String day, Recipe recipe, [MealType? mealType]) {
    final key = _mealPlanKey(day, mealType);
    setState(() {
      _plannedRecipes[key] = PlannedRecipe(
        recipe: recipe,
        targetServings: recipe.servings,
      );
    });
    _saveMealPlan();
  }

  void _removeRecipeFromDay(String day, [MealType? mealType]) {
    final key = _mealPlanKey(day, mealType);
    setState(() => _plannedRecipes.remove(key));
    _saveMealPlan();
  }

  void _updateServings(String day, MealType? mealType, int delta) {
    final key = _mealPlanKey(day, mealType);
    final current = _plannedRecipes[key];
    if (current == null) return;
    final newServings = (current.targetServings + delta).clamp(1, 20);
    setState(() {
      _plannedRecipes[key] = current.copyWith(targetServings: newServings);
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

  void _clearCheckedShoppingItems() {
    setState(() => _checkedShoppingItemKeys.clear());
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

String get _title {
    switch (_selectedIndex) {
      case 0:
        return 'Recipes';
      case 1:
        return 'Weekly Plan';
      case 2:
        return 'Shopping List';
      case 3:
        return 'Settings';
      default:
        return 'MealBridge';
    }
  }

  @override
  Widget build(BuildContext context) {
    final quickRecipes =
        _recipes.where((r) => _quickRecipeIds.contains(r.id)).toList();



    final screens = [
      RecipeListScreen(
        recipes: _recipes,
        canDeleteRecipe: _isCustomRecipe,
        onRecipeAdded: _addRecipe,
        onRecipeUpdated: _updateRecipe,
        onRecipeDeleted: _deleteRecipe,
        onFavoriteToggled: _toggleFavorite,
      ),
      MealPlanScreen(
        recipes: _recipes,
        plannedRecipes: _plannedRecipes,
        onRecipeSelected: _selectRecipeForDay,
        onRecipeRemoved: _removeRecipeFromDay,
        onServingsChanged: _updateServings,
      ),
      ShoppingListScreen(
        plannedRecipes: _plannedRecipes,
        quickRecipes: quickRecipes,
        allRecipes: _recipes,
        checkedItemKeys: _checkedShoppingItemKeys,
        onItemCheckedChanged: _setShoppingItemChecked,
        onClearCheckedItems: _clearCheckedShoppingItems,
        onToggleQuickRecipe: _toggleQuickRecipe,
        onClearQuickRecipes: _clearQuickRecipes,
      ),
      SettingsScreen(
        onImportSuccess: () => _loadSavedData(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(_title), centerTitle: false),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : screens[_selectedIndex],
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