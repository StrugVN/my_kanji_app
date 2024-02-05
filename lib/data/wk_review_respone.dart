import 'package:my_kanji_app/data/wk_review_stat.dart';
import 'package:my_kanji_app/data/wk_srs_stat.dart';

class WkReviewRespone {
  int? id;
  String? object;
  String? url;
  String? dataUpdatedAt;
  Data? data;
  ResourcesUpdated? resourcesUpdated;

  WkReviewRespone(
      {this.id,
      this.object,
      this.url,
      this.dataUpdatedAt,
      this.data,
      this.resourcesUpdated});

  WkReviewRespone.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    object = json['object'];
    url = json['url'];
    dataUpdatedAt = json['data_updated_at'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    resourcesUpdated = json['resources_updated'] != null
        ? ResourcesUpdated.fromJson(json['resources_updated'])
        : null;
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
    if (resourcesUpdated != null) {
      data['resources_updated'] = resourcesUpdated!.toJson();
    }
    return data;
  }
}

class Data {
  String? createdAt;
  int? assignmentId;
  int? subjectId;
  int? spacedRepetitionSystemId;
  int? startingSrsStage;
  int? endingSrsStage;
  int? incorrectMeaningAnswers;
  int? incorrectReadingAnswers;

  Data(
      {this.createdAt,
      this.assignmentId,
      this.subjectId,
      this.spacedRepetitionSystemId,
      this.startingSrsStage,
      this.endingSrsStage,
      this.incorrectMeaningAnswers,
      this.incorrectReadingAnswers});

  Data.fromJson(Map<String, dynamic> json) {
    createdAt = json['created_at'];
    assignmentId = json['assignment_id'];
    subjectId = json['subject_id'];
    spacedRepetitionSystemId = json['spaced_repetition_system_id'];
    startingSrsStage = json['starting_srs_stage'];
    endingSrsStage = json['ending_srs_stage'];
    incorrectMeaningAnswers = json['incorrect_meaning_answers'];
    incorrectReadingAnswers = json['incorrect_reading_answers'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['created_at'] = createdAt;
    data['assignment_id'] = assignmentId;
    data['subject_id'] = subjectId;
    data['spaced_repetition_system_id'] = spacedRepetitionSystemId;
    data['starting_srs_stage'] = startingSrsStage;
    data['ending_srs_stage'] = endingSrsStage;
    data['incorrect_meaning_answers'] = incorrectMeaningAnswers;
    data['incorrect_reading_answers'] = incorrectReadingAnswers;
    return data;
  }
}

class ResourcesUpdated {
  WkSrsStatData? assignment;
  WkReviewStatData? reviewStatistic;

  ResourcesUpdated({this.assignment, this.reviewStatistic});

  ResourcesUpdated.fromJson(Map<String, dynamic> json) {
    assignment = json['assignment'] != null
        ? WkSrsStatData.fromJson(json['assignment'])
        : null;
    reviewStatistic = json['review_statistic'] != null
        ? WkReviewStatData.fromJson(json['review_statistic'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (assignment != null) {
      data['assignment'] = assignment!.toJson();
    }
    if (reviewStatistic != null) {
      data['review_statistic'] = reviewStatistic!.toJson();
    }
    return data;
  }
}