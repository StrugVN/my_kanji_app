import 'package:my_kanji_app/data/shared.dart';
import 'package:my_kanji_app/data/wk_review_stat.dart';
import 'package:my_kanji_app/data/wk_srs_stat.dart';

class VocabResponse {
  String? object;
  String? url;
  Pages? pages;
  int? totalCount;
  String? dataUpdatedAt;
  List<Vocab>? data;

  VocabResponse(
      {this.object,
      this.url,
      this.pages,
      this.totalCount,
      this.dataUpdatedAt,
      this.data});

  VocabResponse.fromJson(Map<String, dynamic> json) {
    object = json['object'];
    url = json['url'];
    pages = json['pages'] != null ? Pages.fromJson(json['pages']) : null;
    totalCount = json['total_count'];
    dataUpdatedAt = json['data_updated_at'];
    if (json['data'] != null) {
      data = <Vocab>[];
      json['data'].forEach((v) {
        data!.add(Vocab.fromJson(v));
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

class Vocab {
  int? id;
  String? object;
  String? url;
  String? dataUpdatedAt;
  VocabData? data;

  // ====
  WkReviewStatData? reviewData;
  WkSrsStatData? srsData;

  Vocab({this.id, this.object, this.url, this.dataUpdatedAt, this.data});

  Vocab.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    object = json['object'];
    url = json['url'];
    dataUpdatedAt = json['data_updated_at'];
    data = json['data'] != null ? VocabData.fromJson(json['data']) : null;
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
    // if (reviewData != null) {
    //   data['reviewData'] = reviewData?.toJson();
    // }
    // if (srsData != null) {
    //   data['srsData'] = srsData?.toJson();
    // }
    return data;
  }
}

class VocabData {
  String? createdAt;
  int? level;
  String? slug;
  String? hiddenAt;
  String? documentUrl;
  String? characters;
  List<Meanings>? meanings;
  List<Meanings>? auxiliaryMeanings;
  List<Readings>? readings;
  List<String>? partsOfSpeech;
  List<int>? componentSubjectIds;
  String? meaningMnemonic;
  String? readingMnemonic;
  List<VocabContextSentences>? contextSentences;
  List<VocabPronunciationAudios>? pronunciationAudios;
  int? lessonPosition;
  int? spacedRepetitionSystemId;

  VocabData(
      {this.createdAt,
      this.level,
      this.slug,
      this.hiddenAt,
      this.documentUrl,
      this.characters,
      this.meanings,
      this.auxiliaryMeanings,
      this.readings,
      this.partsOfSpeech,
      this.componentSubjectIds,
      this.meaningMnemonic,
      this.readingMnemonic,
      this.contextSentences,
      this.pronunciationAudios,
      this.lessonPosition,
      this.spacedRepetitionSystemId});

  VocabData.fromJson(Map<String, dynamic> json) {
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
    partsOfSpeech = json['parts_of_speech']?.cast<String>();
    componentSubjectIds = json['component_subject_ids']?.cast<int>();
    meaningMnemonic = json['meaning_mnemonic'];
    readingMnemonic = json['reading_mnemonic'];
    if (json['context_sentences'] != null) {
      contextSentences = <VocabContextSentences>[];
      json['context_sentences'].forEach((v) {
        contextSentences!.add(VocabContextSentences.fromJson(v));
      });
    }
    if (json['pronunciation_audios'] != null) {
      pronunciationAudios = <VocabPronunciationAudios>[];
      json['pronunciation_audios'].forEach((v) {
        pronunciationAudios!.add(VocabPronunciationAudios.fromJson(v));
      });
    }
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
    data['parts_of_speech'] = partsOfSpeech;
    data['component_subject_ids'] = componentSubjectIds;
    data['meaning_mnemonic'] = meaningMnemonic;
    data['reading_mnemonic'] = readingMnemonic;
    if (contextSentences != null) {
      data['context_sentences'] =
          contextSentences!.map((v) => v.toJson()).toList();
    }
    if (pronunciationAudios != null) {
      data['pronunciation_audios'] =
          pronunciationAudios!.map((v) => v.toJson()).toList();
    }
    data['lesson_position'] = lessonPosition;
    data['spaced_repetition_system_id'] = spacedRepetitionSystemId;
    
    return data;
  }
}

class VocabContextSentences {
  String? en;
  String? ja;

  VocabContextSentences({this.en, this.ja});

  VocabContextSentences.fromJson(Map<String, dynamic> json) {
    en = json['en'];
    ja = json['ja'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['en'] = en;
    data['ja'] = ja;
    return data;
  }
}

class VocabPronunciationAudios {
  String? url;
  VocabMetadata? metadata;
  String? contentType;

  VocabPronunciationAudios({this.url, this.metadata, this.contentType});

  VocabPronunciationAudios.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    metadata = json['metadata'] != null
        ? VocabMetadata.fromJson(json['metadata'])
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

class VocabMetadata {
  String? gender;
  int? sourceId;
  String? pronunciation;
  int? voiceActorId;
  String? voiceActorName;
  String? voiceDescription;

  VocabMetadata(
      {this.gender,
      this.sourceId,
      this.pronunciation,
      this.voiceActorId,
      this.voiceActorName,
      this.voiceDescription});

  VocabMetadata.fromJson(Map<String, dynamic> json) {
    gender = json['gender'];
    sourceId = json['source_id'];
    pronunciation = json['pronunciation'];
    voiceActorId = json['voice_actor_id'];
    voiceActorName = json['voice_actor_name'];
    voiceDescription = json['voice_description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['gender'] = gender;
    data['source_id'] = sourceId;
    data['pronunciation'] = pronunciation;
    data['voice_actor_id'] = voiceActorId;
    data['voice_actor_name'] = voiceActorName;
    data['voice_description'] = voiceDescription;
    return data;
  }
}
