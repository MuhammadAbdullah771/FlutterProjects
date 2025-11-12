import '../../data/models/task.dart';

class RecurrenceUtils {
  static const weekdayLabels = <int, String>{
    DateTime.monday: 'Mon',
    DateTime.tuesday: 'Tue',
    DateTime.wednesday: 'Wed',
    DateTime.thursday: 'Thu',
    DateTime.friday: 'Fri',
    DateTime.saturday: 'Sat',
    DateTime.sunday: 'Sun',
  };

  static int encodeWeekdays(List<int> weekdays) {
    var value = 0;
    for (final day in weekdays) {
      value |= 1 << (day - 1);
    }
    return value;
  }

  static List<int> decodeWeekdays(int bitmask) {
    final days = <int>[];
    for (var i = 0; i < 7; i++) {
      if ((bitmask & (1 << i)) != 0) {
        days.add(i + 1);
      }
    }
    return days;
  }

  static DateTime? nextOccurrence(Task task, {DateTime? from}) {
    if (!task.isRepeating || task.dueDate == null) return null;
    final base = from ?? task.dueDate!;
    switch (task.repeatType) {
      case RepeatType.none:
        return null;
      case RepeatType.daily:
        final interval = task.repeatInterval.clamp(1, 365);
        return base.add(Duration(days: interval));
      case RepeatType.weekly:
        final weekdays = task.repeatWeekdays.isEmpty
            ? [base.weekday]
            : List<int>.from(task.repeatWeekdays)..sort();
        return _nextWeeklyDate(base, weekdays, task.repeatInterval);
      case RepeatType.interval:
        final interval = task.repeatInterval.clamp(1, 365);
        return base.add(Duration(days: interval));
    }
  }

  static DateTime _nextWeeklyDate(
    DateTime from,
    List<int> weekdays,
    int intervalWeeks,
  ) {
    var current = from.add(const Duration(days: 1));
    final interval = intervalWeeks.clamp(1, 52);
    while (true) {
      if (weekdays.contains(current.weekday)) {
        if (current.isAfter(from)) return current;
      }
      current = current.add(const Duration(days: 1));
      if (current.weekday == DateTime.monday) {
        current = current.add(Duration(days: 7 * (interval - 1)));
      }
    }
  }

  static List<DateTime> previewOccurrences(Task task, {int take = 5}) {
    final occurrences = <DateTime>[];
    var current = task.dueDate;
    if (current == null) return occurrences;
    for (var i = 0; i < take; i++) {
      current = nextOccurrence(task, from: current);
      if (current == null) break;
      if (task.repeatEndDate != null && current.isAfter(task.repeatEndDate!)) {
        break;
      }
      occurrences.add(current);
    }
    return occurrences;
  }
}
