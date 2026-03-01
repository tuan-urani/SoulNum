class ChatReplyResponse {
  const ChatReplyResponse({
    required this.sessionId,
    required this.reply,
    required this.remainingQuota,
    required this.quotaLimit,
    required this.quotaExhausted,
  });

  final String? sessionId;
  final String? reply;
  final int remainingQuota;
  final int quotaLimit;
  final bool quotaExhausted;

  factory ChatReplyResponse.fromJson(Map<String, dynamic> json) {
    return ChatReplyResponse(
      sessionId: json['session_id'] as String?,
      reply: json['reply'] as String?,
      remainingQuota: (json['remaining_quota'] as num?)?.toInt() ?? 0,
      quotaLimit: (json['quota_limit'] as num?)?.toInt() ?? 0,
      quotaExhausted: json['quota_exhausted'] as bool? ?? false,
    );
  }
}

