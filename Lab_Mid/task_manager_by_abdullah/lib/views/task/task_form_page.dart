import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utils/recurrence_utils.dart';
import '../../data/models/subtask.dart';
import '../../data/models/tag.dart';
import '../../data/models/task.dart';
import '../../viewmodels/task_viewmodel.dart';

class TaskFormPage extends StatefulWidget {
  const TaskFormPage({super.key, this.existingTask});

  final Task? existingTask;

  @override
  State<TaskFormPage> createState() => _TaskFormPageState();
}

class _TaskFormPageState extends State<TaskFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _descriptionCtrl;
  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  TaskPriority _priority = TaskPriority.medium;
  bool _notificationsEnabled = false;
  int _notifyMinutes = 30;
  RepeatType _repeatType = RepeatType.none;
  final List<int> _repeatWeekdays = [];
  final TextEditingController _intervalCtrl = TextEditingController(text: '1');
  DateTime? _repeatEndDate;
  final List<Subtask> _subtasks = [];
  final List<Tag> _selectedTags = [];
  final TextEditingController _tagCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final task = widget.existingTask;
    _titleCtrl = TextEditingController(text: task?.title ?? '');
    _descriptionCtrl = TextEditingController(text: task?.description ?? '');
    _dueDate = task?.dueDate;
    _dueTime = task?.dueDate != null
        ? TimeOfDay.fromDateTime(task!.dueDate!)
        : null;
    _priority = task?.priority ?? TaskPriority.medium;
    _notificationsEnabled = task?.notificationEnabled ?? false;
    _notifyMinutes = task?.notificationMinutesBefore ?? 30;
    _repeatType = task?.repeatType ?? RepeatType.none;
    _repeatWeekdays.addAll(task?.repeatWeekdays ?? []);
    _intervalCtrl.text = (task?.repeatInterval ?? 1).toString();
    _repeatEndDate = task?.repeatEndDate;
    _subtasks.addAll(task?.subtasks ?? []);
    _selectedTags.addAll(task?.tags ?? []);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    _intervalCtrl.dispose();
    _tagCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _pickDueTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _dueTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _dueTime = picked);
    }
  }

  Future<void> _pickRepeatEnd() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _repeatEndDate ?? now.add(const Duration(days: 30)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() => _repeatEndDate = picked);
    }
  }

  DateTime? _composeDueDate() {
    if (_dueDate == null) return null;
    final time = _dueTime ?? const TimeOfDay(hour: 9, minute: 0);
    return DateTime(
      _dueDate!.year,
      _dueDate!.month,
      _dueDate!.day,
      time.hour,
      time.minute,
    );
  }

  Future<void> _submit(TaskViewModel vm) async {
    if (!_formKey.currentState!.validate()) return;

    final dueDate = _composeDueDate();
    
    // Validate notification timing
    if (_notificationsEnabled && dueDate != null) {
      final now = DateTime.now();
      final scheduledTime = dueDate.subtract(Duration(minutes: _notifyMinutes));
      
      if (scheduledTime.isBefore(now)) {
        final shouldContinue = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('⚠️ Notification Time Passed'),
            content: Text(
              'The notification time (${_notifyMinutes} min before due time) has already passed.\n\n'
              'The notification will be sent in 1 minute instead.\n\n'
              'To get notified at the exact time, set the due time further in the future.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Continue Anyway'),
              ),
            ],
          ),
        ) ?? false;
        
        if (!shouldContinue) return;
      }
    }
    
    final repeatInterval = int.tryParse(_intervalCtrl.text) ?? 1;
    final task = Task(
      id: widget.existingTask?.id,
      title: _titleCtrl.text.trim(),
      description: _descriptionCtrl.text.trim().isEmpty
          ? null
          : _descriptionCtrl.text.trim(),
      dueDate: dueDate,
      priority: _priority,
      isCompleted: widget.existingTask?.isCompleted ?? false,
      repeatType: _repeatType,
      repeatInterval: repeatInterval,
      repeatWeekdays: List<int>.from(_repeatWeekdays),
      repeatEndDate: _repeatEndDate,
      notificationEnabled: _notificationsEnabled,
      notificationMinutesBefore: _notifyMinutes,
      subtasks: List<Subtask>.from(_subtasks),
      tags: List<Tag>.from(_selectedTags),
      occurrences: widget.existingTask?.occurrences ?? const [],
      createdAt: widget.existingTask?.createdAt,
    );

    try {
      await vm.saveTask(task);
      
      // Show success message with notification info
      if (mounted) {
        if (_notificationsEnabled && dueDate != null) {
          final now = DateTime.now();
          final scheduledTime = dueDate.subtract(Duration(minutes: _notifyMinutes));
          
          String message;
          if (scheduledTime.isBefore(now)) {
            message = 'Task saved! Notification will fire in 1 minute.';
          } else {
            final difference = scheduledTime.difference(now);
            final hours = difference.inHours;
            final minutes = difference.inMinutes % 60;
            
            if (hours > 0) {
              message = 'Task saved! Notification in $hours hr $minutes min.';
            } else {
              message = 'Task saved! Notification in $minutes minutes.';
            }
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 4),
            ),
          );
        }
        
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to save task: $error',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TaskViewModel>();
    final weekdays = RecurrenceUtils.weekdayLabels.entries.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingTask == null ? 'Create Task' : 'Edit Task'),
        actions: [
          if (widget.existingTask != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Delete task'),
                        content: const Text('Are you sure you want to delete this task?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    ) ??
                    false;
                if (confirm) {
                  await vm.deleteTask(widget.existingTask!);
                  if (mounted) Navigator.of(context).pop();
                }
              },
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          children: [
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Title *'),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Title is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionCtrl,
              decoration: const InputDecoration(labelText: 'Description'),
              minLines: 2,
              maxLines: 5,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: Text(
                      _dueDate != null
                          ? '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'
                          : 'Pick a due date',
                    ),
                    leading: const Icon(Icons.date_range),
                    onTap: _pickDueDate,
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: Text(
                      _dueTime != null ? _dueTime!.format(context) : 'Pick a time',
                    ),
                    leading: const Icon(Icons.access_time),
                    onTap: _pickDueTime,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<TaskPriority>(
              initialValue: _priority,
              decoration: const InputDecoration(labelText: 'Priority'),
              items: TaskPriority.values
                  .map(
                    (priority) => DropdownMenuItem<TaskPriority>(
                      value: priority,
                      child: Text(priority.label),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _priority = value ?? _priority),
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              value: _notificationsEnabled,
              onChanged: (value) => setState(() => _notificationsEnabled = value),
              title: const Text('Notification'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('Remind: '),
                      DropdownButton<int>(
                        value: _notifyMinutes,
                        onChanged: (value) =>
                            setState(() => _notifyMinutes = value ?? _notifyMinutes),
                        items: const [
                          DropdownMenuItem(value: 0, child: Text('At time')),
                          DropdownMenuItem(value: 5, child: Text('5 min before')),
                          DropdownMenuItem(value: 10, child: Text('10 min before')),
                          DropdownMenuItem(value: 15, child: Text('15 min before')),
                          DropdownMenuItem(value: 30, child: Text('30 min before')),
                          DropdownMenuItem(value: 60, child: Text('1 hour before')),
                          DropdownMenuItem(value: 120, child: Text('2 hours before')),
                          DropdownMenuItem(value: 1440, child: Text('1 day before')),
                        ],
                      ),
                    ],
                  ),
                  if (_notificationsEnabled && _dueDate != null && _dueTime != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Builder(
                        builder: (context) {
                          final dueDate = _composeDueDate();
                          if (dueDate == null) return const SizedBox.shrink();
                          
                          final now = DateTime.now();
                          final scheduledTime = dueDate.subtract(Duration(minutes: _notifyMinutes));
                          
                          if (scheduledTime.isBefore(now)) {
                            return Text(
                              '⚠️ Time passed! Will notify in 1 minute after saving',
                              style: TextStyle(
                                color: Colors.orange.shade700,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          } else {
                            final difference = scheduledTime.difference(now);
                            final hours = difference.inHours;
                            final minutes = difference.inMinutes % 60;
                            
                            String timeText;
                            if (hours > 0) {
                              timeText = '$hours hr ${minutes} min from now';
                            } else {
                              timeText = '$minutes min from now';
                            }
                            
                            return Text(
                              '✅ Will notify $timeText',
                              style: TextStyle(
                                color: Colors.green.shade700,
                                fontSize: 12,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                ],
              ),
            ),
            const Divider(height: 32),
            DropdownButtonFormField<RepeatType>(
              initialValue: _repeatType,
              decoration: const InputDecoration(labelText: 'Repeat'),
              items: RepeatType.values
                  .map(
                    (type) => DropdownMenuItem<RepeatType>(
                      value: type,
                      child: Text(type.label),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _repeatType = value ?? _repeatType),
            ),
            if (_repeatType == RepeatType.weekly) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: weekdays
                    .map(
                      (entry) => FilterChip(
                        label: Text(entry.value),
                        selected: _repeatWeekdays.contains(entry.key),
                        onSelected: (value) => setState(() {
                          if (value) {
                            _repeatWeekdays.add(entry.key);
                          } else {
                            _repeatWeekdays.remove(entry.key);
                          }
                        }),
                      ),
                    )
                    .toList(),
              ),
            ],
            if (_repeatType == RepeatType.daily || _repeatType == RepeatType.interval)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: TextFormField(
                  controller: _intervalCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Repeat interval',
                    helperText: 'Number of days/weeks between repeats',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            if (_repeatType != RepeatType.none)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  _repeatEndDate != null
                      ? 'Ends on ${_repeatEndDate!.day}/${_repeatEndDate!.month}/${_repeatEndDate!.year}'
                      : 'Repeat indefinitely',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _repeatEndDate = null),
                ),
                onTap: _pickRepeatEnd,
              ),
            const Divider(height: 32),
            Text('Subtasks', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ..._subtasks.map((subtask) {
              final controller = TextEditingController(text: subtask.title);
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Checkbox(
                  value: subtask.isDone,
                  onChanged: (value) => setState(() {
                    final idx = _subtasks.indexOf(subtask);
                    _subtasks[idx] = subtask.copyWith(isDone: value ?? false);
                  }),
                ),
                title: TextField(
                  controller: controller,
                  decoration: const InputDecoration(hintText: 'Subtask title'),
                  onChanged: (value) {
                    final idx = _subtasks.indexOf(subtask);
                    _subtasks[idx] = subtask.copyWith(title: value);
                  },
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => setState(() => _subtasks.remove(subtask)),
                ),
              );
            }),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => setState(() {
                  _subtasks.add(const Subtask(title: ''));
                }),
                icon: const Icon(Icons.add),
                label: const Text('Add subtask'),
              ),
            ),
            const Divider(height: 32),
            Text('Tags', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: vm.availableTags
                  .map(
                    (tag) => FilterChip(
                      label: Text(tag.name),
                      selected:
                          _selectedTags.any((selected) => selected.name == tag.name),
                      onSelected: (value) => setState(() {
                        if (value) {
                          _selectedTags.add(tag);
                        } else {
                          _selectedTags
                              .removeWhere((selected) => selected.name == tag.name);
                        }
                      }),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagCtrl,
                    decoration: const InputDecoration(labelText: 'New tag'),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () async {
                    if (_tagCtrl.text.trim().isEmpty) return;
                    final tag = await vm.createTag(_tagCtrl.text.trim());
                    setState(() {
                      _selectedTags.add(tag);
                      _tagCtrl.clear();
                    });
                  },
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomSheet: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            icon: const Icon(Icons.save),
            label: const Text('Save task'),
            onPressed: () => _submit(vm),
          ),
        ),
      ),
    );
  }
}
