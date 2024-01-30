import 'package:flutter/material.dart';
import 'package:my_kanji_app/data/shared.dart';
import 'package:unofficial_jisho_api/api.dart';
import 'package:url_launcher/url_launcher.dart';

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

Future<bool> popUntilTargetPopScope(BuildContext context) async {
  // Retrieve the current route
  final ModalRoute<Object?>? currentRoute = ModalRoute.of(context);

  if (currentRoute == null) return false;

  // Check if current route is the target PopScope
  if (currentRoute is PopScope &&
      currentRoute.popDisposition == RoutePopDisposition.doNotPop) {
    return false; // Stop popping when target PopScope reached
  }

  // Pop the current route and recursively call ourselves
  Navigator.pop(context);
  return await popUntilTargetPopScope(context); // Continue popping
}

List<ExampleSentencePiece> fixFurigana(List<ExampleSentencePiece> input) {
  List<ExampleSentencePiece> result = [];

  for (var item in input) {
    if(item.lifted == null || (item.unlifted.length > 4 && item.lifted!.length  > 4 )){
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