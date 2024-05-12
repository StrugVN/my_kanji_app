import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:my_kanji_app/data/constant.dart';
import 'package:my_kanji_app/service/api.dart';
import 'package:intl/intl.dart';

class Notifier {
  static final platformChannelSpecifics = new NotificationDetails(
    android: AndroidNotificationDetails(
      'wkdrd_channel_id',
      'Wakidroid Channel',
      channelDescription: 'Wakidroid Channel Description',
      importance: Importance.low,
      priority: Priority.max,
      showWhen: true,
      playSound: false,
      icon: '@mipmap/icon_noti',
      subText: ''
    ),
  );

  static Future<FlutterLocalNotificationsPlugin> _getNotiPlugins() async {
    FlutterLocalNotificationsPlugin notiPlugs =
        new FlutterLocalNotificationsPlugin();
    var android = new AndroidInitializationSettings('@mipmap/launcher_icon');
    var settings = new InitializationSettings(android: android);
    await notiPlugs.initialize(settings);

    return notiPlugs;
  }

  static Future<void> showNotification({
    required String title,
    required String message,
    required String payload,
  }) async {
    var notiPlugs = await _getNotiPlugins();

    await notiPlugs.show(
      REVIEW_REMINDER_NOTIFICATION_ID,
      title,
      message,
      platformChannelSpecifics,
      payload: payload,
    );

    print("Notification shown: $title - $message - $payload");
  }

  static Future<void> notifyReviewReminder() async {
    print("Debugger: notifyReviewReminder__6");
    try {
      var notiPlugs = await _getNotiPlugins();

      appData.apiKey = "Bearer ${await appData.loadApiKey()}";
      // print("Key: ${appData.apiKey} loaded @ ${DateTime.now()}");

      var srsData = await appData.getSrsData();
      // print("SRS data loaded: ${srsData.length} items @ ${DateTime.now()}");

      var lessonCount = appData.allSrsData!
          .where((element) =>
              element.data != null &&
              element.data!.unlockedAt != null &&
              element.data!.availableAt == null &&
              (element.data!.srsStage ?? 0) < 1)
          .toList()
          .length;

      var reviewData = appData.allSrsData!.where((element) {
        var nextReview = element.data?.getNextReviewAsDateTime();
        return nextReview == null
            ? false
            : nextReview.toLocal().isBefore(DateTime.now());
      }).toList();

      var reviewCount = reviewData.length;

      if (reviewCount == 0) {
        print("No review available");
        return;
      }

      await notiPlugs.show(
        REVIEW_REMINDER_NOTIFICATION_ID,
        "There${reviewCount > 1 ? "'re" : "'s"} item${reviewCount > 1 ? 's' : ''} to review!",
        "You have ${reviewCount} review${reviewCount > 1 ? 's' : ''} and ${lessonCount} lesson${lessonCount > 1 ? 's' : ''} available.",
        platformChannelSpecifics,
        payload: "payload",
      );
    } catch (e, stackTrace) {
      print("Error: $e");
      print("StackTrace: $stackTrace");
    }
  }
}
