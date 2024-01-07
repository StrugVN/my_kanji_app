import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:my_kanji_app/data/kanji.dart';
import 'package:my_kanji_app/data/user.dart';
import 'package:my_kanji_app/data/vocab.dart';
import 'package:my_kanji_app/service/endpoints.dart';

final user = User();

const String freeApiKey = "4bd7a48c-681f-4aad-9039-04556b53bc90";

Future<Response> getUser(String apiKey) {
  Map<String, String> header = {
    "Wanikani-Revision": "20170710",
    "Authorization": "Bearer $apiKey",
  };

  return http.get(Uri.parse(userEndpoint), headers: header);
}

Future<Response> getSubject(SubjectQueryParam param){
  Map<String, String> header = {
    "Wanikani-Revision": "20170710",
    "Authorization": user.apiKey!,
  };

  final uri =
    Uri.https(authority, subjectPath, param.toMap());

  return http.get(uri, headers: header);
}

Future getAllSubject(types) async {
  Map<String, String> header = {
    "Wanikani-Revision": "20170710",
    "Authorization": "Bearer $freeApiKey",
  };

  final uri =
    Uri.https(authority, subjectPath, {"types": types,});

  var response = await http.get(uri, headers: header);

  print(uri);

  if (types == 'kanji') {
    var data = KanjiResponse.fromJson(jsonDecode(response.body) as Map<String, dynamic>);

    var resultList = data.data;
    
    while (data.pages?.nextUrl != null){
      var next_url = data.pages!.nextUrl;

      print(Uri.parse(next_url!));
      response = await http.get(Uri.parse(next_url), headers: header);

      data = KanjiResponse.fromJson(jsonDecode(response.body) as Map<String, dynamic>);

      resultList = (resultList! + data.data!);
    }

    return resultList;
  }
  else if (types == "vocabulary" || types == "kana_vocabulary"){
    var data = VocabResponse.fromJson(jsonDecode(response.body) as Map<String, dynamic>);

    var resultList = data.data;
    
    while (data.pages?.nextUrl != null){
      var next_url = data.pages!.nextUrl;

      print(Uri.parse(next_url!));
      response = await http.get(Uri.parse(next_url), headers: header);

      data = VocabResponse.fromJson(jsonDecode(response.body) as Map<String, dynamic>);

      resultList = (resultList! + data.data!);
    }

    return resultList;
  }
  
  return null;
}

class SubjectQueryParam{
  List<String>? ids;
  List<String>? levels;
  List<String>? types;
  List<String>? slugs;
  
  SubjectQueryParam({this.ids, this.levels, this.types, this.slugs}) ;

  Map<String, dynamic> toMap() {
    return {
      'ids': ids,
      'levels': levels,
      'types': types,
      'slugs': slugs,
    };
  }
}