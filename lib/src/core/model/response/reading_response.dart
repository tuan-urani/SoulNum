class ReadingResponse {
  const ReadingResponse({
    required this.readingId,
    required this.featureKey,
    required this.result,
    required this.generatedAt,
    required this.fromCache,
  });

  final String readingId;
  final String featureKey;
  final Map<String, dynamic> result;
  final DateTime generatedAt;
  final bool fromCache;

  factory ReadingResponse.fromJson(Map<String, dynamic> json) {
    return ReadingResponse(
      readingId: json['reading_id'] as String? ?? '',
      featureKey: json['feature_key'] as String? ?? '',
      result: (json['result'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{},
      generatedAt: DateTime.tryParse(json['generated_at'] as String? ?? '') ?? DateTime.now(),
      fromCache: json['from_cache'] as bool? ?? false,
    );
  }
}

