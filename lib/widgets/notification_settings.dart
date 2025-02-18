import 'package:flutter/material.dart';
import 'package:personal_expense/provider/notification_provider.dart';
import 'package:provider/provider.dart';

class NotificationSettingsPage extends StatelessWidget {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pop();
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Notification Settings'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: Consumer<NotificationProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Daily Expense Reminder',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('Reminder Time'),
                      subtitle: Text(provider.reminderTime != null
                          ? 'Set for ${provider.reminderTime!.format(context)}'
                          : 'Not set'),
                      trailing: ElevatedButton(
                        onPressed: () => _selectTime(context),
                        child: const Text('Change Time'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ));
  }

  Future<void> _selectTime(BuildContext context) async {
    final provider = context.read<NotificationProvider>();
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime:
          provider.reminderTime ?? const TimeOfDay(hour: 20, minute: 0),
    );

    if (picked != null && picked != provider.reminderTime) {
      await provider.scheduleDaily(picked);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Daily reminder set for ${picked.format(context)}',
            ),
          ),
        );
      }
    }
  }
}
