import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gap/gap.dart';
import 'package:kana_kit/kana_kit.dart';
import 'package:my_kanji_app/component/vocab_info_card.dart';
import 'package:my_kanji_app/data/app_data.dart';
import 'package:my_kanji_app/data/kanji.dart';
import 'package:my_kanji_app/data/mazii_data.dart';
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
import 'package:translator/translator.dart';

class VocabPage extends StatefulWidget {
  VocabPage({super.key, required this.vocab, this.navigationList})
      : hideAppBar = false,
        hideMeaning = false,
        hideReading = false;

  VocabPage.hideAppBar({super.key, required this.vocab, this.navigationList})
      : hideAppBar = true,
        hideMeaning = false,
        hideReading = false;

  VocabPage.readingReviewInfo(
      {super.key, required this.vocab, this.navigationList})
      : hideAppBar = true,
        hideMeaning = true,
        hideReading = false;

  VocabPage.meaningReviewInfo(
      {super.key, required this.vocab, this.navigationList})
      : hideAppBar = true,
        hideMeaning = false,
        hideReading = true;

  final Vocab vocab;

  final List<Vocab>? navigationList;

  bool hideAppBar;
  bool hideMeaning;
  bool hideReading;

  @override
  State<VocabPage> createState() => _VocabPageState(vocab, navigationList);
}

class _VocabPageState extends State<VocabPage>
    with AutomaticKeepAliveClientMixin {
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

  final translator = GoogleTranslator();

  String? meaningVi;

  bool showReadingInKata = appData.showReadingInKata;

  late Future<MaziiWordResponse?> maziiData;

  @override
  void initState() {
    super.initState();

    if (vocab.data?.characters == null ||
        vocab.data?.level == null ||
        vocab.data?.meanings == null) {
      Navigator.of(context).pop();
    }

    String exampleSearchText = vocab.data!.characters!.replaceAll('〜', '');
    example = jisho.searchForExamples(exampleSearchText);
    // print(vocab.data!.characters! + " / " + exampleSearchText);
    maziiData = maziiSearchWord(exampleSearchText).then((value) {
      if (value == null || value.found == false) return null;

      if (value.data != null && value.data!.isNotEmpty) {
        if (value.data![0].shortMean != null) {
          // meaningVi = value.data![0].shortMean;

          meaningVi = "";

          value.data![0].means?.forEach((element) {
            meaningVi = meaningVi! + (element.mean != null  ? element.mean! + '\n' : "");
          });

          meaningVi = meaningVi!.trim();
        }
      }

      setState(() {});

      return value;
    });

    List<VocabPronunciationAudios>? audioData = vocab.data?.pronunciationAudios;

    if (audioData != null) {
      maleAudio = audioData
          .where((element) => element.metadata?.gender == "male")
          .toList();
      femaleAudio = audioData
          .where((element) => element.metadata?.gender == "female")
          .toList();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      genViMeaning();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: !widget.hideAppBar
          ? AppBar(
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
                        route.settings.name == 'homePage' ||
                        route.settings.name == 'lessonPage' ||
                        route.settings.name == 'reviewPage');
                  },
                ),
              ],
              backgroundColor: Colors.purple,
            )
          : null,
      backgroundColor: Colors.grey.shade300,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text("Wanikani lv${vocab.data?.level}"),
                      Text(vocab.srsData?.data?.getSrs().label ?? ""),
                      futureWidget(getLevelTaught(), false, false),
                    ],
                  ),
                  GestureDetector(
                    onDoubleTap: () async {
                      bool launched = await openWebsite(
                          "https://www.wanikani.com/vocabulary/${vocab.data?.characters}");
                      if (!launched) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Failed to open site")));
                      }
                    },
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 5),
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
                              fontFamily: 'KyoukashoICA',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
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
                                    widget.hideMeaning = !widget.hideMeaning;
                                  });
                                },
                            ),
                            TextSpan(
                              text: " meaning",
                              style: TextStyle(fontWeight: FontWeight.w600),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  setState(() {
                                    widget.hideMeaning = !widget.hideMeaning;
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
                    ],
                  ),
                  getTextOfVocab(),
                  getUsedKanji(),
                  futureWidget(getExample(), true, true),
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
                    : Colors.blue.shade600.withOpacity(0.9),
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
        Text(
          vocab.data?.meanings!.map((e) => e.meaning).join(", ") ?? "",
          style: const TextStyle(
            fontSize: 21,
          ),
          textAlign: TextAlign.center,
        ),
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.2),
          child: const Divider(),
        ),
        Text(
          meaningVi ?? "",
          style: const TextStyle(
            fontSize: 18,
          ),
          textAlign: TextAlign.center,
        ),
      ],
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
      if (!widget.hideReading)
        return Center(
          child: Column(
            children: readings.map<Widget>((reading) {
              return Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.2),
                    child: const Divider(),
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: !showReadingInKata
                              ? reading.reading
                              : KanaKit().toKatakana(reading.reading ?? ""),
                          style: const TextStyle(
                            color: Colors.black,
                            fontFamily: 'KyoukashoICA',
                          ),
                        )
                      ],
                      style: const TextStyle(
                        fontSize: 32,
                      ),
                    ),
                  ),
                  getPitch(char, reading.reading),
                  getAudio(reading.reading ?? ""),
                ],
              );
            }).toList(),
          ),
        );
      else
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
        );
    } else {
      return Column(
        children: [
          getPitch(char, char),
          getAudio(char),
        ],
      );
    }
  }

  Widget getAudio(String char) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        maleAudio?.isNotEmpty ?? false
            ? TextButton.icon(
                onPressed: () async {
                  await playAudio(true, char);
                },
                label: const Text(""),
                icon: const Icon(
                  size: 36,
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
                  await playAudio(false, char);
                },
                label: const Text(""),
                icon: const Icon(
                  size: 36,
                  Icons.volume_up,
                  color: Colors.pink,
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                ),
              )
            : const SizedBox.shrink(),
      ],
    );
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
        .map((e) => e.allMatches(reading!).length)
        .toList()
        .sum;

    if (showReadingInKata) reading = KanaKit().toKatakana(reading);

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
      var mainReading = kanji.data?.readings
              ?.firstWhereOrNull((item) => item.primary == true)!
              .reading ??
          "N/A";

      if (showReadingInKata) mainReading = KanaKit().toKatakana(mainReading);

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
                    overflow: TextOverflow.ellipsis,
                    fontFamily: 'KyoukashoICA',
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

  playAudio(bool male, String char) async {
    final _random = Random();
    if (male) {
      var maleAudioOfPronounce = maleAudio!
          .where((element) => element.metadata?.pronunciation == char)
          .toList();
      var url =
          maleAudioOfPronounce[_random.nextInt(maleAudioOfPronounce.length)]
              .url!;
      await audioPlayer.play(UrlSource(url));
    } else {
      var femaleAudioOfPronounce = femaleAudio!
          .where((element) => element.metadata?.pronunciation == char)
          .toList();
      var url =
          femaleAudioOfPronounce[_random.nextInt(femaleAudioOfPronounce.length)]
              .url!;
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
        // WK example
        for (var item
            in vocab.data?.contextSentences ?? <VocabContextSentences>[])
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Tooltip(
                  richMessage: TextSpan(
                    children: [
                      WidgetSpan(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.7),
                          child: Text(
                            "${item.en}",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  showDuration: Duration(seconds: 10),
                  child: Text(
                    item.ja ?? "",
                    style: const TextStyle(fontSize: 18, fontFamily: 'KyoukashoICA',),
                  ),
                ),
                const Gap(3),
                const Divider(
                  color: Colors.black,
                  thickness: 0.2,
                  indent: 20,
                  endIndent: 20,
                ),
                const Gap(3),
                // Text(
                //   " - ${item.en}",
                //   style: const TextStyle(fontSize: 17),
                // ),
                // const Gap(5),
              ],
            ),
          ),
        // -----------------
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

  Widget getWkInfo() {
    var reviewStat = appData.allReviewData
        ?.firstWhereOrNull((element) => element.data?.subjectId == vocab.id);
    var srsStat = appData.allSrsData
        ?.firstWhereOrNull((element) => element.data?.subjectId == vocab.id);

    if (reviewStat == null || srsStat == null) {
      return Column(
        children: [
          const Divider(color: Colors.black),
          const Align(
            alignment: Alignment.topLeft,
            child: Text(
              "Wanikani progression:",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Text(
            "Item is not yet learned",
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          Text(
            vocab.srsData?.data?.getUnlockededDateAsLocalTime() != null
                ? "Item unlocked ${vocab.srsData?.data?.getUnlockededDateAsLocalTime()}"
                : "Item is not yet unlocked",
            style: const TextStyle(
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
                "https://www.wanikani.com/vocabulary/${vocab.data?.characters}");
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
        RichText(
          text: TextSpan(
            children: [
              const TextSpan(
                text: " - Meaning: ",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              // TextSpan(text: vocab.data?.meaningMnemonic ?? "")
              for (var textSpan
                  in buildWakiText(vocab.data?.meaningMnemonic ?? ""))
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
              // TextSpan(text: vocab.data?.readingMnemonic ?? "")
              for (var textSpan
                  in buildWakiText(vocab.data?.readingMnemonic ?? ""))
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

  Future genViMeaning() async {
    await maziiData;

    if (meaningVi != null) return;

    meaningVi = toCamelCase((await translator
            .translate(vocab.data?.characters ?? "", from: 'ja', to: 'vi'))
        .text);

    setState(() {});
  }
}
