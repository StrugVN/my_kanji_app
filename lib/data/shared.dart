import 'package:flutter/material.dart';

class Pages {
  int? perPage;
  String? nextUrl;
  String? previousUrl;

  Pages({this.perPage, this.nextUrl, this.previousUrl});

  Pages.fromJson(Map<String, dynamic> json) {
    perPage = json['per_page'];
    nextUrl = json['next_url'];
    previousUrl = json['previous_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['per_page'] = this.perPage;
    data['next_url'] = this.nextUrl;
    data['previous_url'] = this.previousUrl;
    return data;
  }
}

class Meanings {
  String? meaning;
  bool? primary;
  bool? acceptedAnswer;

  Meanings({this.meaning, this.primary, this.acceptedAnswer});

  Meanings.fromJson(Map<String, dynamic> json) {
    meaning = json['meaning'];
    primary = json['primary'];
    acceptedAnswer = json['accepted_answer'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['meaning'] = meaning;
    data['primary'] = primary;
    data['accepted_answer'] = acceptedAnswer;
    return data;
  }
}

class Readings {
  String? type;
  bool? primary;
  String? reading;
  bool? acceptedAnswer;

  Readings({this.type, this.primary, this.reading, this.acceptedAnswer});

  Readings.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    primary = json['primary'];
    reading = json['reading'];
    acceptedAnswer = json['accepted_answer'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['primary'] = primary;
    data['reading'] = reading;
    data['accepted_answer'] = acceptedAnswer;
    return data;
  }
}

class SubjectItem<T>{
  T? subjectItem;
  bool? isRevealed;
  bool? isCorrect;

  SubjectItem({this.subjectItem, this.isRevealed});
}

class Subject<Kanji, Vocab> {
  final Kanji kanji;
  final Vocab vocab;
  final bool isKanji;

  Subject({required this.kanji, required this.vocab, required this.isKanji});

  getData(){
    if(isKanji) {
      return kanji;
    } else {
      return vocab;
    }
  }
}

showLoaderDialog(BuildContext context, String? loadingText) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              Container(
                  margin: const EdgeInsets.only(left: 10),
                  child: Text(loadingText ?? " ... ")),
            ],
          ),
        );
      },
    );
  }