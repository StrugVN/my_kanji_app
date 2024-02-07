import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_kanji_app/component/selector.dart';
import 'package:my_kanji_app/data/kanji.dart';
import 'package:my_kanji_app/data/pitch_data.dart';
import 'package:my_kanji_app/data/radical.dart';
import 'package:my_kanji_app/data/userdata.dart';
import 'package:my_kanji_app/data/vocab.dart';
import 'package:my_kanji_app/data/wk_review_stat.dart';
import 'package:my_kanji_app/data/wk_srs_stat.dart';
import 'package:my_kanji_app/service/api.dart';
import 'package:collection/collection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppData extends ChangeNotifier {
  static final AppData _singleton = AppData._internal();

  String? apiKey;
  UserData userData = UserData();

  List<Kanji>? allKanjiData;
  List<Vocab>? allVocabData;
  List<Radical>? allRadicalData;
  List<PitchData>? pitchData;
  List<WkSrsStatData>? allSrsData;
  List<WkReviewStatData>? allReviewData;
  bool dataIsLoaded = false;
  bool networkError = false;

  // //////
  Map<String, SrsStage> formatMap = {};

  Map<String, Widget> characterCells = {};

  SourceTypeLabel stuffSourceLabel = SourceTypeLabel.Wanikani;
  // App setting ===========================================
  Map<String, bool> lessonSetting = {
    "radical": true,
    "kanji": true,
    "vocab": true,
  };

  int lessonBatchSize = 3;

  Map<String, bool> reviewSetting = {
    "radical": true,
    "kanji": true,
    "vocab": true,
  };

  int reviewDraftSize = 5;

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
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  void manualNotify() {
    notifyListeners();
  }

  Future<void> getData() async {
    initData();

    SharedPreferences prefs = await SharedPreferences.getInstance();

    print("  -- Data loading initialized --");

    await Future.wait([
      loadKanjiApi(),
      loadVocabApi(),
      loadRadicalApi(),
      loadVocabPitchData(),
      getSrsData(),
      getReviewStatData(),
      loadSetting(),
    ]);

    for (var element in allKanjiData!) {
      var srs =
          allSrsData!.firstWhereOrNull((e) => e.data?.subjectId == element.id);
      var review = allReviewData!
          .firstWhereOrNull((e) => e.data?.subjectId == element.id);

      if (srs != null) {
        element.srsData = srs;
      }

      if (review != null) {
        element.reviewData = review;
      }
    }

    for (var element in allVocabData!) {
      var srs =
          allSrsData!.firstWhereOrNull((e) => e.data?.subjectId == element.id);
      var review = allReviewData!
          .firstWhereOrNull((e) => e.data?.subjectId == element.id);

      if (srs != null) {
        element.srsData = srs;
      }

      if (review != null) {
        element.reviewData = review;
      }
    }

    for (var element in allRadicalData!) {
      var srs =
          allSrsData!.firstWhereOrNull((e) => e.data?.subjectId == element.id);
      var review = allReviewData!
          .firstWhereOrNull((e) => e.data?.subjectId == element.id);

      if (srs != null) {
        element.srsData = srs;
      }

      if (review != null) {
        element.reviewData = review;
      }
    }

    String kanjiDataAsString = jsonEncode(allKanjiData);
    String vocabDataAsString = jsonEncode(allVocabData);
    String radicalDataAsString = jsonEncode(allRadicalData);
    String srsDataAsString = jsonEncode(allSrsData);
    String reviewDataAsString = jsonEncode(allReviewData);

    await prefs.setString('kanjiCache', kanjiDataAsString);
    await prefs.setString('vocabCache', vocabDataAsString);
    await prefs.setString('radicalCache', radicalDataAsString);
    await prefs.setString('srsCache', srsDataAsString);
    await prefs.setString('reviewCache', reviewDataAsString);
    await prefs.setString('dateOfCache', DateTime.now().toString());

    dataIsLoaded = true;

    notifyListeners();
  }

  Future<void> getDataForce() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // await prefs.remove('kanjiCache');
    // await prefs.remove('vocabCache');
    // await prefs.remove('radicalCache');
    // await prefs.remove('srsCache');
    // await prefs.remove('reviewCache');
    await prefs.remove("dateOfCache");

    await getData();
  }

  void initData() {
    dataIsLoaded = false;
    networkError = false;
    // formatMap = {};
    // characterCells = {};
  }

  @Deprecated("Use the api one")
  Future<void> loadKanjiDataFromLocal() async {
    final kanjiDataF = rootBundle.loadString('assets/kanjidata.json');

    allKanjiData = [];
    for (var json in jsonDecode(await kanjiDataF)) {
      allKanjiData!.add(Kanji.fromJson(json));
    }

    print("  Kanji count: ${allKanjiData!.length}");
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

    print("  Kanji count: ${allKanjiData!.length}");
  }

  @Deprecated("Use the api one")
  Future<void> loadVocabDataFromLocal() async {
    final vocabDataF = rootBundle.loadString('assets/vocabdata.json');

    allVocabData = [];
    for (var json in jsonDecode(await vocabDataF)) {
      allVocabData!.add(Vocab.fromJson(json));
    }

    print("  Vocab count: ${allVocabData!.length}");
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

    print("  Vocab count: ${allVocabData!.length}");
  }

  Future<void> loadVocabPitchData() async {
    final pitchDataF = rootBundle.loadString('assets/pitchdata.json');

    pitchData = [];
    for (var json in jsonDecode(await pitchDataF)) {
      pitchData!.add(PitchData.fromJson(json));
    }

    print("  Pitch count: ${pitchData!.length}");
  }

  // For WK user only
  Future<void> getSrsData() async {
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
    } else {
      //1a
      var tempSrsData = await getAllSrsStat();
      if (tempSrsData.isNotEmpty) {
        allSrsData = tempSrsData;
      }
    }

    print("  SRS data count: ${allSrsData!.length}");
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

    print("  Review data count: ${allReviewData!.length}");
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
  }

  Future<void> saveApiKey() async {
    const storage = FlutterSecureStorage();
    await storage.write(
        key: 'apiKey', value: apiKey?.replaceAll("Bearer ", ""));
  }

  Future<String?> loadApiKey() async {
    const storage = FlutterSecureStorage();
    return await storage.read(key: 'apiKey');
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

    print("  Radical count: ${allRadicalData!.length}");
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
  }
}
