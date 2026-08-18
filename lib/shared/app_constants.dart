import 'package:flutter/material.dart';

/// Single source of truth for app metadata shown in the UI (Settings), kept
/// separate from pubspec.yaml's build version so both can't drift apart.
class AppInfo {
  static const String version = '0.5.0';
}

/// Single source of truth for the MealBridge brand palette. All screens
/// should reference these instead of introducing their own green shades (or
/// unrelated hues) so the app reads as one consistent palette.
class AppColors {
  static const Color primaryDark = Color(0xFF2E7D32);
  // Accent green for large filled CTA buttons (Add Ingredient/Instruction,
  // Save Recipe, Add Item, filter sheet actions), the bottom nav bar's
  // selected-tab capsule, and the Shopping List mode toggle's active
  // segment — primaryDark stays reserved for the logo wordmark and small
  // text/icon accents.
  //
  // Requested as the bright mint 0xFF79E4A5, but white text/icons on that
  // tone measure ~1.6:1 contrast (well under WCAG AA's 3:1 floor even for
  // large text). Scaled down uniformly (same R:G:B ratio, so identical
  // hue/saturation, just darker) to 0xFF437D5B, ~4.86:1 for white text —
  // passes AA for normal-size text.
  static const Color primary = Color(0xFF437D5B);
  static const Color accentMid = Color(0xFF66BB6A);
  static const Color surfaceSoft = Color(0xFFE8F3E9);
  // Nudged a small, deliberate step darker/warmer from 0xFFF5F3EA, which
  // was reading as too light/washed out.
  static const Color creamBackground = Color(0xFFEEEADD);
}

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

  /// Typed text inside search bars — a touch lighter/more muted than the
  /// app's default text weight, so search fields feel calmer against the
  /// soft filled surface instead of shouting for attention.
  static const TextStyle searchInput = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: Color(0xFF5A5F58),
  );

  static const TextStyle searchHint = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: Color(0xFF9E9E9E),
  );
}
