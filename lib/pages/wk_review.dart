import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart';
import 'package:kana_kit/kana_kit.dart';
import 'package:my_kanji_app/data/kanji.dart';
import 'package:my_kanji_app/data/radical.dart';
import 'package:my_kanji_app/data/shared.dart';
import 'package:my_kanji_app/data/vocab.dart';
import 'package:my_kanji_app/data/wk_review_respone.dart';
import 'package:my_kanji_app/data/wk_review_stat.dart';
import 'package:my_kanji_app/data/wk_srs_stat.dart';
import 'package:my_kanji_app/pages/kanji_info_page.dart';
import 'package:my_kanji_app/pages/radical_info_page.dart';
import 'package:my_kanji_app/pages/result_page.dart';
import 'package:my_kanji_app/pages/vocab_info_page.dart';
import 'package:my_kanji_app/service/api.dart';
import 'package:my_kanji_app/utility/ult_func.dart';
import 'package:string_similarity/string_similarity.dart';
import 'package:collection/collection.dart';

class WkReviewPage extends StatefulWidget {
  const WkReviewPage({super.key, required this.reviewItems}) : isReview = true;

  const WkReviewPage.createLessonQuiz({super.key, required this.reviewItems})
      : isReview = false;

  final List<dynamic> reviewItems;
  final bool isReview;

  @override
  State<WkReviewPage> createState() => _WkReviewPageState();
}

class _WkReviewPageState extends State<WkReviewPage> {
  late List<dynamic> reviewItems;
  late bool isReview;

  List<ReviewItem> standByList = [];
  List<ReviewItem> draftList = [];
  List<ReviewItem> completedList = [];
  List<ReviewItem> abandonedList = [];

  late int currIndex;
  late bool isReadingAsked;

  Random random = Random();

  bool showInfo = false;
  bool? result;

  // ----
  final meaningInput = TextEditingController();
  final readingInput = TextEditingController();
  final focusNodeReading = FocusNode();
  final focusNodeMeaning = FocusNode();

  bool isMeaningCorrect = true;
  bool isMeaningSlightlyWrong = false;
  bool isReadingCorrect = true;

  final kanaKit = const KanaKit();
  // ----

  @override
  void initState() {
    super.initState();

    reviewItems = widget.reviewItems;
    isReview = widget.isReview;

    // TODO: REMOVE
    // reviewItems = appData.allRadicalData!.where((element) => element.data?.level == 9).map((e) => e as dynamic).toList();
    //

    standByList = reviewItems.map((e) => ReviewItem(data: e)).toList();

    standByList.shuffle();

    draftList = standByList.take(appData.reviewDraftSize).toList();

    standByList =
        standByList.where((element) => !draftList.contains(element)).toList();

    pickFromDraft();
  }

  // ///////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        await showAbandonDialog(context).then((confirm) {
          if (confirm != null && confirm) {
            toResultPage();
          }
        });
      },
      child: Scaffold(
        appBar: AppBar(
          title: isReview ? const Text("Review") : const Text("Quiz"),
          backgroundColor: Colors.blue,
          actions: [
            if (isReview)
              IconButton(
                icon: const Icon(
                  Icons.more_vert,
                  color: Colors.black,
                ),
                onPressed: () => showAppBarMenu(context),
              ),
          ],
        ),
        backgroundColor: Colors.grey.shade300,
        body: draftList.isNotEmpty
            ? GestureDetector(
                onTap: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                child: Column(
                  children: [
                    getQuestionField(),
                    getControllButtons(),
                    getAnswerField(),
                    if (showInfo)
                      Expanded(child: getInfoPage(draftList[currIndex].data))
                    else if (result != null)
                      getInfoButton(),
                  ],
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  // ///////////////////////////////////////////////////

  void pickFromDraft() {
    currIndex = random.nextInt(draftList.length);

    if (draftList[currIndex].data is Vocab) {
      Vocab vocab = draftList[currIndex].data;

      if (vocab.data != null && vocab.data!.readings == null) {
        draftList[currIndex].readingAnswered = true;
      }
    }

    if (draftList[currIndex].data is Radical) {
      draftList[currIndex].readingAnswered = true;
      result = true;
    }

    if (!draftList[currIndex].meaningAnswered &&
        !draftList[currIndex].readingAnswered) {
      // Pick random
      isReadingAsked = random.nextBool();
    } else {
      if (draftList[currIndex].meaningAnswered) {
        // If meaning is answered pick reading
        isReadingAsked = true;
      } else if (draftList[currIndex].readingAnswered) {
        // If reading is answered pick meaning
        isReadingAsked = false;
      }
    }

    focusNodeMeaning.requestFocus();
    focusNodeReading.requestFocus();
  }

  // ================
  Widget getControllButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: () {
              if (result == null) {
                focusNodeMeaning.unfocus();
                focusNodeReading.unfocus();
                setState(() {
                  result = false;
                  showInfo = true;
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: result == null
                  ? Colors.blue
                  : const Color.fromARGB(255, 128, 195, 250),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 15),
            ),
            child: const Text(
              "Don't know",
              style: TextStyle(fontSize: 18),
            ),
          ),
          Text(
            "${completedList.length}/${reviewItems.length}",
            style: const TextStyle(fontSize: 16, color: Colors.black),
          ),
          ElevatedButton.icon(
            onPressed: () {
              focusNodeMeaning.unfocus();
              focusNodeReading.unfocus();
              if (result == null) {
                onSubmitPressed();
              } else {
                recordAnswer();
              }
            },
            icon: result != null
                ? result!
                    ? const Icon(
                        Icons.check,
                        color: Colors.lightGreen,
                      )
                    : const Icon(
                        Icons.close,
                        color: Colors.red,
                      )
                : const SizedBox.shrink(),
            label: Text(
              result == null ? "Submit" : "Next",
              style: const TextStyle(fontSize: 18),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0.0),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget getQuestionField() {
    Kanji? kanji;
    Vocab? vocab;
    Radical? radical;

    if (draftList[currIndex].data is Kanji) {
      kanji = draftList[currIndex].data;
    }
    if (draftList[currIndex].data is Vocab) {
      vocab = draftList[currIndex].data;
    }
    if (draftList[currIndex].data is Radical) {
      radical = draftList[currIndex].data;
    }

    var question = kanji != null
        ? kanji.data?.characters
        : vocab != null
            ? vocab.data?.characters
            : radical?.data?.characters;

    var svg = radical?.data!.characterImages
        ?.firstWhereOrNull((element) => element.contentType == "image/svg+xml");

    Future<String?>? svgString;
    if (svg?.url != null) {
      svgString = getSvgString(svg!.url!);
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          width: double.infinity,
          decoration: BoxDecoration(
              color: kanji != null
                  ? Colors.pink
                  : vocab != null
                      ? Colors.purple.shade700
                      : Colors.lightBlue),
          child: Column(
            children: [
              if (kanji != null ||
                  vocab != null ||
                  question != null ||
                  (radical != null && svgString == null))
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    question ?? "N/A",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 72,
                    ),
                  ),
                )
              else
                futureWidget(getSvg(svgString), true, true),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(5),
          width: double.infinity,
          decoration: const BoxDecoration(color: Colors.black),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: kanji != null
                        ? 'Kanji'
                        : vocab != null
                            ? 'Vocab'
                            : 'Radical',
                    style: const TextStyle(),
                  ),
                  TextSpan(
                    text: isReadingAsked ? ' reading' : ' meaning',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget getAnswerField() {
    if (!isReadingAsked) {
      // Meaning question
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Column(
          children: [
            Focus(
              onFocusChange: (hasFocus) {
                checkMeaningAnswer();
              },
              child: TextField(
                focusNode: focusNodeMeaning,
                controller: meaningInput,
                onSubmitted: (String value) {
                  meaningInput.text = value;
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue[300]!),
                  ),
                  prefixIcon: const Icon(Icons.lightbulb_outline),
                  suffixIcon: meaningInput.text.trim() == ""
                      ? const SizedBox.shrink()
                      : (isMeaningCorrect
                          ? Icon(
                              Icons.check,
                              color: isMeaningSlightlyWrong
                                  ? const Color.fromARGB(255, 167, 150, 2)
                                  : Colors.lightGreen,
                            )
                          : const Icon(
                              Icons.close,
                              color: Colors.red,
                            )),
                  hintText: "Answer",
                  hintStyle: const TextStyle(
                    color: Colors.grey,
                    fontSize: 18,
                  ),
                ),
                style: const TextStyle(fontSize: 20.0),
              ),
            ),
            isMeaningSlightlyWrong
                ? const Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Text(
                      "Answer is a bit off. Double check the meaning.",
                      style: TextStyle(color: Color.fromARGB(255, 146, 132, 6)),
                      textAlign: TextAlign.left,
                    ),
                  )
                : const SizedBox.shrink(),
          ],
        ),
      );
    } else {
      // Reading question
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Focus(
          onFocusChange: (hasFocus) {
            checkReadingAnswer();
          },
          child: TextField(
            focusNode: focusNodeReading,
            controller: readingInput,
            onChanged: (String value) {
              int cursorPosition = readingInput.selection.baseOffset;

              if (value.isNotEmpty && value[value.length - 1] == "n") {
                if (value.length > 1 && value[value.length - 2] == "n") {
                  readingInput.text =
                      kanaKit.toHiragana(value.substring(0, value.length - 1));
                } else {
                  readingInput.text =
                      "${kanaKit.toHiragana(value.substring(0, value.length - 1))}n";
                }
              } else {
                readingInput.text = kanaKit.toHiragana(value);
              }

              if (value.length != readingInput.text.length) {
                cursorPosition =
                    cursorPosition - (value.length - readingInput.text.length);
              }

              readingInput.selection = TextSelection.fromPosition(
                TextPosition(offset: cursorPosition),
              );
            },
            onSubmitted: (value) {},
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue[300]!),
              ),
              prefixIcon: const Icon(Icons.volume_up),
              suffixIcon: readingInput.text.trim() == ""
                  ? const SizedBox.shrink()
                  : (isReadingCorrect
                      ? const Icon(
                          Icons.check,
                          color: Colors.lightGreen,
                        )
                      : const Icon(
                          Icons.close,
                          color: Colors.red,
                        )),
              hintText: "答え",
              hintStyle: const TextStyle(
                color: Colors.grey,
                fontSize: 18,
              ),
            ),
            style: const TextStyle(fontSize: 20.0),
          ),
        ),
      );
    }
  }

  Widget getInfoButton() {
    return ElevatedButton(
      onPressed: () {
        focusNodeMeaning.unfocus();
        focusNodeReading.unfocus();
        setState(() {
          showInfo = true;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(0.0), // Set to 0 for sharp corners
        ),
      ),
      child: const Text(
        "Item info",
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  // -------
  void onSubmitPressed() {
    if (!isReadingAsked) {
      checkMeaningAnswer();
    } else {
      checkReadingAnswer();
    }
  }

  void onSubmitAnswer() {
    result = isMeaningCorrect && isReadingCorrect;
  }

  Future<void> recordAnswer() async {
    if (draftList.isEmpty) {
      toResultPage();
      return;
    }

    // Kanji? kanji;
    // Vocab? vocab;

    // if (draftList[currIndex].data is Kanji) {
    //   kanji = draftList[currIndex].data;
    // }
    // if (draftList[currIndex].data is Vocab) {
    //   vocab = draftList[currIndex].data;
    // }

    String? char = draftList[currIndex].data.data?.slug;

    if (result == null) return;
    // -- Record result
    if (result!) {
      if (isReadingAsked) {
        draftList[currIndex].readingAnswered = true;
      } else {
        draftList[currIndex].meaningAnswered = true;
      }
    } else {
      if (isReadingAsked) {
        draftList[currIndex].incorrectReadingAnswers += 1;
      } else {
        draftList[currIndex].incorrectMeaningAnswers += 1;
      }
    }

    Future<void> requestTask = Future.delayed(Duration.zero);

    // -- Check if item is completed?
    if (draftList[currIndex].readingAnswered &&
        draftList[currIndex].meaningAnswered) {
      // To do: Send review result/assignment init based on page type
      if (isReview) {
        requestTask =
            sendReviewResult(draftList[currIndex]).onError((error, stackTrace) {
          print(error);
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("$char Unexpected error")));
        });
      } else {
        requestTask = startItemAssignment(draftList[currIndex].data)
            .onError((error, stackTrace) {
          print(error);
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("$char Unexpected error")));
        });
      }

      // Move item to completedList
      completedList.add(draftList[currIndex]);
      draftList.removeAt(currIndex);

      // Draft new item
      if (standByList.isNotEmpty) {
        var ind = random.nextInt(standByList.length);
        draftList.add(standByList[ind]);
        standByList.removeAt(ind);
      }
    }

    // If draftList is empty <=> finished review
    if (draftList.isEmpty) {
      showLoaderDialog(context, "Sending data");
      await requestTask;
      Navigator.pop(context, true);
      toResultPage();
      return;
    }

    // -- Reset varible
    showInfo = false;
    result = null;

    meaningInput.text = "";
    readingInput.text = "";

    isMeaningCorrect = true;
    isMeaningSlightlyWrong = false;
    isReadingCorrect = true;

    // -- Pick new review
    pickFromDraft();

    setState(() {});
  }

  void toResultPage() {
    if (isReview) {
      ResultData incorrectData = ResultData(
        data: completedList
            .where((element) =>
                element.incorrectMeaningAnswers +
                    element.incorrectReadingAnswers >
                0)
            .map((e) => e.data)
            .toList(),
        dataLabel: "Incorrect items",
        themeColor: Colors.red,
      );

      ResultData correctData = ResultData(
        data: completedList
            .where((element) =>
                element.incorrectMeaningAnswers +
                    element.incorrectReadingAnswers ==
                0)
            .map((e) => e.data)
            .toList(),
        dataLabel: "Correct items",
        themeColor: Colors.blue,
      );

      ResultData abandonedData = ResultData(
        data: (draftList + standByList + abandonedList)
            .map((e) => e.data)
            .toList(),
        dataLabel: "Abandoned items",
        themeColor: Colors.black,
      );

      Navigator.pop(context, true);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultPage(
              listData: [correctData, incorrectData, abandonedData],
              title: "Review result",
              titleTheme: Colors.blue),
        ),
      );
    } else {
      ResultData data = ResultData(
        data: completedList.map((e) => e.data).toList(),
        dataLabel: "New items learned",
        themeColor: Colors.red,
      );

      Navigator.pop(context, true);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultPage(
              listData: [data], title: "Lesson result", titleTheme: Colors.red),
        ),
      );
    }
  }

  void checkMeaningAnswer() {
    // Kanji? kanji;
    // Vocab? vocab;
    // Radical? radical;

    // if (draftList[currIndex].data is Kanji) {
    //   kanji = draftList[currIndex].data;
    // }
    // if (draftList[currIndex].data is Vocab) {
    //   vocab = draftList[currIndex].data;
    // }
    // if (draftList[currIndex].data is Radical) {
    //   radical = draftList[currIndex].data;
    // }

    if (meaningInput.text.trim() == "") {
      setState(() {
        isMeaningCorrect = true;
        isMeaningSlightlyWrong = false;
      });

      meaningInput.text = meaningInput.text.trim();
    } else {
      // var meaning =
      //     kanji != null ? kanji.data?.meanings : vocab!.data?.meanings;
      // var auxMeaning = kanji != null
      //     ? kanji.data?.auxiliaryMeanings
      //     : vocab!.data?.auxiliaryMeanings;
      var meaning = draftList[currIndex].data.data?.meanings;
      var auxMeaning = draftList[currIndex].data.data?.auxiliaryMeanings;

      if (meaning == null) {
        return;
      }
      if (auxMeaning != null) {
        meaning = meaning + auxMeaning;
      }

      setState(() {
        isMeaningCorrect = meaning
            ?.where((e) =>
                (e.meaning?.toLowerCase() as String)
                    .similarityTo(meaningInput.text.toLowerCase()) >=
                0.75)
            .toList()
            .isNotEmpty as bool;

        isMeaningSlightlyWrong = isMeaningCorrect &&
            meaning
                ?.where((e) =>
                    e.meaning?.toLowerCase() == meaningInput.text.toLowerCase())
                .toList()
                .isEmpty as bool;

        onSubmitAnswer();
      });
      // print("${readingInput.text} - ${meaning.map((e) => e.meaning)}");
    }
  }

  void checkReadingAnswer() {
    Kanji? kanji; // RADICAL FIXED
    Vocab? vocab;

    if (draftList[currIndex].data is Kanji) {
      kanji = draftList[currIndex].data;
    }
    if (draftList[currIndex].data is Vocab) {
      vocab = draftList[currIndex].data;
    }
    if (draftList[currIndex].data is Radical) {
      return;
    }

    readingInput.text = kanaKit.toHiragana(readingInput.text);

    if (readingInput.text.trim() == "") {
      setState(() {
        isReadingCorrect = true;
      });

      readingInput.text = readingInput.text.trim();
    } else {
      var reading =
          kanji != null ? kanji.data?.readings : vocab!.data?.readings;

      if (reading == null) {
        return;
      }

      setState(() {
        isReadingCorrect = reading
            .where((e) =>
                e.reading?.toLowerCase() == readingInput.text.toLowerCase())
            .toList()
            .isNotEmpty;

        onSubmitAnswer();
      });
      // print("${readingInput.text} - ${reading.map((e) => e.reading)}");
    }
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

  Future<void> startItemAssignment(item) async {
    var srsData = item.srsData;

    if (srsData != null) {
      await assignmentStart(srsData.id).then((response) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: RichText(
                    text: TextSpan(
                      children: <TextSpan>[
                        TextSpan(
                          text: item.data?.slug,
                          style: const TextStyle(fontSize: 20),
                        ),
                        const TextSpan(
                          text: " added to review queue",
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        } else {
          print(response.body);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                  "${item.data?.characters ?? item.data?.slug} error '${(jsonDecode(response.body) as Map<String, dynamic>)["error"]}'")));
        }
      }, onError: (error) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error $error")));
      });
    }

    // Kanji ? kanji;
    // Vocab? vocab;

    // if (item is Kanji) {
    //   kanji = item;
    // }
    // if (item is Vocab) {
    //   vocab = item;
    // }

    // if (kanji != null) {
    //   var srsData = kanji.srsData;
    //   if (srsData != null) {
    //     await assignmentStart(srsData.id).then((response) {
    //       if (response.statusCode == 200 || response.statusCode == 201) {
    //         ScaffoldMessenger.of(context).showSnackBar(
    //           SnackBar(
    //             content: Center(
    //               child: FittedBox(
    //                 fit: BoxFit.scaleDown,
    //                 child: RichText(
    //                   text: TextSpan(
    //                     children: <TextSpan>[
    //                       TextSpan(
    //                         text: kanji?.data?.characters,
    //                         style: const TextStyle(fontSize: 20),
    //                       ),
    //                       const TextSpan(
    //                         text: " added to review queue",
    //                         style: TextStyle(fontSize: 14),
    //                       ),
    //                     ],
    //                   ),
    //                 ),
    //               ),
    //             ),
    //           ),
    //         );
    //       } else {
    //         print(response.body);
    //         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //             content: Text(
    //                 "${kanji?.data?.characters} error '${(jsonDecode(response.body) as Map<String, dynamic>)["error"]}'")));
    //       }
    //     }, onError: (error) {
    //       ScaffoldMessenger.of(context)
    //           .showSnackBar(SnackBar(content: Text("Error $error")));
    //     });
    //   }
    // }
    // if (vocab != null) {
    //   var srsData = vocab.srsData;
    //   if (srsData != null) {
    //     await assignmentStart(srsData.id).then((response) {
    //       if (response.statusCode == 200 || response.statusCode == 201) {
    //         ScaffoldMessenger.of(context).showSnackBar(
    //           SnackBar(
    //             content: Center(
    //               child: FittedBox(
    //                 fit: BoxFit.scaleDown,
    //                 child: RichText(
    //                   text: TextSpan(
    //                     children: <TextSpan>[
    //                       TextSpan(
    //                         text: vocab?.data?.characters,
    //                         style: const TextStyle(fontSize: 20),
    //                       ),
    //                       const TextSpan(
    //                         text: " added to review queue",
    //                         style: TextStyle(fontSize: 14),
    //                       ),
    //                     ],
    //                   ),
    //                 ),
    //               ),
    //             ),
    //           ),
    //         );
    //       } else {
    //         print(response.body);
    //         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //             content: Text(
    //                 "${vocab?.data?.characters} error '${(jsonDecode(response.body) as Map<String, dynamic>)["error"]}'")));
    //       }
    //     }, onError: (error) {
    //       ScaffoldMessenger.of(context)
    //           .showSnackBar(SnackBar(content: Text("Error $error")));
    //     });
    //   }
    // }
  }

  Future<void> sendReviewResult(ReviewItem data) async {
    await createReview(data.data.id!, data.data.data!.slug!,
            data.incorrectMeaningAnswers, data.incorrectReadingAnswers)
        .onError(
      (error, stackTrace) {
        print(error);
        print(stackTrace);

        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error $error")));
      },
    );
  }

  Future<void> createReview(
      int id, String char, int meaningIncorrect, int readingIncorrect) async {
    await reviewRequest(id, meaningIncorrect, readingIncorrect).then(
      (response) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          WkReviewRespone body = WkReviewRespone.fromJson(
              jsonDecode(response.body) as Map<String, dynamic>);

          var srs = body.resourcesUpdated?.assignment?.data?.getSrs();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                // content: Center(
                //   child: Text(
                //     "$char - SRS level: ${srs?.label}",
                //     style: TextStyle(color: srs?.textColor, fontSize: 16),
                //     textAlign: TextAlign.center,
                //   ),
                // ),
                content: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: RichText(
                      text: TextSpan(
                        children: <TextSpan>[
                          TextSpan(
                            text: char,
                            style:
                                TextStyle(color: srs?.textColor, fontSize: 20),
                          ),
                          TextSpan(
                            text: "   SRS level: ${srs?.label}",
                            style:
                                TextStyle(color: srs?.textColor, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                backgroundColor: srs?.color),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  "$char something went wrong. '${(jsonDecode(response.body) as Map<String, dynamic>)["error"]}'"),
            ),
          );
        }
      },
      onError: (error) {
        print(error);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error $error")));
      },
    );
  }

  // ---------------------------------
  Future<bool?> showAbandonDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Abandon review section?'),
        content: RichText(
          text: TextSpan(
            children: [
              const TextSpan(
                text: "Remaining ",
                style: TextStyle(),
              ),
              TextSpan(
                text: "${draftList.length + standByList.length}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text:
                    " item${draftList.length + standByList.length > 1 ? "s" : ""} will be discarded.",
                style: const TextStyle(),
              ),
            ],
            style: const TextStyle(
              color: Colors.black,
            ),
          ),
        ),
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

  void showAppBarMenu(BuildContext context) {
    showMenu<int>(
      context: context,
      position: RelativeRect.fromLTRB(MediaQuery.of(context).size.width * 0.8,
          MediaQuery.of(context).size.height * 0.05, 0, 0),
      items: <PopupMenuEntry<int>>[
        PopupMenuItem<int>(
          value: 1,
          child: const Text('Wrap up section'),
          onTap: () async {
            await showConfirmDialog(context).then(
              (value) {
                if (value ?? false) {
                  abandonedList = standByList +
                      draftList
                          .where((element) =>
                              !element.meaningAnswered &&
                              !element.readingAnswered)
                          .toList();
                  var abandonedListData =
                      abandonedList.map((e) => e.data).toList();
                  standByList = [];
                  reviewItems = reviewItems
                      .where((element) => !abandonedListData.contains(element))
                      .toList();
                  draftList = draftList
                      .where((element) =>
                          element.meaningAnswered || element.readingAnswered)
                      .toList();

                  if (draftList.isEmpty) {
                    toResultPage();
                  } else {
                    pickFromDraft();
                    result = null;
                    setState(() {});
                  }
                }
              },
            );
          },
        ),
        PopupMenuItem<int>(
          value: 2,
          child: const Text('Abandon section'),
          onTap: () async {
            await showAbandonDialog(context).then((confirm) {
              if (confirm != null && confirm) {
                toResultPage();
              }
            });
          },
        ),
      ],
    );
  }

  Future<bool?> showConfirmDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Wrap up section?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  Future<Widget> getSvg(Future<String?>? svgString) async {
    if (svgString == null) {
      return const SizedBox.shrink();
    }
    var svg = await svgString;

    if (svg != null) {
      return SvgPicture.string(
        svg,
        height: MediaQuery.of(context).size.width * 0.3,
        width: MediaQuery.of(context).size.width * 0.3,
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  @override
  void dispose() {
    focusNodeMeaning.unfocus();
    focusNodeReading.unfocus();

    super.dispose();

    if (completedList.isNotEmpty) {
      appData.getData();
    }
  }
}

class ReviewItem {
  final dynamic data;
  // null = not yet review, 0 = correct, else +1 every error
  int incorrectMeaningAnswers = 0;
  bool meaningAnswered = false;
  int incorrectReadingAnswers = 0;
  bool readingAnswered = false;
  // Respone when review is sent
  WkReviewRespone? respone;
  // Respone when assignment started is sent
  WkReviewStatData? lessonRespone;

  ReviewItem({required this.data});
}
