import 'package:flutter/material.dart';
import 'package:my_kanji_app/component/list.dart';

import '../component/selector.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("My app")),
        backgroundColor: Colors.blue,
      ),
      body: const SafeArea(
        child: SingleChildScrollView(
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
}
