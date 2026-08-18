import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/recipe.dart';
import '../../../services/recipe_ai_service.dart';
import '../../../shared/app_constants.dart';
import '../../../shared/local_image_storage.dart';
import 'recipe_form_screen.dart';

enum _ScanPhase { picking, loading, error }

/// Scan-a-photo entry point: shows an image picker first, then the picked
/// photo with an animated loading overlay while Gemini reads it, then hands
/// off to the full Add Recipe form pre-filled with the extracted draft
/// (including the scanned photo itself as the recipe's image). Nothing here
/// is ever auto-saved — the user still reviews and taps Save on the form.
class ScanRecipePhotoScreen extends StatefulWidget {
  const ScanRecipePhotoScreen({super.key});

  @override
  State<ScanRecipePhotoScreen> createState() => _ScanRecipePhotoScreenState();
}

class _ScanRecipePhotoScreenState extends State<ScanRecipePhotoScreen> {
  final _imagePicker = ImagePicker();
  final _recipeAiService = RecipeAiService();

  _ScanPhase _phase = _ScanPhase.picking;
  XFile? _pickedImage;
  String? _errorText;

  String _guessImageMimeType(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.heic') || lower.endsWith('.heif')) return 'image/heic';
    return 'image/jpeg';
  }

  Future<void> _pickAndScan(ImageSource source) async {
    final l10n = AppLocalizations.of(context)!;
    XFile? picked;
    try {
      picked = await _imagePicker.pickImage(source: source, imageQuality: 85);
    } on PlatformException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.recipeFormImagePermissionDenied)),
      );
      return;
    }
    if (picked == null) return;

    setState(() {
      _pickedImage = picked;
      _phase = _ScanPhase.loading;
      _errorText = null;
    });

    try {
      final bytes = await picked.readAsBytes();
      final mimeType = picked.mimeType ?? _guessImageMimeType(picked.path);
      final results = await Future.wait([
        _recipeAiService.generateRecipeFromImage(imageBytes: bytes, mimeType: mimeType, servings: 2),
        saveRecipeImageToAppStorage(picked.path),
      ]);
      if (!mounted) return;
      final draft = results[0] as GeneratedRecipeDraft;
      final savedImagePath = results[1] as String;

      final draftRecipe = Recipe(
        id: 'draft',
        name: draft.name ?? '',
        servings: 2,
        category: 'Dinner',
        ingredients: draft.ingredients,
        instructions: draft.instructions,
        calories: draft.estimatedTotalCalories,
        imagePath: savedImagePath,
        instructionDurationsMinutes: draft.instructionDurationsMinutes,
        totalTimeMinutes: draft.totalTimeMinutes,
      );

      final saved = await Navigator.of(context).push<Recipe>(
        MaterialPageRoute(builder: (context) => RecipeFormScreen(draft: draftRecipe)),
      );
      if (!mounted) return;
      Navigator.of(context).pop(saved);
    } on GeminiRateLimitException {
      if (!mounted) return;
      setState(() {
        _phase = _ScanPhase.error;
        _errorText = l10n.recipeFormAiErrorRateLimit;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _phase = _ScanPhase.error;
        _errorText = l10n.recipeFormAiScanErrorGeneric;
      });
    }
  }

  void _reset() {
    setState(() {
      _phase = _ScanPhase.picking;
      _pickedImage = null;
      _errorText = null;
    });
  }

  Future<void> _fallbackToManual() async {
    final recipe = await Navigator.of(context).push<Recipe>(
      MaterialPageRoute(builder: (context) => const RecipeFormScreen()),
    );
    if (!mounted) return;
    Navigator.of(context).pop(recipe);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.recipeFormScanPhoto)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _phase == _ScanPhase.picking ? _buildPicker(l10n) : _buildPreview(l10n),
        ),
      ),
    );
  }

  Widget _buildPicker(AppLocalizations l10n) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.document_scanner_outlined, size: 56, color: AppColors.primary),
        const SizedBox(height: 16),
        Text(l10n.recipeScanPrompt, style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => _pickAndScan(ImageSource.camera),
            icon: const Icon(Icons.photo_camera_outlined),
            label: Text(l10n.recipeFormTakePhoto),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _pickAndScan(ImageSource.gallery),
            icon: const Icon(Icons.photo_library_outlined),
            label: Text(l10n.recipeFormChooseFromGallery),
          ),
        ),
      ],
    );
  }

  Widget _buildPreview(AppLocalizations l10n) {
    return Column(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (_pickedImage != null) Image.file(File(_pickedImage!.path), fit: BoxFit.cover),
                if (_phase == _ScanPhase.loading) _ScanLoadingOverlay(message: l10n.recipeScanLoadingMessage),
              ],
            ),
          ),
        ),
        if (_phase == _ScanPhase.error) ...[
          const SizedBox(height: 20),
          Text(
            _errorText ?? '',
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _reset,
                  child: Text(l10n.recipeScanErrorRetry),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _fallbackToManual,
                  child: Text(l10n.recipeFormFillManually),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// A dark scrim + a sweeping gradient highlight (a simple shimmer
/// approximation built from core Flutter animation primitives, no external
/// package) over the photo, paired with a spinner and status text, shown
/// while the vision-based AI call is in flight.
class _ScanLoadingOverlay extends StatefulWidget {
  final String message;

  const _ScanLoadingOverlay({required this.message});

  @override
  State<_ScanLoadingOverlay> createState() => _ScanLoadingOverlayState();
}

class _ScanLoadingOverlayState extends State<_ScanLoadingOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(color: Colors.black.withValues(alpha: 0.45)),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Align(
                alignment: Alignment(-1.5 + 3.0 * _controller.value, 0),
                child: FractionallySizedBox(
                  widthFactor: 0.5,
                  heightFactor: 1,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.white.withValues(alpha: 0),
                          Colors.white.withValues(alpha: 0.35),
                          Colors.white.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.message,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
