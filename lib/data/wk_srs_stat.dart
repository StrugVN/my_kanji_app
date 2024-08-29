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
  notExist(-2, "", Color.fromARGB(255, 197, 197, 197), Colors.grey),
  unDiscovered(-1, "", Colors.grey, Colors.black),
  locked(0, "Locked", Color.fromARGB(255, 233, 233, 233), Colors.black),
  apprenticeI(1, "Apprentice I", Color.fromARGB(255, 249, 193, 211), Colors.black),
  apprenticeII(2, "Apprentice II", Color.fromARGB(255, 255, 148, 184), Colors.black),
  apprenticeIII(3, "Apprentice III", Color.fromRGBO(255, 55, 122, 1), Colors.black),
  apprenticeIV(4, "Apprentice IV", Color.fromARGB(255, 247, 20, 4), Colors.black),
  guru(5, "Guru", Color.fromARGB(255, 217, 104, 236), Colors.black),
  guruII(6, "Guru II", Color.fromARGB(255, 153, 21, 177), Colors.black),
  master(7, "Master", Color.fromARGB(255, 95, 208, 99), Colors.black),
  enlightened (8, "Enlightened", Colors.blue, Colors.black),
  burned(9, "Burned", Colors.black54, Colors.white70),
  ;

  const SrsStage(this.id, this.label, this.color, this.textColor);
  final int id;
  final String label;
  final Color color;
  final Color textColor;

  static SrsStage fromId(int? id) {
    if (id == null) {
      return SrsStage.locked;
    }

    return SrsStage.values.firstWhere((element) => element.id == id,
        orElse: () => SrsStage.locked);
  }
}
