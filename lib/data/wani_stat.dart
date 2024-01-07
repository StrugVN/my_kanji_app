import 'package:my_kanji_app/data/shared.dart';

class WaniStat {
  String? object;
  String? url;
  Pages? pages;
  int? totalCount;
  String? dataUpdatedAt;
  List<WakiStatData>? data;

  WaniStat(
      {this.object,
      this.url,
      this.pages,
      this.totalCount,
      this.dataUpdatedAt,
      this.data});

  WaniStat.fromJson(Map<String, dynamic> json) {
    object = json['object'];
    url = json['url'];
    pages = json['pages'] != null ? Pages.fromJson(json['pages']) : null;
    totalCount = json['total_count'];
    dataUpdatedAt = json['data_updated_at'];
    if (json['data'] != null) {
      data = <WakiStatData>[];
      json['data'].forEach((v) {
        data!.add(WakiStatData.fromJson(v));
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

class WakiStatData {
  int? id;
  String? object;
  String? url;
  String? dataUpdatedAt;
  Assignment? data;

  WakiStatData({this.id, this.object, this.url, this.dataUpdatedAt, this.data});

  WakiStatData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    object = json['object'];
    url = json['url'];
    dataUpdatedAt = json['data_updated_at'];
    data = json['data'] != null ? Assignment.fromJson(json['data']) : null;
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

class Assignment {
  String? createdAt;
  int? subjectId;
  String? subjectType;
  int? srsStage;
  String? unlockedAt;
  String? startedAt;
  String? passedAt;
  String? burnedAt;
  String? availableAt;
  String? resurrectedAt;
  bool? hidden;

  Assignment(
      {this.createdAt,
      this.subjectId,
      this.subjectType,
      this.srsStage,
      this.unlockedAt,
      this.startedAt,
      this.passedAt,
      this.burnedAt,
      this.availableAt,
      this.resurrectedAt,
      this.hidden});

  Assignment.fromJson(Map<String, dynamic> json) {
    createdAt = json['created_at'];
    subjectId = json['subject_id'];
    subjectType = json['subject_type'];
    srsStage = json['srs_stage'];
    unlockedAt = json['unlocked_at'];
    startedAt = json['started_at'];
    passedAt = json['passed_at'];
    burnedAt = json['burned_at'];
    availableAt = json['available_at'];
    resurrectedAt = json['resurrected_at'];
    hidden = json['hidden'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['created_at'] = createdAt;
    data['subject_id'] = subjectId;
    data['subject_type'] = subjectType;
    data['srs_stage'] = srsStage;
    data['unlocked_at'] = unlockedAt;
    data['started_at'] = startedAt;
    data['passed_at'] = passedAt;
    data['burned_at'] = burnedAt;
    data['available_at'] = availableAt;
    data['resurrected_at'] = resurrectedAt;
    data['hidden'] = hidden;
    return data;
  }
}