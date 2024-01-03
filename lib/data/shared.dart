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