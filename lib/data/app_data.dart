import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:my_kanji_app/data/kanji.dart';
import 'package:my_kanji_app/data/pitch_data.dart';
import 'package:my_kanji_app/data/userdata.dart';
import 'package:my_kanji_app/data/vocab.dart';
import 'package:my_kanji_app/service/api.dart';

class AppData {
  static final AppData _singleton = AppData._internal();

  String? _apiKey;
  List<Kanji>? _allKanjiData;
  List<Vocab>? _allVocabData;
  List<PitchData>? _pitchData;

  List<PitchData>? get pitchData => _pitchData;

  set pitchData(List<PitchData>? value) {
    _pitchData = value;
  }

  List<Vocab>? get allVocabData => _allVocabData;

  set allVocabData(List<Vocab>? value) {
    _allVocabData = value;
  }  

  UserData _userData = UserData();

  UserData get userData => _userData;

  List<Kanji>? get allKanjiData => _allKanjiData;

  set allKanjiData(List<Kanji>? value) {
    _allKanjiData = value;
  }

  set userData(UserData value) {
    _userData = value;
  }

  String? get apiKey => _apiKey;

  set apiKey(String? value) {
    _apiKey = value;
  }

  factory AppData() {
    return _singleton;
  }

  AppData._internal();

  void removeKey(){
    _apiKey = null;
  }

  
  Future<void> loadDataFromAsset() async {
    final kanjiDataF = rootBundle.loadString('assets/kanjidata.json');
    final pitchDataF = rootBundle.loadString('assets/pitchdata.json');
    final vocabDataF = rootBundle.loadString('assets/vocabdata.json');

    _allKanjiData = [];
    for (var json in jsonDecode(await kanjiDataF)) {
      _allKanjiData!.add(Kanji.fromJson(json));
    }

    _pitchData = [];
    for (var json in jsonDecode(await pitchDataF)) {
      _pitchData!.add(PitchData.fromJson(json));
    }

    _allVocabData = [];
    for (var json in jsonDecode(await vocabDataF)) {
      _allVocabData!.add(Vocab.fromJson(json));
    }

    print(_allKanjiData!.length);
    print(_allVocabData!.length);
    print(" -- Pitch data loaded: ${_pitchData?.length}");
  }


  List<Kanji> getListKanjiFromLocal({List<int>? ids, List<int>? levels, List<String>? slugs}){
    if(_allKanjiData == null) return [];

    return _allKanjiData!.where((element) => kanjiFilter(element, ids: ids, levels: levels, slugs: slugs)).toList();
  }

  bool kanjiFilter(Kanji kanji, {List<int>? ids, List<int>? levels, List<String>? slugs}){
    return true 
      && ids != null ? ids.contains(kanji.id) : true
      && levels != null ? levels.contains(kanji.data?.level) : true
      && slugs != null ? slugs.contains(kanji.data?.slug) : true; 
  }

  List<Vocab> getListVocabFromLocal({List<int>? ids, List<int>? levels, List<String>? slugs}){
    if(_allVocabData == null) return [];

    return _allVocabData!.where((element) => vocabFilter(element, ids: ids, levels: levels, slugs: slugs)).toList();
  }

  bool vocabFilter(Vocab kanji, {List<int>? ids, List<int>? levels, List<String>? slugs}){
    return true 
      && ids != null ? ids.contains(kanji.id) : true
      && levels != null ? levels.contains(kanji.data?.level) : true
      && slugs != null ? slugs.contains(kanji.data?.slug) : true; 
  }


  List<Vocab> getListVocabFromLocalByKanji(List<String> usedKanji){
    if(_allVocabData == null) {
      return [];
    }
    
    return _allVocabData!.where((e) => isVocabContain(e, usedKanji)).toList();
  }

  List<String> allKanjiInVocab(Vocab vocab){
    return getListKanjiFromLocal(ids:vocab.data?.componentSubjectIds, levels: null, slugs: null).map((e) => e.data?.slug ?? "").toList();
  }

  bool isVocabContain(Vocab vocab, List<String> usedKanji){
    Set<String> componentSet = {...allKanjiInVocab(vocab)};
    Set<String> usedKanjiSet = {...usedKanji};

    return usedKanjiSet.containsAll(componentSet);
  }

  void getData() async {
    var getKanji = getAllSubject("kanji");
    var getVocab = getAllSubject("vocabulary");
    var getKanaVocab = getAllSubject("kana_vocabulary");
    final pitchDataF = rootBundle.loadString('assets/pitchdata.json');

    _allKanjiData = await getKanji;
    _pitchData = [];
    for (var json in jsonDecode(await pitchDataF)) {
      _pitchData!.add(PitchData.fromJson(json));
    }
    _allVocabData = await getVocab + await getKanaVocab;
    
    print(_allKanjiData!.length);
    print(_allVocabData!.length);

    print(" -- Pitch data loaded: ${_pitchData?.length}");
  }

  @Deprecated("Use load from local")
  Future<List<PitchData>> loadPitchDataPart(int partNum) async {
    String pitchJson = "assets/pitch_json/term_meta_bank_$partNum.json";

    String data = await rootBundle.loadString(pitchJson);
    final jsonS = jsonDecode(data);

    List<PitchData>? pitchData = [];
    for (var item in jsonS){
      pitchData.add(PitchData.fromData(item));
    }
    print("  -- Loaded: $pitchJson");
    return pitchData;
  }

  @Deprecated("Use load from local")
  Future<List<PitchData>> loadPitchData() async {
    List<Future<List<PitchData>>> taskList = [];

    for (int i=1; i<=13; i++){
      taskList.add(loadPitchDataPart(i));
    }

    List<PitchData> data = [];
    for (var task in taskList){
      data = data + await task;
    }

    return data;
  }
}