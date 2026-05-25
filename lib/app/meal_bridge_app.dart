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
  bool _isLoadingRecipes = true;

  List<Recipe> _recipes = List<Recipe>.from(sampleRecipes);
  final Map<String, Recipe> _plannedRecipes = {};

  @override
  void initState() {
    super.initState();
    _loadSavedRecipes();
  }

  Future<void> _loadSavedRecipes() async {
    final savedRecipes = await _recipeStorageService.loadRecipes();

    if (!mounted) {
      return;
    }

    setState(() {
      _recipes = [
        ...sampleRecipes,
        ...savedRecipes,
      ];
      _isLoadingRecipes = false;
    });
  }

  Future<void> _saveCustomRecipes() async {
    final customRecipes = _recipes
        .where(
          (recipe) => !sampleRecipes.any(
            (sampleRecipe) => sampleRecipe.id == recipe.id,
          ),
        )
        .toList();

    await _recipeStorageService.saveRecipes(customRecipes);
  }

  void _addRecipe(Recipe recipe) {
    setState(() {
      _recipes.add(recipe);
    });

    _saveCustomRecipes();
  }

  void _selectRecipeForDay(String day, Recipe recipe) {
    setState(() {
      _plannedRecipes[day] = recipe;
    });
  }

  void _removeRecipeFromDay(String day) {
    setState(() {
      _plannedRecipes.remove(day);
    });
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
        onRecipeAdded: _addRecipe,
      ),
      MealPlanScreen(
        recipes: _recipes,
        plannedRecipes: _plannedRecipes,
        onRecipeSelected: _selectRecipeForDay,
        onRecipeRemoved: _removeRecipeFromDay,
      ),
      ShoppingListScreen(
        plannedRecipes: _plannedRecipes,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        centerTitle: false,
      ),
      body: _isLoadingRecipes
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
