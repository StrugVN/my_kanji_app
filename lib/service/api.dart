import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:my_kanji_app/data/gemini_data.dart';
import 'package:my_kanji_app/data/kanji.dart';
import 'package:my_kanji_app/data/app_data.dart';
import 'package:my_kanji_app/data/mazii_data.dart';
import 'package:my_kanji_app/data/radical.dart';
import 'package:my_kanji_app/data/userdata.dart';
import 'package:my_kanji_app/data/vocab.dart';
import 'package:my_kanji_app/data/wk_review_stat.dart';
import 'package:my_kanji_app/data/wk_srs_stat.dart';
import 'package:my_kanji_app/service/endpoints.dart';
import 'package:html/parser.dart' as parser;

final appData = AppData();

const String freeApiKey = "4bd7a48c-681f-4aad-9039-04556b53bc90";

const String GeminiApiKey = "";

Future<Response> getUser(String apiKey) {
  Map<String, String> header = {
    "Wanikani-Revision": "20170710",
    "Authorization": "Bearer $apiKey",
  };

  return http.get(Uri.parse(userEndpoint), headers: header);
}

Future<UserData?> getUserInfo() async {
  Map<String, String> header = {
    "Wanikani-Revision": "20170710",
    "Authorization": appData.apiKey ?? "",
  };

  var response = await http.get(Uri.parse(userEndpoint), headers: header);
  if (response.statusCode == 200)
    return UserData.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  else
    return null;
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
  return getAllSubjectAfterUpdate(types, "");
}

Future getAllSubjectAfterUpdate(types, updateAfter) async {
  try {
    Map<String, String> header = {
      "Wanikani-Revision": "20170710",
      "Authorization": appData.apiKey ?? "Bearer $freeApiKey",
    };

    final uri = Uri.https(wkAuthority, wkSubjectPath, {
      "types": types,
      "updated_after": updateAfter,
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
    } else if (types == "radical") {
      var data = RadicalResponse.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);

      var resultList = data.data;

      while (data.pages?.nextUrl != null) {
        var next_url = data.pages!.nextUrl;

        print(Uri.parse(next_url!));
        response = await http.get(Uri.parse(next_url), headers: header);

        data = RadicalResponse.fromJson(
            jsonDecode(response.body) as Map<String, dynamic>);

        resultList = (resultList! + data.data!);
      }

      return resultList;
    }
  } on Exception catch (e) {
    // TODO
    print("Network error");
    appData.networkError = true;
  }

  return null;
}

Future<List<WkSrsStatData>> getAllSrsStat() async {
  return getAllSrsStatAfter(null);
}

Future<List<WkSrsStatData>> getAllSrsStatAfter(updateAfter) async {
  try {
    Map<String, String> header = {
      "Wanikani-Revision": "20170710",
      "Authorization": appData.apiKey!,
    };

    final uri =
        Uri.https(wkAuthority, wkSrsStatistics, {"updated_after": updateAfter});

    print(uri);

    var response = await http.get(uri, headers: header);

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
  } on Exception catch (e, stackTrace) {
    // TODO
    print("Network error");
    print(stackTrace);
    appData.networkError = true;
  }
  return [];
}

Future<List<WkReviewStatData>> getAllReviewStat() async {
  return getAllReviewStatAfter(null);
}

Future<List<WkReviewStatData>> getAllReviewStatAfter(updateAfter) async {
  try {
    Map<String, String> header = {
      "Wanikani-Revision": "20170710",
      "Authorization": appData.apiKey!,
    };

    final uri = Uri.https(
        wkAuthority, wkReviewStatistics, {"updated_after": updateAfter});

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
  } on Exception catch (e) {
    // TODO
    print("Network error");
    appData.networkError = true;
  }

  return [];
}

Future<Response> assignmentStart(assignmentId) async {
  Map<String, String> header = {
    "Wanikani-Revision": "20170710",
    "Authorization": appData.apiKey!,
    "Content-Type": "application/json; charset=utf-8",
  };

  final uri = Uri.https(wkAuthority, "$wkSrsStatistics/$assignmentId/start");

  print(uri);

  var response = await http.put(uri, headers: header);

  return response;
}

Future<Response> reviewRequest(
    int subjectId, int meaningIncorrect, int readingIncorrect) async {
  Map<String, String> header = {
    "Wanikani-Revision": "20170710",
    "Authorization": appData.apiKey!,
    "Content-Type": "application/json; charset=utf-8",
  };

  final uri = Uri.https(wkAuthority, wkReviewRequest);

  print(uri);

  var body = jsonEncode({
    "review": {
      "subject_id": subjectId,
      "incorrect_meaning_answers": meaningIncorrect,
      "incorrect_reading_answers": readingIncorrect
    }
  });

  var response = await http.post(uri, headers: header, body: body);

  return response;
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

Future<String?> getSvgString(String url) async {
  // Fetch SVG content from the URL
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    // Parse the HTML response to extract the SVG content
    final document = parser.parse(response.body);
    final svgElement = document.querySelector('svg');

    // Apply CSS styles to the SVG element
    svgElement?.attributes['fill'] = 'none';
    svgElement?.attributes['stroke'] = '#000';
    svgElement?.attributes['stroke-linecap'] = 'square';
    svgElement?.attributes['stroke-miterlimit'] = '2';
    svgElement?.attributes['stroke-width'] = '68px';

    // Generate the SVG string
    final svgString = svgElement?.outerHtml;
    return svgString;
  } else {
    return null;
  }
}

// -------- Mazii

Future<MaziiWordResponse?> maziiSearchWord(String word) async {
  final uri = Uri.parse('https://mazii.net/api/search');

  var body = jsonEncode(
      {"dict": "javi", "type": "word", "query": word, "limit": 1, "page": 1});

  var response = await http.post(uri,
      headers: {'Content-Type': 'application/json '}, body: body);

  final jsonResponse = jsonDecode(Utf8Decoder().convert(response.bodyBytes));

  var data = MaziiWordResponse.fromJson(jsonResponse);

  return data;
}

Future<MaziiKanjiResponse?> maziiSearchKanji(String kanji) async {
  final uri = Uri.parse('https://mazii.net/api/search');

  var body = jsonEncode(
      {"dict": "javi", "type": "kanji", "query": kanji, "limit": 1, "page": 1});

  var response = await http.post(uri,
      headers: {'Content-Type': 'application/json'}, body: body);

  final jsonResponse = jsonDecode(Utf8Decoder().convert(response.bodyBytes));

  var data = MaziiKanjiResponse.fromJson(jsonResponse);

  return data;
}

Future<GeminiResponse?> geminiBatchSearchWords(List<String> words) async {
  final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$GeminiApiKey');

  var body = jsonEncode({
    "system_instruction": {
      "parts": [
        {
          "text":
             "You are a Japanese learning assistant API. Each response is a JSON containing a list of sentences. Each sentence must include: 'word' contain the prompted word and nothing else; 'sentence' is a natural, original sentence using the prompted word, after each word that have a kanji, put it reading in hiragana in a pair of '(' ')' after the kanji, do not include any romanji; and 'meaning' (the meaning in English). If the given word is a single kanji, use its standalone reading and meaning, not in a compound word.\n\nMake sure each sentence is different from any typical or previously generated ones. Add variation by changing context, speaker, tone, or setting. Prioritize uniqueness.\n\nIf the given word is a verb or adjective, prioritize using a conjugated or て-form version of the word rather than its dictionary form when building the sentence."
        }
      ]
    },
    "contents": [
      {
        "parts": [
          {
            "text":
                "Make Japanese sentences using each of these word [${words.map((e) => "'" + e + "'").join(",")}] (1 for each word)"
          }
        ]
      }
    ]
  });

  print("----------------GEMINI API---------------------");
  print(words.map((e) => "'" + e + "'").join(","));

  var response = await http.post(uri,
      headers: {'Content-Type': 'application/json'}, body: body);

  final jsonResponse = jsonDecode(Utf8Decoder().convert(response.bodyBytes));

  var data = GeminiResponse.fromJson(jsonResponse);

  return data;
}
