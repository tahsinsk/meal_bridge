import 'package:flutter/material.dart';

import '../../../models/meal_type.dart';
import '../../../models/recipe.dart';
import '../../../shared/app_constants.dart';
import '../../../shared/meal_type_style.dart';

/// Opens the clean "add a recipe to this slot" bottom sheet for a specific
/// [day] + [mealType] (the empty slot that was tapped) — the user only
/// picks the recipe and servings.
Future<void> showAddToPlanSheet(
  BuildContext context, {
  required List<Recipe> recipes,
  required String day,
  required MealType mealType,
  required void Function(Recipe recipe, int servings) onAdd,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _AddToPlanSheet(
      recipes: recipes,
      day: day,
      mealType: mealType,
      onAdd: onAdd,
    ),
  );
}

class _AddToPlanSheet extends StatefulWidget {
  final List<Recipe> recipes;
  final String day;
  final MealType mealType;
  final void Function(Recipe recipe, int servings) onAdd;

  const _AddToPlanSheet({
    required this.recipes,
    required this.day,
    required this.mealType,
    required this.onAdd,
  });

  @override
  State<_AddToPlanSheet> createState() => _AddToPlanSheetState();
}

class _AddToPlanSheetState extends State<_AddToPlanSheet> {
  static const _categories = ['Breakfast', 'Lunch', 'Dinner', 'Other'];

  Recipe? _recipe;
  int _servings = 1;
  final _searchController = TextEditingController();
  var _query = '';
  String? _categoryFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _selectRecipe(Recipe recipe) {
    setState(() {
      _recipe = recipe;
      _servings = recipe.servings;
    });
  }

  void _confirm() {
    widget.onAdd(_recipe!, _servings);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();
    final filteredRecipes = widget.recipes.where((r) {
      final matchesQuery = query.isEmpty || r.name.toLowerCase().contains(query);
      final matchesCategory = _categoryFilter == null ||
          r.category.toLowerCase() == _categoryFilter!.toLowerCase();
      return matchesQuery && matchesCategory;
    }).toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.94,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.large)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 8, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text('Add to plan', style: Theme.of(context).textTheme.titleLarge),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Row(
                  children: [
                    Icon(widget.mealType.icon, size: 18, color: widget.mealType.accentColor),
                    const SizedBox(width: 8),
                    Text(
                      '${widget.mealType.label} · ${widget.day}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  children: [
                    Text('Recipe', style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search recipes',
                        prefixIcon: Icon(Icons.search),
                        isDense: true,
                      ),
                      onChanged: (v) => setState(() => _query = v),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _categories.map((cat) {
                        final isSelected = _categoryFilter == cat;
                        return FilterChip(
                          label: Text(cat),
                          selected: isSelected,
                          selectedColor: AppColors.primaryDark,
                          checkmarkColor: Colors.white,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppColors.primaryDark,
                            fontWeight: FontWeight.w600,
                          ),
                          onSelected: (val) {
                            setState(() => _categoryFilter = val ? cat : null);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                    if (widget.recipes.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'No recipes yet. Add a recipe first.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      )
                    else if (filteredRecipes.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'No recipes match your search/filter.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      )
                    else
                      ...filteredRecipes.map((recipe) {
                        final selected = _recipe?.id == recipe.id;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          color: selected ? AppColors.surfaceSoft : null,
                          child: ListTile(
                            onTap: () => _selectRecipe(recipe),
                            title: Text(recipe.name),
                            subtitle: Text('${recipe.category} · ${recipe.servings} servings'),
                            trailing: Icon(
                              selected ? Icons.check_circle : Icons.circle_outlined,
                              color: selected ? AppColors.primaryDark : Colors.grey[300],
                            ),
                          ),
                        );
                      }),
                    if (_recipe != null) ...[
                      const SizedBox(height: 8),
                      Text('Servings', style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          IconButton(
                            onPressed: _servings > 1 ? () => setState(() => _servings--) : null,
                            icon: const Icon(Icons.remove_circle_outline),
                            color: AppColors.primaryDark,
                          ),
                          Text(
                            '$_servings',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                          IconButton(
                            onPressed: _servings < 20 ? () => setState(() => _servings++) : null,
                            icon: const Icon(Icons.add_circle_outline),
                            color: AppColors.primaryDark,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _recipe != null ? _confirm : null,
                    child: const Text('Add to Plan'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
