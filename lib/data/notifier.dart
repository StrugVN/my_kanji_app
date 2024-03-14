import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class Notifier {
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static final int REVIEW_REMINDER_NOTIFICATION_ID = 0; 

  static init() async {
    // Initialization Settings for Android
    AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // General Initialization Settings
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> showNotification({
    required String title,
    required String message,
    required String payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'wkdrd_channel_id',
      'Wakidroid Channel',
      channelDescription: 'Wakidroid Channel Description',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await Notifier.flutterLocalNotificationsPlugin.show(
      REVIEW_REMINDER_NOTIFICATION_ID,
      title,
      message,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  static Future<void> scheduleNotification({
    required String title,
    required String message,
    required String payload,
    required TZDateTime scheduledTime,
  }) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      REVIEW_REMINDER_NOTIFICATION_ID,
      title,
      message,
      scheduledTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'wkdrd_channel_id',
          'Wakidroid Channel',
          channelDescription: 'Wakidroid Channel Description',
          importance: Importance.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      // androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
    print("Notification scheduled at: $scheduledTime");
    print("Now: ${tz.TZDateTime.now(tz.local)}");
  }

  static Future<void> cancelNotification() async {
    await flutterLocalNotificationsPlugin.cancel(REVIEW_REMINDER_NOTIFICATION_ID);
  }
}
