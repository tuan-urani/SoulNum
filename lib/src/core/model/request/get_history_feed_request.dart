class GetHistoryFeedRequest {
  const GetHistoryFeedRequest({
    this.profileId,
    this.cursor,
    this.limit = 20,
  });

  final String? profileId;
  final DateTime? cursor;
  final int limit;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'profile_id': profileId,
        'cursor': cursor?.toIso8601String(),
        'limit': limit,
      };
}

