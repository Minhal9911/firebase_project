import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

Future<void> msgBackgroundHandler(RemoteMessage message) async {
  debugPrint("Handling a background message: ${message.notification!.body}");
  AwesomeNotifications().createNotification(
      content: NotificationContent(
          //with image from URL
          id: 1,
          channelKey: 'basic',
          //channel configuration key
          title: message.data["This is Title"],
          body: message.data["This is Body"],
          bigPicture: message.data["assets/loginlogo.png"],
          notificationLayout: NotificationLayout.BigPicture,
          payload: {"name": "Firebase"}));
} // Function should be global

class NotificationService {
  static Future<void> initialize() async {
    FirebaseMessaging.instance;
    log("Notification initialized");

    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      log(token);
    }

    FirebaseMessaging.onBackgroundMessage(msgBackgroundHandler);
  }
}

class InitialiseLocalNotification {
  static Future<void> initialize() async {
    AwesomeNotifications()
        .initialize('resource://drawable/notification_icon', [
      // notification icon
      NotificationChannel(
        channelGroupKey: 'basic_test',
        channelKey: 'basic',
        channelName: 'firebase_testing_channel',
        channelDescription: 'Notification channel for basic tests',
        channelShowBadge: true,
        importance: NotificationImportance.High,
      ),
      //add more notification type with different configuration
    ]);
  }
}

// Local Notification Service

/*class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final AndroidInitializationSettings initializationSettingsAndroid =
      const AndroidInitializationSettings('logo');

  void initialiseNotification() async {
    InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await notificationsPlugin.initialize(initializationSettings);
  }

  void sendNotification(String title, String body) async {
    AndroidNotificationDetails androidNotificationDetails =
        const AndroidNotificationDetails(
      'firebase-notification',
      "firebase_testing_channel",
      importance: Importance.max,
      priority: Priority.high,
      enableLights: true,
      enableVibration: true,
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );
    await notificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails,
    );
  }
}*/
