import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('flutter_logo');

    const DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true);

    const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    await notificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse notificationResponse) async {});
  }

  NotificationDetails notificationDetails() {
    return const NotificationDetails(
        android: AndroidNotificationDetails(
          'channelId',
          'channelName',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher', // Ensure this icon is available in your drawable resources
        ),
        iOS: DarwinNotificationDetails());
  }

  Future<void> showNotification(
      {int id = 0, String? title, String? body, String? payLoad}) async {
    return notificationsPlugin.show(
        id, title, body, notificationDetails());
  }
}