/// ISO-8601 week number for the week that starts on [monday] (must be a
/// Monday — the first day of an ISO week). Shared by anything that displays
/// or keys data by week, so the calculation only lives in one place.
int isoWeekNumberForMonday(DateTime monday) {
  final thursday = monday.add(const Duration(days: 3));
  final year = thursday.year;
  final jan4 = DateTime(year, 1, 4);
  final mondayOfWeek1 = jan4.subtract(Duration(days: jan4.weekday - 1));
  return (monday.difference(mondayOfWeek1).inDays ~/ 7) + 1;
}

/// Monday of the week [offset] weeks from the current week (0 = this week).
DateTime mondayForWeekOffset(int offset) {
  final now = DateTime.now();
  final monday = now.subtract(Duration(days: now.weekday - 1));
  return monday.add(Duration(days: 7 * offset));
}

/// ISO week key ("2026-W30") for the week [offset] weeks from the current
/// week (0 = this week). Single source of truth for this format — used for
/// meal-plan storage keys and to scope Weekly Plan shopping-list exclusions
/// to the specific week being viewed.
String isoWeekKeyForOffset(int offset) {
  final monday = mondayForWeekOffset(offset);
  final weekNum = isoWeekNumberForMonday(monday);
  final year = monday.add(const Duration(days: 3)).year;
  return '$year-W${weekNum.toString().padLeft(2, '0')}';
}
