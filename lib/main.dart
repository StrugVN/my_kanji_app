import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_kanji_app/data/app_data.dart';
import 'package:my_kanji_app/pages/home.dart';
import 'package:my_kanji_app/pages/login.dart';
import 'package:my_kanji_app/service/api.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:io';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:window_size/window_size.dart';

void main() {
  if (Platform.isWindows || Platform.isLinux) {
    // Initialize FFI
    WidgetsFlutterBinding.ensureInitialized();

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
