import 'package:flutter/material.dart';

import '../../../shared/app_constants.dart';

/// Clean "add an extra item to the shopping list" bottom sheet — same spirit
/// as the ingredient-add flow in the recipe form: a name field + add button,
/// with already-added items listed below so you can add several in a row.
/// Works regardless of Weekly Plan / Quick List mode.
Future<void> showAddCustomItemSheet(
  BuildContext context, {
  required List<String> existingItems,
  required void Function(String name) onAdd,
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
  final List<String> existingItems;
  final void Function(String name) onAdd;
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
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  List<String> _items = [];

  @override
  void initState() {
    super.initState();
    _items = List.of(widget.existingItems);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _add() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    if (_items.any((i) => i.toLowerCase() == name.toLowerCase())) {
      _controller.clear();
      return;
    }
    widget.onAdd(name);
    setState(() {
      _items.add(name);
      _controller.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  void _remove(String name) {
    widget.onRemove(name);
    setState(() => _items.remove(name));
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
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
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        autofocus: true,
                        decoration: const InputDecoration(hintText: 'e.g. Trash bags, Napkins'),
                        textCapitalization: TextCapitalization.sentences,
                        onSubmitted: (_) => _add(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: _add,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(48, 48),
                        padding: EdgeInsets.zero,
                      ),
                      child: const Icon(Icons.add),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _items.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'No extra items yet — add your first one above.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                        itemCount: _items.length,
                        itemBuilder: (context, index) {
                          final name = _items[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(name),
                              trailing: IconButton(
                                icon: const Icon(Icons.close, size: 18),
                                onPressed: () => _remove(name),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
