import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:kana_kit/kana_kit.dart';
import 'package:my_kanji_app/data/app_data.dart';
import 'package:my_kanji_app/data/hanviet_data.dart';
import 'package:my_kanji_app/data/kanji.dart';
import 'package:my_kanji_app/data/kanji_set.dart';
import 'package:my_kanji_app/data/mazii_data.dart';
import 'package:my_kanji_app/data/radical.dart';
import 'package:my_kanji_app/data/vocab.dart';
import 'package:my_kanji_app/data/wk_review_stat.dart';
import 'package:my_kanji_app/data/wk_srs_stat.dart';
import 'package:my_kanji_app/pages/radical_info_page.dart';
import 'package:my_kanji_app/pages/vocab_info_page.dart';
import 'package:my_kanji_app/service/api.dart';
import 'package:my_kanji_app/utility/ult_func.dart';
import 'package:unofficial_jisho_api/api.dart' as jisho;
// import 'package:unofficial_jisho_api/api.dart';

class KanjiPage extends StatefulWidget {
  KanjiPage({super.key, required this.kanji, this.navigationList})
      : hideAppBar = false,
        hideMeaning = false,
        hideReading = false;

  KanjiPage.hideAppBar({super.key, required this.kanji, this.navigationList})
      : hideAppBar = true,
        hideMeaning = false,
        hideReading = false;

  KanjiPage.readingReviewInfo(
      {super.key, required this.kanji, this.navigationList})
      : hideAppBar = true,
        hideMeaning = true,
        hideReading = false;

  KanjiPage.meaningReviewInfo(
      {super.key, required this.kanji, this.navigationList})
      : hideAppBar = true,
        hideMeaning = false,
        hideReading = true;

  final Kanji kanji;

  final List<Kanji>? navigationList;

  bool hideAppBar;
  bool hideMeaning;
  bool hideReading;

  @override
  State<KanjiPage> createState() => _KanjiPageState(kanji, navigationList);
}

class _KanjiPageState extends State<KanjiPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  int numberOfExample = 3;

  final Kanji kanji;

  final List<Kanji>? navigationList;

  late Future<jisho.KanjiResult> kanjiInfo;

  late Future<jisho.ExampleResults> example;

  _KanjiPageState(this.kanji, this.navigationList);

  WkReviewStatData? reviewStat;
  WkSrsStatData? srsStat;
  HanViet? hanViet;

  String hanVietMeaning = "";

  String hanVietDetail = "";

  bool showReadingInKata = appData.showReadingInKata;

  late Future<MaziiKanjiResponse?> maziiData;

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

    reviewStat = appData.allReviewData
        ?.firstWhereOrNull((element) => element.data?.subjectId == kanji.id);
    srsStat = appData.allSrsData
        ?.firstWhereOrNull((element) => element.data?.subjectId == kanji.id);
    hanViet = appData.allHanVietData!
        .firstWhereOrNull((element) => element.kanji == kanji.data?.characters);

    maziiData = maziiSearchKanji(kanji.data!.characters!).then((value) {
      if (value == null) return;

      if (value.results != null && value.results!.isNotEmpty) {
        if (value.results![0].detail != null)
          hanVietDetail = value.results![0].detail!.replaceAll("##", "\n");
        if (value.results![0].mean != null) {
          hanVietMeaning = value.results![0].mean!;
          hanVietMeaning = toCamelCase(hanVietMeaning);
        }
      }

      setState(() {
        if (hanVietMeaning.isEmpty) {
          hanVietMeaning =
              hanViet?.meanings?.split(' ').map(toCamelCase).join(', ') ?? "";
        }

        if (hanVietDetail.isEmpty) {
          hanVietDetail = hanViet?.examples
                  ?.map((e) => capitalizeAfterBracket(e))
                  .join("\n") ??
              "N/A";
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: !widget.hideAppBar
          ? AppBar(
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
                        route.settings.name == 'homePage' ||
                        route.settings.name == 'lessonPage' ||
                        route.settings.name == 'reviewPage');
                  },
                ),
              ],
              backgroundColor: Colors.pink,
            )
          : null,
      backgroundColor: Colors.grey.shade300,
      body: Stack(
        children: [
          SingleChildScrollView(
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
                      GestureDetector(
                        onDoubleTap: () async {
                          bool launched = await openWebsite(
                              "https://www.wanikani.com/kanji/${kanji.data?.characters}");
                          if (!launched) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Failed to open site")));
                          }
                        },
                        child: Container(
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
                              fontFamily: 'KyoukashoICA',
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (srsStat?.data != null)
                                Text(
                                  'Srs: ${srsStat?.data?.getSrs().label}',
                                  style: TextStyle(fontSize: 12),
                                ),
                              Text(
                                'Wanikani lv.${kanji.data!.level}, JLPT N${jlpt(kanji.data!.characters!)}',
                              ),
                              futureWidget(getUsageRate(), false, false),
                              const Divider(),
                              if (!widget.hideMeaning)
                                getMeaning()
                              else
                                Container(
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade400,
                                  ),
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: "Click to show",
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              setState(() {
                                                widget.hideMeaning =
                                                    !widget.hideMeaning;
                                              });
                                            },
                                        ),
                                        TextSpan(
                                          text: " meaning",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              setState(() {
                                                widget.hideMeaning =
                                                    !widget.hideMeaning;
                                              });
                                            },
                                        ),
                                      ],
                                      style: TextStyle(
                                        color: Colors.grey.shade800,
                                        fontSize: 18,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  if (!widget.hideReading)
                    getReading()
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      margin: const EdgeInsets.fromLTRB(5, 15, 0, 0),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                      ),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Click to show",
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  setState(() {
                                    widget.hideReading = !widget.hideReading;
                                  });
                                },
                            ),
                            TextSpan(
                              text: " reading",
                              style: TextStyle(fontWeight: FontWeight.w600),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  setState(() {
                                    widget.hideReading = !widget.hideReading;
                                  });
                                },
                            ),
                          ],
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontSize: 18,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ),
                  const Divider(),
                  RichText(
                    text: TextSpan(
                      children: <TextSpan>[
                        const TextSpan(
                          text: 'Bộ: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: hanViet?.data?.radical,
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
          if (!widget.hideReading)
            Positioned(
              top: MediaQuery.of(context).size.height / 3,
              right: 5,
              child: Material(
                color: showReadingInKata
                    ? Colors.purple.shade400
                    : Colors.blue.shade400,
                borderRadius: BorderRadius.circular(50),
                child: InkWell(
                  onTap: () {
                    // Scroll to top animation
                    setState(() {
                      showReadingInKata = !showReadingInKata;
                    });
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Stack(
                      children: [
                        Positioned(
                            top: 0,
                            right: 10,
                            child: Text(
                              !showReadingInKata ? "あ" : "ア",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontFamily: 'KyoukashoICA',
                              ),
                            )),
                        Text(
                          "⇌",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            // fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Column getMeaning() {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            kanji.data?.meanings!.map((e) => e.meaning).join(", ") ?? "",
            style: const TextStyle(fontSize: 24),
            textAlign: TextAlign.left,
          ),
        ),
        if (hanViet != null)
          Tooltip(
            richMessage: TextSpan(
              children: [
                WidgetSpan(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.7),
                    child: Text(
                      hanVietDetail,
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            showDuration: Duration(seconds: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                children: [
                  Text(
                    hanVietMeaning,
                    style: const TextStyle(fontSize: 21),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
          )
      ],
    );
  }

  Widget getReading() {
    // print(kanji.data?.readings?.map((e) => e.toJson().toString() + "\n").toList() ?? []);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                    ?.map((e) =>
                        e.type == "onyomi" && (e.acceptedAnswer ?? false)
                            ? (!showReadingInKata
                                ? e.reading
                                : KanaKit().toKatakana(e.reading ?? ""))
                            : null)
                    .whereNotNull()
                    .join(", "),
                style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'KyoukashoICA',),
              ),
              if ((kanji.data!.readings
                          ?.where((element) => element.type == "onyomi")
                          .map((e) => e.acceptedAnswer)
                          .whereNotNull()
                          .toSet()
                          .length ??
                      0) >
                  1)
                const TextSpan(text: ", "),
              TextSpan(
                text: kanji.data?.readings
                    ?.map((e) =>
                        e.type == "onyomi" && !(e.acceptedAnswer ?? false)
                            ? (!showReadingInKata
                                ? e.reading
                                : KanaKit().toKatakana(e.reading ?? ""))
                            : null)
                    .whereNotNull()
                    .join(", "),
                style: const TextStyle(fontFamily: 'KyoukashoICA',),
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
                    ?.map((e) =>
                        e.type == "kunyomi" && (e.acceptedAnswer ?? false)
                            ? (!showReadingInKata
                                ? e.reading
                                : KanaKit().toKatakana(e.reading ?? ""))
                            : null)
                    .whereNotNull()
                    .join(", "),
                style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'KyoukashoICA',),
              ),
              if ((kanji.data!.readings
                          ?.where((element) => element.type == "kunyomi")
                          .map((e) => e.acceptedAnswer)
                          .whereNotNull()
                          .toSet()
                          .length ??
                      0) >
                  1)
                const TextSpan(text: ", "),
              TextSpan(
                text: kanji.data?.readings
                    ?.map((e) =>
                        e.type == "kunyomi" && !(e.acceptedAnswer ?? false)
                            ? (!showReadingInKata
                                ? e.reading
                                : KanaKit().toKatakana(e.reading ?? ""))
                            : null)
                    .whereNotNull()
                    .join(", "),
                style: TextStyle(fontFamily: 'KyoukashoICA',),
              ),
            ],
            style: const TextStyle(
              fontSize: 18,
              color: Colors.black,
            ),
          ),
        ),
      ],
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
              text: "${info.data?.newspaperFrequencyRank ?? '?'}",
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
    var info = await kanjiInfo;
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
                Tooltip(
                  richMessage: TextSpan(
                  children: [
                    WidgetSpan(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.7),
                        child: Text(
                          sentence.english,
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                showDuration: Duration(seconds: 10),
                  child: Wrap(
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
                              style: const TextStyle(fontSize: 12, fontFamily: 'KyoukashoICA',),
                            ),
                            Text(
                              item.unlifted
                                  .replaceAll(" ", "")
                                  .replaceAll("\n", ""),
                              style: const TextStyle(fontSize: 18, fontFamily: 'KyoukashoICA',),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                // add a small thin line center middle
                const Gap(3),
                const Divider(
                  color: Colors.black,
                  thickness: 0.2,
                  indent: 20,
                  endIndent: 20,
                ),
                const Gap(3),
                // Text(
                //   " - ${sentence.english}",
                //   style: const TextStyle(fontSize: 17),
                // ),
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
      var mainReading = vocab.data?.readings
              ?.firstWhereOrNull((item) => item.primary == true)
              ?.reading ??
          "N/A";

      if (showReadingInKata) {
        mainReading = KanaKit().toKatakana(mainReading);
      }

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
                        fontFamily: 'KyoukashoICA',
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
                          mainReading,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontFamily: 'KyoukashoICA',
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
      var mainReading = kanji.data?.readings
              ?.firstWhereOrNull((item) => item.primary == true)
              ?.reading ??
          "N/A";

      if (showReadingInKata) {
        mainReading = KanaKit().toKatakana(mainReading);
      }

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
                    fontFamily: 'KyoukashoICA',
                  ),
                ),
                Text(
                  mainReading,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontFamily: 'KyoukashoICA',
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
        GestureDetector(
          onDoubleTap: () async {
            bool launched = await openWebsite(
                "https://www.wanikani.com/kanji/${kanji.data?.characters}");
            if (!launched) {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Failed to open site")));
            }
          },
          child: const Text(
            "Wanikani progression:",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
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
                text: srsStat?.data?.getSrs().label,
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
                text: srsStat?.data?.getUnlockededDateAsLocalTime(),
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
                text: srsStat?.data?.getNextReviewAsLocalTime(),
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
                text: "${reviewStat?.data!.percentageCorrect}%",
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
                    "${reviewStat?.data!.meaningCorrect}/${((reviewStat?.data!.meaningCorrect)! + (reviewStat?.data!.meaningIncorrect)!)}, ",
              ),
              TextSpan(
                text:
                    "current streak ${reviewStat?.data!.meaningCurrentStreak}, max streak ${reviewStat?.data!.meaningMaxStreak}",
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
                    "${reviewStat?.data!.readingCorrect}/${((reviewStat?.data!.readingCorrect)! + (reviewStat?.data!.readingIncorrect)!)}, ",
              ),
              TextSpan(
                text:
                    "current streak ${reviewStat?.data!.readingCurrentStreak}, max streak ${reviewStat?.data!.readingMaxStreak}",
              ),
            ],
            style: const TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }

  mnemonic() {
    var radicalWidgets = <Widget>[];

    List<Radical>? radicals = appData.allRadicalData
        ?.where(
          (element) =>
              kanji.data?.componentSubjectIds?.contains(element.id) ?? false,
        )
        .toList();

    for (Radical r in radicals ?? <Radical>[]) {
      Widget char = SizedBox.shrink();
      if (r.data?.characters != null) {
        char = Text(
          r.data!.characters!,
          style: const TextStyle(fontSize: 28, color: Colors.white),
        );
      } else {
        var svg = r.data!.characterImages?.firstWhereOrNull(
            (element) => element.contentType == "image/svg+xml");
        Future<String?>? svgString;
        if (svg?.url != null) {
          svgString = getSvgString(svg!.url!);
          char = futureSingleWidget(getSvg(svgString), true, true);
        }
      }

      radicalWidgets.add(
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RadicalPage(radical: r),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.lightBlue,
            ),
            child: Column(
              children: [
                char,
                Text(
                    r.data?.meanings
                            ?.map((e) =>
                                e.acceptedAnswer == true ? e.meaning : null)
                            .join(", ") ??
                        "",
                    style: const TextStyle(fontSize: 16, color: Colors.white)),
              ],
            ),
          ),
        ),
      );
    }

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
        Container(
          width: double.infinity,
          child: Wrap(
            alignment: WrapAlignment.spaceEvenly,
            children: radicalWidgets,
          ),
        ),
        RichText(
          text: TextSpan(
            children: [
              const TextSpan(
                text: " - Meaning: ",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              // TextSpan(text: kanji.data?.meaningMnemonic ?? "")
              for (var textSpan
                  in buildWakiText(kanji.data?.meaningMnemonic ?? ""))
                textSpan,
            ],
            style: const TextStyle(color: Colors.black, fontSize: 16),
          ),
        ),
        const Gap(10),
        RichText(
          text: TextSpan(
            children: [
              const TextSpan(
                text: " - Reading: ",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              // TextSpan(text: kanji.data?.readingMnemonic ?? "")
              for (var textSpan
                  in buildWakiText(kanji.data?.readingMnemonic ?? ""))
                textSpan,
            ],
            style: const TextStyle(color: Colors.black, fontSize: 16),
          ),
        ),
      ],
    );
  }

  Future<Widget> getSvg(Future<String?>? svgString) async {
    if (svgString == null) {
      return const SizedBox.shrink();
    }
    var svg = await svgString;

    if (svg != null) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.045,
        width: MediaQuery.of(context).size.width * 0.07,
        child: SvgPicture.string(
          svg,
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
