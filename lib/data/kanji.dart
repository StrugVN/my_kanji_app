import 'package:my_kanji_app/data/shared.dart';

class Kanji {
  int? id;
  String? object;
  String? url;
  String? dataUpdatedAt;
  KanjiData? data;

  Kanji({this.id, this.object, this.url, this.dataUpdatedAt, this.data});

  Kanji.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    object = json['object'];
    url = json['url'];
    dataUpdatedAt = json['data_updated_at'];
    data = json['data'] != null ? KanjiData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['object'] = object;
    data['url'] = url;
    data['data_updated_at'] = dataUpdatedAt;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class KanjiData {
  String? createdAt;
  int? level;
  String? slug;
  String? hiddenAt;
  String? documentUrl;
  String? characters;
  List<Meanings>? meanings;
  List<Meanings>? auxiliaryMeanings;
  List<Readings>? readings;
  List<int>? componentSubjectIds;
  List<int>? amalgamationSubjectIds;
  List<int>? visuallySimilarSubjectIds;
  String? meaningMnemonic;
  String? meaningHint;
  String? readingMnemonic;
  String? readingHint;
  int? lessonPosition;
  int? spacedRepetitionSystemId;

  KanjiData(
      {this.createdAt,
      this.level,
      this.slug,
      this.hiddenAt,
      this.documentUrl,
      this.characters,
      this.meanings,
      this.auxiliaryMeanings,
      this.readings,
      this.componentSubjectIds,
      this.amalgamationSubjectIds,
      this.visuallySimilarSubjectIds,
      this.meaningMnemonic,
      this.meaningHint,
      this.readingMnemonic,
      this.readingHint,
      this.lessonPosition,
      this.spacedRepetitionSystemId});

  KanjiData.fromJson(Map<String, dynamic> json) {
    createdAt = json['created_at'];
    level = json['level'];
    slug = json['slug'];
    hiddenAt = json['hidden_at'];
    documentUrl = json['document_url'];
    characters = json['characters'];
    if (json['meanings'] != null) {
      meanings = <Meanings>[];
      json['meanings'].forEach((v) {
        meanings!.add(Meanings.fromJson(v));
      });
    }
    if (json['auxiliary_meanings'] != null) {
      auxiliaryMeanings = <Meanings>[];
      json['auxiliary_meanings'].forEach((v) {
        auxiliaryMeanings!.add(Meanings.fromJson(v));
      });
    }
    if (json['readings'] != null) {
      readings = <Readings>[];
      json['readings'].forEach((v) {
        readings!.add(Readings.fromJson(v));
      });
    }
    componentSubjectIds = json['component_subject_ids'].cast<int>();
    amalgamationSubjectIds = json['amalgamation_subject_ids'].cast<int>();
    visuallySimilarSubjectIds =
        json['visually_similar_subject_ids'].cast<int>();
    meaningMnemonic = json['meaning_mnemonic'];
    meaningHint = json['meaning_hint'];
    readingMnemonic = json['reading_mnemonic'];
    readingHint = json['reading_hint'];
    lessonPosition = json['lesson_position'];
    spacedRepetitionSystemId = json['spaced_repetition_system_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['created_at'] = createdAt;
    data['level'] = level;
    data['slug'] = slug;
    data['hidden_at'] = hiddenAt;
    data['document_url'] = documentUrl;
    data['characters'] = characters;
    if (meanings != null) {
      data['meanings'] = meanings!.map((v) => v.toJson()).toList();
    }
    if (auxiliaryMeanings != null) {
      data['auxiliary_meanings'] =
          auxiliaryMeanings!.map((v) => v.toJson()).toList();
    }
    if (readings != null) {
      data['readings'] = readings!.map((v) => v.toJson()).toList();
    }
    data['component_subject_ids'] = componentSubjectIds;
    data['amalgamation_subject_ids'] = amalgamationSubjectIds;
    data['visually_similar_subject_ids'] = visuallySimilarSubjectIds;
    data['meaning_mnemonic'] = meaningMnemonic;
    data['meaning_hint'] = meaningHint;
    data['reading_mnemonic'] = readingMnemonic;
    data['reading_hint'] = readingHint;
    data['lesson_position'] = lessonPosition;
    data['spaced_repetition_system_id'] = spacedRepetitionSystemId;
    return data;
  }
}

