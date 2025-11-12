import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager_by_abdullah/core/utils/recurrence_utils.dart';
import 'package:task_manager_by_abdullah/data/models/task.dart';

void main() {
  test('nextOccurrence daily interval', () {
    final task = Task(
      title: 'Daily task',
      dueDate: DateTime(2024, 10, 1, 9),
      repeatType: RepeatType.daily,
      repeatInterval: 2,
    );
    final next = RecurrenceUtils.nextOccurrence(task);
    expect(next, DateTime(2024, 10, 3, 9));
  });

  test('nextOccurrence weekly with weekdays', () {
    final task = Task(
      title: 'Weekly task',
      dueDate: DateTime(2024, 10, 1),
      repeatType: RepeatType.weekly,
      repeatWeekdays: [DateTime.thursday, DateTime.friday],
    );
    final next = RecurrenceUtils.nextOccurrence(task);
    expect(next, DateTime(2024, 10, 3));
  });
}
