/// Normalizes a free-text ingredient name for matching/merging: trims,
/// lowercases, and collapses runs of internal whitespace to a single
/// space. Two names that only differ by incidental spacing or casing
/// (e.g. "Domates" vs "domates " with a trailing space) must resolve to
/// the same key — otherwise an ingredient can be "selected" under one key
/// but generated/merged under a slightly different one and silently
/// vanish from the final list.
String normalizeIngredientName(String name) {
  return name.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}

/// Normalizes a unit for matching/merging: trims, lowercases, and folds
/// interchangeable units onto a shared base (kg/g -> g, l/ml -> ml) so the
/// same substance specified in different-but-equivalent units still keys
/// identically.
String normalizeUnit(String unit) {
  final normalized = unit.trim().toLowerCase();
  if (normalized == 'kg' || normalized == 'g') return 'g';
  if (normalized == 'l' || normalized == 'ml') return 'ml';
  return normalized;
}

/// Stable identity for an ingredient — normalized name+unit. This is the
/// single source of truth for ingredient identity across the app: the
/// shopping-list generator's own merge key, checked/excluded shopping item
/// tracking, and Quick List per-ingredient selection all call this same
/// function so an ingredient can never be "selected" under one key and
/// "generated" under another.
String ingredientKey(String name, String unit) =>
    '${normalizeIngredientName(name)}-${normalizeUnit(unit)}';
