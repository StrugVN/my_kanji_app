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

  /// Returns true if [parts] and [partsReading] exist, are not empty,
  /// and have the same number of elements.
  bool isPartsAvailable() {
    return parts != null &&
        parts!.isNotEmpty &&
        partsReading != null &&
        partsReading!.isNotEmpty &&
        parts!.length == partsReading!.length;
  }

  /// Processes the [reading] string and splits it into [parts] and [partsReading].
  ///
  /// The string is expected to contain annotated segments like "大学(だいがく)".
  /// This method separates:
  ///  - The plain text before the annotated Kanji,
  ///  - The annotated Kanji (the last contiguous group of characters in the segment
  ///    that are detected as Kanji), and its associated reading inside the parentheses.
  ///
  /// For example, if [reading] is:
  ///   "この大学(だいがく)は、総合大学(そうごうだいがく)として様々(さまざま)な学部(がくぶ)がある。"
  /// It produces:
  ///   parts:         ["この", "大学", "は、", "総合大学", "として", "様々", "な", "学部", "がある。"]
  ///   partsReading:  ["", "だいがく", "", "そうごうだいがく", "", "さまざま", "", "がく部", ""]
  ///
  /// Note: We use a helper function [isKanjiChar] that calls [KanaKit().isKanji]
  /// and also falls back on a regex check.
  void generatePartsAndReadings() {
    if (reading == null || reading!.isEmpty) return;
    parts = [];
    partsReading = [];

    // Local helper: returns true if [character] is considered Kanji.
    bool isKanjiChar(String character) {
      return KanaKit().isKanji(character) ||
          RegExp(r'[\u4E00-\u9FFF々]').hasMatch(character);
    }

    int cursor = 0;
    String input = reading!;

    while (cursor < input.length) {
      int indexOpen = input.indexOf('(', cursor);
      if (indexOpen == -1) {
        // No more annotations: add remainder and update cursor so that it won't be added later.
        String remainder = input.substring(cursor);
        if (remainder.isNotEmpty) {
          parts!.add(remainder);
          partsReading!.add("");
        }
        cursor = input.length;
        break;
      }

      // The text segment preceding the '('.
      String segment = input.substring(cursor, indexOpen);
      int splitIndex = segment.length;
      // Walk backward over [segment] to separate any trailing Kanji characters.
      while (splitIndex > 0) {
        String character = segment.substring(splitIndex - 1, splitIndex);
        if (isKanjiChar(character)) {
          splitIndex--;
        } else {
          break;
        }
      }
      String plainPrefix = segment.substring(0, splitIndex);
      String annotatedToken = segment.substring(splitIndex);

      if (plainPrefix.isNotEmpty) {
        parts!.add(plainPrefix);
        partsReading!.add("");
      }

      // Look for the corresponding closing parenthesis.
      int indexClose = input.indexOf(')', indexOpen);
      if (indexClose == -1) {
        break; // Malformed input.
      }
      String readingAnnotation = input.substring(indexOpen + 1, indexClose);

      // Add the annotated token if it exists.
      if (annotatedToken.isNotEmpty) {
        parts!.add(annotatedToken);
        partsReading!.add(readingAnnotation);
      }

      // Advance the cursor past the closing parenthesis.
      cursor = indexClose + 1;
    }

    // Note: The final remainder is handled inside the loop when no '(' is found,
    // so we do not add an extra remainder here.
  }
}
