import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:my_kanji_app/data/app_data.dart';
import 'package:my_kanji_app/data/kanji.dart';
import 'package:my_kanji_app/data/shared.dart';
import 'package:my_kanji_app/data/vocab.dart';
import 'package:my_kanji_app/pages/kanji_info_page.dart';
import 'package:my_kanji_app/pages/vocab_info_page.dart';
import 'package:my_kanji_app/service/api.dart';
import 'package:collection/collection.dart';
import 'package:my_kanji_app/utility/ult_func.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:unofficial_jisho_api/api.dart';
import 'package:unofficial_jisho_api/api.dart' as jisho;

class VocabInfoCard extends StatelessWidget {
  VocabInfoCard({super.key, required this.item, required this.context});

  final BuildContext context;

  final appData = AppData();

  int numberOfExample = 5;

  final Vocab item;

  AudioPlayer audioPlayer = AudioPlayer();

  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.55,
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 15,
        ),
        margin: const EdgeInsets.only(
          right: 12,
          top: 5,
        ),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 197, 217, 255),
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(
                color: Color.fromARGB(255, 181, 181, 181),
                blurRadius: 20,
                spreadRadius: 5)
          ],
        ),
        child: Column(
          children: [
            GestureDetector(
              onLongPress: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VocabPage(
                      vocab: item,
                    ),
                  ),
                );
              },
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: item.data?.characters ?? "N/A",
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ],
                  style: const TextStyle(
                    fontSize: 56,
                  ),
                ),
                textAlign: TextAlign.center,
              ),
            ),

            ///

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(color: Colors.black),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Meaning:",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            "(${item.data?.partsOfSpeech?.join(", ")})",
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Text(
                        item.data?.meanings!.map((e) => e.meaning).join(", ") ??
                            "",
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const Divider(color: Colors.black),
                    Center(
                      child: getTextOfVocab(),
                    ),

                    ///

                    getUsedKanji(),

                    ///
                    futureWidget(getExampleJisho(), true, true),
                  ],
                ),
              ),
            ),
          ],
        ));
  }

  getTextOfVocab() {
    String slug = item.data!.slug ?? "N/A";
    var readings = item.data!.readings;

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
                          fontSize: 20,
                        ),
                      ),
                    ),
                    getPitch(slug, reading.reading),
                    getAudioButton(reading.reading ?? ""),
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
          getPitch(slug, slug),
        ],
      );
    }
  }

  Widget getPitch(String? slugs, String? reading) {
    const Widget noData = Text(
      "[No pitch data]",
      style: TextStyle(
        color: Colors.grey,
      ),
    );

    if (slugs == null || reading == null) return noData;

    var pitchData = appData.pitchData
        ?.firstWhereOrNull((element) => element.characters == slugs);

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

  getAudioButton(String char) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton.icon(
          onPressed: () async {
            await playAudio(true, char);
          },
          label: const Text(""),
          icon: const Icon(
            size: 32,
            Icons.volume_up,
            color: Colors.blue,
          ),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
          ),
        ),
        TextButton.icon(
          onPressed: () async {
            await playAudio(false, char);
          },
          label: const Text(""),
          icon: const Icon(
            size: 32,
            Icons.volume_up,
            color: Colors.pink,
          ),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
          ),
        )
      ],
    );
  }

  getExample() {
    List<VocabContextSentences>? contextData = item.data?.contextSentences;

    if (contextData == null) {
      return const SizedBox(
        width: 5,
      );
    }

    List<Widget> list = [];

    for (var context in contextData) {
      list.add(Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.ja ?? " --- ",
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
            ),
          ),
          Text(
            " - ${context.en ?? " --- "}",
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
            ),
          ),
        ],
      ));
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: list,
    );
  }

  Widget getUsedKanji() {
    var usedKanjiIds = item.data?.componentSubjectIds;

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
          crossAxisCount: 2,
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

  Future<Widget> getExampleJisho() async {
    // var info = await kanjiInfo;
    var example = jisho.searchForExamples(item.data!.characters!);
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
                const Divider(
                  thickness: 1.0,
                ),
              ],
            ),
          ),
      ],
    );
  }

  playAudio(bool male, String char) async {
    List<VocabPronunciationAudios>? audioData = item.data?.pronunciationAudios;

    if (audioData != null) {
      var maleAudio = audioData
          .where((element) =>
              element.metadata?.gender == "male" &&
              element.metadata?.pronunciation == char)
          .toList();
      var femaleAudio = audioData
          .where((element) =>
              element.metadata?.gender == "female" &&
              element.metadata?.pronunciation == char)
          .toList();

      final _random = Random();
      if (male) {
        var url = maleAudio![_random.nextInt(maleAudio!.length)].url!;
        await audioPlayer.play(UrlSource(url));
      } else {
        var url = femaleAudio![_random.nextInt(femaleAudio!.length)].url!;
        await audioPlayer.play(UrlSource(url));
      }
    } else {
      return;
    }
  }
}

class PitchLineData {
  PitchLineData(this.char, this.pitch, this.color);
  final String char;
  final int pitch;
  late Color color;
}
