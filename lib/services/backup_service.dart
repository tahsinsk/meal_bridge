import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../models/recipe.dart';
import '../services/recipe_storage_service.dart';


class BackupService {
  final RecipeStorageService _storageService = RecipeStorageService();

  Future<void> exportBackup(BuildContext context) async {
    try {
      final recipes = await _storageService.loadRecipes();
      final mealPlan = await _storageService.loadMealPlan();
      final checkedItems = await _storageService.loadCheckedShoppingItems();
      final quickRecipeIds = await _storageService.loadQuickRecipeIds();

      final backup = {
        'version': 1,
        'exportedAt': DateTime.now().toIso8601String(),
        'recipes': recipes.map((r) => r.toJson()).toList(),
        'mealPlan': mealPlan,
        'checkedItems': checkedItems.toList(),
        'quickRecipeIds': quickRecipeIds.toList(),
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(backup);
      final fileName =
          'mealbridge_backup_${DateTime.now().millisecondsSinceEpoch}.json';

      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/$fileName');
      await tempFile.writeAsString(jsonString);

      await Share.shareXFiles(
        [XFile(tempFile.path)],
        subject: 'MealBridge Backup',
        sharePositionOrigin: Rect.fromLTWH(
          0,
          0,
          MediaQuery.of(context).size.width,
          MediaQuery.of(context).size.height / 2,
        ),
      );

      await tempFile.delete();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    }
  }

  Future<bool> importBackup(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) return false;

      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();
      final backup = jsonDecode(jsonString) as Map<String, dynamic>;

      // Version check
      final version = backup['version'] as int? ?? 1;
      if (version > 1) {
        if (!context.mounted) return false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This backup was created with a newer version of MealBridge.'),
          ),
        );
        return false;
      }

      // Onay al
      if (!context.mounted) return false;
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) {
          final exportedAt = backup['exportedAt'] as String?;
          final recipeCount =
              (backup['recipes'] as List<dynamic>?)?.length ?? 0;
          DateTime? exportDate;
          if (exportedAt != null) {
            exportDate = DateTime.tryParse(exportedAt);
          }

          return AlertDialog(
            title: const Text('Import backup?'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('This will restore:'),
                const SizedBox(height: 8),
                Text('• $recipeCount recipe(s)'),
                if (exportDate != null)
                  Text(
                    '• Exported on ${exportDate.day}/${exportDate.month}/${exportDate.year}',
                  ),
                const SizedBox(height: 12),
                const Text(
                  'Your existing custom recipes will be replaced.',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Import'),
              ),
            ],
          );
        },
      );

      if (confirm != true) return false;

      // Verileri kaydet
      final recipesJson = backup['recipes'] as List<dynamic>? ?? [];
      final recipes = recipesJson
          .map((r) => Recipe.fromJson(r as Map<String, dynamic>))
          .toList();
      await _storageService.saveRecipes(recipes);

      final mealPlanJson =
          backup['mealPlan'] as Map<String, dynamic>? ?? {};
      await _storageService.saveMealPlan(
        mealPlanJson.map((k, v) => MapEntry(k, v as String)),
      );

      final checkedItemsList =
          (backup['checkedItems'] as List<dynamic>?)?.cast<String>() ?? [];
      await _storageService.saveCheckedShoppingItems(
        checkedItemsList.toSet(),
      );

      final quickIdsList =
          (backup['quickRecipeIds'] as List<dynamic>?)?.cast<String>() ?? [];
      await _storageService.saveQuickRecipeIds(quickIdsList.toSet());

      if (!context.mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Backup imported successfully!')),
      );

      return true;
    } catch (e) {
      if (!context.mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Import failed: $e')),
      );
      return false;
    }
  }
}