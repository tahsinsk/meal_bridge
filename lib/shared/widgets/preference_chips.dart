import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/recipe_preference.dart';
import '../app_constants.dart';

extension RecipePreferenceLabel on RecipePreference {
  String label(AppLocalizations l10n) {
    switch (this) {
      case RecipePreference.highProtein:
        return l10n.recipePreferenceHighProtein;
      case RecipePreference.vegetarian:
        return l10n.recipePreferenceVegetarian;
      case RecipePreference.quick:
        return l10n.recipePreferenceQuick;
      case RecipePreference.budgetFriendly:
        return l10n.recipePreferenceBudgetFriendly;
    }
  }
}

/// Shared row of toggleable filter chips for the AI-generate and pantry
/// screens — same set, same styling, in one place instead of duplicated
/// across both entry points.
class PreferenceChips extends StatelessWidget {
  final Set<RecipePreference> selected;
  final ValueChanged<Set<RecipePreference>> onChanged;

  const PreferenceChips({super.key, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: RecipePreference.values.map((preference) {
        final isSelected = selected.contains(preference);
        return FilterChip(
          label: Text(preference.label(l10n)),
          selected: isSelected,
          selectedColor: AppColors.primary,
          checkmarkColor: Colors.white,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : AppColors.primaryDark,
            fontWeight: FontWeight.w600,
          ),
          onSelected: (value) {
            final next = Set<RecipePreference>.from(selected);
            if (value) {
              next.add(preference);
            } else {
              next.remove(preference);
            }
            onChanged(next);
          },
        );
      }).toList(),
    );
  }
}
