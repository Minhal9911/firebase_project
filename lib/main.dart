import 'dart:developer';

import 'package:authentication/services/notification.dart';
import 'package:authentication/splashscreen.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await NotificationService.initialize();
  AwesomeNotifications().initialize('resource://drawable/logo', [
    // notification icon
    NotificationChannel(
      // channelGroupKey: 'basic_test',
      channelKey: '81b022b65a602f5a1bd78bfbed52b26bbd7be7dc',
      channelName: 'firebase_testing_channel',
      channelDescription: 'Notification channel for Firebase tests',
      channelShowBadge: true,
      importance: NotificationImportance.High,
      enableVibration: true,
      ledColor: Colors.white,
      enableLights: true,
    ),
    //add more notification type with different configuration
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.purple),
      home: const SplashScreen(),
      //if i am already signIn then I will go on HomeScreen
    );
  }
}
