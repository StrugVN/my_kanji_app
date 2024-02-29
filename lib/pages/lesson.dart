import 'package:flutter/material.dart';
import 'package:my_kanji_app/data/kanji.dart';
import 'package:my_kanji_app/data/radical.dart';
import 'package:my_kanji_app/data/vocab.dart';
import 'package:my_kanji_app/pages/kanji_info_page.dart';
import 'package:my_kanji_app/pages/radical_info_page.dart';
import 'package:my_kanji_app/pages/vocab_info_page.dart';
import 'package:my_kanji_app/pages/wk_review.dart';
import 'package:my_kanji_app/service/api.dart';
import 'package:collection/collection.dart';
import 'package:preload_page_view/preload_page_view.dart';

class LessonPage extends StatefulWidget {
  const LessonPage({super.key, this.newItemsList});

  final List<Map<String, Object?>>? newItemsList;

  @override
  State<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonPage> {
  List<Map> lessonList = [];

  List<Widget> lessonPages = [];

  int index = 0;

  var pageController = PreloadPageController(initialPage: 0);

  @override
  void initState() {
    super.initState();

    var lessonItem = appData.allSrsData!
        .where((element) =>
            element.data != null &&
            element.data!.unlockedAt != null &&
            element.data!.availableAt == null)
        .toList();

    List<Map<String, Object?>> newItemsList = [];

    if (widget.newItemsList == null || widget.newItemsList!.isEmpty) {
      if (appData.lessonSetting["kanji"] ?? false) {
        newItemsList = newItemsList +
            appData.allKanjiData!
                .where((element) =>
                    lessonItem.firstWhereOrNull(
                      (e) => e.data != null
                          ? element.id == e.data!.subjectId!
                          : false,
                    ) !=
                    null)
                .map((element) {
              var lessonItemStat = lessonItem.firstWhereOrNull(
                (e) =>
                    e.data != null ? element.id == e.data!.subjectId! : false,
              );
              return {
                "id": element.id,
                "char": element.data!.characters,
                "unlockedDate":
                    lessonItemStat!.data!.getUnlockededDateAsDateTime(),
                "isKanji": true,
                "level": element.data?.level,
                "data": element,
              };
            }).toList();
      }

      if (appData.lessonSetting["vocab"] ?? false) {
        newItemsList = newItemsList +
            appData.allVocabData!
                .where((element) =>
                    lessonItem.firstWhereOrNull(
                      (e) => e.data != null
                          ? element.id == e.data!.subjectId!
                          : false,
                    ) !=
                    null)
                .map((element) {
              var lessonItemStat = lessonItem.firstWhereOrNull(
                (e) =>
                    e.data != null ? element.id == e.data!.subjectId! : false,
              );
              return {
                "id": element.id,
                "char": element.data!.characters,
                "unlockedDate":
                    lessonItemStat!.data!.getUnlockededDateAsDateTime(),
                "isKanji": false,
                "level": element.data?.level,
                "data": element,
              };
            }).toList();
      }

      if (appData.lessonSetting["radical"] ?? false) {
        newItemsList = newItemsList +
            appData.allRadicalData!
                .where((element) =>
                    lessonItem.firstWhereOrNull(
                      (e) => e.data != null
                          ? element.id == e.data!.subjectId!
                          : false,
                    ) !=
                    null)
                .map((element) {
              var lessonItemStat = lessonItem.firstWhereOrNull(
                (e) =>
                    e.data != null ? element.id == e.data!.subjectId! : false,
              );
              return {
                "id": element.id,
                "char": element.data!.characters,
                "unlockedDate":
                    lessonItemStat!.data!.getUnlockededDateAsDateTime(),
                "isKanji": false,
                "level": element.data?.level,
                "data": element,
              };
            }).toList();
      }

      if (newItemsList.isEmpty) {
        Navigator.pop(context, true);
      }
    } else {
      newItemsList = widget.newItemsList!;
    }

    newItemsList.sort((a, b) {
      int levelCompare = (a["level"] as int) - (b["level"] as int);

      if (levelCompare != 0) return levelCompare;

      int typeCompare = (a["data"] is Radical ? 1 : 0) +
          (a["data"] is Kanji ? 2 : 0) +
          (a["data"] is Vocab ? 3 : 0) -
          ((b["data"] is Radical ? 1 : 0) +
              (b["data"] is Kanji ? 2 : 0) +
              (b["data"] is Vocab ? 3 : 0));

      if (typeCompare != 0) return typeCompare;

      return (a["unlockedDate"] as DateTime)
          .compareTo(b["unlockedDate"] as DateTime);
    });

    lessonList = newItemsList.take(appData.lessonBatchSize).toList();

    for (int ind = 0; ind < lessonList.length; ind++) {
      lessonPages.add(getInfoPage(lessonList[ind]["data"]));
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        await showAbandoneDialog(context).then((confirm) {
          if (confirm != null && confirm) {
            Navigator.pop(context, true);
          }
        });
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Lesson"),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () async => await showAbandoneDialog(context).then(
              (confirm) {
                if (confirm != null && confirm) {
                  Navigator.pop(context, true);
                }
              },
            ),
          ),
          backgroundColor: Colors.pink,
        ),
        backgroundColor: Colors.grey.shade300,
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              margin: const EdgeInsets.all(5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (index - 1 >= 0) {
                        index = index - 1;
                        setState(() {
                          pageController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.ease,
                          );
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: index > 0
                          ? Colors.pink
                          : const Color.fromARGB(255, 255, 175, 202),
                      foregroundColor: Colors.white,
                    ),
                    child: const Icon(Icons.arrow_back),
                  ),
                  Text(
                    "${index + 1}/${lessonList.length}",
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (index + 1 < lessonList.length) {
                        index = index + 1;
                        setState(() {
                          pageController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.ease,
                          );
                        });
                      } else {
                        Navigator.pop(context, true);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WkReviewPage.createLessonQuiz(
                              reviewItems:
                                  lessonList.map((e) => e["data"]).toList(),
                            ),
                            settings: const RouteSettings(name: "reviewPage"),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: index + 1 < lessonList.length
                          ? Colors.pink
                          : Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: index + 1 < lessonList.length
                        ? const Icon(Icons.arrow_forward)
                        : const Text("To Quiz!"),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: PreloadPageView.builder(
                controller: pageController,
                onPageChanged: (i) {
                  setState(() {
                    index = i;
                  });
                },
                itemBuilder: (context, index) {
                  return lessonPages[index];
                },
                itemCount: lessonPages.length,
                preloadPagesCount: lessonPages
                    .length, // Preload adjacent pages for smoother transitions
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getInfoPage(dynamic item) {
    Kanji? kanji;
    Vocab? vocab;
    Radical? radical;

    if (item is Kanji) {
      kanji = item;
    }
    if (item is Vocab) {
      vocab = item;
    }
    if (item is Radical) {
      radical = item;
    }

    if (kanji != null) {
      return KanjiPage.hideAppBar(kanji: kanji);
    }

    if (vocab != null) {
      return VocabPage.hideAppBar(vocab: vocab);
    }

    if (radical != null) {
      return RadicalPage(radical: radical);
    }

    return const SizedBox.shrink();
  }

  Future<bool?> showAbandoneDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Abandone lesson?'),
        // content: const Text('Leave lesson'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }
}
