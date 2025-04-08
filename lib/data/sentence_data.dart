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

  void generatePartsAndReadings() {
    // Simple manual tokenizer (replace this with proper tokenizer in real app)
    List<String> tempParts = _mockTokenize(sentence!);
    List<String> tempReadings = _mockTokenize(reading!);

    parts = tempParts;
    partsReading = [];

    print(tempParts);
    print(tempReadings);

    for (int i = 0; i < tempParts.length; i++) {
      final part = tempParts[i];
      final readingPart = tempReadings[i];

      // Only keep reading if it's not already visible in the part (i.e., not pure kana)
      final kanaOnly = RegExp(r'^[ぁ-んァ-ンー]+$');
      if (kanaOnly.hasMatch(part)) {
        partsReading!.add('');
      } else {
        // Compare visible Hiragana and remove
        partsReading!.add(_extractKanjiReading(part, readingPart));
      }
    }
  }

  List<String> _mockTokenize(String input) {
    // VERY simple mock: split by punctuation or particles
    // Replace this with MeCab or a better tokenizer in production
    return input
        .replaceAll('、', '')
        .replaceAll('。', '')
        .split(RegExp(r'(?<=[をがにでてはも])|(?=[をがにでてはも])|\s+'))
        .where((e) => e.isNotEmpty)
        .toList();
  }

  String _extractKanjiReading(String word, String reading) {
    // Remove kana from word to isolate Kanji portion
    final hiragana = RegExp(r'[ぁ-んァ-ンー]');
    final kanjiOnly = word.replaceAll(hiragana, '');

    // If no Kanji, no need for reading
    if (kanjiOnly.isEmpty) return '';

    // Assume full reading for now
    return reading;
  }
}
