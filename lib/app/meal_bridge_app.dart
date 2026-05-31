import 'package:flutter/material.dart';

import '../data/sample_recipes.dart';
import '../features/meal_plan/screens/meal_plan_screen.dart';
import '../features/recipes/screens/recipe_list_screen.dart';
import '../features/shopping_list/screens/shopping_list_screen.dart';
import '../models/recipe.dart';
import '../models/meal_type.dart';
import '../models/planned_recipe.dart';
import '../services/recipe_storage_service.dart';

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
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7FAF5),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Color(0xFFF7FAF5),
          foregroundColor: Color(0xFF1B1B1B),
        ),
        cardTheme: CardThemeData(
          elevation: 1,
          shadowColor: Colors.black.withValues(alpha: 0.08),
          surfaceTintColor: Colors.white,
          margin: EdgeInsets.zero,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size(0, 44),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            minimumSize: const Size(0, 40),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, 44),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: const Color(0xFFEAF4E8),
          labelStyle: const TextStyle(color: Color(0xFF1F3D1F)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide.none,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          elevation: 2,
          backgroundColor: Color(0xFF2E7D32),
          foregroundColor: Colors.white,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFFDDEEDB),
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
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
        ],
      ),
    );
  }
}