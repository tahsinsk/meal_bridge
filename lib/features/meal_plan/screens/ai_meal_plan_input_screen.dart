import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/meal_type.dart';
import '../../../models/planned_recipe.dart';
import '../../../models/recipe.dart';
import '../../../models/recipe_preference.dart';
import '../../../services/recipe_ai_service.dart';
import '../../../shared/app_constants.dart';
import '../../../shared/category_labels.dart';
import '../../../shared/widgets/preference_chips.dart';
import 'ai_meal_plan_review_screen.dart';

/// "Plan with AI" entry point: pick how many days and which meals, then
/// hand off to the review screen once a full batch draft comes back.
/// Nothing is saved or planned here — review is where the user actually
/// commits (or doesn't).
class AiMealPlanInputScreen extends StatefulWidget {
  final Map<String, PlannedRecipe> plannedRecipes;
  final void Function(String day, Recipe recipe, int servings, [MealType? mealType]) onRecipeSelected;
  final ValueChanged<Recipe> onRecipeAdded;

  const AiMealPlanInputScreen({
    super.key,
    required this.plannedRecipes,
    required this.onRecipeSelected,
    required this.onRecipeAdded,
  });

  @override
  State<AiMealPlanInputScreen> createState() => _AiMealPlanInputScreenState();
}

class _AiMealPlanInputScreenState extends State<AiMealPlanInputScreen> {
  // Matches MealPlanScreen's own day list — a plan always starts Monday and
  // covers the first N days of the currently-viewed week.
  static const List<String> _days = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
  ];
  static const List<MealType> _mealTypeOrder = [
    MealType.breakfast, MealType.lunch, MealType.dinner,
  ];

  final _recipeAiService = RecipeAiService();
  int _dayCount = 3;
  Set<MealType> _selectedMealTypes = {MealType.breakfast, MealType.lunch, MealType.dinner};
  Set<RecipePreference> _preferences = {};
  bool _isGenerating = false;

  Future<void> _generate() async {
    final l10n = AppLocalizations.of(context)!;
    if (_selectedMealTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.planAiMealsRequiredHint)),
      );
      return;
    }

    final mealTypes = _mealTypeOrder.where(_selectedMealTypes.contains).toList();
    setState(() => _isGenerating = true);
    try {
      final drafts = await _recipeAiService.generateMealPlan(
        dayCount: _dayCount,
        mealTypes: mealTypes,
        servings: 2,
        preferences: _preferences,
      );
      if (!mounted) return;
      setState(() => _isGenerating = false);
      final added = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (context) => AiMealPlanReviewScreen(
            days: _days.take(_dayCount).toList(),
            mealTypes: mealTypes,
            servings: 2,
            preferences: _preferences,
            initialDrafts: drafts,
            plannedRecipes: widget.plannedRecipes,
            onRecipeSelected: widget.onRecipeSelected,
            onRecipeAdded: widget.onRecipeAdded,
          ),
        ),
      );
      if (added == true && mounted) Navigator.of(context).pop();
    } on GeminiRateLimitException {
      if (!mounted) return;
      setState(() => _isGenerating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.recipeFormAiErrorRateLimit)),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isGenerating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.recipeFormAiErrorGeneric)),
      );
    }
  }

  Widget _buildDayStepper(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primaryDark.withValues(alpha: 0.25)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(l10n.planAiDaysLabel, style: const TextStyle(fontSize: 16, color: AppColors.primaryDark)),
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
                  onTap: _dayCount > 1 && !_isGenerating ? () => setState(() => _dayCount--) : null,
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Icon(Icons.remove, size: 16,
                      color: _dayCount > 1 ? AppColors.primaryDark : Colors.grey[400]),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text('$_dayCount',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.primaryDark)),
                ),
                InkWell(
                  onTap: _dayCount < 7 && !_isGenerating ? () => setState(() => _dayCount++) : null,
                  borderRadius: const BorderRadius.horizontal(right: Radius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Icon(Icons.add, size: 16,
                      color: _dayCount < 7 ? AppColors.primaryDark : Colors.grey[400]),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Text(l10n.planAiDaysUnit, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealTypeChips(AppLocalizations l10n) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _mealTypeOrder.map((mealType) {
        final isSelected = _selectedMealTypes.contains(mealType);
        return FilterChip(
          label: Text(localizedMealTypeLabel(l10n, mealType)),
          selected: isSelected,
          selectedColor: AppColors.primary,
          checkmarkColor: Colors.white,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : AppColors.primaryDark,
            fontWeight: FontWeight.w600,
          ),
          onSelected: _isGenerating
              ? null
              : (value) {
                  setState(() {
                    final next = Set<MealType>.from(_selectedMealTypes);
                    if (value) {
                      next.add(mealType);
                    } else {
                      next.remove(mealType);
                    }
                    _selectedMealTypes = next;
                  });
                },
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.planWithAiButton)),
      body: SafeArea(
        child: _isGenerating
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 20),
                    Text(
                      l10n.planAiLoadingMessage,
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    Icon(Icons.auto_awesome_outlined, size: 48, color: AppColors.primary),
                    const SizedBox(height: 24),
                    _buildDayStepper(l10n),
                    const SizedBox(height: 24),
                    Text(l10n.planAiMealsLabel, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    _buildMealTypeChips(l10n),
                    const SizedBox(height: 24),
                    PreferenceChips(
                      selected: _preferences,
                      onChanged: (next) => setState(() => _preferences = next),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 48,
                      child: FilledButton.icon(
                        onPressed: _generate,
                        icon: const Icon(Icons.auto_awesome),
                        label: Text(l10n.planAiGenerateButton),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
