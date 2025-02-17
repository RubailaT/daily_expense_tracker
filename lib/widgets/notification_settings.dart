// import 'package:flutter/material.dart';
// import '../service_utils/notification_service.dart';

// class NotificationSettingsPage extends StatefulWidget {
//   final Function()? onSettingChanged;
//   const NotificationSettingsPage({super.key, this.onSettingChanged});

//   @override
//   State<NotificationSettingsPage> createState() =>
//       _NotificationSettingsPageState();
// }

// class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
//   final NotificationService _notificationService = NotificationService();
//   bool _isDailyReminderEnabled = false;
//   TimeOfDay _reminderTime =
//       const TimeOfDay(hour: 20, minute: 0); // 8 PM default

//   @override
//   void initState() {
//     super.initState();
//     _loadSettings();
//   }

//   Future<void> _loadSettings() async {
//     final isEnabled = await _notificationService.isReminderActive();
//     final savedTime = await _notificationService.getReminderTime();
//     setState(() {
//       _isDailyReminderEnabled = isEnabled;
//       if (savedTime != null) {
//         _reminderTime = savedTime;
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Notification Settings'),
//       ),
//       body: ListView(
//         children: [
//           SwitchListTile(
//             title: const Text('Daily Expense Reminder'),
//             subtitle: Text(_isDailyReminderEnabled
//                 ? 'Reminder set for ${_reminderTime.format(context)}'
//                 : 'Reminder disabled'),
//             value: _isDailyReminderEnabled,
//             onChanged: (bool value) async {
//               setState(() => _isDailyReminderEnabled = value);
//               if (value) {
//                 await _notificationService.scheduleDailyReminder(
//                   time: _reminderTime,
//                   isActive: true,
//                 );
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text('Daily reminder enabled')),
//                 );
//               } else {
//                 await _notificationService.cancelDailyReminder();
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text('Daily reminder disabled')),
//                 );
//               }
//               widget.onSettingChanged?.call(); // Add this line
//             },
//           ),
//           if (_isDailyReminderEnabled)
//             ListTile(
//               title: const Text('Reminder Time'),
//               subtitle: Text(_reminderTime.format(context)),
//               trailing: const Icon(Icons.access_time),
//               onTap: () async {
//                 final TimeOfDay? newTime = await showTimePicker(
//                   context: context,
//                   initialTime: _reminderTime,
//                 );
//                 if (newTime != null) {
//                   setState(() => _reminderTime = newTime);
//                   await _notificationService.scheduleDailyReminder(
//                     time: newTime,
//                     isActive: true,
//                   );
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text(
//                         'Reminder time updated to ${newTime.format(context)}',
//                       ),
//                     ),
//                   );
//                   widget.onSettingChanged?.call(); // Add this line
//                 }
//               },
//             ),
//           const Divider(),
//           ListTile(
//             title: const Text('Test Notification'),
//             subtitle: const Text('Send a test notification'),
//             trailing: const Icon(Icons.send),
//             onTap: () async {
//               await _notificationService.showInstantNotification(
//                 title: 'Expense Reminder',
//                 body: 'Don\'t forget to log your expenses for today!',
//               );
//             },
//           ),
//           ListTile(
//             title: const Text('Clear All Notifications'),
//             subtitle: const Text('Remove all pending notifications'),
//             trailing: const Icon(Icons.clear_all),
//             onTap: () async {
//               await _notificationService.cancelAllNotifications();
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(
//                   content: Text('All notifications cleared'),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:personal_expense/service_utils/notification_service.dart';
// import '../services/notification_service.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  final NotificationService _notificationService = NotificationService();
  TimeOfDay? _reminderTime;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReminderTime();
  }

  Future<void> _loadReminderTime() async {
    final savedTime = await _notificationService.getReminderTime();
    setState(() {
      _reminderTime =
          savedTime ?? const TimeOfDay(hour: 20, minute: 0); // Default 8:00 PM
      _isLoading = false;
    });
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime ?? const TimeOfDay(hour: 20, minute: 0),
    );

    if (picked != null && picked != _reminderTime) {
      setState(() {
        _reminderTime = picked;
      });

      // Schedule the notification
      await _notificationService.scheduleDaily(picked);

      if (mounted) {
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
      ),
      body: Padding(
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
              subtitle: Text(_reminderTime != null
                  ? 'Set for ${_reminderTime!.format(context)}'
                  : 'Not set'),
              trailing: ElevatedButton(
                onPressed: _selectTime,
                child: const Text('Change Time'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
