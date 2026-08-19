import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/meal_type.dart';
import '../../../models/planned_recipe.dart';
import '../../../models/recipe.dart';
import '../../../shared/app_constants.dart';
import '../../../shared/category_labels.dart';
import '../../../shared/day_labels.dart';
import '../../../shared/iso_week.dart';
import '../../../shared/meal_type_style.dart';
import '../../recipes/screens/recipe_detail_screen.dart';
import 'add_to_plan_sheet.dart';
import 'ai_meal_plan_input_screen.dart';

class MealPlanScreen extends StatelessWidget {
  final List<Recipe> recipes;
  final Map<String, PlannedRecipe> plannedRecipes;
  final int weekOffset;
  final void Function(int) onWeekChanged;
  final void Function(String day, Recipe recipe, int servings, [MealType? mealType]) onRecipeSelected;
  final void Function(String day, [MealType? mealType]) onRecipeRemoved;
  final void Function(String day, MealType? mealType, int delta) onServingsChanged;
  final bool hasCopiedDay;
  final void Function(String day) onCopyDay;
  final void Function(String day) onPasteDay;
  // Lets the "Plan with AI" flow save its newly-generated recipes into the
  // user's recipe library, same as adding one from the Recipes tab.
  final ValueChanged<Recipe> onRecipeAdded;

  const MealPlanScreen({
    super.key,
    required this.recipes,
    required this.plannedRecipes,
    required this.weekOffset,
    required this.onWeekChanged,
    required this.onRecipeSelected,
    required this.onRecipeRemoved,
    required this.onServingsChanged,
    required this.hasCopiedDay,
    required this.onCopyDay,
    required this.onPasteDay,
    required this.onRecipeAdded,
  });

  static const List<String> _days = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
  ];

  static const List<MealType> _mealTypes = [
    MealType.breakfast, MealType.lunch, MealType.dinner,
  ];

  static DateTime _mondayForOffset(int offset) {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return monday.add(Duration(days: 7 * offset));
  }

  // Locale-aware short date ("Jan 5", "5 Oca", "5 jan.", ...) — the CLDR
  // data behind DateFormat picks the right month form/order per language.
  String _shortDate(BuildContext context, DateTime d) {
    final locale = Localizations.localeOf(context).toString();
    return DateFormat.MMMd(locale).format(d);
  }

  String _dayDate(BuildContext context, String day) {
    final monday = _mondayForOffset(weekOffset);
    final date = monday.add(Duration(days: _days.indexOf(day)));
    return _shortDate(context, date);
  }

  String _mealPlanKey(String day, [MealType? mealType]) {
    if (mealType == null) return day;
    return '$day-${mealType.name}';
  }

  String _recipeMetaInfo(BuildContext context, Recipe recipe) {
    final l10n = AppLocalizations.of(context)!;
    if (recipe.calories != null) {
      return l10n.planKcalPerServing((recipe.calories! / recipe.servings).round());
    }
    return l10n.planIngredientCount(recipe.ingredients.length);
  }

  void _handleCopyDay(BuildContext context, String day) {
    final l10n = AppLocalizations.of(context)!;
    onCopyDay(day);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.planCopiedDaySnackbar(localizedDayName(l10n, day)))),
    );
  }

  Future<void> _handlePasteDay(BuildContext context, String day, bool dayHasMeals) async {
    final l10n = AppLocalizations.of(context)!;
    if (dayHasMeals) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.planOverwriteDialogTitle),
          content: Text(l10n.planOverwriteDialogContent(localizedDayName(l10n, day))),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.commonCancel)),
            FilledButton(onPressed: () => Navigator.of(context).pop(true), child: Text(l10n.planOverwriteConfirm)),
          ],
        ),
      );
      if (confirmed != true) return;
    }
    onPasteDay(day);
  }

  // Read-only recipe view, opened by tapping a planned meal's row — lets the
  // user check the recipe (ingredients/instructions) while cooking without
  // disturbing the remove/servings controls in the same row.
  void _openRecipeDetail(BuildContext context, Recipe recipe) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => RecipeDetailScreen(recipe: recipe)),
    );
  }

  void _openAddToPlanSheet(BuildContext context, String day, MealType mealType) {
    showAddToPlanSheet(
      context,
      recipes: recipes,
      day: day,
      mealType: mealType,
      onAdd: (recipe, servings) => onRecipeSelected(day, recipe, servings, mealType),
    );
  }

  void _openAiMealPlan(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AiMealPlanInputScreen(
          plannedRecipes: plannedRecipes,
          onRecipeSelected: onRecipeSelected,
          onRecipeAdded: onRecipeAdded,
        ),
      ),
    );
  }

  Widget _buildMiniStepper(BuildContext context, String day, MealType? mealType, PlannedRecipe pr, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: pr.targetServings > 1
              ? () => onServingsChanged(day, mealType, -1)
              : null,
          child: Icon(
            Icons.remove_circle_outline,
            size: 18,
            color: pr.targetServings > 1 ? color : Colors.grey[300],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(
            '${pr.targetServings}',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color),
          ),
        ),
        GestureDetector(
          onTap: pr.targetServings < 20
              ? () => onServingsChanged(day, mealType, 1)
              : null,
          child: Icon(
            Icons.add_circle_outline,
            size: 18,
            color: pr.targetServings < 20 ? color : Colors.grey[300],
          ),
        ),
      ],
    );
  }

  // Full-width row for a slot — used for BOTH filled and empty slots once
  // the day has at least one planned meal (see _buildMealsSection): filled
  // shows the recipe info + stepper + remove, empty shows an "Add X" row
  // that opens the add-to-plan sheet, same as a filled row's tap opens the
  // recipe detail.
  Widget _buildMealRow(BuildContext context, String day, MealType mealType) {
    final l10n = AppLocalizations.of(context)!;
    final pr = plannedRecipes[_mealPlanKey(day, mealType)];
    final isPlanned = pr != null;
    // State-based, not meal-type-based: a filled slot always reads as the
    // darker "dinner" tone and an empty one as the lighter "lunch" tone,
    // regardless of which meal this actually is — Breakfast/Lunch/Dinner
    // stay distinguishable by icon glyph, not by a unique color anymore.
    final bg = isPlanned ? MealType.dinner.surfaceColor : MealType.lunch.surfaceColor;
    final onBg = isPlanned ? MealType.dinner.onSurfaceColor : MealType.lunch.onSurfaceColor;

    return GestureDetector(
      onTap: isPlanned
          ? () => _openRecipeDetail(context, pr.recipe)
          : () => _openAddToPlanSheet(context, day, mealType),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          child: Row(
            children: [
              Icon(mealType.icon, size: 18, color: onBg),
              const SizedBox(width: 8),
              Expanded(
                child: isPlanned
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pr.recipe.name,
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: onBg),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 1),
                          Text(
                            _recipeMetaInfo(context, pr.recipe),
                            style: TextStyle(fontSize: 11, color: onBg.withValues(alpha: 0.75)),
                          ),
                        ],
                      )
                    : Text(
                        l10n.planAddMealType(localizedMealTypeLabel(l10n, mealType)),
                        style: TextStyle(
                          fontSize: 13,
                          color: onBg.withValues(alpha: 0.7),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
              ),
              if (isPlanned) ...[
                _buildMiniStepper(context, day, mealType, pr, onBg),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () => onRecipeRemoved(day, mealType),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(Icons.close, size: 16, color: onBg.withValues(alpha: 0.45)),
                  ),
                ),
              ] else
                Icon(Icons.add, size: 16, color: onBg.withValues(alpha: 0.5)),
            ],
          ),
        ),
      ),
    );
  }

  // Small round tappable icon for an EMPTY slot — always the lighter
  // "lunch" tone (state-based, not meal-type-based; see _buildMealRow),
  // just compact so several can sit side by side instead of each claiming
  // a full-width row before anything's planned.
  Widget _buildEmptySlotButton(BuildContext context, String day, MealType mealType) {
    final l10n = AppLocalizations.of(context)!;
    return Tooltip(
      message: l10n.planAddMealType(localizedMealTypeLabel(l10n, mealType)),
      child: Material(
        color: MealType.lunch.surfaceColor,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => _openAddToPlanSheet(context, day, mealType),
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(mealType.icon, size: 20, color: MealType.lunch.onSurfaceColor),
          ),
        ),
      ),
    );
  }

  // All still-empty slots for the day, side by side — placed after any
  // already-filled full-width rows so a partially-planned day shows filled
  // rows on top and the remaining round buttons together below them.
  Widget _buildEmptySlotsRow(BuildContext context, String day, List<MealType> emptyMealTypes) {
    return Row(
      children: [
        for (final mealType in emptyMealTypes) ...[
          _buildEmptySlotButton(context, day, mealType),
          if (mealType != emptyMealTypes.last) const SizedBox(width: 10),
        ],
      ],
    );
  }

  // All-or-nothing per day: zero planned meals shows the compact round-icon
  // row; as soon as ONE meal is planned, all three slots switch to
  // full-width rows at once (filled ones show recipe info, the rest show
  // "Add X") so the card is immediately "full size" rather than growing
  // one row at a time as more meals get added. The AnimatedSwitcher key is
  // just this boolean, not which specific slots are filled, so only the
  // one-time compact-to-full switch animates — going from 1 to 2 to 3
  // filled slots re-renders the same-sized Column in place with no
  // transition to trigger.
  Widget _buildMealsSection(BuildContext context, String day) {
    final hasAnyMeal = _mealTypes.any((m) => plannedRecipes[_mealPlanKey(day, m)] != null);

    return AnimatedSize(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeInOut,
      alignment: Alignment.topLeft,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: hasAnyMeal
            ? Column(
                key: const ValueKey('full'),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _mealTypes.map((mealType) => _buildMealRow(context, day, mealType)).toList(),
              )
            : KeyedSubtree(
                key: const ValueKey('compact'),
                child: _buildEmptySlotsRow(context, day, _mealTypes),
              ),
      ),
    );
  }

  Widget _buildLegacyMealRow(BuildContext context, String day, PlannedRecipe pr) {
    return GestureDetector(
      onTap: () => _openRecipeDetail(context, pr.recipe),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceSoft,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          child: Row(
            children: [
              const Icon(Icons.restaurant_menu_outlined, size: 18, color: AppColors.primaryDark),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pr.recipe.name,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1),
                    Text(
                      _recipeMetaInfo(context, pr.recipe),
                      style: TextStyle(fontSize: 11, color: AppColors.primaryDark.withValues(alpha: 0.7)),
                    ),
                  ],
                ),
              ),
              _buildMiniStepper(context, day, null, pr, AppColors.primaryDark),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () => onRecipeRemoved(day),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(Icons.close, size: 16, color: AppColors.primaryDark.withValues(alpha: 0.45)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDayCard(BuildContext context, String day) {
    final l10n = AppLocalizations.of(context)!;
    final legacyPr = plannedRecipes[_mealPlanKey(day)];
    final mealEntries = _mealTypes
        .map((m) => MapEntry(m, plannedRecipes[_mealPlanKey(day, m)]))
        .where((e) => e.value != null)
        .toList();

    // Highlight today's card
    final monday = _mondayForOffset(weekOffset);
    final dayDate = monday.add(Duration(days: _days.indexOf(day)));
    final today = DateTime.now();
    final isToday = weekOffset == 0 &&
        dayDate.year == today.year &&
        dayDate.month == today.month &&
        dayDate.day == today.day;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isToday
            ? const BorderSide(color: AppColors.primary, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            localizedDayName(l10n, day),
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: isToday ? AppColors.primary : null,
                            ),
                          ),
                          if (isToday) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                l10n.planTodayBadge,
                                style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        _dayDate(context, day),
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.more_vert, color: Colors.grey[500], size: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onSelected: (value) {
                    if (value == 'copy') _handleCopyDay(context, day);
                    if (value == 'paste') {
                      _handlePasteDay(context, day, legacyPr != null || mealEntries.isNotEmpty);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'copy',
                      child: Row(children: [
                        const Icon(Icons.copy_outlined, size: 18),
                        const SizedBox(width: 10),
                        Text(l10n.planCopyDay),
                      ]),
                    ),
                    if (hasCopiedDay)
                      PopupMenuItem(
                        value: 'paste',
                        child: Row(children: [
                          const Icon(Icons.content_paste_outlined, size: 18),
                          const SizedBox(width: 10),
                          Text(l10n.planPasteDay),
                        ]),
                      ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Meal rows (filled full-width rows + a row of round buttons
            // for whatever's still empty), animated as slots fill in.
            _buildMealsSection(context, day),

            // Legacy planned recipe (no mealType) — only shown if no typed meals
            if (legacyPr != null && mealEntries.isEmpty)
              _buildLegacyMealRow(context, day, legacyPr),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      // Extra bottom clearance (AppSpacing.navBarClearance) so the last day
      // card never ends up behind the floating nav bar now that the body
      // scrolls underneath it (Scaffold.extendBody).
      padding: const EdgeInsets.fromLTRB(16, 16, 16, AppSpacing.navBarClearance + 16),
      children: [
        // Week navigation + general add
        _WeekHeaderCard(weekOffset: weekOffset, onWeekChanged: onWeekChanged),

        const SizedBox(height: 12),

        SizedBox(
          height: 44,
          child: OutlinedButton.icon(
            onPressed: () => _openAiMealPlan(context),
            icon: const Icon(Icons.auto_awesome_outlined, size: 18),
            label: Text(AppLocalizations.of(context)!.planWithAiButton),
          ),
        ),

        const SizedBox(height: 16),

        // Day cards
        ..._days.map((day) => _buildDayCard(context, day)),
      ],
    );
  }
}

/// Week nav row: chevrons either side of a small header that, when there's
/// a relative label ("This week"/"Next week"/"Last week"), shows it as a
/// constant top line with the week-number/date-range toggle beneath it —
/// otherwise (further-out weeks, with no relative label) the toggle is the
/// whole header by itself. The toggle itself mirrors the Shopping List
/// week header: "Week 34" by default, tap swaps to "Aug 17 – Aug 23" in
/// the same spot, tap again swaps back — never both at once.
class _WeekHeaderCard extends StatefulWidget {
  final int weekOffset;
  final void Function(int) onWeekChanged;

  const _WeekHeaderCard({required this.weekOffset, required this.onWeekChanged});

  @override
  State<_WeekHeaderCard> createState() => _WeekHeaderCardState();
}

class _WeekHeaderCardState extends State<_WeekHeaderCard> {
  bool _showDateRange = false;

  String _shortDate(BuildContext context, DateTime d) {
    final locale = Localizations.localeOf(context).toString();
    return DateFormat.MMMd(locale).format(d);
  }

  String? _relativeLabel(AppLocalizations l10n) {
    switch (widget.weekOffset) {
      case -1: return l10n.planLastWeek;
      case 0: return l10n.planThisWeek;
      case 1: return l10n.planNextWeek;
      default: return null;
    }
  }

  String _toggleLabel(BuildContext context, AppLocalizations l10n) {
    final monday = MealPlanScreen._mondayForOffset(widget.weekOffset);
    if (!_showDateRange) {
      return l10n.planWeekNumberLabel(isoWeekNumberForMonday(monday));
    }
    final sunday = monday.add(const Duration(days: 6));
    return '${_shortDate(context, monday)} – ${_shortDate(context, sunday)}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final relativeLabel = _relativeLabel(l10n);

    return Card(
      // Subtle frame around the header, in the same green as the nav bar's
      // selected-tab capsule — thin enough to read as a soft outline, not
      // a heavy border.
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: const BorderSide(color: AppColors.primary, width: 1.2),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => widget.onWeekChanged(widget.weekOffset - 1),
              color: AppColors.primaryDark,
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _showDateRange = !_showDateRange),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (relativeLabel != null)
                      Text(
                        relativeLabel,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    Text(
                      _toggleLabel(context, l10n),
                      style: relativeLabel != null
                          ? TextStyle(fontSize: 12, color: Colors.grey[600])
                          : const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () => widget.onWeekChanged(widget.weekOffset + 1),
              color: AppColors.primaryDark,
            ),
          ],
        ),
      ),
    );
  }
}
