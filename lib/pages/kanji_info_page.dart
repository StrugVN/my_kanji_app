import 'package:collection/collection.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:my_kanji_app/data/app_data.dart';
import 'package:my_kanji_app/data/kanji.dart';
import 'package:my_kanji_app/data/kanji_set.dart';
import 'package:my_kanji_app/data/vocab.dart';
import 'package:my_kanji_app/pages/vocab_info_page.dart';
import 'package:my_kanji_app/service/api.dart';
import 'package:my_kanji_app/utility/ult_func.dart';
import 'package:unofficial_jisho_api/api.dart' as jisho;
import 'package:unofficial_jisho_api/api.dart';

class KanjiPage extends StatefulWidget {
  KanjiPage({super.key, required this.kanji, this.navigationList}) : hideAppBar = false;

  KanjiPage.hideAppBar({super.key, required this.kanji, this.navigationList}) : hideAppBar = true;

  final Kanji kanji;

  final List<Kanji>? navigationList;

  bool hideAppBar;

  @override
  State<KanjiPage> createState() => _KanjiPageState(kanji, navigationList);
}

class _KanjiPageState extends State<KanjiPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  int numberOfExample = 3;

  final Kanji kanji;

  final List<Kanji>? navigationList;

  late Future<KanjiResult> kanjiInfo;

  late Future<ExampleResults> example;

  _KanjiPageState(this.kanji, this.navigationList);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    kanjiInfo = jisho.searchForKanji(kanji.data!.characters!);
    example = jisho.searchForExamples(kanji.data!.characters!);

    if (kanji.data?.characters == null ||
        kanji.data?.level == null ||
        kanji.data?.meanings == null ||
        kanji.data?.readings == null) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: !widget.hideAppBar ? AppBar(
        title: Text(
          kanji.data!.characters ?? "",
          style: const TextStyle(color: Colors.white),
        ),
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
      ) : null,
      backgroundColor: Colors.grey.shade300,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      color: Colors.pinkAccent.shade400,
                    ),
                    child: Text(
                      kanji.data?.characters ?? "N/A",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 96,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          futureWidget(getUsageRate(), false, false),
                          Text(
                            'Wanikani lv.${kanji.data!.level}, JLPT N${jlpt(kanji.data!.characters!)}',
                          ),
                          const Divider(),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              kanji.data?.meanings!
                                      .map((e) => e.meaning)
                                      .join(", ") ??
                                  "",
                              style: const TextStyle(fontSize: 24),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
              RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    const TextSpan(
                      text: 'On: ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: kanji.data?.readings
                          ?.map((e) => e.type == "onyomi" ? e.reading : null)
                          .whereNotNull()
                          .join(", "),
                    ),
                  ],
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
              ),
              RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    const TextSpan(
                      text: 'Kun: ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: kanji.data?.readings
                          ?.map((e) => e.type == "kunyomi" ? e.reading : null)
                          .whereNotNull()
                          .join(", "),
                    ),
                  ],
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
              ),
              const Divider(color: Colors.black),
              futureWidget(stroke(), true, true),
              futureWidget(getExample(), false, false),
              getRelatedVocab(),
              getVisualySimilar(),
              getWkInfo(),
              mnemonic(),
            ],
          ),
        ),
      ),
    );
  }

  Future<Widget> getUsageRate() async {
    var info = await kanjiInfo;
    // var exp_phase = await jisho.searchForExamples(kanji.data!.characters!);

    // print(kanji.data!.characters!);

    // print(exp_phase.results.map((element) => "${element.kanji} - ${element.english}\n").toList());

    return Align(
      alignment: Alignment.topRight,
      child: RichText(
        textAlign: TextAlign.right,
        text: TextSpan(
          children: [
            TextSpan(
              text: "${info.data?.newspaperFrequencyRank}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const TextSpan(
              text: " of 2500 most used kanji",
            ),
          ],
          style: const TextStyle(color: Colors.black),
        ),
      ),
    );
  }

  Future<Widget> stroke() async {
    var info = await kanjiInfo;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Stroke order:",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SvgPicture.network(
                info.data!.strokeOrderSvgUri,
                height: MediaQuery.of(context).size.width * 0.4,
                width: MediaQuery.of(context).size.width * 0.4,
              ),
              Image(
                width: MediaQuery.of(context).size.width * 0.4,
                height: MediaQuery.of(context).size.width * 0.4,
                image: NetworkImage(info.data!.strokeOrderGifUri),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<Widget> getExample() async {
    // var info = await kanjiInfo;
    var exampleResults = await example;

    exampleResults.results.sort((a, b) => a.kanji.length - b.kanji.length);

    var exampleList = exampleResults.results
        .take(exampleResults.results.length > numberOfExample
            ? numberOfExample
            : exampleResults.results.length)
        .toList();

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Divider(color: Colors.black),
        const Align(
          alignment: Alignment.topLeft,
          child: Text(
            "Example sentences:",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        for (var sentence in exampleList)
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  alignment: WrapAlignment.start,
                  crossAxisAlignment: WrapCrossAlignment.start,
                  children: [
                    for (var item in fixFurigana(sentence.pieces))
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            item.lifted
                                    ?.replaceAll(" ", "")
                                    .replaceAll("\n", "") ??
                                "",
                            style: const TextStyle(fontSize: 12),
                          ),
                          Text(
                            item.unlifted
                                .replaceAll(" ", "")
                                .replaceAll("\n", ""),
                            style: const TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                  ],
                ),
                Text(
                  " - ${sentence.english}",
                  style: const TextStyle(fontSize: 17),
                ),
                const Gap(5),
              ],
            ),
          ),
        exampleResults.results.length > numberOfExample
            ? Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.grey[350],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: (exampleResults.results.length <= numberOfExample)
                            ? "Show Less"
                            : "Show More",
                        style: const TextStyle(color: Colors.blue),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            if (exampleResults.results.length <=
                                numberOfExample) {
                              setState(() {
                                numberOfExample = 3;
                              });
                            } else {
                              setState(() {
                                numberOfExample += 3;
                              });
                            }
                          },
                      ),
                    ],
                  ),
                ),
              )
            : const SizedBox.shrink(),
      ],
    );
  }

  Widget getRelatedVocab() {
    var relatedIds = kanji.data?.amalgamationSubjectIds;

    if (relatedIds == null || relatedIds.isEmpty) {
      return const SizedBox.shrink();
    }

    List<Vocab>? relatedVocab = AppData()
        .allVocabData
        ?.where((element) => relatedIds.contains(element.id))
        .toList();

    if (relatedVocab == null || relatedVocab.isEmpty) {
      return const SizedBox.shrink();
    }

    List<Widget> widgets = [];

    widgets.add(
      const Divider(color: Colors.black),
    );
    widgets.add(
      const Text(
        "Used in:",
        textAlign: TextAlign.left,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    for (var vocab in relatedVocab) {
      widgets.add(
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VocabPage(
                  vocab: vocab,
                ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.all(5.0),
            padding: const EdgeInsets.all(2.0),
            decoration: BoxDecoration(
              color: Colors.purple.shade600,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      vocab.data?.characters ?? "N/A",
                      style: const TextStyle(
                        fontSize: 32,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          vocab.data?.readings
                                  ?.firstWhereOrNull(
                                      (item) => item.primary == true)
                                  ?.reading ??
                              "N/A",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          vocab.data?.meanings
                                  ?.firstWhereOrNull(
                                      (item) => item.primary == true)
                                  ?.meaning ??
                              "N/A",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget getVisualySimilar() {
    var visualySimilarId = kanji.data?.visuallySimilarSubjectIds;

    if (visualySimilarId == null || visualySimilarId.isEmpty) {
      return const SizedBox.shrink();
    }

    List<Kanji>? similarKanji = AppData()
        .allKanjiData
        ?.where((element) => visualySimilarId.contains(element.id))
        .toList();

    if (similarKanji == null || similarKanji.isEmpty) {
      return const SizedBox.shrink();
    }

    List<Widget> widgets = [];

    widgets.add(
      const Divider(color: Colors.black),
    );
    widgets.add(
      const Text(
        "Visually similar:",
        textAlign: TextAlign.left,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    var gridList = <Widget>[];

    for (var kanji in similarKanji) {
      gridList.add(
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => KanjiPage(
                  kanji: kanji,
                ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.all(5.0),
            // padding: const EdgeInsets.all(3.0),
            decoration: BoxDecoration(
              color: Colors.red.shade500,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  kanji.data?.characters ?? "N/A",
                  style: const TextStyle(
                    fontSize: 42,
                    color: Colors.white,
                  ),
                ),
                Text(
                  kanji.data?.readings
                          ?.firstWhereOrNull((item) => item.primary == true)
                          ?.reading ??
                      "N/A" ??
                      "N/A",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  kanji.data?.meanings
                          ?.firstWhereOrNull((item) => item.primary == true)
                          ?.meaning ??
                      "N/A" ??
                      "N/A",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      );
    }

    widgets.add(
      GridView(
        padding: const EdgeInsets.only(left: 10.0),
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: 1,
          crossAxisCount: 3,
        ),
        physics: const NeverScrollableScrollPhysics(),
        children: gridList,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget getWkInfo() {
    var reviewStat = appData.allReviewData
        ?.firstWhereOrNull((element) => element.data?.subjectId == kanji.id);
    var srsStat = appData.allSrsData
        ?.firstWhereOrNull((element) => element.data?.subjectId == kanji.id);

    if (reviewStat == null || srsStat == null) {
      return const Column(
        children: [
          Divider(color: Colors.black),
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              "Wanikani progression:",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            "Item is not yet learned",
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(color: Colors.black),
        const Text(
          "Wanikani progression:",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        RichText(
          text: TextSpan(
            children: [
              const TextSpan(
                text: " - SRS Stage: ",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: srsStat.data?.getSrs().label,
              ),
            ],
            style: const TextStyle(color: Colors.black),
          ),
        ),
        RichText(
          text: TextSpan(
            children: [
              const TextSpan(
                text: " - Unlocked at: ",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: srsStat.data?.getUnlockededDateAsLocalTime(),
              ),
            ],
            style: const TextStyle(color: Colors.black),
          ),
        ),
        RichText(
          text: TextSpan(
            children: [
              const TextSpan(
                text: " - Next review: ",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: srsStat.data?.getNextReviewAsLocalTime(),
              ),
            ],
            style: const TextStyle(color: Colors.black),
          ),
        ),
        RichText(
          text: TextSpan(
            children: [
              const TextSpan(
                text: " - Overall correct: ",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: "${reviewStat.data!.percentageCorrect}%",
              ),
            ],
            style: const TextStyle(color: Colors.black),
          ),
        ),
        RichText(
          text: TextSpan(
            children: [
              const TextSpan(
                text: " - Meaning correct: ",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text:
                    "${reviewStat.data!.meaningCorrect}/${((reviewStat.data!.meaningCorrect)! + (reviewStat.data!.meaningIncorrect)!)}, ",
              ),
              TextSpan(
                text:
                    "current streak ${reviewStat.data!.meaningCurrentStreak}, max streak ${reviewStat.data!.meaningMaxStreak}",
              ),
            ],
            style: const TextStyle(color: Colors.black),
          ),
        ),
        RichText(
          text: TextSpan(
            children: [
              const TextSpan(
                text: " - Reading correct: ",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text:
                    "${reviewStat.data!.readingCorrect}/${((reviewStat.data!.readingCorrect)! + (reviewStat.data!.readingIncorrect)!)}, ",
              ),
              TextSpan(
                text:
                    "current streak ${reviewStat.data!.readingCurrentStreak}, max streak ${reviewStat.data!.readingMaxStreak}",
              ),
            ],
            style: const TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }

  mnemonic() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(color: Colors.black),
        const Text(
          "Wanikani mnemonic:",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Gap(5),
        const Center(
          child: Text(
            "😬 Not fixing their weird ass encoding😬\nI'm not using these most of the time anyway",
            style: TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const Gap(5),
        RichText(
          text: TextSpan(
            children: [
              const TextSpan(
                text: " - Meaning: ",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: kanji.data?.meaningMnemonic ?? "")
            ],
            style: const TextStyle(color: Colors.black),
          ),
        ),
        const Gap(10),
        RichText(
          text: TextSpan(
            children: [
              const TextSpan(
                text: " - Reading: ",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: kanji.data?.readingMnemonic ?? "")
            ],
            style: const TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }
}
