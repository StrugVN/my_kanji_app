import 'package:flutter/material.dart';
import 'package:my_kanji_app/data/app_data.dart';
import 'package:my_kanji_app/data/shared.dart';
import 'package:my_kanji_app/data/vocab.dart';
import 'package:my_kanji_app/service/api.dart';
import 'package:collection/collection.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:audioplayers/audioplayers.dart';

class VocabInfoCard extends StatelessWidget {
  VocabInfoCard({super.key, required this.item});

  final appData = AppData();

  final Vocab item;

  AudioPlayer audioPlayer = AudioPlayer();

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 400,
        height: 500,
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: item.data?.slug ?? "N/A",
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
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: getTextOfVocab(),
                  ),
                  const Divider(color: Colors.black),

                  ///
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

                  ///
                  getAudio(),
                  const Divider(color: Colors.black),

                  ///
                  const Text(
                    "Example:",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  getExample(),
                ],
              ),
            ],
          ),
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
    ;

    List<Widget> widgetList = [];
    for (var pitch in pitchData.pitches!) {
      if (pitch.position == null) continue;
      List<int> pitchArr =
          List<int>.filled(reading.length + 1, 0, growable: true);

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

    for (int i = 0; i < characters.length; i++) {
      // Handle duplicated char for graph drawing
      int nDup = i > 0
          ? characters[i].allMatches(characters.substring(0, i - 1)).length
          : 0;
      String char = List.filled(nDup, " ").join() + characters[i];
      //

      pitchDataLine.add(PitchLineData(
          char,
          pitchData[i],
          pitchData[i] == 1 && pitchData[i + 1] == 0
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
          ]),
    );
  }

  getAudio() {
    List<VocabPronunciationAudios>? audioData = item.data?.pronunciationAudios;

    if (audioData == null) {
      return const SizedBox(
        width: 5,
      );
    }

    List<Widget> list = [];

    list.add(const Text(
      "Audio:",
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ));

    for (var data in audioData) {
      list.add(TextButton.icon(
        onPressed: () async {
          await audioPlayer.play(UrlSource(data.url!));
        },
        label: const Text(""),
        icon: Icon(
          Icons.volume_up,
          color: data.metadata!.gender == "male" ? Colors.blue : Colors.pink,
        ),
      ));
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.spaceEvenly,
      children: list,
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
}

class PitchLineData {
  PitchLineData(this.char, this.pitch, this.color);
  final String char;
  final int pitch;
  late Color color;
}
