import 'package:flutter/material.dart';

import '../../../models/ingredient.dart';
import '../../../shared/app_constants.dart';
import '../../../shared/widgets/option_picker_sheet.dart';

/// Clean "add an extra item to the shopping list" bottom sheet — same
/// fields and flow as the ingredient-add flow in the recipe form (name,
/// amount, unit), so items land in the right smart-guessed category and
/// show the same amount badge as recipe ingredients. Works regardless of
/// Weekly Plan / Quick List mode.
Future<void> showAddCustomItemSheet(
  BuildContext context, {
  required List<Ingredient> existingItems,
  required void Function(Ingredient item) onAdd,
  required void Function(String name) onRemove,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _AddCustomItemSheet(
      existingItems: existingItems,
      onAdd: onAdd,
      onRemove: onRemove,
    ),
  );
}

class _AddCustomItemSheet extends StatefulWidget {
  final List<Ingredient> existingItems;
  final void Function(Ingredient item) onAdd;
  final void Function(String name) onRemove;

  const _AddCustomItemSheet({
    required this.existingItems,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  State<_AddCustomItemSheet> createState() => _AddCustomItemSheetState();
}

class _AddCustomItemSheetState extends State<_AddCustomItemSheet> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _unitController = TextEditingController(text: 'g');
  final _nameFocusNode = FocusNode();
  List<Ingredient> _items = [];

  static const _units = [
    'g', 'kg', 'ml', 'l', 'pcs', 'tbsp', 'tsp', 'cup', 'slice', 'can', 'pack',
  ];

  @override
  void initState() {
    super.initState();
    _items = List.of(widget.existingItems);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _unitController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  String _formatAmount(double amount) {
    if (amount == amount.roundToDouble()) return amount.toInt().toString();
    return amount.toString();
  }

  void _requestFocusAfterFrame() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await Future<void>.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;
      FocusScope.of(context).requestFocus(_nameFocusNode);
    });
  }

  void _add() {
    final name = _nameController.text.trim();
    final unit = _unitController.text.trim();
    final amount = double.tryParse(_amountController.text.trim().replaceAll(',', '.'));

    if (name.isEmpty || amount == null || unit.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid item.')),
      );
      return;
    }
    if (name.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item name must be at least 2 characters.')),
      );
      return;
    }
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item amount must be greater than 0.')),
      );
      return;
    }
    if (_items.any((i) => i.name.toLowerCase() == name.toLowerCase())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('That item is already on the list.')),
      );
      return;
    }

    final item = Ingredient(name: name, amount: amount, unit: unit);
    widget.onAdd(item);
    setState(() {
      _items.add(item);
      _nameController.clear();
      _amountController.clear();
      _unitController.text = 'g';
    });
    _requestFocusAfterFrame();
  }

  void _remove(Ingredient item) {
    widget.onRemove(item.name);
    setState(() => _items.remove(item));
  }

  @override
  Widget build(BuildContext context) {
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
                      child: Text('Add item', style: Theme.of(context).textTheme.titleLarge),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  children: [
                    TextField(
                      controller: _nameController,
                      focusNode: _nameFocusNode,
                      autofocus: true,
                      decoration: const InputDecoration(
                        labelText: 'Item name',
                        hintText: 'e.g. Milk, Trash bags, Napkins',
                      ),
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _amountController,
                            decoration: const InputDecoration(labelText: 'Amount'),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            onSubmitted: (_) => _add(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OptionPickerField<String>(
                            label: 'Unit',
                            value: _units.contains(_unitController.text)
                                ? _unitController.text
                                : 'g',
                            options: _units,
                            labelBuilder: (u) => u,
                            onChanged: (v) => setState(() => _unitController.text = v),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _add,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Item'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_items.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'No extra items yet — add your first one above.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      )
                    else
                      ..._items.map((item) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item.name, style: Theme.of(context).textTheme.titleSmall),
                                      Text(
                                        item.resolvedCategory,
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceSoft,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${_formatAmount(item.amount)} ${item.unit}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, size: 18),
                                  onPressed: () => _remove(item),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
