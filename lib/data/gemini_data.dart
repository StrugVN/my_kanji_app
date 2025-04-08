class GeminiResponse {
  List<Candidates>? candidates;
  UsageMetadata? usageMetadata;
  String? modelVersion;

  GeminiResponse({this.candidates, this.usageMetadata, this.modelVersion});

  GeminiResponse.fromJson(Map<String, dynamic> json) {
    if (json['candidates'] != null) {
      candidates = <Candidates>[];
      json['candidates'].forEach((v) {
        candidates!.add(Candidates.fromJson(v));
      });
    }
    usageMetadata = json['usage_metadata'] != null
        ? UsageMetadata.fromJson(json['usage_metadata'])
        : null;
    modelVersion = json['model_version'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (candidates != null) {
      data['candidates'] = candidates!.map((v) => v.toJson()).toList();
    }
    if (usageMetadata != null) {
      data['usage_metadata'] = usageMetadata!.toJson();
    }
    data['model_version'] = modelVersion;
    return data;
  }
}

class Candidates {
  Content? content;
  String? finishReason;
  double? avgLogProbs;

  Candidates({this.content, this.finishReason, this.avgLogProbs});

  Candidates.fromJson(Map<String, dynamic> json) {
    content = json['content'] != null
        ? Content.fromJson(json['content'])
        : null;
    finishReason = json['finish_reason'];
    avgLogProbs = json['avg_logprobs'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (content != null) {
      data['content'] = content!.toJson();
    }
    data['finish_reason'] = finishReason;
    data['avg_logprobs'] = avgLogProbs;
    return data;
  }
}

class Content {
  List<Map<String, String>>? parts;
  String? role;

  Content({this.parts, this.role});

  Content.fromJson(Map<String, dynamic> json) {
    if (json['parts'] != null) {
      parts = <Map<String, String>>[];
      json['parts'].forEach((v) {
        parts!.add(Map<String, String>.from(v));
      });
    }
    role = json['role'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (parts != null) {
      data['parts'] = parts!.map((v) => v).toList();
    }
    data['role'] = role;
    return data;
  }
}

class UsageMetadata {
  int? promptTokenCount;
  int? candidatesTokenCount;
  int? totalTokenCount;
  TokensDetails? promptTokenDetails;
  TokensDetails? candidatesTokenDetails;

  UsageMetadata(
      {this.promptTokenCount,
      this.candidatesTokenCount,
      this.totalTokenCount,
      this.promptTokenDetails,
      this.candidatesTokenDetails});

  UsageMetadata.fromJson(Map<String, dynamic> json) {
    promptTokenCount = json['prompt_token_count'];
    candidatesTokenCount = json['candidates_token_count'];
    totalTokenCount = json['total_token_count'];
    promptTokenDetails = json['prompt_token_details'] != null
        ? TokensDetails.fromJson(json['prompt_token_details'])
        : null;
    candidatesTokenDetails = json['candidates_token_details'] != null
        ? TokensDetails.fromJson(json['candidates_token_details'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['prompt_token_count'] = promptTokenCount;
    data['candidates_token_count'] = candidatesTokenCount;
    data['total_token_count'] = totalTokenCount;
    if (promptTokenDetails != null) {
      data['prompt_token_details'] = promptTokenDetails!.toJson();
    }
    if (candidatesTokenDetails != null) {
      data['candidates_token_details'] = candidatesTokenDetails!.toJson();
    }
    return data;
  }
}

class TokensDetails {
  String? modality;
  int? tokenCount;

  TokensDetails({this.modality, this.tokenCount});

  TokensDetails.fromJson(Map<String, dynamic> json) {
    modality = json['modality'];
    tokenCount = json['token_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['modality'] = modality;
    data['token_count'] = tokenCount;
    return data;
  }
}

