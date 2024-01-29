import 'dart:math';

import 'package:flutter/material.dart';
import 'package:my_kanji_app/data/app_data.dart';
import 'package:my_kanji_app/data/kanji.dart';
import 'package:collection/collection.dart';
import 'package:my_kanji_app/data/vocab.dart';
import 'package:unofficial_jisho_api/api.dart' as jisho;
import 'package:unofficial_jisho_api/api.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:collection/src/iterable_extensions.dart';

class KanjiInfoCard extends StatelessWidget {
  KanjiInfoCard({
    super.key,
    required this.item,
  }) : kanjiInfo = jisho.searchForKanji(item.data!.characters!);

  final Kanji item;

  late Future<KanjiResult> kanjiInfo;

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
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                item.data?.characters ?? "N/A",
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 96,
                ),
              ),
              Flexible(
                child: Container(
                  alignment: Alignment.center,
                  width: 190,
                  child: Center(
                    child: Text(
                      item.data?.meanings!.map((e) => e.meaning).join(", ") ?? "",
                      style: const TextStyle(
                        fontSize: 21,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
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
                  text: item.data?.readings
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
                  text: item.data?.readings
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
          // Jisho info
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FutureBuilder<KanjiResult>(
                    future: kanjiInfo, // a previously-obtained Future
                    builder: (BuildContext context,
                        AsyncSnapshot<KanjiResult> snapshot) {
                      List<Widget> children;
                      if (snapshot.hasData) {
                        children = <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Column(
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
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    SvgPicture.network(
                                      snapshot.data!.data!.strokeOrderSvgUri,
                                      height: MediaQuery.of(context).size.width * 0.3,
                                      width: MediaQuery.of(context).size.width * 0.3,
                                    ),
                                    Image(
                                      width: MediaQuery.of(context).size.width * 0.3,
                                      height: MediaQuery.of(context).size.width * 0.3,
                                      image: NetworkImage(snapshot
                                          .data!.data!.strokeOrderGifUri),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ];
                      } else if (snapshot.hasError) {
                        children = <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Text(
                                'Error: Cannot load stroke order "${snapshot.error}"'),
                          ),
                        ];
                      } else {
                        children = const <Widget>[
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 2),
                            child: Text('Fetching data...'),
                          ),
                        ];
                      }
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: children,
                        ),
                      );
                    },
                  ),
                  getVisualySimilar(),
                  // getRelatedVocab(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getRelatedVocab() {
    var relatedIds = item.data?.amalgamationSubjectIds;

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
        Container(
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
                Flexible (
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        vocab.data?.readings
                                ?.firstWhereOrNull((item) => item.primary == true)
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
                                ?.firstWhereOrNull((item) => item.primary == true)
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
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget getVisualySimilar() {
    var visualySimilarId = item.data?.visuallySimilarSubjectIds;

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
        Container(
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
              ),
            ],
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

}
