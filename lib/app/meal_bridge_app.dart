
import 'package:flutter/material.dart';

import '../data/sample_recipes.dart';
import '../features/meal_plan/screens/meal_plan_screen.dart';
import '../features/recipes/screens/recipe_list_screen.dart';
import '../features/shopping_list/screens/shopping_list_screen.dart';
import '../models/recipe.dart';
import '../services/recipe_storage_service.dart';

class MealBridgeApp extends StatelessWidget {
  const MealBridgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MealBridge',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
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
  Map<String, Recipe> _plannedRecipes = {};
  Set<String> _checkedShoppingItemKeys = {};

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

    final allRecipes = [
      ...sampleRecipes,
      ...savedRecipes,
    ];

    final plannedRecipes = <String, Recipe>{};

    for (final entry in savedMealPlan.entries) {
      final matchingRecipe = allRecipes.where(
        (recipe) => recipe.id == entry.value,
      );

      if (matchingRecipe.isNotEmpty) {
        plannedRecipes[entry.key] = matchingRecipe.first;
      }
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _recipes = allRecipes;
      _plannedRecipes = plannedRecipes;
      _checkedShoppingItemKeys = savedCheckedShoppingItems;
      _isLoadingData = false;
    });
  }

  bool _isCustomRecipe(Recipe recipe) {
    return !sampleRecipes.any(
      (sampleRecipe) => sampleRecipe.id == recipe.id,
    );
  }

  Future<void> _saveCustomRecipes() async {
    final customRecipes = _recipes.where(_isCustomRecipe).toList();

    await _recipeStorageService.saveRecipes(customRecipes);
  }

  Future<void> _saveMealPlan() async {
    final mealPlan = _plannedRecipes.map(
      (day, recipe) => MapEntry(day, recipe.id),
    );

    await _recipeStorageService.saveMealPlan(mealPlan);
  }

  void _addRecipe(Recipe recipe) {
    setState(() {
      _recipes.add(recipe);
    });

    _saveCustomRecipes();
  }

  void _updateRecipe(Recipe updatedRecipe) {
    setState(() {
      final recipeIndex = _recipes.indexWhere(
        (recipe) => recipe.id == updatedRecipe.id,
      );

      if (recipeIndex != -1) {
        _recipes[recipeIndex] = updatedRecipe;
      }

      _plannedRecipes.updateAll((day, plannedRecipe) {
        if (plannedRecipe.id == updatedRecipe.id) {
          return updatedRecipe;
        }

        return plannedRecipe;
      });
    });

    _saveCustomRecipes();
    _saveMealPlan();
  }

  void _deleteRecipe(Recipe recipe) {
    setState(() {
      _recipes.removeWhere((item) => item.id == recipe.id);
      _plannedRecipes.removeWhere(
        (day, plannedRecipe) => plannedRecipe.id == recipe.id,
      );
    });

    _saveCustomRecipes();
    _saveMealPlan();
  }

  void _selectRecipeForDay(String day, Recipe recipe) {
    setState(() {
      _plannedRecipes[day] = recipe;
    });

    _saveMealPlan();
  }

  void _removeRecipeFromDay(String day) {
    setState(() {
      _plannedRecipes.remove(day);
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
    setState(() {
      _checkedShoppingItemKeys.clear();
    });

    _recipeStorageService.saveCheckedShoppingItems(_checkedShoppingItemKeys);
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
    final screens = [
      RecipeListScreen(
        recipes: _recipes,
        canDeleteRecipe: _isCustomRecipe,
        onRecipeAdded: _addRecipe,
        onRecipeUpdated: _updateRecipe,
        onRecipeDeleted: _deleteRecipe,
      ),
      MealPlanScreen(
        recipes: _recipes,
        plannedRecipes: _plannedRecipes,
        onRecipeSelected: _selectRecipeForDay,
        onRecipeRemoved: _removeRecipeFromDay,
      ),
      ShoppingListScreen(
        plannedRecipes: _plannedRecipes,
        checkedItemKeys: _checkedShoppingItemKeys,
        onItemCheckedChanged: _setShoppingItemChecked,
        onClearCheckedItems: _clearCheckedShoppingItems,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        centerTitle: false,
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
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
