import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_kanji_app/data/app_data.dart';
import 'package:my_kanji_app/data/constant.dart';
import 'package:my_kanji_app/data/notifier.dart';
import 'package:my_kanji_app/pages/home.dart';
import 'package:my_kanji_app/pages/login.dart';
import 'package:my_kanji_app/service/api.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:io';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:window_size/window_size.dart';
import 'dart:ui' as ui;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';

Future<void> main() async {
  // Initialize FFI
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid) {
    Workmanager().initialize(callbackDispatcher, isInDebugMode: false);

    // SETUP NOTIFICATIONS
    createReminderTask();
  }

  if (Platform.isWindows || Platform.isLinux) {
    setWindowTitle("Waki Droid");

    doWhenWindowReady(() {
      const initialSize = Size(480, 780);
      appWindow.minSize = const Size(420, 760);
      appWindow.size = initialSize;
      appWindow.alignment = Alignment.center;
      // appWindow.show();
    });
  }

  runApp(ChangeNotifierProvider(
    create: (_) => AppData(),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        DefaultCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('ja', ''),
      ],
      locale: const Locale('ja', ''),
      routes: {
        '/homePage': (context) => const Home(),
        '/login': (context) => const Login(),
      },
      theme: ThemeData(
        fontFamily: 'KyoukashoICA',
        // Other theme properties
      ),
      home: const Home(),
    );
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() async {
  print("Background task started...");

  Workmanager().executeTask((task, inputData) async {
    await Notifier.notifyReviewReminder();

    // Cancel and prepare next task
    Workmanager().cancelByTag(TASK_REVIEW_REMINDER_TAG);

    DateTime now = DateTime.now();
    DateTime nextHour = DateTime(now.year, now.month, now.day, now.hour + 1);
    Duration initialDelay = nextHour.difference(now);

    Workmanager().registerOneOffTask(
      TASK_REVIEW_REMINDER_ID + "_${nextHour.hour}",
      TASK_REVIEW_REMINDER_NAME,
      tag: TASK_REVIEW_REMINDER_TAG,
      initialDelay: initialDelay,
    );

    print("Background task completed...");

    return Future.value(true);
  });
}

void createReminderTask() async {
  Workmanager().cancelByTag(TASK_REVIEW_REMINDER_TAG);

  DateTime now = DateTime.now();
  DateTime nextHour = DateTime(now.year, now.month, now.day, now.hour + 1);
  Duration initialDelay = nextHour.difference(now);

  Workmanager().registerOneOffTask(
    TASK_REVIEW_REMINDER_ID + "_${nextHour.hour}",
    TASK_REVIEW_REMINDER_NAME,
    tag: TASK_REVIEW_REMINDER_TAG,
    initialDelay: initialDelay,
    // frequency: const Duration(hours: 1),
  );
}
