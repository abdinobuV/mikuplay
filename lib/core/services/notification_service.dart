import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_model.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  static const String _storageKey = 'mikuplay_notifications';

  Future<List<NotificationModel>> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload(); // Force reload from disk in case background isolate updated it
    final jsonStringList = prefs.getStringList(_storageKey) ?? [];
    
    final notifications = jsonStringList
        .map((jsonStr) => NotificationModel.fromJson(jsonDecode(jsonStr)))
        .toList();
        
    // Urutkan dari yang terbaru
    notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return notifications;
  }

  Future<void> saveNotification(NotificationModel notification) async {
    final prefs = await SharedPreferences.getInstance();
    final notifications = await getNotifications();
    
    // Mencegah duplikasi jika ID sama (opsional)
    if (!notifications.any((n) => n.id == notification.id)) {
      notifications.add(notification);
      
      final jsonStringList = notifications
          .map((n) => jsonEncode(n.toJson()))
          .toList();
          
      await prefs.setStringList(_storageKey, jsonStringList);
    }
  }

  Future<void> markAllAsRead() async {
    final prefs = await SharedPreferences.getInstance();
    final notifications = await getNotifications();
    
    final updatedNotifications = notifications
        .map((n) => n.copyWith(isRead: true))
        .toList();
        
    final jsonStringList = updatedNotifications
        .map((n) => jsonEncode(n.toJson()))
        .toList();
        
    await prefs.setStringList(_storageKey, jsonStringList);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
