import 'package:flutter/material.dart';

/// Displays a recipe photo when [imagePath] is a reachable URL, otherwise
/// shows an intentional gradient placeholder so recipes never look "broken".
class RecipeImage extends StatelessWidget {
  final String? imagePath;
  final double iconSize;

  const RecipeImage({super.key, this.imagePath, this.iconSize = 40});

  bool get _hasNetworkImage {
    final path = imagePath;
    return path != null &&
        path.isNotEmpty &&
        (path.startsWith('http://') || path.startsWith('https://'));
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasNetworkImage) return _Placeholder(iconSize: iconSize);

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
}

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
          colors: [Color(0xFFEFF6E6), Color(0xFFD7EAC4)],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.restaurant_rounded,
          size: iconSize,
          color: const Color(0xFF7CB342).withValues(alpha: 0.75),
        ),
      ),
    );
  }
}
