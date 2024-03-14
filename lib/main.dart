import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_kanji_app/data/app_data.dart';
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
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

Future<void> main() async {
  // Initialize FFI
  WidgetsFlutterBinding.ensureInitialized();

  _configureLocalTimeZone();

  if(Platform.isAndroid){
    Notifier.init();
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

class MyApp extends StatelessWidget  {
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
      home: const Home(),
    );
  }
}

Future<void> _configureLocalTimeZone() async {
  tz.initializeTimeZones();
  final String timeZoneName = "Asia/Ho_Chi_Minh";
  print("init time zone: $timeZoneName");
  tz.setLocalLocation(tz.getLocation(timeZoneName));
}