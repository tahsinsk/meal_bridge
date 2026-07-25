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
