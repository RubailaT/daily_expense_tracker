// import 'package:flutter/material.dart';
// import '../service_utils/notification_service.dart';

// class NotificationsTestPage extends StatelessWidget {
//   NotificationsTestPage({super.key});

//   final NotificationService _notificationService = NotificationService();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Test Notifications'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             ElevatedButton(
//               onPressed: () async {
//                 await _notificationService.showInstantNotification(
//                   title: 'Test Notification',
//                   body: 'This is a test notification',
//                 );
//               },
//               child: const Text('Show Instant Notification'),
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () async {
//                 await _notificationService.showScheduledNotification(
//                   title: 'Scheduled Notification',
//                   body: 'This notification was scheduled for 5 seconds later',
//                   seconds: 5,
//                 );
//               },
//               child: const Text('Show Notification in 5 seconds'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
