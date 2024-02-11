import 'dart:convert';

class HanViet {
  String? kanji;
  String? meanings;
  String? holder1;
  String? holder2;
  List<String>? examples;
  HanVietData? data;

  HanViet.fromData(dynamic inputData){
    kanji = inputData[0];
    meanings = inputData[1];
    holder1 = inputData[2];
    holder2 = inputData[3];

    examples = (inputData[4] as List<dynamic>).map((item) => item.toString()).toList();

    data = HanVietData.fromJson(inputData[5]);
  }

  HanViet.fromJson(Map<String, dynamic> json){
    kanji = json["kanji"];
    meanings = json["meanings"];
    holder1 = json["holder1"];
    holder2 = json["holder2"];

    examples = [];
    for (var item in json["examples"]){
      examples!.add(item);
    }
    
    data = HanVietData.fromJson(json["data"]);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['kanji'] = kanji;
    data['meanings'] = meanings;
    data['holder1'] = holder1;
    data['holder2'] = holder2;
    data['examples'] = examples;

    if(this.data != null){
      data['data'] = this.data!.toJson();
    }

    return data;
  }
}

class HanVietData {
  String? strokes;
  String? radical;
  String? penStrokes;
  String? shape;
  String? unicode;

  HanVietData.fromJson(dynamic data){
    strokes = data["Strokes"];
    radical = data["Radical"];
    penStrokes = data["PenStrokes"];
    shape = data["Shape"];
    unicode = data["Unicode"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Strokes'] = strokes;
    data['Radical'] = radical;
    data['PenStrokes'] = penStrokes;
    data['Shape'] = shape;
    data['Unicode'] = unicode;
    
    return data;
  }
}


