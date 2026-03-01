class ChatWithGuideRequest {
  const ChatWithGuideRequest({
    required this.profileId,
    required this.message,
    this.sessionId,
  });

  final String profileId;
  final String message;
  final String? sessionId;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'profile_id': profileId,
        'session_id': sessionId,
        'message': message,
      };
}

