import '../l10n/app_localizations.dart';

/// Maps a persisted day-of-week value ("Monday".."Sunday" — used inside
/// meal plan storage keys and must never change) to its localized display
/// label.
String localizedDayName(AppLocalizations l10n, String day) {
  switch (day) {
    case 'Monday':
      return l10n.dayMonday;
    case 'Tuesday':
      return l10n.dayTuesday;
    case 'Wednesday':
      return l10n.dayWednesday;
    case 'Thursday':
      return l10n.dayThursday;
    case 'Friday':
      return l10n.dayFriday;
    case 'Saturday':
      return l10n.daySaturday;
    case 'Sunday':
      return l10n.daySunday;
    default:
      return day;
  }
}
