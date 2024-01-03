class UserData {
  String? object;
  String? url;
  String? dataUpdatedAt;
  ProfileData? data;

  UserData({this.object, this.url, this.dataUpdatedAt, this.data});

  UserData.fromJson(Map<String, dynamic> json) {
    object = json['object'];
    url = json['url'];
    dataUpdatedAt = json['data_updated_at'];
    data = json['data'] != null ? ProfileData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['object'] = object;
    data['url'] = url;
    data['data_updated_at'] = dataUpdatedAt;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class ProfileData {
  String? id;
  String? username;
  int? level;
  String? profileUrl;
  String? startedAt;
  Subscription? subscription;
  String? currentVacationStartedAt;
  Preferences? preferences;

  ProfileData(
      {this.id,
      this.username,
      this.level,
      this.profileUrl,
      this.startedAt,
      this.subscription,
      this.currentVacationStartedAt,
      this.preferences});

  ProfileData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    level = json['level'];
    profileUrl = json['profile_url'];
    startedAt = json['started_at'];
    subscription = json['subscription'] != null
        ? Subscription.fromJson(json['subscription'])
        : null;
    currentVacationStartedAt = json['current_vacation_started_at'];
    preferences = json['preferences'] != null
        ? Preferences.fromJson(json['preferences'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['username'] = username;
    data['level'] = level;
    data['profile_url'] = profileUrl;
    data['started_at'] = startedAt;
    if (subscription != null) {
      data['subscription'] = subscription!.toJson();
    }
    data['current_vacation_started_at'] = currentVacationStartedAt;
    if (preferences != null) {
      data['preferences'] = preferences!.toJson();
    }
    return data;
  }
}

class Subscription {
  bool? active;
  String? type;
  int? maxLevelGranted;
  String? periodEndsAt;

  Subscription(
      {this.active, this.type, this.maxLevelGranted, this.periodEndsAt});

  Subscription.fromJson(Map<String, dynamic> json) {
    active = json['active'];
    type = json['type'];
    maxLevelGranted = json['max_level_granted'];
    periodEndsAt = json['period_ends_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['active'] = active;
    data['type'] = type;
    data['max_level_granted'] = maxLevelGranted;
    data['period_ends_at'] = periodEndsAt;
    return data;
  }
}

class Preferences {
  int? lessonsBatchSize;
  int? defaultVoiceActorId;
  bool? lessonsAutoplayAudio;
  bool? reviewsAutoplayAudio;
  bool? extraStudyAutoplayAudio;
  String? lessonsPresentationOrder;
  String? reviewsPresentationOrder;
  bool? reviewsDisplaySrsIndicator;

  Preferences(
      {this.lessonsBatchSize,
      this.defaultVoiceActorId,
      this.lessonsAutoplayAudio,
      this.reviewsAutoplayAudio,
      this.extraStudyAutoplayAudio,
      this.lessonsPresentationOrder,
      this.reviewsPresentationOrder,
      this.reviewsDisplaySrsIndicator});

  Preferences.fromJson(Map<String, dynamic> json) {
    lessonsBatchSize = json['lessons_batch_size'];
    defaultVoiceActorId = json['default_voice_actor_id'];
    lessonsAutoplayAudio = json['lessons_autoplay_audio'];
    reviewsAutoplayAudio = json['reviews_autoplay_audio'];
    extraStudyAutoplayAudio = json['extra_study_autoplay_audio'];
    lessonsPresentationOrder = json['lessons_presentation_order'];
    reviewsPresentationOrder = json['reviews_presentation_order'];
    reviewsDisplaySrsIndicator = json['reviews_display_srs_indicator'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['lessons_batch_size'] = lessonsBatchSize;
    data['default_voice_actor_id'] = defaultVoiceActorId;
    data['lessons_autoplay_audio'] = lessonsAutoplayAudio;
    data['reviews_autoplay_audio'] = reviewsAutoplayAudio;
    data['extra_study_autoplay_audio'] = extraStudyAutoplayAudio;
    data['lessons_presentation_order'] = lessonsPresentationOrder;
    data['reviews_presentation_order'] = reviewsPresentationOrder;
    data['reviews_display_srs_indicator'] = reviewsDisplaySrsIndicator;
    return data;
  }
}