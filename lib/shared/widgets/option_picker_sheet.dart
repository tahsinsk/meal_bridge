import 'package:flutter/material.dart';

import '../app_constants.dart';

/// Opens a clean modal bottom-sheet list picker (rounded top, drag handle,
/// title, rows with a check mark on the selected option) and resolves with
/// the tapped option, or `null` if dismissed without a selection.
Future<T?> showOptionPickerSheet<T>(
  BuildContext context, {
  required String title,
  required List<T> options,
  required T selected,
  required String Function(T option) labelBuilder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.large)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options[index];
                      final isSelected = option == selected;
                      return InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => Navigator.of(context).pop(option),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.surfaceSoft : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  labelBuilder(option),
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check, size: 20, color: AppColors.primaryDark),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

/// A form-field-styled tappable row (matches [TextFormField]'s look via
/// [InputDecorator]) that opens [showOptionPickerSheet] instead of a native
/// dropdown menu. Drop-in replacement for `DropdownButtonFormField` wherever
/// the options are a short fixed list (category, unit, etc.).
class OptionPickerField<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<T> options;
  final String Function(T option) labelBuilder;
  final ValueChanged<T> onChanged;

  const OptionPickerField({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.labelBuilder,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        final result = await showOptionPickerSheet<T>(
          context,
          title: label,
          options: options,
          selected: value,
          labelBuilder: labelBuilder,
        );
        if (result != null) onChanged(result);
      },
      child: InputDecorator(
        decoration: const InputDecoration(border: OutlineInputBorder()).copyWith(
          labelText: label,
          suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primaryDark),
        ),
        child: Text(labelBuilder(value), style: const TextStyle(fontSize: 15)),
      ),
    );
  }
}
