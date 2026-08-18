import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

/// Displays a recipe photo when [imagePath] is a reachable URL or a local
/// file path (e.g. a photo picked via the camera/gallery and copied into
/// app storage), otherwise shows an intentional gradient placeholder so
/// recipes never look "broken".
class RecipeImage extends StatelessWidget {
  final String? imagePath;
  final double iconSize;

  const RecipeImage({super.key, this.imagePath, this.iconSize = 40});

  bool get _isNetworkImage {
    final path = imagePath;
    return path != null &&
        path.isNotEmpty &&
        (path.startsWith('http://') || path.startsWith('https://'));
  }

  bool get _isLocalFileImage {
    final path = imagePath;
    return path != null && path.isNotEmpty && !_isNetworkImage;
  }

  @override
  Widget build(BuildContext context) {
    if (_isNetworkImage) {
      return Image.network(
        imagePath!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) => _Placeholder(iconSize: iconSize),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return _Placeholder(iconSize: iconSize);
        },
      );
    }

    if (_isLocalFileImage) {
      final path = imagePath!;
      // Recipes saved before this fix stored a full absolute path (which
      // embeds the app's sandbox container id on iOS/its internal-storage
      // path on Android) — that breaks the moment the container changes
      // across a reinstall/rebuild, even though the underlying file is
      // still there. New saves store a path relative to the documents
      // directory instead and get resolved fresh here every time, so they
      // stay valid across reinstalls. Absolute legacy paths are used as-is
      // for backward compatibility with recipes saved before this fix.
      if (path.startsWith('/')) {
        return _LocalFileImage(file: File(path), iconSize: iconSize);
      }
      return FutureBuilder<Directory>(
        future: getApplicationDocumentsDirectory(),
        builder: (context, snapshot) {
          final docsDir = snapshot.data;
          if (docsDir == null) return _Placeholder(iconSize: iconSize);
          return _LocalFileImage(file: File('${docsDir.path}/$path'), iconSize: iconSize);
        },
      );
    }

    return _Placeholder(iconSize: iconSize);
  }
}

class _LocalFileImage extends StatelessWidget {
  final File file;
  final double iconSize;

  const _LocalFileImage({required this.file, required this.iconSize});

  @override
  Widget build(BuildContext context) {
    return Image.file(
      file,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, stackTrace) => _Placeholder(iconSize: iconSize),
    );
  }
}

// The single "no photo" look shared by every recipe placeholder — recipe
// grid cards, list rows, and the Recipe Detail hero image all render this
// exact same crossed fork-and-spoon-on-gradient treatment, centralized
// here rather than each screen styling its own empty state.
class _Placeholder extends StatelessWidget {
  final double iconSize;

  const _Placeholder({required this.iconSize});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF3F8EC), Color(0xFFA9D6AE)],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.restaurant_menu_outlined,
          size: iconSize,
          color: const Color(0xFF4C7A3F).withValues(alpha: 0.8),
        ),
      ),
    );
  }
}
