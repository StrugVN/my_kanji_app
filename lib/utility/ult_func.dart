import 'package:flutter/material.dart';
import 'package:my_kanji_app/data/kanji.dart';
import 'package:my_kanji_app/data/shared.dart';
import 'package:my_kanji_app/data/vocab.dart';
import 'package:my_kanji_app/pages/kanji_info_page.dart';
import 'package:my_kanji_app/pages/vocab_info_page.dart';
import 'package:unofficial_jisho_api/api.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:collection/collection.dart';

String helloAccordingToTime() {
  int hour = DateTime.now().hour;
  if (hour >= 3 && hour <= 10) {
    return "お早う, ";
  } else if (hour >= 11 && hour <= 17) {
    return "こんにちは, ";
  } else if (hour >= 18 && hour <= 23) {
    return "今晩は, ";
  } else if (hour >= 0 && hour <= 2) {
    return "お早う, ";
  } else {
    return "こんにちは, "; // Default case
  }
}

Future<void> openWebsite(String url) async {
  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(Uri.parse(url));
  } else {}
}

futureWidget(Future<Widget> scheduleTask, bool showError, bool showLoading) {
  return FutureBuilder<Widget>(
    future: scheduleTask, // a previously-obtained Future
    builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
      List<Widget> children;
      if (snapshot.hasData) {
        children = <Widget>[
          snapshot.data!,
        ];
      } else if (snapshot.hasError) {
        children = showError
            ? <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                      'Error: Cannot load new items list "${snapshot.error}"'),
                ),
              ]
            : [const SizedBox.shrink()];
      } else {
        children = showError
            ? const <Widget>[
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Text('Fetching data...'),
                ),
              ]
            : [const SizedBox.shrink()];
      }
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: children,
        ),
      );
    },
  );
}

List<ExampleSentencePiece> fixFurigana(List<ExampleSentencePiece> input) {
  List<ExampleSentencePiece> result = [];

  for (var item in input) {
    if (item.lifted == null ||
        (item.unlifted.length > 4 && item.lifted!.length > 4)) {
      result.add(item);
      continue;
    }

    final match = kanaRegEx.firstMatch(item.unlifted);

    if (match != null) {
      final start = match.start;
      final end = match.end;
      final part1 = item.unlifted.substring(0, start);
      final part2 = item.unlifted.substring(start);

      result.add(ExampleSentencePiece(lifted: item.lifted, unlifted: part1));
      result.add(ExampleSentencePiece(lifted: null, unlifted: part2));
    } else {
      result.add(item);
    }
  }

  return result;
}

int countLatinCharacters(String text) {
  // Define a regular expression to match Latin characters
  RegExp latinRegExp = RegExp(r'[a-zA-Z]');

  // Use the allMatches method to find all matches in the text
  Iterable<Match> matches = latinRegExp.allMatches(text);

  // Return the count of matches
  return matches.length;
}

Widget kanjiBar(Kanji item, BuildContext context) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => KanjiPage(
            kanji: item,
          ),
        ),
      );
    },
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      decoration: const BoxDecoration(
        color: Color.fromARGB(119, 255, 65, 135),
        border: Border(
          bottom: BorderSide(color: Colors.black, width: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              item.data?.characters ?? "N/A",
              style: const TextStyle(
                fontSize: 26,
                color: Colors.black,
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
                  item.data?.readings
                          ?.firstWhereOrNull((item) => item.primary == true)
                          ?.reading ??
                      "",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  item.data?.meanings
                          ?.firstWhereOrNull((item) => item.primary == true)
                          ?.meaning ??
                      "N/A",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget vocabBar(Vocab item, BuildContext context) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VocabPage(
            vocab: item,
          ),
        ),
      );
    },
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      decoration: const BoxDecoration(
        color: Color.fromARGB(119, 105, 27, 154),
        border: Border(
          bottom: BorderSide(color: Colors.black, width: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              item.data?.characters ?? "N/A",
              style: const TextStyle(
                fontSize: 26,
                color: Colors.black,
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
                  item.data?.readings
                          ?.firstWhereOrNull((item) => item.primary == true)
                          ?.reading ??
                      "",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  item.data?.meanings
                          ?.firstWhereOrNull((item) => item.primary == true)
                          ?.meaning ??
                      "N/A",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

String toCamelCase(String text) {
  if (text.isEmpty) return '';
  return text[0].toUpperCase() + text.substring(1).toLowerCase();
}