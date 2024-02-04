import 'package:flutter/material.dart';
import 'package:my_kanji_app/data/kanji.dart';
import 'package:my_kanji_app/data/vocab.dart';
import 'package:my_kanji_app/pages/kanji_info_page.dart';
import 'package:my_kanji_app/pages/vocab_info_page.dart';
import 'package:my_kanji_app/service/api.dart';
import 'package:collection/collection.dart';

class LessonPage extends StatefulWidget {
  const LessonPage({super.key});

  @override
  State<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonPage> {
  List<Map> lessonItems = [];

  int index = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    var lessonItem = appData.allSrsData!
        .where((element) =>
            element.data != null &&
            element.data!.unlockedAt != null &&
            element.data!.availableAt == null)
        .toList();

    var newItemsList = appData.allKanjiData!
        .where((element) =>
            lessonItem.firstWhereOrNull(
              (e) => e.data != null ? element.id == e.data!.subjectId! : false,
            ) !=
            null)
        .map((element) {
      var lessonItemStat = lessonItem.firstWhereOrNull(
        (e) => e.data != null ? element.id == e.data!.subjectId! : false,
      );
      return {
        "id": element.id,
        "char": element.data!.characters,
        "unlockedDate": lessonItemStat!.data!.getUnlockededDateAsDateTime(),
        "isKanji": true,
        "data": element,
      };
    }).toList();
    newItemsList = newItemsList +
        appData.allVocabData!
            .where((element) =>
                lessonItem.firstWhereOrNull(
                  (e) =>
                      e.data != null ? element.id == e.data!.subjectId! : false,
                ) !=
                null)
            .map((element) {
          var lessonItemStat = lessonItem.firstWhereOrNull(
            (e) => e.data != null ? element.id == e.data!.subjectId! : false,
          );
          return {
            "id": element.id,
            "char": element.data!.characters,
            "unlockedDate": lessonItemStat!.data!.getUnlockededDateAsDateTime(),
            "isKanji": false,
            "data": element,
          };
        }).toList();

    newItemsList.sort((a, b) => (a["unlockedDate"] as DateTime)
        .compareTo(b["unlockedDate"] as DateTime));

    lessonItems = newItemsList.take(appData.lessonBatchSize).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lesson"),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.home,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.of(context).popUntil((route) =>
                  route.isFirst ||
                  route.settings.name == '/homePage' ||
                  route.settings.name == 'homePage');
            },
          ),
        ],
        backgroundColor: Colors.pink,
      ),
      body: Column(
        children: [
          
          getInfoPage(lessonItems[index]["data"]),
        ],
      ),
    );
  }

  Widget getInfoPage(dynamic item) {
    Kanji? kanji;
    Vocab? vocab;

    if (item is Kanji) {
      kanji = item;
    }
    if (item is Vocab) {
      vocab = item;
    }

    if (kanji != null) {
      return KanjiPage(kanji: kanji);
    }

    if (vocab != null) {
      return VocabPage.hideAppBar(vocab: vocab);
    }

    return const SizedBox.shrink();
  }
}
