import 'package:kana_kit/kana_kit.dart';

class Sentence {
  String? sentence;
  String? meaning;
  String? word;
  String? reading;
  List<String>? parts;
  List<String>? partsReading;

  Sentence({this.sentence, this.meaning, this.word, this.reading});

  Sentence.fromJson(Map<String, dynamic> json) {
    sentence = json['sentence'];
    meaning = json['meaning'];
    word = json['word'];
    reading = json['reading'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['sentence'] = sentence;
    data['meaning'] = meaning;
    data['word'] = word;
    data['reading'] = reading;
    data['parts'] = parts;
    data['partsReading'] = partsReading;
    return data;
  }

  bool isPartsAvailable() {
    return parts != null &&
        parts!.isNotEmpty &&
        partsReading != null &&
        partsReading!.isNotEmpty &&
        parts!.length == partsReading!.length;
  }

  /// Processes the [reading] string and splits it into [parts] and [partsReading].
  ///
  /// The method detects segments that follow the pattern "休憩(きゅうけい)".
  /// - For a segment like "休憩(きゅうけい)", it extracts "休憩" as the annotated token
  ///   and "きゅうけい" as its reading.
  /// - Any non-annotated text (typically hiragana) is added as a segment with an empty reading.
  ///
  /// For example, the string:
  ///   "その辺(あた)りで休憩(きゅうけい)しませんか。"
  /// is split into:
  ///   parts: ["その", "辺", "りで", "休憩", "しませんか。"]
  ///   partsReading: ["", "あた", "", "きゅうけい", ""]
  void generatePartsAndReadings() {
    if (reading == null || reading!.isEmpty) return;

    parts = [];
    partsReading = [];

    int cursor = 0;
    String input = reading!;

    while (cursor < input.length) {
      // Find the next opening parenthesis
      int indexOpen = input.indexOf('(', cursor);
      if (indexOpen == -1) {
        // No annotated token remaining; add the rest of the text as plain segment.
        String remainder = input.substring(cursor);
        if (remainder.isNotEmpty) {
          parts!.add(remainder);
          partsReading!.add("");
        }
        break;
      }

      // The segment before the opening parenthesis.
      String segment = input.substring(cursor, indexOpen);

      // Determine the boundary between plain text and Kanji token.
      int splitIndex = segment.length;
      while (splitIndex > 0) {
        String character = segment.substring(splitIndex - 1, splitIndex);
        // Use KanaKit's isKanji method to check if the character is Kanji.
        if (KanaKit().isKanji(character)) {
          splitIndex--;
        } else {
          break;
        }
      }

      // plainPrefix holds non-annotated text preceding the annotated Kanji.
      String plainPrefix = segment.substring(0, splitIndex);
      // annotatedToken holds the Kanji that is being annotated.
      String annotatedToken = segment.substring(splitIndex);

      // If there is any plain text, add it with an empty reading.
      if (plainPrefix.isNotEmpty) {
        parts!.add(plainPrefix);
        partsReading!.add("");
      }

      // Find the closing parenthesis for the annotated token.
      int indexClose = input.indexOf(')', indexOpen);
      if (indexClose == -1) {
        // If a closing parenthesis isn't found, exit the loop.
        break;
      }
      // Extract the text inside the parentheses as the reading.
      String readingAnnotation = input.substring(indexOpen + 1, indexClose);

      // Add the annotated Kanji and its corresponding reading.
      parts!.add(annotatedToken);
      partsReading!.add(readingAnnotation);

      // Continue after the closing parenthesis.
      cursor = indexClose + 1;
    }

    // Append any remaining text after the last annotation.
    if (cursor < input.length) {
      String remaining = input.substring(cursor);
      if (remaining.isNotEmpty) {
        parts!.add(remaining);
        partsReading!.add("");
      }
    }
  }
}
