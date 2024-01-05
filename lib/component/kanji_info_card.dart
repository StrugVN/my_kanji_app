import 'package:flutter/material.dart';
import 'package:my_kanji_app/data/kanji.dart';
import 'package:collection/collection.dart';
import 'package:unofficial_jisho_api/api.dart' as jisho;
import 'package:unofficial_jisho_api/api.dart';
import 'package:flutter_svg/flutter_svg.dart';

class KanjiInfoCard extends StatelessWidget {
  KanjiInfoCard({
    super.key,
    required this.item,
  }) : kanjiInfo = jisho.searchForKanji(item.data!.slug!);

  final Kanji item;

  late Future<KanjiResult> kanjiInfo;

  @override
  Widget build(BuildContext context) {
    // var jishoData = await getJishoData(item.data!.slug!);

    return Container(
      width: 400,
      height: 400,
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
          ]),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                item.data?.slug ?? "N/A",
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 96,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 40,
                ),
                child: Container(
                  alignment: Alignment.center,
                  width: 200,
                  child: Center(
                    child: Text(
                      item.data?.meanings!.map((e) => e.meaning).join(", ") ??
                          "",
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
                  style: TextStyle(fontWeight: FontWeight.bold),
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
              ),
            ),
          ),

          RichText(
            text: TextSpan(
              children: <TextSpan>[
                const TextSpan(
                  text: 'Kun: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
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
              ),
            ),
          ),

          const Divider(color: Colors.black),
          // Jisho info
          FutureBuilder<KanjiResult>(
            future: kanjiInfo, // a previously-obtained Future
            builder:
                (BuildContext context, AsyncSnapshot<KanjiResult> snapshot) {
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
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SvgPicture.network(
                              snapshot.data!.data!.strokeOrderSvgUri,
                              height: 130,
                              width: 130,
                            ),
                            Image(
                              width: 130,
                              height: 130,
                              image: NetworkImage(
                                  snapshot.data!.data!.strokeOrderGifUri),
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
        ],
      ),
    );
  }
}
