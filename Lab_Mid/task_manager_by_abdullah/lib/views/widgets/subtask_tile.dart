import 'package:flutter/material.dart';
import '../../data/models/subtask.dart';

class SubtaskTile extends StatelessWidget {
  const SubtaskTile({
    super.key,
    required this.subtask,
    required this.onChanged,
  });

  final Subtask subtask;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: subtask.isDone,
      onChanged: (value) => onChanged(value ?? false),
      controlAffinity: ListTileControlAffinity.leading,
      title: Text(
        subtask.title,
        style: TextStyle(
          decoration: subtask.isDone ? TextDecoration.lineThrough : null,
        ),
      ),
    );
  }
}
