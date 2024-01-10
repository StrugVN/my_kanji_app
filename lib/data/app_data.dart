import 'package:my_kanji_app/data/kanji.dart';
import 'package:my_kanji_app/data/pitch_data.dart';
import 'package:my_kanji_app/data/userdata.dart';
import 'package:my_kanji_app/data/vocab.dart';

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
}