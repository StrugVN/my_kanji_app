import 'package:my_kanji_app/data/shared.dart';

class ProgressionStat {
  String? object;
  String? url;
  Pages? pages;
  int? totalCount;
  String? dataUpdatedAt;
  List<ProgressionData>? data;

  ProgressionStat(
      {this.object,
      this.url,
      this.pages,
      this.totalCount,
      this.dataUpdatedAt,
      this.data});

  ProgressionStat.fromJson(Map<String, dynamic> json) {
    object = json['object'];
    url = json['url'];
    pages = json['pages'] != null ? Pages.fromJson(json['pages']) : null;
    totalCount = json['total_count'];
    dataUpdatedAt = json['data_updated_at'];
    if (json['data'] != null) {
      data = <ProgressionData>[];
      json['data'].forEach((v) {
        data!.add(ProgressionData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['object'] = object;
    data['url'] = url;
    if (pages != null) {
      data['pages'] = pages!.toJson();
    }
    data['total_count'] = totalCount;
    data['data_updated_at'] = dataUpdatedAt;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ProgressionData {
  int? id;
  String? object;
  String? url;
  String? dataUpdatedAt;
  Progression? data;

  ProgressionData({this.id, this.object, this.url, this.dataUpdatedAt, this.data});

  ProgressionData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    object = json['object'];
    url = json['url'];
    dataUpdatedAt = json['data_updated_at'];
    data = json['data'] != null ? Progression.fromJson(json['data']) : null;
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

class Progression {
  String? createdAt;
  int? subjectId;
  String? subjectType;
  int? meaningCorrect;
  int? meaningIncorrect;
  int? meaningMaxStreak;
  int? meaningCurrentStreak;
  int? readingCorrect;
  int? readingIncorrect;
  int? readingMaxStreak;
  int? readingCurrentStreak;
  int? percentageCorrect;
  bool? hidden;

  Progression(
      {this.createdAt,
      this.subjectId,
      this.subjectType,
      this.meaningCorrect,
      this.meaningIncorrect,
      this.meaningMaxStreak,
      this.meaningCurrentStreak,
      this.readingCorrect,
      this.readingIncorrect,
      this.readingMaxStreak,
      this.readingCurrentStreak,
      this.percentageCorrect,
      this.hidden});

  Progression.fromJson(Map<String, dynamic> json) {
    createdAt = json['created_at'];
    subjectId = json['subject_id'];
    subjectType = json['subject_type'];
    meaningCorrect = json['meaning_correct'];
    meaningIncorrect = json['meaning_incorrect'];
    meaningMaxStreak = json['meaning_max_streak'];
    meaningCurrentStreak = json['meaning_current_streak'];
    readingCorrect = json['reading_correct'];
    readingIncorrect = json['reading_incorrect'];
    readingMaxStreak = json['reading_max_streak'];
    readingCurrentStreak = json['reading_current_streak'];
    percentageCorrect = json['percentage_correct'];
    hidden = json['hidden'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['created_at'] = createdAt;
    data['subject_id'] = subjectId;
    data['subject_type'] = subjectType;
    data['meaning_correct'] = meaningCorrect;
    data['meaning_incorrect'] = meaningIncorrect;
    data['meaning_max_streak'] = meaningMaxStreak;
    data['meaning_current_streak'] = meaningCurrentStreak;
    data['reading_correct'] = readingCorrect;
    data['reading_incorrect'] = readingIncorrect;
    data['reading_max_streak'] = readingMaxStreak;
    data['reading_current_streak'] = readingCurrentStreak;
    data['percentage_correct'] = percentageCorrect;
    data['hidden'] = hidden;
    return data;
  }
}