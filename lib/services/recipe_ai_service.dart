import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../models/ingredient.dart';
import '../shared/ai_config.dart';

/// Thrown when Gemini responds with HTTP 429 (rate limited), so the UI can
/// show a friendlier "try again in a moment" message instead of the generic
/// failure one.
class GeminiRateLimitException implements Exception {}

/// Any other failure — network error, non-200/429 status, missing/malformed
/// response content. Carries [message] for logging; the UI only ever shows
/// a generic localized string for this, never the raw message.
class GeminiException implements Exception {
  final String message;
  GeminiException(this.message);

  @override
  String toString() => 'GeminiException: $message';
}

/// A freshly AI-generated recipe draft — meant to populate the Add/Edit
/// Recipe form for the user to review and edit, not to be saved as-is.
class GeneratedRecipeDraft {
  // Only ever populated by generateRecipeFromImage (extracted from the
  // photo) — text-based generation already has the name typed by the user,
  // so it doesn't ask the model for one.
  final String? name;
  final List<Ingredient> ingredients;
  final List<String> instructions;
  // Same length/order as [instructions]; a null entry means no estimate for
  // that step.
  final List<int?> instructionDurationsMinutes;
  final int? estimatedTotalCalories;
  final int? totalTimeMinutes;

  const GeneratedRecipeDraft({
    this.name,
    required this.ingredients,
    required this.instructions,
    this.instructionDurationsMinutes = const [],
    this.estimatedTotalCalories,
    this.totalTimeMinutes,
  });
}

/// Generates a draft recipe (ingredients + instructions + estimated total
/// calories/time) either from just a dish name or from a photo of a written
/// recipe, via the Gemini API's structured-output mode (responseSchema), so
/// the model is constrained to return our exact unit/category vocabulary
/// instead of free text we'd have to guess-parse.
class RecipeAiService {
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models';

  // A per-serving ceiling used to sanity-check the model's total-calorie
  // estimate — real home-cook recipes essentially never exceed this per
  // serving, so a number above it almost always means the model summed
  // wrong (e.g. answered per-ingredient or misread "total" as "per
  // serving"). We'd rather show nothing than a misleading number.
  static const int _maxReasonableCaloriesPerServing = 2500;

  // Kept in sync with the unit/category option lists shown elsewhere in the
  // recipe form — the response schema's enums below reference these so
  // Gemini can only ever return one of our own known values.
  static const List<String> _units = [
    'can', 'cup', 'g', 'kg', 'l', 'ml', 'pack', 'pcs', 'slice', 'tbsp', 'tsp',
  ];
  static const List<String> _categories = [
    'Vegetables', 'Fruit', 'Meat', 'Dairy', 'Bakery',
    'Pantry', 'Frozen', 'Drinks', 'Snacks', 'Spices', 'Other',
  ];

  Future<GeneratedRecipeDraft> generateRecipe({
    required String recipeName,
    required int servings,
  }) {
    final parts = [
      {'text': '${_taskPreamble(recipeName, servings)}\n\n${_sharedInstructions(servings)}'},
    ];
    return _generateWithFallback(parts, servings);
  }

  Future<GeneratedRecipeDraft> generateRecipeFromImage({
    required Uint8List imageBytes,
    required String mimeType,
    required int servings,
  }) {
    final parts = [
      {
        'inlineData': {'mimeType': mimeType, 'data': base64Encode(imageBytes)},
      },
      {'text': '${_imageTaskPreamble(servings)}\n\n${_sharedInstructions(servings)}'},
    ];
    return _generateWithFallback(parts, servings);
  }

  Future<GeneratedRecipeDraft> _generateWithFallback(
    List<Map<String, dynamic>> parts,
    int servings,
  ) async {
    try {
      return await _generateWithModel(AiConfig.model, parts, servings);
    } on GeminiRateLimitException {
      // Retrying a different model won't help if we're rate limited — that
      // rethrows so the UI can show the specific "AI is busy" message.
      rethrow;
    } catch (_) {
      return await _generateWithModel(AiConfig.fallbackModel, parts, servings);
    }
  }

  Future<GeneratedRecipeDraft> _generateWithModel(
    String model,
    List<Map<String, dynamic>> parts,
    int servings,
  ) async {
    final uri = Uri.parse('$_baseUrl/$model:generateContent?key=${AiConfig.geminiApiKey}');

    http.Response response;
    try {
      response = await http
          .post(
            uri,
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({
              'contents': [
                {'parts': parts},
              ],
              'generationConfig': {
                'responseMimeType': 'application/json',
                'responseSchema': _responseSchema,
              },
            }),
          )
          .timeout(const Duration(seconds: 45));
    } catch (e) {
      throw GeminiException('Request failed: $e');
    }

    if (response.statusCode == 429) {
      throw GeminiRateLimitException();
    }
    if (response.statusCode != 200) {
      throw GeminiException('Unexpected status ${response.statusCode}: ${response.body}');
    }

    return _parseResponse(response.body, servings);
  }

  String _taskPreamble(String recipeName, int servings) {
    return 'Generate a realistic, practical home-cook recipe for '
        '"$recipeName", scaled for $servings servings.';
  }

  String _imageTaskPreamble(int servings) {
    return 'The attached photo shows a recipe — e.g. a cookbook page, a '
        'printed recipe card, or a handwritten note. Read and transcribe it '
        'into a structured recipe, scaled for $servings servings if the '
        "photo's own serving count differs. First extract the recipe's NAME "
        '(title) exactly as written, or your best short descriptive title '
        "if none is visible. If the photo is blurry, unreadable, or doesn't "
        'show a recipe at all, do your best with whatever IS legible rather '
        'than inventing content — if truly nothing usable is visible, '
        'respond with empty ingredients and instructions arrays instead of '
        'guessing.';
  }

  String _sharedInstructions(int servings) {
    return 'LANGUAGE: Respond in the SAME language as the recipe name/text '
        '— if Turkish, respond in Turkish; if Dutch, respond in Dutch; if '
        'English, respond in English. Match the input language exactly.\n\n'
        'INGREDIENTS: Provide sensible ingredient amounts and units. For '
        'each ingredient, pick the closest matching category from the '
        'allowed list.\n\n'
        'INSTRUCTIONS: Clear step-by-step instructions in order. For each '
        'step, if it has a meaningful duration, estimate it in minutes '
        '(e.g. "simmer for 10 minutes" -> 10); omit the duration for steps '
        'with no real time cost (e.g. "serve and enjoy").\n\n'
        'TOTAL TIME: Estimate the total time for the whole recipe in '
        'minutes, as a holistic real-world estimate — NOT just the sum of '
        'the step durations, since steps often overlap in practice (e.g. '
        'chopping vegetables while water boils).\n\n'
        'CALORIES: Estimate the TOTAL calorie count for the ENTIRE recipe '
        'as written — summing every ingredient, for ALL $servings servings '
        'combined. This is NOT a per-serving number. Sanity check before '
        'answering: a simple 2-serving pasta dish is typically 600-1000 '
        'kcal TOTAL, not per ingredient and not per serving multiplied '
        'again — if your number implies more than roughly '
        '$_maxReasonableCaloriesPerServing kcal per serving, you have '
        'made an arithmetic mistake and must recompute it.\n\n'
        'Respond only with the requested JSON.';
  }

  static const Map<String, dynamic> _responseSchema = {
    'type': 'OBJECT',
    'properties': {
      'name': {'type': 'STRING'},
      'ingredients': {
        'type': 'ARRAY',
        'items': {
          'type': 'OBJECT',
          'properties': {
            'name': {'type': 'STRING'},
            'amount': {'type': 'NUMBER'},
            'unit': {'type': 'STRING', 'enum': _units},
            'category': {'type': 'STRING', 'enum': _categories},
          },
          'required': ['name', 'amount', 'unit', 'category'],
        },
      },
      'instructions': {
        'type': 'ARRAY',
        'items': {
          'type': 'OBJECT',
          'properties': {
            'text': {'type': 'STRING'},
            'durationMinutes': {'type': 'INTEGER'},
          },
          'required': ['text'],
        },
      },
      'totalTimeMinutes': {'type': 'INTEGER'},
      'estimatedTotalCalories': {'type': 'INTEGER'},
    },
    'required': ['ingredients', 'instructions', 'estimatedTotalCalories'],
  };

  GeneratedRecipeDraft _parseResponse(String body, int servings) {
    try {
      final decoded = jsonDecode(body) as Map<String, dynamic>;
      final candidates = decoded['candidates'] as List<dynamic>?;
      if (candidates == null || candidates.isEmpty) {
        throw GeminiException('No candidates in response');
      }
      final content = candidates.first['content'] as Map<String, dynamic>?;
      final parts = content?['parts'] as List<dynamic>?;
      final text = (parts != null && parts.isNotEmpty) ? parts.first['text'] as String? : null;
      if (text == null || text.trim().isEmpty) {
        throw GeminiException('Empty response text');
      }

      final parsed = jsonDecode(text) as Map<String, dynamic>;

      final nameRaw = parsed['name'];
      final name = (nameRaw is String && nameRaw.trim().isNotEmpty) ? nameRaw.trim() : null;

      final ingredientsJson = parsed['ingredients'] as List<dynamic>? ?? const [];
      final ingredients = ingredientsJson
          .map((raw) {
            final map = raw as Map<String, dynamic>;
            final ingredientName = (map['name'] as String?)?.trim() ?? '';
            final amount = (map['amount'] as num?)?.toDouble() ?? 0;
            final unit = map['unit'] as String?;
            final category = map['category'] as String?;
            return Ingredient(
              name: ingredientName,
              amount: amount > 0 ? amount : 1,
              unit: _units.contains(unit) ? unit! : 'g',
              categoryOverride: _categories.contains(category) ? category : null,
            );
          })
          .where((i) => i.name.isNotEmpty)
          .toList();

      // Instructions arrive as {text, durationMinutes?} objects (not a flat
      // string array) specifically so each step's duration stays paired
      // with its own text — two separately-indexed parallel arrays would
      // risk the model miscounting and silently misaligning them.
      final instructionsJson = parsed['instructions'] as List<dynamic>? ?? const [];
      final instructions = <String>[];
      final instructionDurations = <int?>[];
      for (final raw in instructionsJson) {
        final map = raw as Map<String, dynamic>;
        final stepText = (map['text'] as String?)?.trim() ?? '';
        if (stepText.isEmpty) continue;
        instructions.add(stepText);
        final duration = map['durationMinutes'];
        instructionDurations.add((duration is num && duration > 0) ? duration.toInt() : null);
      }

      if (ingredients.isEmpty || instructions.isEmpty) {
        throw GeminiException('Incomplete recipe data (missing ingredients or instructions)');
      }

      final caloriesRaw = parsed['estimatedTotalCalories'];
      var calories = (caloriesRaw is num && caloriesRaw > 0) ? caloriesRaw.toInt() : null;
      // Sanity check rather than trust blindly: a wildly high per-serving
      // implication means the model got the total-vs-per-serving math
      // wrong. Left blank (not retried) so a bad number never reaches the
      // form — the user can always fill it in manually, same as any recipe
      // without an AI estimate.
      if (calories != null && servings > 0 && calories / servings > _maxReasonableCaloriesPerServing) {
        calories = null;
      }

      final totalTimeRaw = parsed['totalTimeMinutes'];
      final totalTimeMinutes = (totalTimeRaw is num && totalTimeRaw > 0) ? totalTimeRaw.toInt() : null;

      return GeneratedRecipeDraft(
        name: name,
        ingredients: ingredients,
        instructions: instructions,
        instructionDurationsMinutes: instructionDurations,
        estimatedTotalCalories: calories,
        totalTimeMinutes: totalTimeMinutes,
      );
    } on GeminiException {
      rethrow;
    } catch (e) {
      throw GeminiException('Malformed response: $e');
    }
  }
}
