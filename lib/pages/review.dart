import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:my_kanji_app/component/list.dart';
import 'package:my_kanji_app/component/selector.dart';
import 'package:my_kanji_app/data/kanji.dart';
import 'package:my_kanji_app/data/kanji_set.dart';
import 'package:my_kanji_app/data/shared.dart';
import 'package:my_kanji_app/data/user.dart';
import 'package:my_kanji_app/data/vocab.dart';
import 'package:my_kanji_app/service/api.dart';
import 'dart:convert';

class Review extends StatefulWidget {
  const Review({super.key});

  @override
  State<Review> createState() => _ReviewState();
}

class _ReviewState extends State<Review> {
  List<SubjectItem>? dataList;
  List<SubjectItem>? dataListResult;
  bool? isKanji;
  bool? isToEN;

  final User user = User();

  late bool reviewInProgress;

  @override
  void initState() {
    super.initState();

    reviewInProgress = false;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            getSelector(),
            SubjectList(
              data: dataList,
              isToEN: isToEN,
              isKanji: isKanji,
              dataCheckCallback: dataCallback,
            ),
          ],
        ),
      ),
    );
  }

  getReview(String types, int levels, bool toEn, String? nonWani) async {
    late Response response, response2;

    if (types != "kanji") {
      types = "vocabulary";
    }
    ;

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
        });
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(response.body)));
      print(response.body);
    }
  }

  getSelector() {
    if (reviewInProgress) {
      return ExpansionTile(
        title: const Center(
          child: Text(
            "Review in progress",
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
            ),
          ),
        ),
        leading: const Icon(Icons.bookmark_outline),
        initiallyExpanded: true,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
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
                                setState(() {
                                  revealAll();
                                });
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
                        backgroundColor:
                            const Color.fromARGB(255, 255, 103, 103),
                        shape: ContinuousRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      onPressed: () {
                        setState(() {
                          closeSection();
                        });
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
              ],
            ),
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
            maxLevel: user.userData.data?.level ?? 60,
            onPressedCallback: getReview,
          ),
        ],
      );
    }
  }

  closeSection() {
    dataListResult = dataList;
    dataList = [];
    reviewInProgress = false;
  }

  revealAll() {
    dataList?.forEach((element) {
      element.isRevealed = true;
    });
  }

  dataCallback() {
    setState(() {
      if (dataList!.where((element) => element.isCorrect == null).isEmpty) {
        closeSection();
      }
    });
  }
}
