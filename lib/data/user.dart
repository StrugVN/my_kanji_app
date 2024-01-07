import 'package:my_kanji_app/data/kanji.dart';
import 'package:my_kanji_app/data/userdata.dart';
import 'package:my_kanji_app/data/vocab.dart';

class User {
  static final User _singleton = User._internal();

  String? _apiKey;
  List<Kanji>? _allKanjiData;
  List<Vocab>? allVocabData;  

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

  factory User() {
    return _singleton;
  }

  User._internal();

  void removeKey(){
    _apiKey = null;
  }
}