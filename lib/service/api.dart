import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:my_kanji_app/data/user.dart';
import 'package:my_kanji_app/service/endpoints.dart';

final user = User();

Future<Response> getUser(String apiKey) {
  Map<String, String> header = {
    "Wanikani-Revision": "20170710",
    "Authorization": "Bearer $apiKey",
  };

  return http.get(Uri.parse(userEndpoint), headers: header);
}

Future<Response> getSubject(SubjectQueryParam param){
  Map<String, String> header = {
    "Wanikani-Revision": "20170710",
    "Authorization": user.apiKey!,
  };

  final uri =
    Uri.https(authority, subjectPath, param.toMap());

  print(uri);

  return http.get(uri, headers: header);
}


class SubjectQueryParam{
  List<String>? ids;
  List<String>? levels;
  List<String>? types;
  List<String>? slugs;
  
  SubjectQueryParam({this.ids, this.levels, this.types, this.slugs}) ;

  Map<String, dynamic> toMap() {
    return {
      'ids': ids,
      'levels': levels,
      'types': types,
      'slugs': slugs,
    };
  }
}