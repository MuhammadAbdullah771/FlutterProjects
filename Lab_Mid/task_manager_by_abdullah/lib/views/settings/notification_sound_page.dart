import 'package:flutter/material.dart';
import '../../data/services/notification_service.dart';

class NotificationSoundPage extends StatelessWidget {
  const NotificationSoundPage({
    super.key,
    required this.options,
    required this.selected,
  });

  final List<NotificationSoundOption> options;
  final NotificationSoundOption selected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification sound')),
      body: ListView.builder(
        itemCount: options.length,
        itemBuilder: (_, index) {
          final option = options[index];
          final isSelected = option.id == selected.id;
          return ListTile(
            title: Text(option.label),
            trailing: isSelected
                ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                : null,
            onTap: () => Navigator.of(context).pop(option),
          );
        },
      ),
    );
  }
}
