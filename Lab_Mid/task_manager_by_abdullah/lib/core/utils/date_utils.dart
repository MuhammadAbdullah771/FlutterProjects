import 'package:intl/intl.dart';

class DateUtilsHelper {
  static final DateFormat shortDate = DateFormat('EEE, d MMM');
  static final DateFormat shortTime = DateFormat('h:mm a');
  static final DateFormat fullDateTime = DateFormat('EEE, d MMM • h:mm a');

  static DateTime startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static DateTime endOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static String formatDueDate(DateTime? dueDate) {
    if (dueDate == null) return 'No due date';
    final now = DateTime.now();
    if (isSameDay(dueDate, now)) {
      return 'Today • ${shortTime.format(dueDate)}';
    }
    if (isSameDay(dueDate, now.add(const Duration(days: 1)))) {
      return 'Tomorrow • ${shortTime.format(dueDate)}';
    }
    return fullDateTime.format(dueDate);
  }
}
