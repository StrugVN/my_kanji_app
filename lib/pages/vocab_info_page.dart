import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:my_kanji_app/component/vocab_info_card.dart';
import 'package:my_kanji_app/data/app_data.dart';
import 'package:my_kanji_app/data/kanji.dart';
import 'package:my_kanji_app/data/shared.dart';
import 'package:my_kanji_app/data/vocab.dart';
import 'package:my_kanji_app/pages/kanji_info_page.dart';
import 'package:my_kanji_app/service/api.dart';
import 'package:my_kanji_app/utility/ult_func.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:unofficial_jisho_api/api.dart';
import 'package:unofficial_jisho_api/api.dart' as jisho;
import 'package:collection/collection.dart';
import 'package:audioplayers/audioplayers.dart';

class VocabPage extends StatefulWidget {
  VocabPage({super.key, required this.vocab, this.navigationList}) : hideAppBar = false;

  VocabPage.hideAppBar({super.key, required this.vocab, this.navigationList}) : hideAppBar = true;

  final Vocab vocab;

  final List<Vocab>? navigationList;

  bool hideAppBar;

  @override
  State<VocabPage> createState() => _VocabPageState(vocab, navigationList);
}

class _VocabPageState extends State<VocabPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  int numberOfExample = 5;

  final Vocab vocab;

  final List<Vocab>? navigationList;

  late Future<ExampleResults> example;

  _VocabPageState(this.vocab, this.navigationList);

  List<VocabPronunciationAudios>? maleAudio;
  List<VocabPronunciationAudios>? femaleAudio;

  AudioPlayer audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();

    if (vocab.data?.characters == null ||
        vocab.data?.level == null ||
        vocab.data?.meanings == null
        ) {
      Navigator.of(context).pop();
    }

    example = jisho.searchForExamples(vocab.data!.characters!);
    print(vocab.data!.characters!);

    List<VocabPronunciationAudios>? audioData = vocab.data?.pronunciationAudios;

    if (audioData != null) {
      maleAudio = audioData
          .where((element) => element.metadata?.gender == "male")
          .toList();
      femaleAudio = audioData
          .where((element) => element.metadata?.gender == "female")
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: !widget.hideAppBar ? AppBar(
        title: Text(
          vocab.data!.characters ?? "",
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
        backgroundColor: Colors.purple,
      ) : null,
      backgroundColor: Colors.grey.shade300,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          margin: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text("Wanikani lv${vocab.data?.level}"),
                  futureWidget(getLevelTaught(), false, false),
                ],
              ),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade800,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      vocab.data?.characters ?? "N/A",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 72,
                      ),
                    ),
                  ),
                ),
              ),
              Text(
                vocab.data?.meanings!.map((e) => e.meaning).join(", ") ?? "",
                style: const TextStyle(
                  fontSize: 21,
                ),
                textAlign: TextAlign.center,
              ),
              getTextOfVocab(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      "${vocab.data?.partsOfSpeech?.join(", ")}",
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      maleAudio?.isNotEmpty ?? false
                          ? TextButton.icon(
                              onPressed: () async {
                                await playAudio(true);
                              },
                              label: const Text(""),
                              icon: const Icon(
                                size: 42,
                                Icons.volume_up,
                                color: Colors.blue,
                              ),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                              ),
                            )
                          : const SizedBox.shrink(),
                      femaleAudio?.isNotEmpty ?? false
                          ? TextButton.icon(
                              onPressed: () async {
                                await playAudio(false);
                              },
                              label: const Text(""),
                              icon: const Icon(
                                size: 42,
                                Icons.volume_up,
                                color: Colors.pink,
                              ),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                              ),
                            )
                          : const SizedBox.shrink(),
                    ],
                  ),
                ],
              ),
              getUsedKanji(),
              futureWidget(getExample(), true, true),
              getWkInfo(),
              mnemonic(),
            ],
          ),
        ),
      ),
    );
  }

  Future<Widget> getLevelTaught() async {
    var response = await jisho.searchForPhrase(vocab.data!.characters!);

    return Text("${response.data?[0].jlpt[0].toUpperCase()}");
  }

  getTextOfVocab() {
    String char = vocab.data!.characters ?? "N/A";
    var readings = vocab.data!.readings;

    if (readings != null) {
      return Center(
        child: Column(
          children: [
            Column(
              children: readings.map<Widget>((reading) {
                return Column(
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: reading.reading,
                            style: const TextStyle(
                              color: Colors.black,
                            ),
                          )
                        ],
                        style: const TextStyle(
                          fontSize: 32,
                        ),
                      ),
                    ),
                    getPitch(char, reading.reading),
                  ],
                );
              }).toList(),
            )
          ],
        ),
      );
    } else {
      return Column(
        children: [
          getPitch(char, char),
        ],
      );
    }
  }

  Widget getPitch(String? chars, String? reading) {
    const Widget noData = SizedBox.shrink();

    if (chars == null || reading == null) return noData;

    var pitchData = appData.pitchData
        ?.firstWhereOrNull((element) => element.characters == chars);

    if (pitchData == null || pitchData.pitches == null) {
      // Retry with kana reading only
      pitchData = appData.pitchData
          ?.firstWhereOrNull((element) => element.reading == reading);

      if (pitchData == null || pitchData.pitches == null) {
        return noData;
      }
    }

    var smallKanaCount = smallKana
        .split("")
        .map((e) => e.allMatches(reading).length)
        .toList()
        .sum;

    List<Widget> widgetList = [];
    for (var pitch in pitchData.pitches!) {
      if (pitch.position == null) continue;

      List<int> pitchArr = List<int>.filled(
          reading.length + 1 - smallKanaCount, 0,
          growable: true);

      if (pitch.position == 0) {
        pitchArr = pitchArr.map((e) => 1).toList();
        pitchArr[0] = 0;
      } else if (pitch.position == 1) {
        pitchArr[0] = 1;
      } else {
        for (int i = 1; i < pitch.position!; i++) {
          pitchArr[i] = 1;
        }
      }

      widgetList.add(drawPitch(reading, pitchArr));

      // Get the first one only - FOR NOW
      break;
    }

    return Column(
      children: widgetList,
    );
  }

  drawPitch(String? characters, List<int>? pitchData) {
    if (characters == null || pitchData == null) {
      return const Text("Pitch data error");
    }

    List<PitchLineData> pitchDataLine = [];

    for (int i = 0, j = 0; i < characters.length; i++, j++) {
      var char = characters[i];

      if (i + 1 < characters.length && smallKana.contains(characters[i + 1])) {
        char = char + characters[i + 1];
        i += 1;
      }

      // Handle duplicated char for graph drawing
      int nDup = i > 0 && i < characters.length
          ? char.allMatches(characters.substring(0, i)).length
          : 0;
      char = List.filled(nDup, " ").join() + char;
      //

      pitchDataLine.add(PitchLineData(
          char,
          pitchData[j],
          pitchData[j] == 1 && pitchData[j + 1] == 0
              ? Colors.grey
              : Colors.black));
    }
    pitchDataLine.add(PitchLineData(" ", pitchData.last, Colors.grey));

    return SizedBox(
      width: 250,
      height: 100,
      child: SfCartesianChart(
        primaryXAxis: const CategoryAxis(
          borderWidth: 0,
          axisLine: AxisLine(
            width: 0,
          ),
          labelStyle: TextStyle(
            color: Colors.black,
            fontSize: 16,
            // fontWeight: FontWeight.w500
          ),
          majorGridLines: MajorGridLines(
            width: 0,
          ),
        ),
        primaryYAxis: const NumericAxis(
          borderWidth: 0,
          isVisible: false,
        ),
        series: <CartesianSeries>[
          // Renders line chart
          LineSeries<PitchLineData, String>(
            dataSource: pitchDataLine,
            xValueMapper: (PitchLineData data, _) => data.char,
            yValueMapper: (PitchLineData data, _) => data.pitch,
            pointColorMapper: (PitchLineData data, _) => data.color,
            markerSettings: const MarkerSettings(isVisible: true),
          ),
        ],
      ),
    );
  }

  Widget getUsedKanji() {
    var usedKanjiIds = vocab.data?.componentSubjectIds;

    if (usedKanjiIds == null || usedKanjiIds.isEmpty) {
      return const SizedBox.shrink();
    }

    List<Kanji>? similarKanji = AppData()
        .allKanjiData
        ?.where((element) => usedKanjiIds.contains(element.id))
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
        "Used kanji:",
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
                          ?.firstWhereOrNull((item) => item.primary == true)!
                          .reading ??
                      "N/A",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  kanji.data?.meanings
                          ?.firstWhereOrNull((item) => item.primary == true)
                          ?.meaning ??
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

  playAudio(bool male) async {
    final _random = Random();
    if (male) {
      var url = maleAudio![_random.nextInt(maleAudio!.length)].url!;
      await audioPlayer.play(UrlSource(url));
    } else {
      var url = femaleAudio![_random.nextInt(femaleAudio!.length)].url!;
      await audioPlayer.play(UrlSource(url));
    }
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

    // var x = fixFurigana(exampleList[0].pieces);
    // print(exampleList[0].pieces.map((e) => e.lifted));
    // print(exampleList[0].pieces.map((e) => e.unlifted));
    // print(x.map((e) => e.lifted));
    // print(x.map((e) => e.unlifted));

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

  Widget getWkInfo() {
    var reviewStat = appData.allReviewData
        ?.firstWhereOrNull((element) => element.data?.subjectId == vocab.id);
    var srsStat = appData.allSrsData
        ?.firstWhereOrNull((element) => element.data?.subjectId == vocab.id);

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
              TextSpan(text: vocab.data?.meaningMnemonic ?? "")
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
              TextSpan(text: vocab.data?.readingMnemonic ?? "")
            ],
            style: const TextStyle(color: Colors.black),
          ),
        ),
        const Gap(10),
        RichText(
          text: TextSpan(
            children: [
              const TextSpan(
                text: " Item id: ",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: "${vocab.id}")
            ],
            style: const TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }
}
