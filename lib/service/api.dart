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

const String _geminiPrimaryModel = 'gemini-2.5-flash';
const String _geminiBackupModel = 'gemini-2.5-flash-lite';

const String _geminiSystemPrompt = '''You are a Japanese learning assistant API.

OUTPUT FORMAT
Respond with a single JSON array. Each element has exactly these fields:
- "word": the exact prompted word, unchanged.
- "sentence": one natural Japanese sentence using the word. See FURIGANA RULES below.
- "meaning": the English translation of the sentence.

FURIGANA RULES (critical, follow exactly)
- After every kanji character or kanji compound in the sentence, append its hiragana reading in parentheses immediately after.
- Wrap a whole kanji compound once, NOT each kanji separately.
- Never wrap hiragana or katakana. Particles like は, が, を, に, て get no parentheses.
- Never use romaji anywhere.

EXAMPLES
Word: 権利
Correct: 国民(こくみん)には自由(じゆう)に意見(いけん)を述(の)べる権利(けんり)がある。
Wrong:   国民(こくみん)に(に)は(は)自由(じゆう)に...   ← hiragana wrapped
Wrong:   国(こく)民(みん)には...                       ← compound split

Word: 消す
Correct: 部屋(へや)を出(で)る前(まえ)に、電気(でんき)を消(け)してください。

CONTENT RULES
- Sentences should be original and varied: change context, speaker, tone, or setting between calls.
- Maximum 40 words per sentence; short to medium length.
- If the prompted word is a verb or adjective, prefer a conjugated or て-form over the dictionary form.
- If the prompted word is a single kanji, use it standalone (with its standalone reading and meaning), not inside a compound.''';

Future<Response?> _callGemini(String model, String requestBody) async {
  final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$GeminiApiKey');
  try {
    return await http.post(uri,
        headers: {'Content-Type': 'application/json'}, body: requestBody);
  } catch (e) {
    print('Gemini $model network error: $e');
    return null;
  }
}

String _extractGeminiErrorMessage(Response resp) {
  try {
    final j = jsonDecode(Utf8Decoder().convert(resp.bodyBytes));
    if (j is Map && j['error'] is Map) {
      final msg = (j['error'] as Map)['message'];
      if (msg is String && msg.isNotEmpty) return msg;
    }
  } catch (_) {}
  return resp.body;
}

Future<GeminiResponse?> geminiBatchSearchWords(List<String> words) async {
  final body = jsonEncode({
    "system_instruction": {
      "parts": [
        {"text": _geminiSystemPrompt}
      ]
    },
    "contents": [
      {
        "parts": [
          {
            "text":
                "Find actual Japanese sentences (quote of real text, literature), short to medium length with maximum 40 words per sentence, using each of these words [${words.map((e) => "'" + e + "'").join(",")}] (1 for each word)"
          }
        ]
      }
    ],
    "generationConfig": {
      "temperature": 0.3,
      "responseMimeType": "application/json",
    },
  });

  print("----------------GEMINI API---------------------");
  print(words.map((e) => "'" + e + "'").join(","));

  // Try primary model
  var response = await _callGemini(_geminiPrimaryModel, body);
  if (response == null || response.statusCode != 200) {
    final errMsg = response == null
        ? 'network error'
        : 'HTTP ${response.statusCode}: ${_extractGeminiErrorMessage(response)}';
    print('Gemini $_geminiPrimaryModel failed ($errMsg); trying backup $_geminiBackupModel...');

    response = await _callGemini(_geminiBackupModel, body);
    if (response == null || response.statusCode != 200) {
      final err2 = response == null
          ? 'network error'
          : 'HTTP ${response.statusCode}: ${_extractGeminiErrorMessage(response)}';
      print('Gemini $_geminiBackupModel also failed ($err2)');
      return null;
    }
  }

  final jsonResponse = jsonDecode(Utf8Decoder().convert(response.bodyBytes));

  return GeminiResponse.fromJson(jsonResponse);
}
