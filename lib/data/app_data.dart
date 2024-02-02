import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:my_kanji_app/data/kanji.dart';
import 'package:my_kanji_app/data/pitch_data.dart';
import 'package:my_kanji_app/data/userdata.dart';
import 'package:my_kanji_app/data/vocab.dart';
import 'package:my_kanji_app/data/wk_review_stat.dart';
import 'package:my_kanji_app/data/wk_srs_stat.dart';
import 'package:my_kanji_app/service/api.dart';
import 'package:collection/collection.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppData {
  static final AppData _singleton = AppData._internal();

  String? apiKey;
  List<Kanji>? allKanjiData;
  List<Vocab>? allVocabData;
  List<PitchData>? pitchData;
  List<WkSrsStatData>? allSrsData;
  List<WkReviewStatData>? allReviewData;
  bool dataIsLoaded = false;

  UserData userData = UserData();

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

  Future<void> loadData() async {
    dataIsLoaded = false;

    SharedPreferences prefs = await SharedPreferences.getInstance();

    print("  -- Data loading initialized --");

    await Future.wait([
      loadKanjiApi(),
      loadVocabApi(),
      loadVocabPitchData(),
      getSrsData(),
      getReviewStatData()
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

    String kanjiDataAsString = jsonEncode(allKanjiData);
    String vocabDataAsString = jsonEncode(allVocabData);
    String srsDataAsString = jsonEncode(allSrsData);
    String reviewDataAsString = jsonEncode(allReviewData);

    await prefs.setString('kanjiCache', kanjiDataAsString);
    await prefs.setString('vocabCache', vocabDataAsString);
    await prefs.setString('srsCache', srsDataAsString);
    await prefs.setString('reviewCache', reviewDataAsString);
    await prefs.setString('dateOfCache', DateTime.now().toString());

    dataIsLoaded = true;
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

    if (kanjiListAsString != null) {
      //1b
      List<Kanji> tempKanjiList = (jsonDecode(kanjiListAsString) as List)
          .map((e) => Kanji.fromJson(e))
          .toList();
      DateTime date = DateTime.parse(dateString!);

      List<Kanji> updatedKanji = [];
      updatedKanji = await getAllSubjectAfterUpdate(
              "kanji", date.add(const Duration(days: -1)).toIso8601String()) ??
          [];

      for (var updatedItem in updatedKanji) {
        int index =
            tempKanjiList.indexWhere((item) => item.id == updatedItem.id);
        if (index != -1) {
          tempKanjiList[index] = updatedItem;
        }
      }

      allKanjiData = tempKanjiList;
    } else {
      //1a
      var kanjiDataF = getAllSubject("kanji");

      allKanjiData = await kanjiDataF ?? [];
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

    if (vocabListAsString != null) {
      //1
      List<Vocab> tempVocabList = (jsonDecode(vocabListAsString) as List)
          .map((e) => Vocab.fromJson(e))
          .toList();
      DateTime date = DateTime.parse(dateString!);

      //1b
      var updatedVocab = getAllSubjectAfterUpdate(
          "vocabulary", date.add(const Duration(days: -1)).toIso8601String());
      var updatedKanaVocab = getAllSubjectAfterUpdate("kana_vocabulary",
          date.add(const Duration(days: -1)).toIso8601String());

      List<Vocab> updatedAllVocab = [];
      updatedAllVocab =
          (await updatedVocab ?? []) + (await updatedKanaVocab ?? []);

      for (var updatedItem in updatedAllVocab) {
        int index =
            tempVocabList.indexWhere((item) => item.id == updatedItem.id);
        if (index != -1) {
          tempVocabList[index] = updatedItem;
        }
      }

      allVocabData = tempVocabList;
    } else {
      //1a
      var getVocab = getAllSubject("vocabulary");
      var getKanaVocab = getAllSubject("kana_vocabulary");

      allVocabData = (await getVocab ?? []) + (await getKanaVocab ?? []);
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

    if (srsListAsString != null) {
      //1
      List<WkSrsStatData> tempSrsList = (jsonDecode(srsListAsString) as List)
          .map((e) => WkSrsStatData.fromJson(e))
          .toList();
      DateTime date = DateTime.parse(dateString!);

      //1b
      var updatedSrsData = await getAllSrsStatAfter(
          date.add(const Duration(days: -1)).toIso8601String());

      for (var updatedItem in updatedSrsData) {
        int index = tempSrsList.indexWhere((item) => item.id == updatedItem.id);
        if (index != -1) {
          tempSrsList[index] = updatedItem;
        }
      }

      allSrsData = tempSrsList;
    } else {
      //1a
      allSrsData = await getAllSrsStat();
    }

    print("  SRS data count: ${allSrsData!.length}");
  }

  // For WK user only
  Future<void> getReviewStatData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? reviewListAsString = prefs.getString('reviewCache');
    String? dateString = prefs.getString('dateOfCache');

    if (reviewListAsString != null) {
      //1
      List<WkReviewStatData> tempReviewList = (jsonDecode(reviewListAsString) as List)
          .map((e) => WkReviewStatData.fromJson(e))
          .toList();
      DateTime date = DateTime.parse(dateString!);

      //1b
      var updatedReviewData = await getAllReviewStatAfter(
          date.add(const Duration(days: -1)).toIso8601String());

      for (var updatedItem in updatedReviewData) {
        int index = tempReviewList.indexWhere((item) => item.id == updatedItem.id);
        if (index != -1) {
          tempReviewList[index] = updatedItem;
        }
      }

      allReviewData = tempReviewList;
    } else {
      //1a
      allReviewData = await getAllReviewStat();
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

  void getData() async {
    var getKanji = getAllSubject("kanji");
    var getVocab = getAllSubject("vocabulary");
    var getKanaVocab = getAllSubject("kana_vocabulary");
    final pitchDataF = rootBundle.loadString('assets/pitchdata.json');

    allKanjiData = await getKanji;
    pitchData = [];
    for (var json in jsonDecode(await pitchDataF)) {
      pitchData!.add(PitchData.fromJson(json));
    }
    allVocabData = await getVocab + await getKanaVocab;

    print(allKanjiData!.length);
    print(allVocabData!.length);

    print(" -- Pitch data loaded: ${pitchData?.length}");
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
}
