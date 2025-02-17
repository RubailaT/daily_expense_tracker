import 'package:flutter/material.dart';
import 'package:personal_expense/screens/home_screen.dart';
import 'package:personal_expense/service_utils/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Important for notifications

  // Initialize notifications
  final notificationService = NotificationService();
  // await notificationService.initialize();
  await notificationService.initNotification();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const HomeScreen(title: 'Expense Tracker'),
    );
  }
}
