import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotification {
  
  static Future<void> requestPermissionLocalNotifications() async {

    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin
    .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
    ?.requestNotificationsPermission();
  }

  static Future<void> initializeLocalNotifications() async {

    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettingsDarwin =DarwinInitializationSettings(
     // onDidReceiveLocalNotification: iosShowNotification
    );

    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static void iosShowNotification(int id, String? title, String? body, String? data) {
    showLocalNotification(
      id: id,
      title: title,
      body: body,
      data: data
    );
  }

  static void showLocalNotification({
    required int id,
    String? title,
    String? body,
    String? data
  }){
    const androidDetails = AndroidNotificationDetails(
      'channelId',
      'channelName',
      channelDescription: 'channelDescription',
      playSound: true,
      importance: Importance.max,
      priority: Priority.high,
      //ticker: 'ticker'
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentSound: true,
        presentAlert: true,
      ),
    );

    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
      flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        notificationDetails
      );
  }

  

}