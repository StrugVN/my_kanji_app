import 'package:my_kanji_app/data/shared.dart';

class RadicalResponse {
  String? object;
  String? url;
  Pages? pages;
  int? totalCount;
  String? dataUpdatedAt;
  List<Radical>? data;

  RadicalResponse(
      {this.object,
      this.url,
      this.pages,
      this.totalCount,
      this.dataUpdatedAt,
      this.data});

  RadicalResponse.fromJson(Map<String, dynamic> json) {
    object = json['object'];
    url = json['url'];
    pages = json['pages'] != null ? Pages.fromJson(json['pages']) : null;
    totalCount = json['total_count'];
    dataUpdatedAt = json['data_updated_at'];
    if (json['data'] != null) {
      data = <Radical>[];
      json['data'].forEach((v) {
        data!.add(Radical.fromJson(v));
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

class Radical {
  int? id;
  String? object;
  String? url;
  String? dataUpdatedAt;
  Data? data;

  Radical({this.id, this.object, this.url, this.dataUpdatedAt, this.data});

  Radical.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    object = json['object'];
    url = json['url'];
    dataUpdatedAt = json['data_updated_at'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
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

class Data {
  String? createdAt;
  int? level;
  String? slug;
  String? hiddenAt;
  String? documentUrl;
  String? characters;
  List<CharacterImages>? characterImages;
  List<Meanings>? meanings;
  List<Meanings>? auxiliaryMeanings;
  List<int>? amalgamationSubjectIds;
  String? meaningMnemonic;
  int? lessonPosition;
  int? spacedRepetitionSystemId;

  Data(
      {this.createdAt,
      this.level,
      this.slug,
      this.hiddenAt,
      this.documentUrl,
      this.characters,
      this.characterImages,
      this.meanings,
      this.auxiliaryMeanings,
      this.amalgamationSubjectIds,
      this.meaningMnemonic,
      this.lessonPosition,
      this.spacedRepetitionSystemId});

  Data.fromJson(Map<String, dynamic> json) {
    createdAt = json['created_at'];
    level = json['level'];
    slug = json['slug'];
    hiddenAt = json['hidden_at'];
    documentUrl = json['document_url'];
    characters = json['characters'];
    if (json['character_images'] != null) {
      characterImages = <CharacterImages>[];
      json['character_images'].forEach((v) {
        characterImages!.add(CharacterImages.fromJson(v));
      });
    }
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
    amalgamationSubjectIds = json['amalgamation_subject_ids'].cast<int>();
    meaningMnemonic = json['meaning_mnemonic'];
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
    if (characterImages != null) {
      data['character_images'] =
          characterImages!.map((v) => v.toJson()).toList();
    }
    if (meanings != null) {
      data['meanings'] = meanings!.map((v) => v.toJson()).toList();
    }
    if (auxiliaryMeanings != null) {
      data['auxiliary_meanings'] =
          auxiliaryMeanings!.map((v) => v.toJson()).toList();
    }
    data['amalgamation_subject_ids'] = amalgamationSubjectIds;
    data['meaning_mnemonic'] = meaningMnemonic;
    data['lesson_position'] = lessonPosition;
    data['spaced_repetition_system_id'] = spacedRepetitionSystemId;
    return data;
  }
}

class CharacterImages {
  String? url;
  Metadata? metadata;
  String? contentType;

  CharacterImages({this.url, this.metadata, this.contentType});

  CharacterImages.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    metadata = json['metadata'] != null
        ? Metadata.fromJson(json['metadata'])
        : null;
    contentType = json['content_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['url'] = url;
    if (metadata != null) {
      data['metadata'] = metadata!.toJson();
    }
    data['content_type'] = contentType;
    return data;
  }
}

class Metadata {
  String? color;
  String? dimensions;
  String? styleName;
  bool? inlineStyles;

  Metadata({this.color, this.dimensions, this.styleName, this.inlineStyles});

  Metadata.fromJson(Map<String, dynamic> json) {
    color = json['color'];
    dimensions = json['dimensions'];
    styleName = json['style_name'];
    inlineStyles = json['inline_styles'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['color'] = color;
    data['dimensions'] = dimensions;
    data['style_name'] = styleName;
    data['inline_styles'] = inlineStyles;
    return data;
  }
}