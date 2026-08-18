import 'dart:convert';

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

/// A freshly AI-generated recipe draft — ingredients/instructions/calories
/// meant to populate the Add/Edit Recipe form for the user to review and
/// edit, not to be saved as-is.
class GeneratedRecipeDraft {
  final List<Ingredient> ingredients;
  final List<String> instructions;
  final int? estimatedTotalCalories;

  const GeneratedRecipeDraft({
    required this.ingredients,
    required this.instructions,
    this.estimatedTotalCalories,
  });
}

/// Generates a draft recipe (ingredients + instructions + an estimated
/// total calorie count) from just a dish name, via the Gemini API's
/// structured-output mode (responseSchema), so the model is constrained to
/// return our exact unit/category vocabulary instead of free text we'd
/// have to guess-parse.
class RecipeAiService {
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models';

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
  }) async {
    try {
      return await _generateWithModel(AiConfig.model, recipeName, servings);
    } on GeminiRateLimitException {
      // Retrying a different model won't help if we're rate limited — that
      // rethrows so the UI can show the specific "AI is busy" message.
      rethrow;
    } catch (_) {
      return await _generateWithModel(AiConfig.fallbackModel, recipeName, servings);
    }
  }

  Future<GeneratedRecipeDraft> _generateWithModel(
    String model,
    String recipeName,
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
                {'parts': [{'text': _buildPrompt(recipeName, servings)}]},
              ],
              'generationConfig': {
                'responseMimeType': 'application/json',
                'responseSchema': _responseSchema,
              },
            }),
          )
          .timeout(const Duration(seconds: 30));
    } catch (e) {
      throw GeminiException('Request failed: $e');
    }

    if (response.statusCode == 429) {
      throw GeminiRateLimitException();
    }
    if (response.statusCode != 200) {
      throw GeminiException('Unexpected status ${response.statusCode}: ${response.body}');
    }

    return _parseResponse(response.body);
  }

  String _buildPrompt(String recipeName, int servings) {
    return 'Generate a realistic, practical home-cook recipe for "$recipeName", '
        'scaled for $servings servings. Provide sensible ingredient amounts '
        'and units, clear step-by-step instructions in order, and an '
        'estimated TOTAL calorie count for the whole recipe (all servings '
        'combined, not per serving). For each ingredient, pick the closest '
        'matching category from the allowed list. Respond only with the '
        'requested JSON.';
  }

  static const Map<String, dynamic> _responseSchema = {
    'type': 'OBJECT',
    'properties': {
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
        'items': {'type': 'STRING'},
      },
      'estimatedTotalCalories': {'type': 'INTEGER'},
    },
    'required': ['ingredients', 'instructions', 'estimatedTotalCalories'],
  };

  GeneratedRecipeDraft _parseResponse(String body) {
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

      final ingredientsJson = parsed['ingredients'] as List<dynamic>? ?? const [];
      final ingredients = ingredientsJson
          .map((raw) {
            final map = raw as Map<String, dynamic>;
            final name = (map['name'] as String?)?.trim() ?? '';
            final amount = (map['amount'] as num?)?.toDouble() ?? 0;
            final unit = map['unit'] as String?;
            final category = map['category'] as String?;
            return Ingredient(
              name: name,
              amount: amount > 0 ? amount : 1,
              unit: _units.contains(unit) ? unit! : 'g',
              categoryOverride: _categories.contains(category) ? category : null,
            );
          })
          .where((i) => i.name.isNotEmpty)
          .toList();

      final instructionsJson = parsed['instructions'] as List<dynamic>? ?? const [];
      final instructions = instructionsJson
          .map((s) => s.toString().trim())
          .where((s) => s.isNotEmpty)
          .toList();

      if (ingredients.isEmpty || instructions.isEmpty) {
        throw GeminiException('Incomplete recipe data (missing ingredients or instructions)');
      }

      final caloriesRaw = parsed['estimatedTotalCalories'];
      final calories = caloriesRaw is num ? caloriesRaw.toInt() : null;

      return GeneratedRecipeDraft(
        ingredients: ingredients,
        instructions: instructions,
        estimatedTotalCalories: (calories != null && calories > 0) ? calories : null,
      );
    } on GeminiException {
      rethrow;
    } catch (e) {
      throw GeminiException('Malformed response: $e');
    }
  }
}
