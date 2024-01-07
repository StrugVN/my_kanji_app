import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:my_kanji_app/component/list.dart';
import 'package:my_kanji_app/component/selector.dart';
import 'package:my_kanji_app/data/kanji.dart';
import 'package:my_kanji_app/data/shared.dart';
import 'package:my_kanji_app/data/user.dart';
import 'package:my_kanji_app/pages/dashboard.dart';
import 'package:my_kanji_app/pages/review.dart';
import 'package:my_kanji_app/pages/stuff.dart';
import 'package:my_kanji_app/service/api.dart';
import 'package:unofficial_jisho_api/api.dart' as jisho;
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late int pageIndex;

  List<Widget> pageList = <Widget>[
    const Dashboard(),
    const Review(),
    const Stuff(),
  ];

  final User user = User();

  @override
  void initState() {
    super.initState();

    pageIndex = 0;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      initData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Center(child: Text("My app")),
            backgroundColor: Colors.blue,
          ),
          body: IndexedStack(
            index: pageIndex,
            children: pageList,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: pageIndex,
            onTap: (value) {
              setState(() {
                pageIndex = value;
              });
            },
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.home), label: "Dashboard"),
              BottomNavigationBarItem(icon: Icon(Icons.book), label: "Review"),
              BottomNavigationBarItem(icon: Icon(Icons.info), label: "Stuff"),
            ],
          ),
        ),
      ),
    );
  }

  void initData() async {
    // showLoaderDialog(context, "Loading data");

    var getKanji = getAllSubject("kanji");
    var getVocab = getAllSubject("vocabulary");
    var getKanaVocab = getAllSubject("kana_vocabulary");

    user.allKanjiData = await getKanji;
    user.allVocabData = await getVocab + await getKanaVocab;

    print(user.allKanjiData!.length);
    print(user.allVocabData!.length);
    
    // Navigator.pop(context);
  }

  
}
