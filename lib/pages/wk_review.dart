import 'dart:math';

import 'package:flutter/material.dart';
import 'package:kana_kit/kana_kit.dart';
import 'package:my_kanji_app/data/kanji.dart';
import 'package:my_kanji_app/data/vocab.dart';
import 'package:my_kanji_app/data/wk_review_respone.dart';
import 'package:my_kanji_app/data/wk_review_stat.dart';
import 'package:my_kanji_app/pages/kanji_info_page.dart';
import 'package:my_kanji_app/pages/vocab_info_page.dart';
import 'package:my_kanji_app/service/api.dart';
import 'package:my_kanji_app/utility/ult_func.dart';
import 'package:string_similarity/string_similarity.dart';

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
  late final List<dynamic> reviewItems;
  late final bool isReview;

  List<ReviewItem> standByList = [];
  List<ReviewItem> draftList = [];
  List<ReviewItem> completedList = [];

  late int currIndex;
  late bool isReadingAsked;

  Random random = Random();

  bool showInfo = false;
  bool? result;

  // ----
  final meaningInput = TextEditingController();

  final readingInput = TextEditingController();

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

        await showAbandoneDialog(context).then((confirm) {
          if (confirm != null && confirm) {
            Navigator.pop(context, true);
          }
        });
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Review"),
          backgroundColor: Colors.blue,
        ),
        backgroundColor: Colors.grey.shade300,
        body: GestureDetector(
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
              else
                getInfoButton(),
            ],
          ),
        ),
      ),
    );
  }

  // ///////////////////////////////////////////////////

  void pickFromDraft() {
    currIndex = random.nextInt(draftList.length);

    if (draftList[currIndex].data is Vocab) {
      Vocab vocab = draftList[currIndex].data;

      if (vocab.data != null && vocab.data!.readings == null) {
        draftList[currIndex].incorrectReadingAnswers = 0;
      }
    }

    if (draftList[currIndex].incorrectMeaningAnswers == null &&
        draftList[currIndex].incorrectReadingAnswers == null) {
      isReadingAsked = random.nextBool();
    } else {
      if (draftList[currIndex].incorrectMeaningAnswers != null) {
        isReadingAsked = false;
      } else if (draftList[currIndex].incorrectReadingAnswers != null) {
        isReadingAsked = true;
      }
    }
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
              setState(() {
                result = false;
                showInfo = true;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: result == null
                  ? Colors.blue
                  : const Color.fromARGB(255, 128, 195, 250),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0.0),
              ),
            ),
            child: const Text(
              "Don't know",
              style: TextStyle(fontSize: 18),
            ),
          ),
          Text(
            "${completedList.length}/${draftList.length + standByList.length}",
            style: const TextStyle(fontSize: 16, color: Colors.black),
          ),
          ElevatedButton.icon(
            onPressed: () {},
            icon: result != null
                ? result!
                    ? const Icon(
                        Icons.check,
                        color: Colors.green,
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
              backgroundColor: result == null
                  ? const Color.fromARGB(255, 128, 195, 250)
                  : Colors.blue,
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

    if (draftList[currIndex].data is Kanji) {
      kanji = draftList[currIndex].data;
    }
    if (draftList[currIndex].data is Vocab) {
      vocab = draftList[currIndex].data;
    }

    var question =
        kanji != null ? kanji.data?.characters : vocab?.data?.characters;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          width: double.infinity,
          decoration: BoxDecoration(
              color: kanji != null ? Colors.pink : Colors.purple.shade700),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              question ?? "N/A",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 72,
              ),
            ),
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
                    text: kanji != null ? 'Kanji' : 'Vocab',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: isReadingAsked ? ' reading' : ' meaning',
                    style: const TextStyle(),
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
    Kanji? kanji;
    Vocab? vocab;

    if (draftList[currIndex].data is Kanji) {
      kanji = draftList[currIndex].data;
    }
    if (draftList[currIndex].data is Vocab) {
      vocab = draftList[currIndex].data;
    }

    if (!isReadingAsked) {
      // Meaning question
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Column(
          children: [
            Focus(
              onFocusChange: (hasFocus) {
                if (meaningInput.text.trim() == "") {
                  setState(() {
                    isMeaningCorrect = true;
                    isMeaningSlightlyWrong = false;
                  });

                  meaningInput.text = meaningInput.text.trim();
                } else {
                  var meaning = kanji != null
                      ? kanji.data?.meanings
                      : vocab!.data?.meanings;
                  var auxMeaning = kanji != null
                      ? kanji.data?.auxiliaryMeanings
                      : vocab!.data?.auxiliaryMeanings;

                  if (meaning == null) {
                    return;
                  }
                  if (auxMeaning != null) {
                    meaning = meaning + auxMeaning;
                  }

                  setState(() {
                    isMeaningCorrect = meaning
                        ?.where((e) =>
                            (e.meaning?.toLowerCase() as String).similarityTo(
                                meaningInput.text.toLowerCase()) >=
                            0.75)
                        .toList()
                        .isNotEmpty as bool;

                    isMeaningSlightlyWrong = isMeaningCorrect &&
                        meaning
                            ?.where((e) =>
                                e.meaning?.toLowerCase() ==
                                meaningInput.text.toLowerCase())
                            .toList()
                            .isEmpty as bool;
                  });
                  // print("${readingInput.text} - ${meaning.map((e) => e.meaning)}");
                }
              },
              child: TextField(
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
                                  ? Colors.yellow
                                  : Colors.green,
                            )
                          : const Icon(
                              Icons.close,
                              color: Colors.red,
                            )),
                  hintText: "Meaning",
                  hintStyle: const TextStyle(
                    color: Colors.grey,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            isMeaningSlightlyWrong
                ? const Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Text(
                      "Answer is a bit off. Double check the meaning.",
                      style:
                          TextStyle(color: Color.fromARGB(255, 199, 184, 46)),
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
                        e.reading?.toLowerCase() ==
                        readingInput.text.toLowerCase())
                    .toList()
                    .isNotEmpty;
              });
              // print("${readingInput.text} - ${reading.map((e) => e.reading)}");
            }
          },
          child: TextField(
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
                          color: Colors.green,
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
          ),
        ),
      );
    }
  }

  Widget getInfoButton() {
    return ElevatedButton(
      onPressed: () {
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
  void onSubmitAnswer() {
    result = isMeaningCorrect || isReadingCorrect;
  }

  void recordAnswer() {
    if (result == null) return;
    // -- Record result
    if (result!) {
      if (isReadingAsked) {
        draftList[currIndex].incorrectReadingAnswers = 0;
      } else {
        draftList[currIndex].incorrectMeaningAnswers = 0;
      }
    } else {
      if (isReadingAsked) {
        draftList[currIndex].incorrectReadingAnswers =
            draftList[currIndex].incorrectReadingAnswers != null
                ? draftList[currIndex].incorrectReadingAnswers! + 1
                : 1;
      } else {
        draftList[currIndex].incorrectMeaningAnswers =
            draftList[currIndex].incorrectMeaningAnswers != null
                ? draftList[currIndex].incorrectMeaningAnswers! + 1
                : 1;
      }
    }

    // -- Check if item is completed?
    if(draftList[currIndex].incorrectReadingAnswers != null && draftList[currIndex].incorrectMeaningAnswers != null){
      // Move item to completedList
      completedList.add(draftList[currIndex]);
      draftList.removeAt(currIndex);

      // To do: Send review result/assignment init based on page type
      if(isReview){

      }else{

      }

      // Draft new item
      if(standByList.isNotEmpty){
        draftList.add(standByList[random.nextInt(standByList.length)]);
      }
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

    setState(() {
      
    });
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
      return KanjiPage.hideAppBar(kanji: kanji); // key: UniqueKey(),
    }

    if (vocab != null) {
      return VocabPage.hideAppBar(vocab: vocab);
    }

    return const SizedBox.shrink();
  }

  // ---------------------------------
  Future<bool?> showAbandoneDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Abandone review section?'),
        content: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "${completedList.length}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text:
                    " item${completedList.length > 1 ? "s" : ""} is recorded. ",
                style: const TextStyle(),
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
}

class ReviewItem {
  final dynamic data;
  // null = not yet review, 0 = correct, else +1 every error
  int? incorrectMeaningAnswers;
  int? incorrectReadingAnswers;
  // Respone when review is sent
  WkReviewRespone? respone;
  // Respone when assignment started is sent
  WkReviewStatData? lessonRespone;

  ReviewItem({required this.data});
}
