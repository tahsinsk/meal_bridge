import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Copies [sourcePath] into the app's persistent recipe_images folder and
/// returns a path relative to the documents directory (not absolute — see
/// RecipeImage for why: an absolute path embeds the app's sandbox container
/// id, which can change across reinstalls/rebuilds and silently orphan the
/// saved photo).
Future<String> saveRecipeImageToAppStorage(String sourcePath) async {
  final docsDir = await getApplicationDocumentsDirectory();
  final imagesDir = Directory('${docsDir.path}/recipe_images');
  if (!await imagesDir.exists()) {
    await imagesDir.create(recursive: true);
  }
  final dotIndex = sourcePath.lastIndexOf('.');
  final ext = dotIndex == -1 ? '.jpg' : sourcePath.substring(dotIndex);
  final fileName = 'recipe_${DateTime.now().millisecondsSinceEpoch}$ext';
  await File(sourcePath).copy('${imagesDir.path}/$fileName');
  return 'recipe_images/$fileName';
}
