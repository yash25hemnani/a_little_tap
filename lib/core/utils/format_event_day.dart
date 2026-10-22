import 'package:intl/intl.dart';

// "Sat, Oct 25 • today" / "• tomorrow" / "• in 5 days"
String formatEventDay(DateTime day) {
  // UTC midnight, same as event dates, so the difference is whole days
  final now = DateTime.now();
  final today = DateTime.utc(now.year, now.month, now.day);
  final days = day.difference(today).inDays;

  final label = switch (days) {
    0 => 'today',
    1 => 'tomorrow',
    _ => 'in $days days',
  };

  return '${DateFormat('EEE, MMM d').format(day)} • $label';
}
