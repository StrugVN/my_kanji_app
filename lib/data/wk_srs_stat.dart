import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_kanji_app/data/shared.dart';

class WkSrsStatResponse {
  String? object;
  String? url;
  Pages? pages;
  int? totalCount;
  String? dataUpdatedAt;
  List<WkSrsStatData>? data;

  WkSrsStatResponse(
      {this.object,
      this.url,
      this.pages,
      this.totalCount,
      this.dataUpdatedAt,
      this.data});

  WkSrsStatResponse.fromJson(Map<String, dynamic> json) {
    object = json['object'];
    url = json['url'];
    pages = json['pages'] != null ? Pages.fromJson(json['pages']) : null;
    totalCount = json['total_count'];
    dataUpdatedAt = json['data_updated_at'];
    if (json['data'] != null) {
      data = <WkSrsStatData>[];
      json['data'].forEach((v) {
        data!.add(WkSrsStatData.fromJson(v));
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

class WkSrsStatData {
  int? id;
  String? object;
  String? url;
  String? dataUpdatedAt;
  Assignment? data;

  WkSrsStatData(
      {this.id, this.object, this.url, this.dataUpdatedAt, this.data});

  WkSrsStatData.fromJson(Map<String, dynamic> json) {
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

  DateTime? getNextReviewAsDateTime() {
    if (availableAt != null) {
      return DateTime.parse(availableAt!).toLocal();
    }
    return null;
  }

  String? getNextReviewAsLocalTime() {
    if (availableAt != null) {
      return DateFormat('dd/MM/yyyy hh:mm:ss a')
          .format((DateTime.parse(availableAt!).toLocal()));
    }
    return null;
  }

  DateTime? getUnlockededDateAsDateTime() {
    if (unlockedAt != null) {
      return DateTime.parse(unlockedAt!).toLocal();
    }
    return null;
  }

  String? getUnlockededDateAsLocalTime() {
    if (unlockedAt != null) {
      return DateFormat('dd/MM/yyyy hh:mm:ss a')
          .format((DateTime.parse(unlockedAt!).toLocal()));
    }
    return null;
  }

  SrsStage getSrs() {
    return SrsStage.fromId(srsStage!);
  }
}

enum SrsStage {
  locked(0, "Locked", Colors.grey),
  apprenticeI(1, "A1", Color.fromARGB(255, 255, 159, 191)),
  apprenticeII(2, "A2", Color.fromARGB(255, 252, 110, 157)),
  apprenticeIII(3, "A3", Color.fromRGBO(255, 57, 123, 1)),
  apprenticeIV(4, "A4", Color.fromARGB(255, 255, 15, 95)),
  guru(5, "Guru", Colors.purple),
  guruII(6, "Guru II", Colors.purple),
  master(7, "Master", Colors.blue),
  enlighted(8, "Enlightened", Colors.green),
  burned(9, "Burned", Colors.black54),
  ;

  const SrsStage(this.id, this.label, this.color);
  final int id;
  final String label;
  final Color color;

  static SrsStage fromId(int? id) {
    if (id == null) {
      return SrsStage.locked;
    }

    return SrsStage.values.firstWhere((element) => element.id == id,
        orElse: () => SrsStage.locked);
  }
}
