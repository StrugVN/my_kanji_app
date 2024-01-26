import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:my_kanji_app/data/kanji.dart';
import 'package:my_kanji_app/data/app_data.dart';
import 'package:my_kanji_app/data/vocab.dart';
import 'package:my_kanji_app/data/wk_review_stat.dart';
import 'package:my_kanji_app/data/wk_srs_stat.dart';
import 'package:my_kanji_app/service/endpoints.dart';

final appData = AppData();

const String freeApiKey = "4bd7a48c-681f-4aad-9039-04556b53bc90";

Future<Response> getUser(String apiKey) {
  Map<String, String> header = {
    "Wanikani-Revision": "20170710",
    "Authorization": "Bearer $apiKey",
  };

  return http.get(Uri.parse(userEndpoint), headers: header);
}

Future<Response> getSubject(SubjectQueryParam param) {
  Map<String, String> header = {
    "Wanikani-Revision": "20170710",
    "Authorization": appData.apiKey!,
  };

  final uri = Uri.https(wkAuthority, wkSubjectPath, param.toMap());

  return http.get(uri, headers: header);
}

Future getAllSubject(types) async {
  Map<String, String> header = {
    "Wanikani-Revision": "20170710",
    "Authorization": "Bearer $freeApiKey",
  };

  final uri = Uri.https(wkAuthority, wkSubjectPath, {
    "types": types,
  });

  var response = await http.get(uri, headers: header);

  print(uri);

  if (types == 'kanji') {
    var data = KanjiResponse.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);

    var resultList = data.data;

    while (data.pages?.nextUrl != null) {
      var next_url = data.pages!.nextUrl;

      print(Uri.parse(next_url!));
      response = await http.get(Uri.parse(next_url), headers: header);

      data = KanjiResponse.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);

      resultList = (resultList! + data.data!);
    }

    return resultList;
  } else if (types == "vocabulary" || types == "kana_vocabulary") {
    var data = VocabResponse.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);

    var resultList = data.data;

    while (data.pages?.nextUrl != null) {
      var next_url = data.pages!.nextUrl;

      print(Uri.parse(next_url!));
      response = await http.get(Uri.parse(next_url), headers: header);

      data = VocabResponse.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);

      resultList = (resultList! + data.data!);
    }

    return resultList;
  }

  return null;
}

Future<List<WkSrsStatData>> getAllSrsStat() async {
  Map<String, String> header = {
    "Wanikani-Revision": "20170710",
    "Authorization": appData.apiKey!,
  };

  final uri = Uri.https(
    wkAuthority, wkSrsStatistics,
    // {"subject_types": "kanji,vocabulary,kana_vocabulary"}
  );

  var response = await http.get(uri, headers: header);

  print(uri);

  var data = WkSrsStatResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>);

  List<WkSrsStatData> resultList = data.data ?? [];

  while (data.pages?.nextUrl != null) {
    var next_url = data.pages!.nextUrl;

    print(Uri.parse(next_url!));
    response = await http.get(Uri.parse(next_url), headers: header);

    data = WkSrsStatResponse.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);

    resultList = (resultList + (data.data ?? []));
  }

  return resultList;
}

Future<List<WkReviewStatData>> getAllReviewStat() async {
  Map<String, String> header = {
    "Wanikani-Revision": "20170710",
    "Authorization": appData.apiKey!,
  };

  final uri = Uri.https(
    wkAuthority, wkReviewStatistics,
    // {"subject_types": "kanji,vocabulary,kana_vocabulary"}
  );

  var response = await http.get(uri, headers: header);

  print(uri);

  var data = WkReviewStatRespone.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>);

  List<WkReviewStatData> resultList = data.data ?? [];

  while (data.pages?.nextUrl != null) {
    var next_url = data.pages!.nextUrl;

    print(Uri.parse(next_url!));
    response = await http.get(Uri.parse(next_url), headers: header);

    data = WkReviewStatRespone.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);

    resultList = (resultList + (data.data ?? []));
  }

  return resultList;
}

class SubjectQueryParam {
  List<String>? ids;
  List<String>? levels;
  List<String>? types;
  List<String>? slugs;

  SubjectQueryParam({this.ids, this.levels, this.types, this.slugs});

  Map<String, dynamic> toMap() {
    return {
      'ids': ids,
      'levels': levels,
      'types': types,
      'slugs': slugs,
    };
  }
}
