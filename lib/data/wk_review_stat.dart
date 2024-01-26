import 'dart:math';

import 'package:my_kanji_app/data/shared.dart';

class WkReviewStatRespone {
  String? object;
  String? url;
  Pages? pages;
  int? totalCount;
  String? dataUpdatedAt;
  List<WkReviewStatData>? data;

  WkReviewStatRespone(
      {this.object,
      this.url,
      this.pages,
      this.totalCount,
      this.dataUpdatedAt,
      this.data});

  WkReviewStatRespone.fromJson(Map<String, dynamic> json) {
    object = json['object'];
    url = json['url'];
    pages = json['pages'] != null ? Pages.fromJson(json['pages']) : null;
    totalCount = json['total_count'];
    dataUpdatedAt = json['data_updated_at'];
    if (json['data'] != null) {
      data = <WkReviewStatData>[];
      json['data'].forEach((v) {
        data!.add(WkReviewStatData.fromJson(v));
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

class WkReviewStatData {
  int? id;
  String? object;
  String? url;
  String? dataUpdatedAt;
  SubjectReviewStat? data;

  WkReviewStatData(
      {this.id, this.object, this.url, this.dataUpdatedAt, this.data});

  WkReviewStatData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    object = json['object'];
    url = json['url'];
    dataUpdatedAt = json['data_updated_at'];
    data =
        json['data'] != null ? SubjectReviewStat.fromJson(json['data']) : null;
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

class SubjectReviewStat {
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

  //
  double? meaningScore;
  double? readingScore;
  double? memoryScore;

  SubjectReviewStat(
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

  SubjectReviewStat.fromJson(Map<String, dynamic> json) {
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

    /*
    int correct = data['correct'];
    int incorrect = data['incorrect'];
    int maxStreak = data['max_streak'];
    int currentStreak = data['current_streak'];
    */

    meaningScore = calculateMemoryScore({
      "correct": meaningCorrect,
      "incorrect": meaningIncorrect,
      "max_streak": meaningMaxStreak,
      "current_streak": meaningCurrentStreak,
    });

    readingScore = calculateMemoryScore({
      "correct": readingCorrect,
      "incorrect": readingIncorrect,
      "max_streak": readingMaxStreak,
      "current_streak": readingCurrentStreak,
    });

    memoryScore = min(meaningScore!, readingScore!);
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
    data['meaningScore'] = meaningScore;
    data['readingScore'] = readingScore;
    data['memoryScore'] = memoryScore;
    return data;
  }

  /// This function calculates a score ranging from -1 to 1.
  /// A score closer to 1 indicates better memory, while closer to -1 suggests frequent forgetting.
  /// It considers:
  ///  - Accuracy: Base score based on correct/incorrect ratio.
  ///  - Streak Performance: Penalties for low current streak and high incorrect/correct ratio.
  double calculateMemoryScore(Map<String, dynamic> data) {
    // Extract data points
    int correct = data['correct'];
    int incorrect = data['incorrect'];
    int maxStreak = data['max_streak'];
    int currentStreak = data['current_streak'];

    // Base score based on correct/incorrect ratio
    double baseScore = correct / (correct + incorrect);

    // Penalty for low current streak relative to max streak
    double streakPenalty = 1.0 - (currentStreak / maxStreak);

    // Penalty for high incorrect/correct ratio
    double incorrectPenalty = incorrect / (correct + 1);

    // Combine penalties with base score
    double memoryScore = baseScore * (1 - streakPenalty*1.5 - incorrectPenalty);

    return memoryScore;
  }
}
