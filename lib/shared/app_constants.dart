import 'package:flutter/material.dart';

class AppRadius {
  static const double small = 12;
  static const double medium = 20;
  static const double card = 24;
  static const double large = 28;
  static const double pill = 999;
}

class AppSpacing {
  static const double screenPadding = 18;
}

/// Reusable text styles for the large in-content page headings (e.g. "Your
/// recipes") and their secondary subtitle line, kept consistent across tabs.
class AppTextStyles {
  static const TextStyle pageHeading = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    height: 1.15,
    color: Color(0xFF1A1C19),
  );

  static const TextStyle pageSubtitle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: Color(0xFF757575),
  );
}
