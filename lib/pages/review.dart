import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:my_kanji_app/component/list.dart';
import 'package:my_kanji_app/component/selector.dart';
import 'package:my_kanji_app/data/kanji.dart';
import 'package:my_kanji_app/data/kanji_set.dart';
import 'package:my_kanji_app/data/shared.dart';
import 'package:my_kanji_app/data/app_data.dart';
import 'package:my_kanji_app/data/vocab.dart';
import 'package:my_kanji_app/pages/result_page.dart';
import 'package:my_kanji_app/service/api.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collection/collection.dart';

class Review extends StatefulWidget {
  Review({super.key, this.listKanji, this.listVocab, this.kanjiOnFront});

  List<Kanji>? listKanji;
  List<Vocab>? listVocab;
  bool? kanjiOnFront;
  // Create items with list x2,
  // kanjiOnFront:
  //  - True: Kanji
  //  - False: Kana
  //  - Null: Meaning

  @override
  State<Review> createState() => _ReviewState();
}

class _ReviewState extends State<Review> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List<SubjectItem>? dataList;
  bool? isKanji;
  bool? isToEN;
  bool? kanjiOnFront;
  bool? isAudio;

  final AppData appData = AppData();

  bool reviewInProgress = true;

  late SharedPreferences sharedPreferences;

  final scrollController = ScrollController();

  bool vocabDisclaim = false;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();

    print("Init review");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      initReviewIfExist();
    });

    // scrollController.jumpTo(0.0);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: scrollController,
      // physics: const NeverScrollableScrollPhysics(),
      child: NotificationListener<ScrollUpdateNotification>(
        onNotification: (notification) {
          scrollController.animateTo(
            0.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.linear,
          );
          return true;
        },
        child: Column(
          children: <Widget>[
            getSelector(),
            SubjectList(
              data: dataList,
              isToEN: isToEN,
              kanjiOnFront: kanjiOnFront,
              isAudio: isAudio,
              dataCheckCallback: dataCallback,
            ),
          ],
        ),
      ),
    );
  }

  @Deprecated("Use getReviewFromLocal instead")
  getReview(String types, int levels, bool toEn, String? nonWani,
      String? frontVocabSetting) async {
    late Response response, response2;

    if (types != "kanji") {
      types = "vocabulary";
    }

    if (nonWani == null) {
      response = await getSubject(
          SubjectQueryParam(types: [types], levels: [levels.toString()]));
    } else {
      String? set = kanjiSet[nonWani];
      if (set != null) {
        response =
            await getSubject(SubjectQueryParam(types: [types], slugs: [set]));
      } else {
        return;
      }
    }

    if (response.statusCode == 200) {
      if (types == "kanji") {
        var body = KanjiResponse.fromJson(
            jsonDecode(response.body) as Map<String, dynamic>);

        setState(() {
          dataList = body.data
              ?.map(
                  (e) => SubjectItem<Kanji>(subjectItem: e, isRevealed: false))
              .toList();

          isToEN = toEn;

          dataList?.shuffle();
          isKanji = true;
          reviewInProgress = true;
          kanjiOnFront = true;
          isAudio = false;
        });
      } else {
        response2 = await getSubject(SubjectQueryParam(
            types: ["kana_vocabulary"], levels: [levels.toString()]));

        var body = VocabResponse.fromJson(
            jsonDecode(response.body) as Map<String, dynamic>);

        var body2 = VocabResponse.fromJson(
            jsonDecode(response2.body) as Map<String, dynamic>);

        setState(() {
          dataList = body.data!
                  .map((e) =>
                      SubjectItem<Vocab>(subjectItem: e, isRevealed: false))
                  .toList() +
              body2.data!
                  .map((e) =>
                      SubjectItem<Vocab>(subjectItem: e, isRevealed: false))
                  .toList();

          isToEN = toEn;

          dataList?.shuffle();
          isKanji = false;
          reviewInProgress = true;
          kanjiOnFront = (frontVocabSetting == "Show Kanji");
          isAudio = (frontVocabSetting == "Audio");
        });
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(response.body)));
      print(response.body);
    }
  }

  getReviewFromLocal(String types, int levels, bool toEn, String? nonWani,
      String? frontVocabSetting) {
    if (types != "kanji") {
      types = "vocabulary";
    }

    if (types == "kanji") {
      List<Kanji> temp;
      if (nonWani == null) {
        temp = appData.getListKanjiFromLocal(
            ids: null, levels: [levels], slugs: null);
      } else {
        String? set = kanjiSet[nonWani];
        if (set != null) {
          temp = appData.getListKanjiFromLocal(
              ids: null, levels: null, slugs: set.split(""));
        } else {
          return;
        }
      }

      setState(() {
        dataList = temp
            ?.map((e) => SubjectItem<Kanji>(subjectItem: e, isRevealed: false))
            .toList();

        isToEN = toEn;

        dataList?.shuffle();
        isKanji = true;
        reviewInProgress = true;
        kanjiOnFront = true;
        isAudio = false;
      });
    } else {
      List<Vocab> temp;
      if (nonWani == null) {
        temp = appData.getListVocabFromLocal(
            ids: null, levels: [levels], slugs: null);
      } else {
        String? set = kanjiSet[nonWani];
        if (set != null) {
          temp = appData.getListVocabFromLocalByKanji(set.split(""));
          vocabDisclaim = true;
        } else {
          return;
        }
      }

      setState(() {
        dataList = temp
            .map((e) => SubjectItem<Vocab>(subjectItem: e, isRevealed: false))
            .toList();

        isToEN = toEn;

        dataList?.shuffle();
        isKanji = false;
        reviewInProgress = true;
        kanjiOnFront = (frontVocabSetting == "Show Kanji");
        print(frontVocabSetting);
        isAudio = (frontVocabSetting == "Audio");
      });
    }
  }

  getReviewCallback(String types, int levels, bool toEn, String? nonWani,
      String? frontVocabSetting) {
    showLoaderDialog(context, "Creating set");

    getReviewFromLocal(types, levels, toEn, nonWani, frontVocabSetting);

    Navigator.pop(context);
  }

  getSelector() {
    if (reviewInProgress) {
      return ExpansionTile(
        title: Center(
          child: Text(
            "${isKanji != null ? (isKanji! ? "Kanji" : "Vocab") : "Critical item${dataList != null && dataList!.length > 1 ? "s" : ""}"} self-review in progress",
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
            ),
          ),
        ),
        leading: const Icon(Icons.bookmark),
        initiallyExpanded: true,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Builder(builder: (context) {
                    if (dataList
                            ?.where((element) => element.isRevealed == false)
                            .isNotEmpty ??
                        false) {
                      return Row(
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 103, 174, 255),
                              shape: ContinuousRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                            ),
                            onPressed: () {
                              revealAllItemConfirmDialog();
                            },
                            child: RichText(
                              text: const TextSpan(
                                children: <TextSpan>[
                                  TextSpan(
                                    text: 'Reveal all ',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  TextSpan(
                                    text: 'item',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                      );
                    } else {
                      return const SizedBox(
                        width: 0,
                      );
                    }
                  }),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 255, 103, 103),
                      shape: ContinuousRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: () {
                      closeSectionConfirmDialog();
                    },
                    child: RichText(
                      text: const TextSpan(
                        children: <TextSpan>[
                          TextSpan(
                            text: 'End ',
                            style: TextStyle(color: Colors.black),
                          ),
                          TextSpan(
                            text: 'section',
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: RichText(
                  text: TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        text:
                            "${dataList?.where((element) => element.isCorrect == null).toList().length}",
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const TextSpan(
                        text: ' item remained',
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              isKanji != null && !isKanji! && vocabDisclaim
                  ? const Center(
                      child: Text(
                        "Disclaimer: These vocab is selected from wanikani data only",
                        style: TextStyle(
                            fontSize: 10, fontWeight: FontWeight.w100),
                      ),
                    )
                  : const SizedBox.shrink(),
            ],
          )
        ],
      );
    } else {
      return ExpansionTile(
        title: const Center(
          child: Text(
            "Create flashcard set",
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
            ),
          ),
        ),
        leading: const Icon(Icons.bookmark_add_outlined),
        initiallyExpanded: true,
        children: [
          ReviewCreator(
            maxLevel: appData.userData.data?.level ?? 60,
            onPressedCallback: getReviewFromLocal,
          ),
        ],
      );
    }
  }

  ResultPage closeSection() {
    ResultData passedItems = ResultData(
      data: dataList!
          .where((element) => element.isCorrect == true)
          .map((e) => e.subjectItem)
          .toList(),
      dataLabel: 'Correct items',
      themeColor: Colors.green,
    );

    ResultData failedItems = ResultData(
      data: dataList!
          .where((element) => element.isCorrect == false)
          .map((e) => e.subjectItem)
          .toList(),
      dataLabel: 'Incorrect items',
      themeColor: Colors.red,
    );

    ResultData untouchItems = ResultData(
      data: dataList!
          .where((element) => element.isCorrect == null)
          .map((e) => e.subjectItem)
          .toList(),
      dataLabel: 'Unreviewed items',
      themeColor: Colors.black,
    );

    dataList = [];
    reviewInProgress = false;
    vocabDisclaim = false;

    sharedPreferences.remove('dataList');
    sharedPreferences.remove('isKanji');
    sharedPreferences.remove('isToEN');
    sharedPreferences.remove('kanjiOnFront');

    setState(() {});

    return ResultPage(
      listData: [passedItems, failedItems, untouchItems],
      title: 'Self-study result',
      titleTheme: Colors.indigo,
    );
  }

  revealAll() {
    dataList?.forEach((element) {
      element.isRevealed = true;
    });

    setState(() {});
  }

  dataCallback(bool toSetState) async {
    await saveReview();
    if (toSetState) {
      setState(() {
        if (dataList!.where((element) => element.isCorrect == null).isEmpty) {
          var page = closeSection();

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => page,
            ),
          );
        }
      });
    }
  }

  initReviewIfExist() async {
    await appData.assertDataIsLoaded();

    sharedPreferences = await SharedPreferences.getInstance();

    // showLoaderDialog(context, "Loading data");

    if (widget.listKanji != null && widget.listVocab != null) {
      print("Create critical item review");

      try {
        dataList = [];

        for (var item in widget.listKanji!) {
          dataList!.add(SubjectItem(
              subjectItem: item, isRevealed: false, isCorrect: null));
        }

        for (var item in widget.listVocab!) {
          dataList!.add(SubjectItem(
              subjectItem: item, isRevealed: false, isCorrect: null));
        }

        dataList!.shuffle();

        isKanji = null;
        isToEN = widget.kanjiOnFront != null;
        kanjiOnFront = widget.kanjiOnFront ?? false;
        isAudio = false;

        setState(() {
          reviewInProgress = true;
        });

        saveReview();
      } catch (e) {
        print(e);
      }
    } else {
      print("Load review");
      try {
        final List<String>? items = sharedPreferences.getStringList('dataList');

        if (items == null) {
          setState(() {
            reviewInProgress = false;
          });
          return;
        }

        isKanji = sharedPreferences.getBool('isKanji');
        isToEN = sharedPreferences.getBool('isToEN');
        kanjiOnFront = sharedPreferences.getBool('kanjiOnFront');
        isAudio = sharedPreferences.getBool('isAudio');

        dataList = [];
        for (var s in items) {
          var json = jsonDecode(s) as Map<String, dynamic>;
          Kanji? kanji = appData.allKanjiData!
              .firstWhereOrNull((element) => element.id == json["itemId"]);

          if (kanji != null) {
            dataList!.add(SubjectItem(
                subjectItem: kanji,
                isRevealed: json["isRevealed"],
                isCorrect: json["isCorrect"]));
          }

          Vocab? vocab = appData.allVocabData!
              .firstWhereOrNull((element) => element.id == json["itemId"]);

          if (vocab != null) {
            dataList!.add(SubjectItem(
                subjectItem: vocab,
                isRevealed: json["isRevealed"],
                isCorrect: json["isCorrect"]));
          }
        }

        setState(() {
          reviewInProgress = true;
        });
      } on Exception catch (e) {
        print(e);
      }
    }

    // Navigator.of(context, rootNavigator: true).pop(true);
  }

  saveReview() async {
    if (dataList == null || isToEN == null || kanjiOnFront == null) {
      return;
    }

    var toSave = dataList!
        .map((e) => jsonEncode({
              "isRevealed": e.isRevealed,
              "isCorrect": e.isCorrect,
              "itemId": e.subjectItem.id,
            }))
        .toList();

    await sharedPreferences.setStringList('dataList', toSave);
    if (isKanji != null) {
      await sharedPreferences.setBool('isKanji', isKanji!);
    } else {
      await sharedPreferences.remove('isKanji');
    }
    await sharedPreferences.setBool('isToEN', isToEN!);
    await sharedPreferences.setBool('kanjiOnFront', kanjiOnFront!);
    await sharedPreferences.setBool('isAudio', isAudio!);
  }

  revealAllItemConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reveal all item?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              revealAll();
              Navigator.pop(context);
            },
            child: const Text('Reveal all'),
          ),
        ],
      ),
    ).then((value) {});
  }

  closeSectionConfirmDialog() {
    var remain = dataList
            ?.where((element) => element.isCorrect == null)
            .toList()
            .length ??
        0;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End section'),
        content: RichText(
          text: TextSpan(
            children: <TextSpan>[
              TextSpan(
                text: "There'${remain > 1 ? "re" : "s"} ",
                style: const TextStyle(color: Colors.black),
              ),
              TextSpan(
                text: '$remain',
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold),
              ),
              const TextSpan(
                text: " remained.\nDo you want to end this section?",
                style: TextStyle(color: Colors.black),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                ResultPage page = closeSection();

                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => page,
                  ),
                );
              } on Exception catch (e) {
                print(e);
                Navigator.pop(context);
              }
            },
            child: const Text('Close section'),
          ),
        ],
      ),
    ).then((value) {});
  }

  void reinitializePage() {
    initState();
  }
}
