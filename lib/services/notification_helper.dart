import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationHelper {
  static final _notification = FlutterLocalNotificationsPlugin();

  static void init() {
    // Initialize notification settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOSSettings = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iOSSettings,
    );

    _notification.initialize(initSettings);
    tz.initializeTimeZones();
  }

  static void scheduledNotification(String title, String body) {
    const androidDetails = AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      channelDescription: 'This is the channel description',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iOSDetails = DarwinNotificationDetails();

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    _notification.zonedSchedule(
      0, // Notification ID
      title,
      body,
      tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10)),
      notificationDetails,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exact,
    );
  }
}
