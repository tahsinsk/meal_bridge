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
  late final TextEditingController _caloriesController;

  final _ingredientNameController = TextEditingController();
  final _ingredientAmountController = TextEditingController();
  final _ingredientUnitController = TextEditingController(text: 'g');
  final _instructionController = TextEditingController();

  final _ingredientNameFocusNode = FocusNode();
  final _instructionFocusNode = FocusNode();

  final List<Ingredient> _ingredients = [];
  final List<String> _instructions = [];

  final List<String> _marketCategories = const [
    'Vegetables', 'Fruit', 'Meat', 'Dairy', 'Bakery',
    'Pantry', 'Frozen', 'Drinks', 'Snacks', 'Spices', 'Other',
  ];

  final List<String> _units = const [
    'g', 'kg', 'ml', 'l', 'pcs', 'tbsp', 'tsp', 'cup', 'slice', 'can', 'pack',
  ];

  @override
  void initState() {
    super.initState();
    final recipe = widget.initialRecipe;
    _nameController = TextEditingController(text: recipe?.name ?? '');
    _categoryController = TextEditingController(text: recipe?.category ?? 'Dinner');
    _servingsController = TextEditingController(text: recipe?.servings.toString() ?? '2');
    _notesController = TextEditingController(text: recipe?.notes ?? '');
    _caloriesController = TextEditingController(text: recipe?.calories?.toString() ?? '');
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
    _caloriesController.dispose();
    _ingredientNameController.dispose();
    _ingredientAmountController.dispose();
    _ingredientUnitController.dispose();
    _instructionController.dispose();
    _ingredientNameFocusNode.dispose();
    _instructionFocusNode.dispose();
    super.dispose();
  }

  String _formatAmount(double amount) {
    if (amount == amount.roundToDouble()) return amount.toInt().toString();
    return amount.toString();
  }

  void _requestFocusAfterFrame(FocusNode focusNode) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await Future<void>.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;
      FocusScope.of(context).requestFocus(focusNode);
    });
  }

  void _addIngredient() {
    final name = _ingredientNameController.text.trim();
    final amountText = _ingredientAmountController.text.trim();
    final unit = _ingredientUnitController.text.trim();
    final amount = double.tryParse(amountText.replaceAll(',', '.'));

    if (name.isEmpty || amount == null || unit.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid ingredient.')),
      );
      return;
    }
    if (name.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingredient name must be at least 2 characters.')),
      );
      return;
    }
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingredient amount must be greater than 0.')),
      );
      return;
    }

    setState(() {
      _ingredients.add(Ingredient(name: name, amount: amount, unit: unit));
      _ingredientNameController.clear();
      _ingredientAmountController.clear();
      _ingredientUnitController.text = 'g';
    });
    _requestFocusAfterFrame(_ingredientNameFocusNode);
  }

  void _removeIngredient(int index) {
    setState(() => _ingredients.removeAt(index));
  }

  void _showCategoryPicker(int index) {
    final ingredient = _ingredients[index];
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Category for "${ingredient.name}"',
                        style: Theme.of(context).textTheme.titleMedium),
                    const Spacer(),
                    if (!ingredient.isCategoryAuto)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _ingredients[index] = ingredient.copyWith(
                              clearCategoryOverride: true,
                            );
                          });
                          Navigator.of(context).pop();
                        },
                        child: const Text('Reset to auto'),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _marketCategories.map((cat) {
                    final isSelected = ingredient.resolvedCategory == cat;
                    return FilterChip(
                      label: Text(cat),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() {
                          _ingredients[index] = ingredient.copyWith(
                            categoryOverride: cat,
                          );
                        });
                        Navigator.of(context).pop();
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditIngredientDialog(int index) {
    final ingredient = _ingredients[index];
    final nameCtrl = TextEditingController(text: ingredient.name);
    final amountCtrl = TextEditingController(text: _formatAmount(ingredient.amount));
    String selectedUnit = _units.contains(ingredient.unit) ? ingredient.unit : 'g';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit ingredient'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Ingredient name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: amountCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Amount',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedUnit,
                            decoration: const InputDecoration(
                              labelText: 'Unit',
                              border: OutlineInputBorder(),
                            ),
                            items: _units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                            onChanged: (v) { if (v != null) setDialogState(() => selectedUnit = v); },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                FilledButton(
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    final amount = double.tryParse(amountCtrl.text.trim().replaceAll(',', '.'));
                    if (name.length < 2 || amount == null || amount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter valid values.')),
                      );
                      return;
                    }
                    setState(() {
                      _ingredients[index] = Ingredient(
                        name: name,
                        amount: amount,
                        unit: selectedUnit,
                        categoryOverride: ingredient.categoryOverride,
                      );
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
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
        const SnackBar(content: Text('Instruction step must be at least 5 characters.')),
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
    setState(() => _instructions.removeAt(index));
  }

  void _showEditInstructionDialog(int index) {
    final instructionCtrl = TextEditingController(text: _instructions[index]);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit step ${index + 1}'),
          content: TextField(
            controller: instructionCtrl,
            decoration: const InputDecoration(
              labelText: 'Instruction',
              border: OutlineInputBorder(),
            ),
            minLines: 2,
            maxLines: 5,
            autofocus: true,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                final text = instructionCtrl.text.trim();
                if (text.length < 5) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Instruction must be at least 5 characters.')),
                  );
                  return;
                }
                setState(() => _instructions[index] = text);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _saveRecipe() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;
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
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      calories: int.tryParse(_caloriesController.text.trim()),
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
            // Basic info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.info_outline),
                      const SizedBox(width: 8),
                      Text('Basic info', style: Theme.of(context).textTheme.titleMedium),
                    ]),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Recipe name', border: OutlineInputBorder()),
                      validator: (value) {
                        final name = value?.trim() ?? '';
                        if (name.isEmpty) return 'Recipe name is required.';
                        if (name.length < 2) return 'Recipe name must be at least 2 characters.';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: ['Breakfast', 'Lunch', 'Dinner', 'Other'].contains(_categoryController.text)
                          ? _categoryController.text
                          : 'Other',
                      decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                      items: ['Breakfast', 'Lunch', 'Dinner', 'Other']
                          .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _categoryController.text = value);
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Category is required.';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _servingsController,
                      decoration: const InputDecoration(labelText: 'Servings', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        final servings = int.tryParse(value ?? '');
                        if (servings == null || servings <= 0) return 'Enter a valid serving amount.';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Ingredients
            Row(children: [
              const Icon(Icons.shopping_basket_outlined),
              const SizedBox(width: 8),
              Text('Ingredients', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(width: 8),
              Chip(label: Text('${_ingredients.length} item(s)')),
            ]),
            const SizedBox(height: 8),

            ..._ingredients.asMap().entries.map((entry) {
              final index = entry.key;
              final ingredient = entry.value;
              final category = ingredient.resolvedCategory;
              final isAuto = ingredient.isCategoryAuto;

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ingredient.name,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F5E9),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${_formatAmount(ingredient.amount)} ${ingredient.unit}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF2E7D32),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                // Kategori chip — tıklanabilir
                                GestureDetector(
                                  onTap: () => _showCategoryPicker(index),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isAuto
                                          ? const Color(0xFFF4F9F1)
                                          : const Color(0xFFE3F2FD),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isAuto
                                            ? const Color(0xFF2E7D32).withValues(alpha: 0.2)
                                            : const Color(0xFF1565C0).withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          category,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: isAuto
                                                ? const Color(0xFF558B2F)
                                                : const Color(0xFF1565C0),
                                          ),
                                        ),
                                        const SizedBox(width: 3),
                                        Icon(
                                          isAuto ? Icons.auto_awesome_outlined : Icons.edit_outlined,
                                          size: 10,
                                          color: isAuto
                                              ? const Color(0xFF558B2F)
                                              : const Color(0xFF1565C0),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        onPressed: () => _showEditIngredientDialog(index),
                        tooltip: 'Edit',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18),
                        onPressed: () => _removeIngredient(index),
                        tooltip: 'Delete',
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 8),

            // Add ingredient — sadeleştirilmiş
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.add_circle_outline),
                      const SizedBox(width: 8),
                      Text('Add ingredient', style: Theme.of(context).textTheme.titleMedium),
                    ]),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _ingredientNameController,
                      focusNode: _ingredientNameFocusNode,
                      decoration: const InputDecoration(
                        labelText: 'Ingredient name',
                        border: OutlineInputBorder(),
                        hintText: 'e.g. Tomato, Chicken, Pasta',
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
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _units.contains(_ingredientUnitController.text)
                                ? _ingredientUnitController.text
                                : 'g',
                            decoration: const InputDecoration(
                              labelText: 'Unit',
                              border: OutlineInputBorder(),
                            ),
                            items: _units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                            onChanged: (v) {
                              if (v != null) setState(() => _ingredientUnitController.text = v);
                            },
                          ),
                        ),
                      ],
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

            // Instructions
            Row(children: [
              const Icon(Icons.format_list_numbered),
              const SizedBox(width: 8),
              Text('Instructions', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(width: 8),
              Chip(label: Text('${_instructions.length} step(s)')),
            ]),
            const SizedBox(height: 8),
            ..._instructions.asMap().entries.map((entry) {
              final index = entry.key;
              final instruction = entry.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  title: Text(instruction),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        onPressed: () => _showEditInstructionDialog(index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18),
                        onPressed: () => _removeInstruction(index),
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 8),

            // Add instruction
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.add_task_outlined),
                      const SizedBox(width: 8),
                      Text('Add instruction step', style: Theme.of(context).textTheme.titleMedium),
                    ]),
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

            // Calories
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.local_fire_department_outlined),
                      const SizedBox(width: 8),
                      Text('Calories', style: Theme.of(context).textTheme.titleMedium),
                    ]),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _caloriesController,
                      decoration: const InputDecoration(
                        labelText: 'Total calories (optional)',
                        hintText: 'e.g. 450',
                        border: OutlineInputBorder(),
                        suffixText: 'kcal',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Per serving will be calculated automatically.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Notes
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.notes_outlined),
                      const SizedBox(width: 8),
                      Text('Notes', style: Theme.of(context).textTheme.titleMedium),
                    ]),
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
                label: Text(widget.initialRecipe == null ? 'Save Recipe' : 'Update Recipe'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}