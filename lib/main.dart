import 'package:flutter/material.dart';
import 'package:personal_expense/constants/color_class.dart';
import 'package:personal_expense/provider/expense_provider.dart';
import 'package:personal_expense/provider/notification_provider.dart';
import 'package:provider/provider.dart';
import 'package:personal_expense/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: ColorClass.primaryColor),
        useMaterial3: true,
      ),

      initialRoute: '/',

      routes: {
        '/': (context) => const HomeScreen(title: 'Expense Tracker'),
      },
      // Handle unknown routes
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const HomeScreen(title: 'Expense Tracker'),
        );
      },
    );
  }
}
