import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/meal_type.dart';
import '../../../models/planned_recipe.dart';
import '../../../models/recipe.dart';
import '../../../models/recipe_preference.dart';
import '../../../services/recipe_ai_service.dart';
import '../../../shared/category_labels.dart';
import '../../../shared/day_labels.dart';
import '../../../shared/meal_type_style.dart';
import '../../recipes/screens/recipe_form_screen.dart';

/// Review-before-committing screen for a freshly AI-generated meal plan —
/// nothing is saved or planned until "Add to Plan" is pressed. Each slot
/// can be tapped to review/edit in the full recipe form, regenerated with
/// one more targeted single-recipe call, or removed entirely, before the
/// whole batch is committed at once.
class AiMealPlanReviewScreen extends StatefulWidget {
  // Real day-of-week names for the currently-viewed week, e.g.
  // ['Monday', 'Tuesday', 'Wednesday'] for a 3-day plan.
  final List<String> days;
  final List<MealType> mealTypes;
  final int servings;
  final Set<RecipePreference> preferences;
  // Day-major order matching days × mealTypes (see _slotIndex).
  final List<GeneratedRecipeDraft> initialDrafts;
  // The currently-viewed week's existing plan, keyed "Day-mealType" — used
  // only to detect slots that would be overwritten.
  final Map<String, PlannedRecipe> plannedRecipes;
  final void Function(String day, Recipe recipe, int servings, [MealType? mealType]) onRecipeSelected;
  final ValueChanged<Recipe> onRecipeAdded;

  const AiMealPlanReviewScreen({
    super.key,
    required this.days,
    required this.mealTypes,
    required this.servings,
    required this.preferences,
    required this.initialDrafts,
    required this.plannedRecipes,
    required this.onRecipeSelected,
    required this.onRecipeAdded,
  });

  @override
  State<AiMealPlanReviewScreen> createState() => _AiMealPlanReviewScreenState();
}

class _AiMealPlanReviewScreenState extends State<AiMealPlanReviewScreen> {
  final _recipeAiService = RecipeAiService();
  late final List<Recipe?> _slotRecipes;
  late final List<bool> _isRegenerating;

  int get _slotCount => widget.days.length * widget.mealTypes.length;

  @override
  void initState() {
    super.initState();
    _slotRecipes = List.generate(
      _slotCount,
      (i) => i < widget.initialDrafts.length ? _buildRecipe(index: i, draft: widget.initialDrafts[i]) : null,
    );
    _isRegenerating = List.filled(_slotCount, false);
  }

  int _slotIndex(int dayIndex, int mealIndex) => dayIndex * widget.mealTypes.length + mealIndex;

  String _mealTypeCategory(MealType mealType) {
    switch (mealType) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
    }
  }

  Recipe _buildRecipe({required int index, required GeneratedRecipeDraft draft, String? fallbackName}) {
    final mealType = widget.mealTypes[index % widget.mealTypes.length];
    final mealLabel = _mealTypeCategory(mealType);
    final name = (draft.name != null && draft.name!.trim().isNotEmpty)
        ? draft.name!.trim()
        : (fallbackName ?? mealLabel);
    return Recipe(
      id: 'ai-plan-${DateTime.now().millisecondsSinceEpoch}-$index',
      name: name,
      servings: widget.servings,
      category: mealLabel,
      ingredients: draft.ingredients,
      instructions: draft.instructions,
      calories: draft.estimatedTotalCalories,
      instructionDurationsMinutes: draft.instructionDurationsMinutes,
      totalTimeMinutes: draft.totalTimeMinutes,
    );
  }

  Future<void> _regenerateSlot(int index) async {
    final l10n = AppLocalizations.of(context)!;
    final mealType = widget.mealTypes[index % widget.mealTypes.length];
    final current = _slotRecipes[index];
    final mealLabel = _mealTypeCategory(mealType);
    final prompt = current != null
        ? 'a different $mealLabel idea than "${current.name}"'
        : 'a $mealLabel idea for a meal plan';

    setState(() => _isRegenerating[index] = true);
    try {
      final draft = await _recipeAiService.generateRecipe(
        recipeName: prompt,
        servings: widget.servings,
        preferences: widget.preferences,
      );
      if (!mounted) return;
      setState(() {
        _slotRecipes[index] = _buildRecipe(index: index, draft: draft, fallbackName: current?.name);
        _isRegenerating[index] = false;
      });
    } on GeminiRateLimitException {
      if (!mounted) return;
      setState(() => _isRegenerating[index] = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.recipeFormAiErrorRateLimit)),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isRegenerating[index] = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.recipeFormAiErrorGeneric)),
      );
    }
  }

  void _removeSlot(int index) {
    setState(() => _slotRecipes[index] = null);
  }

  Future<void> _editSlot(int index) async {
    final recipe = _slotRecipes[index];
    if (recipe == null) return;
    final edited = await Navigator.of(context).push<Recipe>(
      MaterialPageRoute(builder: (context) => RecipeFormScreen(draft: recipe)),
    );
    if (edited != null && mounted) {
      setState(() => _slotRecipes[index] = edited);
    }
  }

  Future<void> _confirmAddToPlan() async {
    final l10n = AppLocalizations.of(context)!;
    final entries = <(int dayIndex, int mealIndex, Recipe recipe)>[];
    for (var d = 0; d < widget.days.length; d++) {
      for (var m = 0; m < widget.mealTypes.length; m++) {
        final recipe = _slotRecipes[_slotIndex(d, m)];
        if (recipe != null) entries.add((d, m, recipe));
      }
    }

    if (entries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.planAiEmptyAfterRemovalHint)),
      );
      return;
    }

    final conflictCount = entries.where((e) {
      final key = '${widget.days[e.$1]}-${widget.mealTypes[e.$2].name}';
      return widget.plannedRecipes[key] != null;
    }).length;

    if (conflictCount > 0) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.planAiOverwriteTitle),
          content: Text(l10n.planAiOverwriteContent(conflictCount)),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.commonCancel)),
            FilledButton(onPressed: () => Navigator.of(context).pop(true), child: Text(l10n.planOverwriteConfirm)),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    for (final entry in entries) {
      final recipe = entry.$3;
      widget.onRecipeAdded(recipe);
      widget.onRecipeSelected(widget.days[entry.$1], recipe, recipe.servings, widget.mealTypes[entry.$2]);
    }
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  String _slotPreviewLine(AppLocalizations l10n, Recipe recipe) {
    final parts = <String>[];
    if (recipe.calories != null) parts.add('${recipe.calories} ${l10n.recipeFormKcalSuffix}');
    if (recipe.totalTimeMinutes != null) parts.add('${recipe.totalTimeMinutes} ${l10n.recipeStatMinutes}');
    return parts.join(' · ');
  }

  Widget _buildSlotRow(BuildContext context, AppLocalizations l10n, int dayIndex, int mealIndex) {
    final mealType = widget.mealTypes[mealIndex];
    final index = _slotIndex(dayIndex, mealIndex);
    final recipe = _slotRecipes[index];
    final isRegenerating = _isRegenerating[index];

    if (isRegenerating) {
      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: Icon(mealType.icon, color: Colors.grey[400]),
          title: const SizedBox(
            height: 18,
            child: LinearProgressIndicator(),
          ),
        ),
      );
    }

    if (recipe == null) {
      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        color: Colors.grey[100],
        child: ListTile(
          leading: Icon(mealType.icon, color: Colors.grey[400]),
          title: Text(
            '${localizedMealTypeLabel(l10n, mealType)} · ${l10n.planAiSlotRemovedLabel}',
            style: TextStyle(color: Colors.grey[500]),
          ),
          trailing: TextButton(
            onPressed: () => _regenerateSlot(index),
            child: Text(l10n.planAiBringBackButton),
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: mealType.surfaceColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(mealType.icon, color: mealType.onSurfaceColor, size: 20),
        ),
        title: Text(recipe.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(_slotPreviewLine(l10n, recipe)),
        onTap: () => _editSlot(index),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.refresh, size: 20),
              tooltip: l10n.planAiRegenerateTooltip,
              onPressed: () => _regenerateSlot(index),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              tooltip: l10n.planAiRemoveTooltip,
              onPressed: () => _removeSlot(index),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.planAiReviewTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        children: [
          for (var d = 0; d < widget.days.length; d++) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 8, top: 8),
              child: Text(
                localizedDayName(l10n, widget.days[d]),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            for (var m = 0; m < widget.mealTypes.length; m++) _buildSlotRow(context, l10n, d, m),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            height: 48,
            child: FilledButton.icon(
              onPressed: _confirmAddToPlan,
              icon: const Icon(Icons.check),
              label: Text(l10n.planAddToPlanButton),
            ),
          ),
        ),
      ),
    );
  }
}
