class MaziiWordResponse {
  int? status;
  bool? found;
  List<MaziiData>? data;

  MaziiWordResponse({this.status, this.found, this.data});

  MaziiWordResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    found = json['found'];
    if (json['data'] != null) {
      data = <MaziiData>[];
      json['data'].forEach((v) {
        data!.add(new MaziiData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['found'] = this.found;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class MaziiData {
  int? mobileId;
  String? shortMean;
  String? word;
  String? type;
  List<Means>? means;
  String? phonetic;
  List<Synsets>? synsets;
  int? weight;
  List<String>? oppositeWord;
  List<Pronunciation>? pronunciation;
  String? label;
  String? sId;
  String? sRev;

  MaziiData(
      {this.mobileId,
      this.shortMean,
      this.word,
      this.type,
      this.means,
      this.phonetic,
      this.synsets,
      this.weight,
      this.oppositeWord,
      this.pronunciation,
      this.label,
      this.sId,
      this.sRev});

  MaziiData.fromJson(Map<String, dynamic> json) {
    mobileId = json['mobileId'];
    shortMean = json['short_mean'];
    word = json['word'];
    type = json['type'];
    if (json['means'] != null) {
      means = <Means>[];
      json['means'].forEach((v) {
        means!.add(new Means.fromJson(v));
      });
    }
    phonetic = json['phonetic'];
    if (json['synsets'] != null) {
      synsets = <Synsets>[];
      json['synsets'].forEach((v) {
        synsets!.add(new Synsets.fromJson(v));
      });
    }
    weight = json['weight'];
    oppositeWord = json['opposite_word'] != null ? json['opposite_word'].cast<String>() : null;
    if (json['pronunciation'] != null) {
      pronunciation = <Pronunciation>[];
      json['pronunciation'].forEach((v) {
        pronunciation!.add(new Pronunciation.fromJson(v));
      });
    }
    label = json['label'];
    sId = json['_id'];
    sRev = json['_rev'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['mobileId'] = this.mobileId;
    data['short_mean'] = this.shortMean;
    data['word'] = this.word;
    data['type'] = this.type;
    if (this.means != null) {
      data['means'] = this.means!.map((v) => v.toJson()).toList();
    }
    data['phonetic'] = this.phonetic;
    if (this.synsets != null) {
      data['synsets'] = this.synsets!.map((v) => v.toJson()).toList();
    }
    data['weight'] = this.weight;
    data['opposite_word'] = this.oppositeWord;
    if (this.pronunciation != null) {
      data['pronunciation'] =
          this.pronunciation!.map((v) => v.toJson()).toList();
    }
    data['label'] = this.label;
    data['_id'] = this.sId;
    data['_rev'] = this.sRev;
    return data;
  }
}

class Means {
  String? kind;
  String? mean;
  dynamic examples;

  Means({this.kind, this.mean, this.examples});

  Means.fromJson(Map<String, dynamic> json) {
    kind = json['kind'];
    mean = json['mean'];
    examples = json['examples'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['kind'] = this.kind;
    data['mean'] = this.mean;
    data['examples'] = this.examples;
    return data;
  }
}

class Synsets {
  String? pos;
  String? baseForm;
  List<Entry>? entry;

  Synsets({this.pos, this.baseForm, this.entry});

  Synsets.fromJson(Map<String, dynamic> json) {
    pos = json['pos'];
    baseForm = json['base_form'];
    if (json['entry'] != null) {
      entry = <Entry>[];
      json['entry'].forEach((v) {
        entry!.add(new Entry.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['pos'] = this.pos;
    data['base_form'] = this.baseForm;
    if (this.entry != null) {
      data['entry'] = this.entry!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Entry {
  List<String>? synonym;
  String? definitionId;

  Entry({this.synonym, this.definitionId});

  Entry.fromJson(Map<String, dynamic> json) {
    synonym = json['synonym'] != null ? json['synonym'].cast<String>() : null;
    definitionId = json['definition_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['synonym'] = this.synonym;
    data['definition_id'] = this.definitionId;
    return data;
  }
}

class Pronunciation {
  List<Transcriptions>? transcriptions;
  String? type;
  String? word;

  Pronunciation({this.transcriptions, this.type, this.word});

  Pronunciation.fromJson(Map<String, dynamic> json) {
    if (json['transcriptions'] != null) {
      transcriptions = <Transcriptions>[];
      json['transcriptions'].forEach((v) {
        transcriptions!.add(new Transcriptions.fromJson(v));
      });
    }
    type = json['type'];
    word = json['word'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.transcriptions != null) {
      data['transcriptions'] =
          this.transcriptions!.map((v) => v.toJson()).toList();
    }
    data['type'] = this.type;
    data['word'] = this.word;
    return data;
  }
}

class Transcriptions {
  String? romaji;
  String? kana;

  Transcriptions({this.romaji, this.kana});

  Transcriptions.fromJson(Map<String, dynamic> json) {
    romaji = json['romaji'];
    kana = json['kana'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['romaji'] = this.romaji;
    data['kana'] = this.kana;
    return data;
  }
}

// ==============================================================
// ==============================================================

class MaziiKanjiResponse {
  int? status;
  List<Results>? results;
  int? total;

  MaziiKanjiResponse({this.status, this.results, this.total});

  MaziiKanjiResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['results'] != null) {
      results = <Results>[];
      json['results'].forEach((v) {
        results!.add(new Results.fromJson(v));
      });
    }
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.results != null) {
      data['results'] = this.results!.map((v) => v.toJson()).toList();
    }
    data['total'] = this.total;
    return data;
  }
}

class Results {
  String? mean;
  String? kun;
  dynamic writing;
  String? label;
  String? on;
  String? detail;
  int? freq;
  List<Examples>? examples;
  List<String>? level;
  String? kanji;
  dynamic exampleKun;
  dynamic exampleOn;
  String? strokeCount;
  dynamic compDetail;
  int? mobileId;

  Results(
      {this.mean,
      this.kun,
      this.writing,
      this.label,
      this.on,
      this.detail,
      this.freq,
      this.examples,
      this.level,
      this.kanji,
      this.exampleKun,
      this.exampleOn,
      this.strokeCount,
      this.compDetail,
      this.mobileId});

  Results.fromJson(Map<String, dynamic> json) {
    mean = json['mean'];
    kun = json['kun'];
    writing = json['writing'];
    label = json['label'];
    on = json['on'];
    detail = json['detail'];
    freq = json['freq'];
    if (json['examples'] != null) {
      examples = <Examples>[];
      json['examples'].forEach((v) {
        examples!.add(new Examples.fromJson(v));
      });
    }
    level = json['level'] != null ? json['level'].cast<String>() : null;
    kanji = json['kanji'];
    exampleKun = json['example_kun'];
    exampleOn = json['example_on'];
    strokeCount = json['stroke_count'];
    compDetail = json['compDetail'];
    mobileId = json['mobileId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['mean'] = this.mean;
    data['kun'] = this.kun;
    data['writing'] = this.writing;
    data['label'] = this.label;
    data['on'] = this.on;
    data['detail'] = this.detail;
    data['freq'] = this.freq;
    if (this.examples != null) {
      data['examples'] = this.examples!.map((v) => v.toJson()).toList();
    }
    data['level'] = this.level;
    data['kanji'] = this.kanji;
    data['example_kun'] = this.exampleKun;
    data['example_on'] = this.exampleOn;
    data['stroke_count'] = this.strokeCount;
    data['compDetail'] = this.compDetail;
    data['mobileId'] = this.mobileId;
    return data;
  }
}

class Examples {
  String? m;
  String? h;
  String? p;
  String? w;

  Examples({this.m, this.h, this.p, this.w});

  Examples.fromJson(Map<String, dynamic> json) {
    m = json['m'];
    h = json['h'];
    p = json['p'];
    w = json['w'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['m'] = this.m;
    data['h'] = this.h;
    data['p'] = this.p;
    data['w'] = this.w;
    return data;
  }
}
