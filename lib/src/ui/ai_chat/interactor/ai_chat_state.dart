import 'package:equatable/equatable.dart';
import 'package:soulnum/src/core/model/chat_message_model.dart';
import 'package:soulnum/src/ui/base/interactor/page_states.dart';

class AiChatState extends Equatable {
  const AiChatState({
    required this.pageState,
    this.messages = const <ChatMessageModel>[],
    this.sessionId,
    this.activeProfileId,
    this.activeProfileName,
    this.activeProfileBirthDate,
    this.remainingQuota = 0,
    this.quotaLimit = 0,
    this.quotaExhausted = false,
    this.isSubmitting = false,
    this.errorMessage,
  });

  final PageState pageState;
  final List<ChatMessageModel> messages;
  final String? sessionId;
  final String? activeProfileId;
  final String? activeProfileName;
  final DateTime? activeProfileBirthDate;
  final int remainingQuota;
  final int quotaLimit;
  final bool quotaExhausted;
  final bool isSubmitting;
  final String? errorMessage;

  AiChatState copyWith({
    PageState? pageState,
    List<ChatMessageModel>? messages,
    String? sessionId,
    String? activeProfileId,
    String? activeProfileName,
    DateTime? activeProfileBirthDate,
    int? remainingQuota,
    int? quotaLimit,
    bool? quotaExhausted,
    bool? isSubmitting,
    String? errorMessage,
  }) {
    return AiChatState(
      pageState: pageState ?? this.pageState,
      messages: messages ?? this.messages,
      sessionId: sessionId ?? this.sessionId,
      activeProfileId: activeProfileId ?? this.activeProfileId,
      activeProfileName: activeProfileName ?? this.activeProfileName,
      activeProfileBirthDate:
          activeProfileBirthDate ?? this.activeProfileBirthDate,
      remainingQuota: remainingQuota ?? this.remainingQuota,
      quotaLimit: quotaLimit ?? this.quotaLimit,
      quotaExhausted: quotaExhausted ?? this.quotaExhausted,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    pageState,
    messages,
    sessionId,
    activeProfileId,
    activeProfileName,
    activeProfileBirthDate,
    remainingQuota,
    quotaLimit,
    quotaExhausted,
    isSubmitting,
    errorMessage,
  ];
}
