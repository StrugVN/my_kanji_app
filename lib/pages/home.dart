import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:my_kanji_app/data/pitch_data.dart';
import 'package:my_kanji_app/data/shared.dart';
import 'package:my_kanji_app/data/app_data.dart';
import 'package:my_kanji_app/pages/dashboard.dart';
import 'package:my_kanji_app/pages/review.dart';
import 'package:my_kanji_app/pages/stuff.dart';
import 'package:my_kanji_app/service/api.dart';
import 'package:collection/collection.dart';

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

  final AppData appData = AppData();

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

    // var getKanji = getAllSubject("kanji");
    // var getVocab = getAllSubject("vocabulary");
    // var getKanaVocab = getAllSubject("kana_vocabulary");
    var getPitchData = loadPitchData();

    // appData.allKanjiData = await getKanji;
    // appData.allVocabData = await getVocab + await getKanaVocab;

    // print(appData.allKanjiData!.length);
    // print(appData.allVocabData!.length);

    appData.pitchData = await getPitchData;
    print(" -- Pitch data loaded: ${appData.pitchData?.length}");
    
    // Navigator.pop(context);
  }

  Future<List<PitchData>> loadPitchDataPart(int partNum) async {
    String pitchJson = "assets/pitch_json/term_meta_bank_$partNum.json";

    String data = await DefaultAssetBundle.of(context).loadString(pitchJson);
    final jsonS = jsonDecode(data);

    List<PitchData>? pitchData = [];
    for (var item in jsonS){
      pitchData.add(PitchData.fromData(item));
    }
    print("  -- Loaded: $pitchJson");
    return pitchData;
  }

  Future<List<PitchData>> loadPitchData() async {
    List<Future<List<PitchData>>> taskList = [];

    for (int i=1; i<=13; i++){
      taskList.add(loadPitchDataPart(i));
    }

    List<PitchData> data = [];
    for (var task in taskList){
      data = data + await task;
    }

    return data;
  }
}
