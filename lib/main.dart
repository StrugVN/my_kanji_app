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
      const initialSize = Size(420, 760);
      appWindow.minSize = const Size(420*0.6, 760*0.6);
      appWindow.size = initialSize;
      appWindow.alignment = Alignment.center;
      appWindow.show();
    });
  }

  runApp(ChangeNotifierProvider(
    create: (_) => AppData(),
    child: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addObserver(this);
  }

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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      // Call your function when the app goes into the paused state
      print('Window is closing...');
      appData.saveCache(null);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // TODO: implement dispose
    super.dispose();
  }
}
