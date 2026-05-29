import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../models/ingredient.dart';
import '../../../models/recipe.dart';

class RecipeFormScreen extends StatefulWidget {
  final Recipe? initialRecipe;

  const RecipeFormScreen({super.key, this.initialRecipe});

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

  final _ingredientNameFocusNode = FocusNode();
  final _instructionFocusNode = FocusNode();

  final List<Ingredient> _ingredients = [];
  final List<String> _instructions = [];

  final List<String> _marketCategories = const [
    'Vegetables',
    'Fruit',
    'Meat',
    'Dairy',
    'Bakery',
    'Pantry',
    'Frozen',
    'Drinks',
    'Snacks',
    'Other',
  ];

  final List<String> _units = const [
    'g',
    'kg',
    'ml',
    'l',
    'pcs',
    'tbsp',
    'tsp',
    'cup',
    'slice',
    'can',
    'pack',
  ];

  @override
  void initState() {
    super.initState();

    final recipe = widget.initialRecipe;

    _nameController = TextEditingController(text: recipe?.name ?? '');
    _categoryController = TextEditingController(
      text: recipe?.category ?? 'Dinner',
    );
    _servingsController = TextEditingController(
      text: recipe?.servings.toString() ?? '2',
    );
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
    _ingredientNameFocusNode.dispose();
    _instructionFocusNode.dispose();
    super.dispose();
  }

  String _formatAmount(double amount) {
    if (amount == amount.roundToDouble()) {
      return amount.toInt().toString();
    }
    return amount.toString();
  }

  void _requestFocusAfterFrame(FocusNode focusNode) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        return;
      }

      await Future<void>.delayed(const Duration(milliseconds: 100));

      if (!mounted) {
        return;
      }

      FocusScope.of(context).requestFocus(focusNode);
    });
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

    if (name.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingredient name must be at least 2 characters.'),
        ),
      );
      return;
    }

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingredient amount must be greater than 0.'),
        ),
      );
      return;
    }

    final alreadyExists = _ingredients.any(
      (ingredient) =>
          ingredient.name.trim().toLowerCase() == name.toLowerCase() &&
          ingredient.unit.trim().toLowerCase() == unit.toLowerCase() &&
          ingredient.category.trim().toLowerCase() == category.toLowerCase(),
    );

    if (alreadyExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This ingredient already exists in the recipe.'),
        ),
      );
      return;
    }

    setState(() {
      _ingredients.add(
        Ingredient(name: name, amount: amount, unit: unit, category: category),
      );

      _ingredientNameController.clear();
      _ingredientAmountController.clear();
      _ingredientUnitController.text = 'g';
      _ingredientCategoryController.text = 'Other';
    });

    _requestFocusAfterFrame(_ingredientNameFocusNode);
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredients.removeAt(index);
    });
  }

  void _addInstruction() {
    final instruction = _instructionController.text.trim();

    if (instruction.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an instruction step.')),
      );
      return;
    }

    if (instruction.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Instruction step must be at least 5 characters.'),
        ),
      );
      return;
    }

    setState(() {
      _instructions.add(instruction);
      _instructionController.clear();
    });

    _requestFocusAfterFrame(_instructionFocusNode);
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
      id:
          widget.initialRecipe?.id ??
          'recipe-${DateTime.now().millisecondsSinceEpoch}',
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
        title: Text(
          widget.initialRecipe == null ? 'Add Recipe' : 'Edit Recipe',
        ),
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
                    Row(
                      children: [
                        const Icon(Icons.info_outline),
                        const SizedBox(width: 8),
                        Text(
                          'Basic info',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Recipe name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        final name = value?.trim() ?? '';

                        if (name.isEmpty) {
                          return 'Recipe name is required.';
                        }

                        if (name.length < 2) {
                          return 'Recipe name must be at least 2 characters.';
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
                        final category = value?.trim() ?? '';

                        if (category.isEmpty) {
                          return 'Category is required.';
                        }

                        if (category.length < 2) {
                          return 'Category must be at least 2 characters.';
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
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
            Row(
              children: [
                const Icon(Icons.shopping_basket_outlined),
                const SizedBox(width: 8),
                Text(
                  'Ingredients',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(width: 8),
                Chip(label: Text('${_ingredients.length} item(s)')),
              ],
            ),
            const SizedBox(height: 8),
            ..._ingredients.asMap().entries.map((entry) {
              final index = entry.key;
              final ingredient = entry.value;

              return Card(
                child: ListTile(
                  leading: const Icon(Icons.shopping_basket_outlined),
                  title: Text(ingredient.name),
                  subtitle: Text(ingredient.category),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Chip(
                        label: Text(
                          '${_formatAmount(ingredient.amount)} ${ingredient.unit}',
                        ),
                      ),
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
                    Row(
                      children: [
                        const Icon(Icons.add_circle_outline),
                        const SizedBox(width: 8),
                        Text(
                          'Add ingredient',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _ingredientNameController,
                      focusNode: _ingredientNameFocusNode,
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
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              TextInputFormatter.withFunction((
                                oldValue,
                                newValue,
                              ) {
                                final text = newValue.text.replaceAll(',', '.');

                                if (text.isEmpty) {
                                  return newValue;
                                }

                                final isValidAmount = RegExp(
                                  r'^\d*\.?\d*$',
                                ).hasMatch(text);

                                if (!isValidAmount) {
                                  return oldValue;
                                }

                                return newValue;
                              }),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue:
                                _units.contains(_ingredientUnitController.text)
                                ? _ingredientUnitController.text
                                : 'g',
                            decoration: const InputDecoration(
                              labelText: 'Unit',
                              border: OutlineInputBorder(),
                            ),
                            items: _units
                                .map(
                                  (unit) => DropdownMenuItem(
                                    value: unit,
                                    child: Text(unit),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value == null) {
                                return;
                              }

                              setState(() {
                                _ingredientUnitController.text = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue:
                          _marketCategories.contains(
                            _ingredientCategoryController.text,
                          )
                          ? _ingredientCategoryController.text
                          : 'Other',
                      decoration: const InputDecoration(
                        labelText: 'Market category',
                        border: OutlineInputBorder(),
                      ),
                      items: _marketCategories
                          .map(
                            (category) => DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }

                        setState(() {
                          _ingredientCategoryController.text = value;
                        });
                      },
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
            Row(
              children: [
                const Icon(Icons.format_list_numbered),
                const SizedBox(width: 8),
                Text(
                  'Instructions',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(width: 8),
                Chip(label: Text('${_instructions.length} step(s)')),
              ],
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
                    Row(
                      children: [
                        const Icon(Icons.add_task_outlined),
                        const SizedBox(width: 8),
                        Text(
                          'Add instruction step',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _instructionController,
                      focusNode: _instructionFocusNode,
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
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.notes_outlined),
                        const SizedBox(width: 8),
                        Text(
                          'Notes',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Optional notes',
                        border: OutlineInputBorder(),
                      ),
                      minLines: 2,
                      maxLines: 4,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: _saveRecipe,
                icon: const Icon(Icons.save_outlined),
                label: Text(
                  widget.initialRecipe == null
                      ? 'Save Recipe'
                      : 'Update Recipe',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
