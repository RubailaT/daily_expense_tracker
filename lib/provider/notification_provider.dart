import 'package:flutter/material.dart';
import 'package:personal_expense/service_utils/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  TimeOfDay? _reminderTime;
  bool _isLoading = true;

  // Getters
  TimeOfDay? get reminderTime => _reminderTime;
  bool get isLoading => _isLoading;

  NotificationProvider() {
    _loadReminderTime();
  }

  Future<void> _loadReminderTime() async {
    _reminderTime = await _notificationService.getReminderTime() ??
        const TimeOfDay(hour: 20, minute: 0); // Default 8:00 PM
    _isLoading = false;
    notifyListeners();
  }

  Future<void> initNotifications() async {
    await _notificationService.initNotification();
  }

  Future<void> scheduleDaily(TimeOfDay time) async {
    await _notificationService.scheduleDaily(time);
    _reminderTime = time;
    notifyListeners();
  }

  Future<void> showInstantNotification({
    required String title,
    required String body,
  }) async {
    await _notificationService.showInstantNotification(
      title: title,
      body: body,
    );
  }
}
