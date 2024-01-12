class PitchData{
  String? characters;
  String? reading;
  List<Pitch>? pitches;

  PitchData({this.characters, this.reading, this.pitches});

  PitchData.fromJson(Map<String, dynamic> json){
    characters = json["characters"];
    reading = json["reading"];
    pitches = [];
    for (var item in json["pitches"]){
      pitches!.add(Pitch.fromJson(item));
    }
  }

  PitchData.fromData(dynamic data){
    characters = data[0];
    reading = data[2]["reading"];
    pitches = [];
    for (var item in data[2]["pitches"]){
      pitches!.add(Pitch.fromJson(item));
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['characters'] = characters;
    data['reading'] = reading;

    if (pitches != null) {
      data['pitches'] = pitches!.map((v) => v.toJson()).toList();
    }
    
    return data;
  }
}


class Pitch {
  int? position;

  Pitch({required this.position});

  Pitch.fromJson(Map<String, dynamic> json) {
    position = json['position'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['position'] = position;
    
    return data;
  }
}