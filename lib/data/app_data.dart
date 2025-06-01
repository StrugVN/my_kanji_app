import 'dart:convert';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_kanji_app/component/selector.dart';
import 'package:my_kanji_app/data/gemini_data.dart';
import 'package:my_kanji_app/data/hanviet_data.dart';
import 'package:my_kanji_app/data/kanji.dart';
import 'package:my_kanji_app/data/pitch_data.dart';
import 'package:my_kanji_app/data/radical.dart';
import 'package:my_kanji_app/data/sentence_data.dart';
import 'package:my_kanji_app/data/userdata.dart';
import 'package:my_kanji_app/data/vocab.dart';
import 'package:my_kanji_app/data/wk_review_stat.dart';
import 'package:my_kanji_app/data/wk_srs_stat.dart';
import 'package:my_kanji_app/service/api.dart';
import 'package:collection/collection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io';

class AppData extends ChangeNotifier {
  static final AppData _singleton = AppData._internal();

  String? apiKey;
  UserData userData = UserData();

  DateTime lastDataSync = DateTime.now();

  List<Kanji>? allKanjiData;
  List<Vocab>? allVocabData;
  List<Radical>? allRadicalData;
  List<PitchData>? pitchData;
  List<HanViet>? allHanVietData;
  List<WkSrsStatData>? allSrsData;
  List<WkReviewStatData>? allReviewData;
  bool dataIsLoaded = false;
  bool networkError = false;

  // //////
  Map<String, SrsStage> formatMap = {};

  Map<String, Widget> characterCells = {};

  SourceTypeLabel stuffSourceLabel = SourceTypeLabel.Wanikani;

  Future<bool>? sentenceReviewFuture;
  List<Sentence> sentenceReviewList = [];

  // App setting ===========================================
  Map<String, bool> lessonSetting = {
    "radical": true,
    "kanji": true,
    "vocab": true,
  };

  int lessonBatchSize = 5;

  Map<String, bool> reviewSetting = {
    "radical": true,
    "kanji": true,
    "vocab": true,
  };

  bool showReadingInKata = false;

  int reviewDraftSize = 10;
  //  ----------------------------------------------

  factory AppData() {
    return _singleton;
  }

  AppData._internal();

  void removeKey() {
    apiKey = null;
  }

  Future<void> assertDataIsLoaded() async {
    while (dataIsLoaded == false) {
      await Future.delayed(const Duration(milliseconds: 200));
    }
  }

  void manualNotify() {
    notifyListeners();
  }

  Future<void> getData() async {
    initData();

    print("  -- Data loading initialized --");

    await Future.wait([
      loadKanjiApi(),
      loadVocabApi(),
      loadRadicalApi(),
      loadVocabPitchData(),
      loadHanVietData(),
      getSrsData(),
      getReviewStatData(),
      getUserData(),
      loadSetting(),
    ]);

    if (allKanjiData != null)
      for (var element in allKanjiData!) {
        var srs = allSrsData!
            .firstWhereOrNull((e) => e.data?.subjectId == element.id);
        var review = allReviewData!
            .firstWhereOrNull((e) => e.data?.subjectId == element.id);

        if (srs != null) {
          element.srsData = srs;
        }

        if (review != null) {
          element.reviewData = review;
        }
      }

    if (allVocabData != null)
      for (var element in allVocabData!) {
        var srs = allSrsData!
            .firstWhereOrNull((e) => e.data?.subjectId == element.id);
        var review = allReviewData!
            .firstWhereOrNull((e) => e.data?.subjectId == element.id);

        if (srs != null) {
          element.srsData = srs;
        }

        if (review != null) {
          element.reviewData = review;
        }
      }

    if (allRadicalData != null)
      for (var element in allRadicalData!) {
        var srs = allSrsData!
            .firstWhereOrNull((e) => e.data?.subjectId == element.id);
        var review = allReviewData!
            .firstWhereOrNull((e) => e.data?.subjectId == element.id);

        if (srs != null) {
          element.srsData = srs;
        }

        if (review != null) {
          element.reviewData = review;
        }
      }

    if (!Platform.isWindows) {
      saveCache(null);
    }

    dataIsLoaded = true;

    lastDataSync = DateTime.now();

    notifyListeners();
  }

  Future<void> getDataForce() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.remove("dateOfCache");
    await prefs.remove("kanjiCache");
    await prefs.remove("vocabCache");
    await prefs.remove("radicalCache");
    await prefs.remove("srsCache");
    await prefs.remove("reviewCache");

    await getData();
  }

  Future<void> autoDataSync() async {
    DateTime now = DateTime.now();

    if (now.hour - lastDataSync.hour >= 1) {
      await getData();
      // check if appData.sentenceReviewFuture is on going, if it is cancel it
      appData.sentenceReviewFuture = appData.getSentenceReview();
      lastDataSync = DateTime.now();
    }
  }

  void initData() {
    dataIsLoaded = false;
    networkError = false;
    formatMap = {};
    characterCells = {};
    notifyListeners();
  }

  @Deprecated("Use the api one")
  Future<void> loadKanjiDataFromLocal() async {
    final kanjiDataF = rootBundle.loadString('assets/kanjidata.json');

    allKanjiData = [];
    for (var json in jsonDecode(await kanjiDataF)) {
      allKanjiData!.add(Kanji.fromJson(json));
    }

    print("  Kanji count: ${allKanjiData?.length}");
  }

  Future<void> loadKanjiApi() async {
    /// 1 Load local
    ///   - 1a If not, load all.
    ///   - 1b If is:
    ///       + Then check update_after date of local cache.
    /// 2 Then save to local with date

    // 1
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? kanjiListAsString = prefs.getString('kanjiCache');
    String? dateString = prefs.getString('dateOfCache');

    if (kanjiListAsString != null && dateString != null) {
      //1b
      List<Kanji> tempKanjiList = (jsonDecode(kanjiListAsString) as List)
          .map((e) => Kanji.fromJson(e))
          .toList();

      DateTime date = DateTime.parse(dateString!);

      List<Kanji> updatedKanji = [];
      updatedKanji = await getAllSubjectAfterUpdate(
              "kanji", date.add(const Duration(days: -1)).toIso8601String()) ??
          <Kanji>[];

      for (var updatedItem in updatedKanji) {
        int index =
            tempKanjiList.indexWhere((item) => item.id == updatedItem.id);
        if (index != -1) {
          tempKanjiList[index] = updatedItem;
        } else {
          tempKanjiList.add(updatedItem);
        }
      }

      allKanjiData = tempKanjiList;
    } else {
      //1a
      var kanjiDataF = await getAllSubject("kanji");

      if (kanjiDataF != null) {
        allKanjiData = kanjiDataF;
      }
    }

    print("  Kanji count: ${allKanjiData?.length}");
  }

  @Deprecated("Use the api one")
  Future<void> loadVocabDataFromLocal() async {
    final vocabDataF = rootBundle.loadString('assets/vocabdata.json');

    allVocabData = [];
    for (var json in jsonDecode(await vocabDataF)) {
      allVocabData!.add(Vocab.fromJson(json));
    }

    print("  Vocab count: ${allVocabData?.length}");
  }

  Future<void> loadVocabApi() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? vocabListAsString = prefs.getString('vocabCache');
    String? dateString = prefs.getString('dateOfCache');

    if (vocabListAsString != null && dateString != null) {
      //1
      List<Vocab> tempVocabList = (jsonDecode(vocabListAsString) as List)
          .map((e) => Vocab.fromJson(e))
          .toList();
      DateTime date = DateTime.parse(dateString);

      //1b
      var updatedVocab = getAllSubjectAfterUpdate(
          "vocabulary", date.add(const Duration(days: -1)).toIso8601String());
      var updatedKanaVocab = getAllSubjectAfterUpdate("kana_vocabulary",
          date.add(const Duration(days: -1)).toIso8601String());

      List<Vocab> updatedAllVocab = [];
      updatedAllVocab = (await updatedVocab ?? <Vocab>[]) +
          (await updatedKanaVocab ?? <Vocab>[]);

      for (var updatedItem in updatedAllVocab) {
        int index =
            tempVocabList.indexWhere((item) => item.id == updatedItem.id);
        if (index != -1) {
          tempVocabList[index] = updatedItem;
        } else {
          tempVocabList.add(updatedItem);
        }
      }

      allVocabData = tempVocabList;
    } else {
      //1a
      var getVocab = getAllSubject("vocabulary");
      var getKanaVocab = getAllSubject("kana_vocabulary");

      var tempVocabList =
          (await getVocab ?? <Vocab>[]) + (await getKanaVocab ?? <Vocab>[]);

      if (tempVocabList.isNotEmpty) {
        allVocabData = tempVocabList;
      }
    }

    print("  Vocab count: ${allVocabData?.length}");
  }

  Future<void> loadVocabPitchData() async {
    final pitchDataF = rootBundle.loadString('assets/pitchdata.json');

    pitchData = [];
    for (var json in jsonDecode(await pitchDataF)) {
      pitchData!.add(PitchData.fromJson(json));
    }

    print("  Pitch count: ${pitchData?.length}");
  }

  Future<void> loadHanVietData() async {
    allHanVietData = await appData.loadHanVietFromParts();

    print("  HanViet count: ${allHanVietData?.length}");
  }

  // For WK user only
  Future<List<WkSrsStatData>> getSrsData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? srsListAsString = prefs.getString('srsCache');
    String? dateString = prefs.getString('dateOfCache');

    if (srsListAsString != null && dateString != null) {
      //1
      List<WkSrsStatData> tempSrsList = (jsonDecode(srsListAsString) as List)
          .map((e) => WkSrsStatData.fromJson(e))
          .toList();
      DateTime date = DateTime.parse(dateString);

      //1b
      var updatedSrsData = await getAllSrsStatAfter(
          date.add(const Duration(days: -1)).toIso8601String());

      for (var updatedItem in updatedSrsData) {
        int index = tempSrsList.indexWhere((item) => item.id == updatedItem.id);
        if (index != -1) {
          tempSrsList[index] = updatedItem;
        } else {
          tempSrsList.add(updatedItem);
        }
      }

      allSrsData = tempSrsList;

      return allSrsData!;
    } else {
      //1a
      var tempSrsData = await getAllSrsStat();
      if (tempSrsData.isNotEmpty) {
        allSrsData = tempSrsData;
      }

      return allSrsData!;
    }
  }

  // For WK user only
  Future<void> getReviewStatData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? reviewListAsString = prefs.getString('reviewCache');
    String? dateString = prefs.getString('dateOfCache');

    if (reviewListAsString != null && dateString != null) {
      //1
      List<WkReviewStatData> tempReviewList =
          (jsonDecode(reviewListAsString) as List)
              .map((e) => WkReviewStatData.fromJson(e))
              .toList();
      DateTime date = DateTime.parse(dateString);

      //1b
      var updatedReviewData = await getAllReviewStatAfter(
          date.add(const Duration(days: -1)).toIso8601String());

      for (var updatedItem in updatedReviewData) {
        int index =
            tempReviewList.indexWhere((item) => item.id == updatedItem.id);
        if (index != -1) {
          tempReviewList[index] = updatedItem;
        } else {
          tempReviewList.add(updatedItem);
        }
      }

      allReviewData = tempReviewList;
    } else {
      //1a
      var tempReviewData = await getAllReviewStat();
      if (tempReviewData.isNotEmpty) {
        allReviewData = tempReviewData;
      }
    }

    print("  Review data count: ${allReviewData?.length}");
  }

  Future<void> getUserData() async {
    var newUserData = await getUserInfo();

    if (newUserData != null) {
      userData = newUserData;
      saveUserData();
    }
  }

  List<Kanji> getListKanjiFromLocal(
      {List<int>? ids, List<int>? levels, List<String>? slugs}) {
    if (allKanjiData == null) return [];

    return allKanjiData!
        .where((element) =>
            kanjiFilter(element, ids: ids, levels: levels, slugs: slugs))
        .toList();
  }

  bool kanjiFilter(Kanji kanji,
      {List<int>? ids, List<int>? levels, List<String>? slugs}) {
    return true && ids != null
        ? ids.contains(kanji.id)
        : true && levels != null
            ? levels.contains(kanji.data?.level)
            : true && slugs != null
                ? slugs.contains(kanji.data?.slug)
                : true;
  }

  List<Vocab> getListVocabFromLocal(
      {List<int>? ids, List<int>? levels, List<String>? slugs}) {
    if (allVocabData == null) return [];

    return allVocabData!
        .where((element) =>
            vocabFilter(element, ids: ids, levels: levels, slugs: slugs))
        .toList();
  }

  bool vocabFilter(Vocab kanji,
      {List<int>? ids, List<int>? levels, List<String>? slugs}) {
    return true && ids != null
        ? ids.contains(kanji.id)
        : true && levels != null
            ? levels.contains(kanji.data?.level)
            : true && slugs != null
                ? slugs.contains(kanji.data?.slug)
                : true;
  }

  List<Vocab> getListVocabFromLocalByKanji(List<String> usedKanji) {
    if (allVocabData == null) {
      return [];
    }

    return allVocabData!.where((e) => isVocabContain(e, usedKanji)).toList();
  }

  List<String> allKanjiInVocab(Vocab vocab) {
    return getListKanjiFromLocal(
            ids: vocab.data?.componentSubjectIds, levels: null, slugs: null)
        .map((e) => e.data?.slug ?? "")
        .toList();
  }

  bool isVocabContain(Vocab vocab, List<String> usedKanji) {
    Set<String> componentSet = {...allKanjiInVocab(vocab)};
    Set<String> usedKanjiSet = {...usedKanji};

    return usedKanjiSet.containsAll(componentSet);
  }

  @Deprecated("Use load from local")
  Future<List<PitchData>> loadPitchDataPart(int partNum) async {
    String pitchJson = "assets/pitch_json/term_meta_bank_$partNum.json";

    String data = await rootBundle.loadString(pitchJson);
    final jsonS = jsonDecode(data);

    List<PitchData>? pitchData = [];
    for (var item in jsonS) {
      pitchData.add(PitchData.fromData(item));
    }
    print("  -- Loaded: $pitchJson");
    return pitchData;
  }

  Future<List<HanViet>> loadHanVietFromParts() async {
    List<HanViet> hanData = [];

    String hanVietJson = "assets/handata.json";

    String data = await rootBundle.loadString(hanVietJson);
    final jsonS = jsonDecode(data);

    for (var item in jsonS) {
      hanData.add(HanViet.fromData(item));
    }

    return hanData;
  }

  @Deprecated("Use load from local")
  Future<List<PitchData>> loadPitchDataFromParts() async {
    List<Future<List<PitchData>>> taskList = [];

    for (int i = 1; i <= 13; i++) {
      taskList.add(loadPitchDataPart(i));
    }

    List<PitchData> data = [];
    for (var task in taskList) {
      data = data + await task;
    }

    return data;
  }

  Future<void> saveSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    /*
      appData.lessonSetting = lessonSetting;
      appData.reviewSetting = reviewSetting;
    */

    await prefs.setInt('sLessonBatchSize', lessonBatchSize);
    await prefs.setInt('sReviewDraftSize', reviewDraftSize);

    await prefs.setBool('sLessonRadical', lessonSetting["radical"] ?? true);
    await prefs.setBool('sLessonKanji', lessonSetting["kanji"] ?? true);
    await prefs.setBool('sLessonVocab', lessonSetting["vocab"] ?? true);

    await prefs.setBool('sReviewRadical', reviewSetting["radical"] ?? true);
    await prefs.setBool('sReviewKanji', reviewSetting["kanji"] ?? true);
    await prefs.setBool('sReviewVocab', reviewSetting["vocab"] ?? true);
    await prefs.setBool('sShowReadingInKata', showReadingInKata);
  }

  Future<void> loadSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    lessonBatchSize = prefs.getInt('sLessonBatchSize') ?? 3;
    reviewDraftSize = prefs.getInt('sReviewDraftSize') ?? 5;

    lessonSetting["radical"] = prefs.getBool('sLessonRadical') ?? true;
    lessonSetting["kanji"] = prefs.getBool('sLessonKanji') ?? true;
    lessonSetting["vocab"] = prefs.getBool('sLessonVocab') ?? true;

    reviewSetting["radical"] = prefs.getBool('sReviewRadical') ?? true;
    reviewSetting["kanji"] = prefs.getBool('sReviewKanji') ?? true;
    reviewSetting["vocab"] = prefs.getBool('sReviewVocab') ?? true;
    showReadingInKata = prefs.getBool('sShowReadingInKata') ?? false;
  }

  Future<void> saveApiKey() async {
    const storage = FlutterSecureStorage();
    await storage.write(
        key: 'apiKey', value: apiKey?.replaceAll("Bearer ", ""));
  }

  Future<String?> loadApiKey() async {
    const storage = FlutterSecureStorage();
    var key = await storage.read(key: 'apiKey');
    print(" - Loaded key: $key");
    return key;
  }

  Future<void> loadRadicalApi() async {
    /// 1 Load local
    ///   - 1a If not, load all.
    ///   - 1b If is:
    ///       + Then check update_after date of local cache.
    /// 2 Then save to local with date

    // 1
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? radicalListAsString = prefs.getString('radicalCache');
    String? dateString = prefs.getString('dateOfCache');

    if (radicalListAsString != null && dateString != null) {
      //1b
      List<Radical> tempRadicalList = (jsonDecode(radicalListAsString) as List)
          .map((e) => Radical.fromJson(e))
          .toList();
      DateTime date = DateTime.parse(dateString!);

      List<Radical> updatedRadical = [];
      updatedRadical = await getAllSubjectAfterUpdate("radical",
              date.add(const Duration(days: -1)).toIso8601String()) ??
          <Radical>[];

      for (var updatedItem in updatedRadical) {
        int index =
            tempRadicalList.indexWhere((item) => item.id == updatedItem.id);
        if (index != -1) {
          tempRadicalList[index] = updatedItem;
        } else {
          tempRadicalList.add(updatedItem);
        }
      }

      allRadicalData = tempRadicalList;
    } else {
      //1a
      var radicalDataF = await getAllSubject("radical");

      if (radicalDataF != null) {
        allRadicalData = radicalDataF;
      }
    }

    print("  Radical count: ${allRadicalData?.length}");
  }

  Future<void> saveUserData() async {
    const storage = FlutterSecureStorage();
    String userDataAsString = jsonEncode(userData);
    await storage.write(key: 'userData', value: userDataAsString);
  }

  Future<void> loadUserData() async {
    const storage = FlutterSecureStorage();
    var userDataAsString = await storage.read(key: 'userData');
    if (userDataAsString != null) {
      userData = UserData.fromJson(jsonDecode(userDataAsString));
    }
  }

  Future<void> logout() async {
    const storage = FlutterSecureStorage();

    await storage.delete(key: 'userData');
    await storage.delete(key: 'apiKey');
  }

  Future<void> saveCache(dynamic) async {
    String kanjiDataAsString = jsonEncode(allKanjiData);
    String vocabDataAsString = jsonEncode(allVocabData);
    String radicalDataAsString = jsonEncode(allRadicalData);
    String srsDataAsString = jsonEncode(allSrsData);
    String reviewDataAsString = jsonEncode(allReviewData);

    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString('kanjiCache', kanjiDataAsString);
    prefs.setString('vocabCache', vocabDataAsString);
    prefs.setString('radicalCache', radicalDataAsString);
    prefs.setString('srsCache', srsDataAsString);
    prefs.setString('reviewCache', reviewDataAsString);
    prefs.setString('dateOfCache', DateTime.now().toString());
  }

  // void _heavyOperationWrapper(dynamic message) {
  //     saveCache();
  // }

  Future<void> offloadSaveCacheOperation() async {
    // ReceivePort receivePort = ReceivePort();
    Isolate.spawn(saveCache, null);
  }

  Future<bool> getSentenceReview() async {
    await assertDataIsLoaded();

    var vocabReviewList = appData.allVocabData
            ?.where((element) {
              var nextReview = element.srsData?.data?.getNextReviewAsDateTime();
              return nextReview == null
                  ? false
                  : nextReview.toLocal().isBefore(DateTime.now());
            })
            .map((e) => e.data?.characters)
            .whereNotNull()
            .where((element) => !element.contains('〜'))
            .toList() ??
        [];

    print("  Vocab review count: ${vocabReviewList.length}");

    // split vocabReviewList into chunks of 50
    List<List<String>> chunks = [];
    for (int i = 0; i < vocabReviewList.length; i += 50) {
      chunks.add(vocabReviewList.sublist(i,
          i + 50 > vocabReviewList.length ? vocabReviewList.length : i + 50));
    }

    int errorCount = 0;

    int warningCount = 0;

    List<Future<GeminiResponse?>> geminiResponseList = [];

    for (var list in chunks) {
      geminiResponseList.add(geminiBatchSearchWords(list));
    }

    List<GeminiResponse?> responseList = await Future.wait(geminiResponseList);
    List<Sentence> sentenceReviewListTotalTemp = [];
    for (var response in responseList) {
      try {
        if (response == null ||
            response.candidates?.length == 0 ||
            response.candidates?[0].content?.parts?.length == 0) {
          errorCount++;
          break;
        }

        String? rawJson =
            response.candidates?[0].content?.parts?[0]['text'] ?? null;

        if (rawJson == null || rawJson.isEmpty) {
          errorCount++;
          break;
        }

        String jsonString =
            rawJson.replaceAll('```', '').replaceAll('json', '');

        List<Sentence> sentenceReviewListTemp = (jsonDecode(jsonString) as List)
            .map((e) => Sentence.fromJson(e))
            .toList();

        sentenceReviewListTemp.forEach((element) {
          element.generatePartsAndReadings();

          if (element.word?.contains("(") ?? false) {
            print("  Warning: ${element.toJson()}");
            warningCount++;
          }
        });

        sentenceReviewListTotalTemp.addAll(sentenceReviewListTemp);
      } catch (e) {
        print("  Error: $e");
        errorCount++;
      }
    }

    sentenceReviewList = sentenceReviewListTotalTemp;

    print("  Sentence review count: ${sentenceReviewList.length}");
    print("  Warning count: $warningCount");
    print("  Error count: $errorCount");

    notifyListeners();

    return errorCount == 0;
  }

  Future<bool> addSentenceReview(List<String> vocab) async {
    GeminiResponse? responseList = await geminiBatchSearchWords(vocab);
    try {
      if (responseList == null ||
          responseList.candidates?.length == 0 ||
          responseList.candidates?[0].content?.parts?.length == 0) {
        return false;
      }

      String? rawJson =
          responseList.candidates?[0].content?.parts?[0]['text'] ?? null;

      if (rawJson == null || rawJson.isEmpty) {
        return false;
      }

      String jsonString = rawJson.replaceAll('```', '').replaceAll('json', '');

      List<Sentence> sentenceReviewListTemp = (jsonDecode(jsonString) as List)
          .map((e) => Sentence.fromJson(e))
          .toList();

      sentenceReviewListTemp.forEach((element) {
        element.generatePartsAndReadings();

        if (element.word?.contains("(") ?? false) {
          print("  Warning: ${element.toJson()}");
        }
      });

      sentenceReviewList.addAll(sentenceReviewListTemp);
      notifyListeners();

      return true;
    } catch (e) {
      print("  Error: $e");
      return false;
    }
  }

  Sentence? getSentenceReviewByWord(String word) {
    return sentenceReviewList
        .firstWhereOrNull((element) => element.word == word);
  }

  bool isLearnt(String? character) {
    if (character == null || character.isEmpty) {
      return false;
    }

    character = character.replaceAll("々", "");

    if (character.length > 1) {
      Vocab? vocab = allVocabData?.firstWhereOrNull(
          (element) => element.data?.characters == character);

      var srsData = allSrsData!.firstWhereOrNull((element) =>
          element.data != null && element.data?.subjectId == vocab?.id);

      if (srsData != null && srsData.data?.startedAt != null) {
        return true;
      }
    }

    for (int i = 0; i < character.length; i++) {
      String? char = character[i];

      Kanji? kanji = allKanjiData
          ?.firstWhereOrNull((element) => element.data?.characters == char);

      var srsData = allSrsData!.firstWhereOrNull((element) =>
          element.data != null && element.data?.subjectId == kanji?.id);

      if (srsData == null || srsData.data?.startedAt == null) {
        return false;
      }
    }

    return true;
  }
}
