import 'package:equatable/equatable.dart';

class ChatMessageModel extends Equatable {
  const ChatMessageModel({
    required this.role,
    required this.content,
    required this.createdAt,
  });

  final String role;
  final String content;
  final DateTime createdAt;

  bool get isUser => role == 'user';

  @override
  List<Object?> get props => <Object?>[role, content, createdAt];
}

