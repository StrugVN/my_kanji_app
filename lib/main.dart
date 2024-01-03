import 'package:flutter/material.dart';
import 'package:my_kanji_app/pages/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: Login());
  }
}

/*
Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: Center(child: Text("My app")),
        backgroundColor: Colors.blue,
      ),
      body: const SafeArea(
        child: SingleChildScrollView (
          child: Column(
            children: <Widget>[
              DropdownMenuExample(maxLevel: 25),
              ExpansionPanelListExample(),
            ],
          ),
        ),
      ),
    ));
  }
*/
