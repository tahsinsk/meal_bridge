import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/recipe.dart';
import '../../../models/recipe_preference.dart';
import '../../../services/recipe_ai_service.dart';
import '../../../shared/app_constants.dart';
import '../../../shared/widgets/preference_chips.dart';
import 'recipe_form_screen.dart';

/// Lightweight AI-generation entry point: a single prompt for what to cook,
/// then hands off to the full Add Recipe form pre-filled with the draft so
/// the user reviews/edits everything before saving. Nothing here is ever
/// auto-saved — the draft only becomes a real recipe once the user taps
/// Save on the full form.
class AiGenerateRecipeScreen extends StatefulWidget {
  const AiGenerateRecipeScreen({super.key});

  @override
  State<AiGenerateRecipeScreen> createState() => _AiGenerateRecipeScreenState();
}

class _AiGenerateRecipeScreenState extends State<AiGenerateRecipeScreen> {
  final _promptController = TextEditingController();
  final _recipeAiService = RecipeAiService();
  bool _isGenerating = false;
  Set<RecipePreference> _preferences = {};

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final l10n = AppLocalizations.of(context)!;
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.recipeFormGenerateWithAiHint)),
      );
      return;
    }

    setState(() => _isGenerating = true);
    try {
      final draft = await _recipeAiService.generateRecipe(
        recipeName: prompt,
        servings: 2,
        preferences: _preferences,
      );
      if (!mounted) return;
      final draftRecipe = Recipe(
        id: 'draft',
        name: prompt,
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
      appBar: AppBar(title: Text(l10n.recipeFormGenerateWithAi)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              Icon(Icons.auto_awesome_outlined, size: 48, color: AppColors.primary),
              const SizedBox(height: 16),
              Text(
                l10n.recipeAiPromptQuestion,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _promptController,
                decoration: InputDecoration(
                  hintText: l10n.recipeAiPromptHint,
                  border: const OutlineInputBorder(),
                ),
                minLines: 1,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                enabled: !_isGenerating,
                onSubmitted: (_) => _generate(),
              ),
              const SizedBox(height: 16),
              PreferenceChips(
                selected: _preferences,
                onChanged: (next) => setState(() => _preferences = next),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 48,
                child: FilledButton.icon(
                  onPressed: _isGenerating ? null : _generate,
                  icon: _isGenerating
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.auto_awesome),
                  label: Text(l10n.recipeAiPromptButton),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
