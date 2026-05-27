import 'package:flutter/material.dart';

import '../../../models/ingredient.dart';
import '../../../models/recipe.dart';

class RecipeFormScreen extends StatefulWidget {
  final Recipe? initialRecipe;

  const RecipeFormScreen({
    super.key,
    this.initialRecipe,
  });

  @override
  State<RecipeFormScreen> createState() => _RecipeFormScreenState();
}

class _RecipeFormScreenState extends State<RecipeFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _categoryController;
  late final TextEditingController _servingsController;
  late final TextEditingController _notesController;

  final _ingredientNameController = TextEditingController();
  final _ingredientAmountController = TextEditingController();
  final _ingredientUnitController = TextEditingController(text: 'g');
  final _ingredientCategoryController = TextEditingController(text: 'Other');
  final _instructionController = TextEditingController();

  final List<Ingredient> _ingredients = [];
  final List<String> _instructions = [];

  @override
  void initState() {
    super.initState();

    final recipe = widget.initialRecipe;

    _nameController = TextEditingController(text: recipe?.name ?? '');
    _categoryController = TextEditingController(text: recipe?.category ?? 'Dinner');
    _servingsController = TextEditingController(text: recipe?.servings.toString() ?? '2');
    _notesController = TextEditingController(text: recipe?.notes ?? '');

    if (recipe != null) {
      _ingredients.addAll(recipe.ingredients);
      _instructions.addAll(recipe.instructions);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _servingsController.dispose();
    _notesController.dispose();
    _ingredientNameController.dispose();
    _ingredientAmountController.dispose();
    _ingredientUnitController.dispose();
    _ingredientCategoryController.dispose();
    _instructionController.dispose();
    super.dispose();
  }

  String _formatAmount(double amount) {
    if (amount == amount.roundToDouble()) {
      return amount.toInt().toString();
    }
    return amount.toString();
  }

  void _addIngredient() {
    final name = _ingredientNameController.text.trim();
    final amountText = _ingredientAmountController.text.trim();
    final unit = _ingredientUnitController.text.trim();
    final category = _ingredientCategoryController.text.trim();
    final amount = double.tryParse(amountText.replaceAll(',', '.'));

    if (name.isEmpty || amount == null || unit.isEmpty || category.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid ingredient.')),
      );
      return;
    }

    setState(() {
      _ingredients.add(
        Ingredient(
          name: name,
          amount: amount,
          unit: unit,
          category: category,
        ),
      );

      _ingredientNameController.clear();
      _ingredientAmountController.clear();
      _ingredientUnitController.text = 'g';
      _ingredientCategoryController.text = 'Other';
    });
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredients.removeAt(index);
    });
  }

  void _addInstruction() {
    final instruction = _instructionController.text.trim();

    if (instruction.isEmpty) {
      return;
    }

    setState(() {
      _instructions.add(instruction);
      _instructionController.clear();
    });
  }

  void _removeInstruction(int index) {
    setState(() {
      _instructions.removeAt(index);
    });
  }

  void _saveRecipe() {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    if (_ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one ingredient.')),
      );
      return;
    }

    if (_instructions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one instruction.')),
      );
      return;
    }

    final recipe = Recipe(
      id: widget.initialRecipe?.id ?? 'recipe-${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      servings: int.parse(_servingsController.text.trim()),
      category: _categoryController.text.trim(),
      ingredients: List.unmodifiable(_ingredients),
      instructions: List.unmodifiable(_instructions),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    Navigator.of(context).pop(recipe);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialRecipe == null ? 'Add Recipe' : 'Edit Recipe'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Basic info',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Recipe name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Recipe name is required.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _categoryController,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Category is required.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _servingsController,
                      decoration: const InputDecoration(
                        labelText: 'Servings',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final servings = int.tryParse(value ?? '');
                        if (servings == null || servings <= 0) {
                          return 'Enter a valid serving amount.';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Ingredients',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            ..._ingredients.asMap().entries.map((entry) {
              final index = entry.key;
              final ingredient = entry.value;

              return Card(
                child: ListTile(
                  title: Text(ingredient.name),
                  subtitle: Text(ingredient.category),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${_formatAmount(ingredient.amount)} ${ingredient.unit}'),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _removeIngredient(index),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add ingredient',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _ingredientNameController,
                      decoration: const InputDecoration(
                        labelText: 'Ingredient name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _ingredientAmountController,
                            decoration: const InputDecoration(
                              labelText: 'Amount',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _ingredientUnitController,
                            decoration: const InputDecoration(
                              labelText: 'Unit',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _ingredientCategoryController,
                      decoration: const InputDecoration(
                        labelText: 'Market category',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _addIngredient,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Ingredient'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Instructions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            ..._instructions.asMap().entries.map((entry) {
              final index = entry.key;
              final instruction = entry.value;

              return Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text('${index + 1}')),
                  title: Text(instruction),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _removeInstruction(index),
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add instruction step',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _instructionController,
                      decoration: const InputDecoration(
                        labelText: 'Instruction',
                        border: OutlineInputBorder(),
                      ),
                      minLines: 2,
                      maxLines: 4,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _addInstruction,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Instruction'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes optional',
                border: OutlineInputBorder(),
              ),
              minLines: 2,
              maxLines: 4,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: _saveRecipe,
                icon: const Icon(Icons.save_outlined),
                label: Text(
                  widget.initialRecipe == null ? 'Save Recipe' : 'Update Recipe',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
