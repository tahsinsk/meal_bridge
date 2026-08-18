import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/ingredient.dart';
import '../../../models/recipe.dart';
import '../../../shared/app_constants.dart';
import '../../../shared/category_labels.dart';
import '../../../shared/widgets/option_picker_sheet.dart';
import '../../../shared/widgets/recipe_image.dart';

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
  late int _servings;
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

  // Stable per-row ids (independent of list position/content) so
  // ReorderableListView can track each row's identity through a drag —
  // using the ingredient/instruction value itself as the key would break
  // for duplicate content (e.g. two identical instruction steps).
  final List<int> _ingredientKeys = [];
  final List<int> _instructionKeys = [];
  int _nextIngredientKeyId = 0;
  int _nextInstructionKeyId = 0;

  String? _imagePath;
  final ImagePicker _imagePicker = ImagePicker();

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
    _servings = recipe?.servings ?? 2;
    _notesController = TextEditingController(text: recipe?.notes ?? '');
    _caloriesController = TextEditingController(text: recipe?.calories?.toString() ?? '');
    _imagePath = recipe?.imagePath;
    if (recipe != null) {
      _ingredients.addAll(recipe.ingredients);
      _instructions.addAll(recipe.instructions);
    }
    _ingredientKeys.addAll(List.generate(_ingredients.length, (_) => _nextIngredientKeyId++));
    _instructionKeys.addAll(List.generate(_instructions.length, (_) => _nextInstructionKeyId++));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
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
    final l10n = AppLocalizations.of(context)!;
    final name = _ingredientNameController.text.trim();
    final amountText = _ingredientAmountController.text.trim();
    final unit = _ingredientUnitController.text.trim();
    final amount = double.tryParse(amountText.replaceAll(',', '.'));

    if (name.isEmpty || amount == null || unit.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.recipeFormInvalidIngredient)),
      );
      return;
    }
    if (name.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.recipeFormIngredientNameTooShort)),
      );
      return;
    }
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.recipeFormIngredientAmountInvalid)),
      );
      return;
    }

    setState(() {
      _ingredients.add(Ingredient(name: name, amount: amount, unit: unit));
      _ingredientKeys.add(_nextIngredientKeyId++);
      _ingredientNameController.clear();
      _ingredientAmountController.clear();
      _ingredientUnitController.text = 'g';
    });
    _requestFocusAfterFrame(_ingredientNameFocusNode);
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredients.removeAt(index);
      _ingredientKeys.removeAt(index);
    });
  }

  void _reorderIngredients(int oldIndex, int newIndex) {
    setState(() {
      _ingredients.insert(newIndex, _ingredients.removeAt(oldIndex));
      _ingredientKeys.insert(newIndex, _ingredientKeys.removeAt(oldIndex));
    });
  }

  void _showCategoryPicker(int index) {
    final l10n = AppLocalizations.of(context)!;
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
                    Text(l10n.recipeFormIngredientCategoryTitle(ingredient.name),
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
                        child: Text(l10n.recipeFormResetToAuto),
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
                      label: Text(localizedMarketCategory(l10n, cat)),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      checkmarkColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.primaryDark,
                        fontWeight: FontWeight.w600,
                      ),
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
    final l10n = AppLocalizations.of(context)!;
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
              title: Text(l10n.recipeFormEditIngredientTitle),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        labelText: l10n.recipeFormIngredientNameLabel,
                        border: const OutlineInputBorder(),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: amountCtrl,
                            decoration: InputDecoration(
                              labelText: l10n.recipeFormAmountLabel,
                              border: const OutlineInputBorder(),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OptionPickerField<String>(
                            label: l10n.recipeFormUnitLabel,
                            value: selectedUnit,
                            options: _units,
                            labelBuilder: (u) => u,
                            onChanged: (v) => setDialogState(() => selectedUnit = v),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.commonCancel)),
                FilledButton(
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    final amount = double.tryParse(amountCtrl.text.trim().replaceAll(',', '.'));
                    if (name.length < 2 || amount == null || amount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.recipeFormInvalidValues)),
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
                  child: Text(l10n.commonSave),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _addInstruction() {
    final l10n = AppLocalizations.of(context)!;
    final instruction = _instructionController.text.trim();
    if (instruction.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.recipeFormInstructionEmpty)),
      );
      return;
    }
    if (instruction.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.recipeFormInstructionTooShort)),
      );
      return;
    }
    setState(() {
      _instructions.add(instruction);
      _instructionKeys.add(_nextInstructionKeyId++);
      _instructionController.clear();
    });
    _requestFocusAfterFrame(_instructionFocusNode);
  }

  void _removeInstruction(int index) {
    setState(() {
      _instructions.removeAt(index);
      _instructionKeys.removeAt(index);
    });
  }

  void _reorderInstructions(int oldIndex, int newIndex) {
    setState(() {
      _instructions.insert(newIndex, _instructions.removeAt(oldIndex));
      _instructionKeys.insert(newIndex, _instructionKeys.removeAt(oldIndex));
    });
  }

  void _showEditInstructionDialog(int index) {
    final l10n = AppLocalizations.of(context)!;
    final instructionCtrl = TextEditingController(text: _instructions[index]);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.recipeFormEditStepTitle(index + 1)),
          content: TextField(
            controller: instructionCtrl,
            decoration: InputDecoration(
              labelText: l10n.recipeFormInstructionLabel,
              border: const OutlineInputBorder(),
            ),
            minLines: 2,
            maxLines: 5,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.commonCancel)),
            FilledButton(
              onPressed: () {
                final text = instructionCtrl.text.trim();
                if (text.length < 5) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.recipeFormInstructionTooShort)),
                  );
                  return;
                }
                setState(() => _instructions[index] = text);
                Navigator.of(context).pop();
              },
              child: Text(l10n.commonSave),
            ),
          ],
        );
      },
    );
  }

  void _showImageSourcePicker() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: Text(l10n.recipeFormTakePhoto),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text(l10n.recipeFormChooseFromGallery),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final l10n = AppLocalizations.of(context)!;
    XFile? picked;
    try {
      picked = await _imagePicker.pickImage(source: source, imageQuality: 85);
    } on PlatformException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.recipeFormImagePermissionDenied)),
      );
      return;
    }
    if (picked == null) return;

    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${docsDir.path}/recipe_images');
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }
      final dotIndex = picked.path.lastIndexOf('.');
      final ext = dotIndex == -1 ? '.jpg' : picked.path.substring(dotIndex);
      final fileName = 'recipe_${DateTime.now().millisecondsSinceEpoch}$ext';
      final savedFile = await File(picked.path).copy('${imagesDir.path}/$fileName');
      if (!mounted) return;
      setState(() => _imagePath = savedFile.path);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.recipeFormImagePickFailed)),
      );
    }
  }

  void _saveRecipe() {
    final l10n = AppLocalizations.of(context)!;
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;
    if (_ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.recipeFormNoIngredients)),
      );
      return;
    }
    final recipe = Recipe(
      id: widget.initialRecipe?.id ?? 'recipe-${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      servings: _servings,
      category: _categoryController.text.trim(),
      ingredients: List.unmodifiable(_ingredients),
      instructions: List.unmodifiable(_instructions),
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      calories: int.tryParse(_caloriesController.text.trim()),
      imagePath: _imagePath,
    );
    Navigator.of(context).pop(recipe);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialRecipe == null ? l10n.recipeFormTitleAdd : l10n.recipeFormTitleEdit),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Photo
            GestureDetector(
              onTap: _showImageSourcePicker,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  height: 160,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      RecipeImage(imagePath: _imagePath, iconSize: 48),
                      Positioned(
                        right: 10,
                        bottom: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.camera_alt_outlined, size: 16, color: Colors.white),
                              const SizedBox(width: 6),
                              Text(
                                _imagePath == null ? l10n.recipeFormAddPhoto : l10n.recipeFormChangePhoto,
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Basic info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.edit_note),
                      const SizedBox(width: 8),
                      Text(l10n.recipeFormBasicInfo, style: Theme.of(context).textTheme.titleMedium),
                    ]),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: l10n.recipeFormNameLabel, border: const OutlineInputBorder()),
                      textCapitalization: TextCapitalization.sentences,
                      validator: (value) {
                        final name = value?.trim() ?? '';
                        if (name.isEmpty) return l10n.recipeFormNameRequired;
                        if (name.length < 2) return l10n.recipeFormNameTooShort;
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    OptionPickerField<String>(
                      label: l10n.recipeFormCategoryLabel,
                      value: ['Breakfast', 'Lunch', 'Dinner', 'Other'].contains(_categoryController.text)
                          ? _categoryController.text
                          : 'Other',
                      options: const ['Breakfast', 'Lunch', 'Dinner', 'Other'],
                      labelBuilder: (cat) => localizedRecipeCategory(l10n, cat),
                      onChanged: (value) => setState(() => _categoryController.text = value),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primaryDark.withValues(alpha: 0.25)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Text(l10n.recipeFormServingsLabel, style: const TextStyle(fontSize: 16, color: AppColors.primaryDark)),
                          const Spacer(),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.creamBackground,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.primaryDark.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: _servings > 1 ? () => setState(() => _servings--) : null,
                                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    child: Icon(Icons.remove, size: 16,
                                      color: _servings > 1 ? AppColors.primaryDark : Colors.grey[400]),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: Text('$_servings',
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.primaryDark)),
                                ),
                                InkWell(
                                  onTap: _servings < 20 ? () => setState(() => _servings++) : null,
                                  borderRadius: const BorderRadius.horizontal(right: Radius.circular(20)),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    child: Icon(Icons.add, size: 16,
                                      color: _servings < 20 ? AppColors.primaryDark : Colors.grey[400]),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: Text(l10n.recipeStatServings, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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
              Text(l10n.recipeSectionIngredients, style: Theme.of(context).textTheme.titleLarge),
            ]),
            const SizedBox(height: 8),

            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              onReorderItem: _reorderIngredients,
              itemCount: _ingredients.length,
              itemBuilder: (context, index) {
              final ingredient = _ingredients[index];
              final category = ingredient.resolvedCategory;
              final isAuto = ingredient.isCategoryAuto;

              return Card(
                key: ValueKey(_ingredientKeys[index]),
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      ReorderableDelayedDragStartListener(
                        index: index,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Icon(Icons.drag_indicator, size: 20, color: Colors.grey[400]),
                        ),
                      ),
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
                                    color: AppColors.surfaceSoft,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${_formatAmount(ingredient.amount)} ${ingredient.unit}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.primaryDark,
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
                                          ? AppColors.creamBackground
                                          : const Color(0xFFE3F2FD),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isAuto
                                            ? AppColors.primaryDark.withValues(alpha: 0.2)
                                            : const Color(0xFF1565C0).withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          localizedMarketCategory(l10n, category),
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: isAuto
                                                ? AppColors.primaryDark
                                                : const Color(0xFF1565C0),
                                          ),
                                        ),
                                        const SizedBox(width: 3),
                                        Icon(
                                          isAuto ? Icons.auto_awesome_outlined : Icons.edit_outlined,
                                          size: 10,
                                          color: isAuto
                                              ? AppColors.primaryDark
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
                        tooltip: l10n.commonEdit,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18),
                        onPressed: () => _removeIngredient(index),
                        tooltip: l10n.commonDelete,
                      ),
                    ],
                  ),
                ),
              );
              },
            ),

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
                      Text(l10n.recipeFormAddIngredient, style: Theme.of(context).textTheme.titleMedium),
                    ]),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _ingredientNameController,
                      focusNode: _ingredientNameFocusNode,
                      decoration: InputDecoration(
                        labelText: l10n.recipeFormIngredientNameLabel,
                        border: const OutlineInputBorder(),
                        hintText: l10n.recipeFormIngredientNameHint,
                      ),
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _ingredientAmountController,
                            decoration: InputDecoration(
                              labelText: l10n.recipeFormAmountLabel,
                              border: const OutlineInputBorder(),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OptionPickerField<String>(
                            label: l10n.recipeFormUnitLabel,
                            value: _units.contains(_ingredientUnitController.text)
                                ? _ingredientUnitController.text
                                : 'g',
                            options: _units,
                            labelBuilder: (u) => u,
                            onChanged: (v) => setState(() => _ingredientUnitController.text = v),
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
                        label: Text(l10n.recipeFormAddIngredientButton),
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
              Text(l10n.recipeSectionInstructions, style: Theme.of(context).textTheme.titleLarge),
            ]),
            const SizedBox(height: 8),
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              onReorderItem: _reorderInstructions,
              itemCount: _instructions.length,
              itemBuilder: (context, index) {
              final instruction = _instructions[index];
              return Card(
                key: ValueKey(_instructionKeys[index]),
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ReorderableDelayedDragStartListener(
                        index: index,
                        child: Icon(Icons.drag_indicator, size: 20, color: Colors.grey[400]),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.primaryDark,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
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
              },
            ),

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
                      Text(l10n.recipeFormAddInstructionSection, style: Theme.of(context).textTheme.titleMedium),
                    ]),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _instructionController,
                      focusNode: _instructionFocusNode,
                      decoration: InputDecoration(
                        labelText: l10n.recipeFormInstructionLabel,
                        border: const OutlineInputBorder(),
                      ),
                      minLines: 2,
                      maxLines: 4,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _addInstruction,
                        icon: const Icon(Icons.add),
                        label: Text(l10n.recipeFormAddInstructionButton),
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
                      Text(l10n.recipeFormCaloriesSection, style: Theme.of(context).textTheme.titleMedium),
                    ]),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _caloriesController,
                      decoration: InputDecoration(
                        labelText: l10n.recipeFormCaloriesLabel,
                        hintText: l10n.recipeFormCaloriesHint,
                        border: const OutlineInputBorder(),
                        suffixText: l10n.recipeFormKcalSuffix,
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.recipeFormCaloriesHelper,
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
                      Text(l10n.recipeSectionNotes, style: Theme.of(context).textTheme.titleMedium),
                    ]),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _notesController,
                      decoration: InputDecoration(
                        labelText: l10n.recipeFormNotesLabel,
                        border: const OutlineInputBorder(),
                      ),
                      minLines: 2,
                      maxLines: 4,
                      textCapitalization: TextCapitalization.sentences,
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
                label: Text(widget.initialRecipe == null ? l10n.recipeFormSaveButton : l10n.recipeFormUpdateButton),
              ),
            ),
          ],
        ),
      ),
    );
  }
}