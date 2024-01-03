import 'package:my_kanji_app/data/userdata.dart';

class User {
  static final User _singleton = User._internal();

  String? _apiKey;

  UserData _userData = UserData();

  UserData get userData => _userData;

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