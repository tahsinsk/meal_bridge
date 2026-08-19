import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/recipe.dart';
import '../../../services/recipe_ai_service.dart';
import '../../../shared/app_constants.dart';
import 'recipe_form_screen.dart';

/// "What can I make?" entry point: a free-text list of ingredients the
/// user already has, then hands off to the full Add Recipe form pre-filled
/// with the AI's suggested draft so the user reviews/edits everything
/// before saving. Nothing here is ever auto-saved — the draft only becomes
/// a real recipe once the user taps Save on the full form.
class PantryRecipeScreen extends StatefulWidget {
  const PantryRecipeScreen({super.key});

  @override
  State<PantryRecipeScreen> createState() => _PantryRecipeScreenState();
}

class _PantryRecipeScreenState extends State<PantryRecipeScreen> {
  final _ingredientsController = TextEditingController();
  final _recipeAiService = RecipeAiService();
  bool _isGenerating = false;

  @override
  void dispose() {
    _ingredientsController.dispose();
    super.dispose();
  }

  Future<void> _suggest() async {
    final l10n = AppLocalizations.of(context)!;
    final ingredientsText = _ingredientsController.text.trim();
    if (ingredientsText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.recipePantryEmptyHint)),
      );
      return;
    }

    setState(() => _isGenerating = true);
    try {
      final draft = await _recipeAiService.generateRecipeFromPantry(
        ingredientsText: ingredientsText,
        servings: 2,
      );
      if (!mounted) return;
      final draftRecipe = Recipe(
        id: 'draft',
        name: draft.name ?? '',
        servings: 2,
        category: 'Dinner',
        ingredients: draft.ingredients,
        instructions: draft.instructions,
        calories: draft.estimatedTotalCalories,
        instructionDurationsMinutes: draft.instructionDurationsMinutes,
        totalTimeMinutes: draft.totalTimeMinutes,
      );
      setState(() => _isGenerating = false);
      final saved = await Navigator.of(context).push<Recipe>(
        MaterialPageRoute(builder: (context) => RecipeFormScreen(draft: draftRecipe)),
      );
      if (!mounted) return;
      Navigator.of(context).pop(saved);
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.recipeFormPantrySuggest)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              Icon(Icons.kitchen_outlined, size: 48, color: AppColors.primary),
              const SizedBox(height: 16),
              Text(
                l10n.recipePantryQuestion,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _ingredientsController,
                decoration: InputDecoration(
                  hintText: l10n.recipePantryHint,
                  border: const OutlineInputBorder(),
                ),
                minLines: 3,
                maxLines: 6,
                textCapitalization: TextCapitalization.sentences,
                enabled: !_isGenerating,
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 48,
                child: FilledButton.icon(
                  onPressed: _isGenerating ? null : _suggest,
                  icon: _isGenerating
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.kitchen_outlined),
                  label: Text(l10n.recipePantryButton),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
