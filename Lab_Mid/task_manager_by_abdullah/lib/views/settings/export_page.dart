import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utils/date_utils.dart';
import '../../data/models/task.dart';
import '../../viewmodels/task_viewmodel.dart';

class ExportPage extends StatefulWidget {
  const ExportPage({super.key});

  @override
  State<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  DateTimeRange? _range;
  bool _includeCompleted = true;
  final Map<int, bool> _selections = {};

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365)),
      initialDateRange: _range,
    );
    if (picked != null) setState(() => _range = picked);
  }

  @override
  Widget build(BuildContext context) {
    final taskVm = context.watch<TaskViewModel>();
    final allTasks = <Task>[];
    final seen = <int>{};

    void addTasks(List<Task> tasks) {
      for (final task in tasks) {
        final key = task.id ?? task.hashCode;
        if (seen.add(key)) {
          allTasks.add(task);
        }
      }
    }

    addTasks(taskVm.pendingTasks);
    if (_includeCompleted) addTasks(taskVm.completedTasks);

    final filteredTasks = allTasks.where((task) {
      if (_range == null) return true;
      final dueDate = task.dueDate;
      if (dueDate == null) return false;
      return dueDate
              .isAfter(_range!.start.subtract(const Duration(days: 1))) &&
          dueDate.isBefore(_range!.end.add(const Duration(days: 1)));
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Export & Share')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.date_range),
            title: const Text('Date range'),
            subtitle: Text(
              _range == null
                  ? 'All dates'
                  : '${DateUtilsHelper.shortDate.format(_range!.start)} → ${DateUtilsHelper.shortDate.format(_range!.end)}',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () => setState(() => _range = null),
            ),
            onTap: _pickRange,
          ),
          SwitchListTile(
            value: _includeCompleted,
            onChanged: (value) => setState(() => _includeCompleted = value),
            title: const Text('Include completed tasks'),
          ),
          const SizedBox(height: 12),
          if (filteredTasks.isEmpty)
            const Text('No tasks match the current filters.'),
          if (filteredTasks.isNotEmpty)
            ...filteredTasks.map((task) {
              _selections.putIfAbsent(task.id ?? task.hashCode, () => true);
              return CheckboxListTile(
                value: _selections[task.id ?? task.hashCode],
                onChanged: (value) => setState(
                  () => _selections[task.id ?? task.hashCode] = value ?? false,
                ),
                title: Text(task.title),
                subtitle: Text(task.readableDueDate),
              );
            }),
          const SizedBox(height: 24),
          FilledButton.icon(
            icon: const Icon(Icons.table_view),
            label: const Text('Export CSV'),
            onPressed: filteredTasks.isEmpty
                ? null
                : () async {
                    final selected = filteredTasks
                        .where((task) =>
                            _selections[task.id ?? task.hashCode] ?? false)
                        .toList();
                    if (selected.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Select at least one task')),
                      );
                      return;
                    }
                    await taskVm.exportTasksToCsv(tasks: selected);
                  },
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Export PDF'),
            onPressed: filteredTasks.isEmpty
                ? null
                : () async {
                    final selected = filteredTasks
                        .where((task) =>
                            _selections[task.id ?? task.hashCode] ?? false)
                        .toList();
                    if (selected.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Select at least one task')),
                      );
                      return;
                    }
                    await taskVm.exportTasksToPdf(selected);
                  },
          ),
        ],
      ),
    );
  }
}
