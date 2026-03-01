import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soulnum/src/core/mapper/soul_mapper.dart';
import 'package:soulnum/src/core/model/chat_message_model.dart';
import 'package:soulnum/src/core/model/request/chat_with_guide_request.dart';
import 'package:soulnum/src/core/model/user_profile_model.dart';
import 'package:soulnum/src/core/repository/chat_repository.dart';
import 'package:soulnum/src/core/repository/profile_repository.dart';
import 'package:soulnum/src/ui/ai_chat/interactor/ai_chat_state.dart';
import 'package:soulnum/src/ui/base/interactor/page_states.dart';

class AiChatCubit extends Cubit<AiChatState> {
  AiChatCubit(this._chatRepository, this._profileRepository)
    : super(const AiChatState(pageState: PageState.initial));

  final ChatRepository _chatRepository;
  final ProfileRepository _profileRepository;

  Future<void> bootstrap() async {
    emit(state.copyWith(pageState: PageState.loading, errorMessage: null));
    try {
      final profiles = await _profileRepository.getProfiles();
      final entitlement = await _profileRepository.getEntitlement();
      final UserProfileModel? active = profiles
          .cast<UserProfileModel?>()
          .firstWhere(
            (UserProfileModel? p) => p?.isActive ?? false,
            orElse: () => profiles.isNotEmpty ? profiles.first : null,
          );
      if (active == null) {
        emit(state.copyWith(pageState: PageState.empty));
        return;
      }
      if (entitlement?.isVipPro != true) {
        emit(state.copyWith(pageState: PageState.unauthorized));
        return;
      }
      emit(
        state.copyWith(
          pageState: PageState.success,
          activeProfileId: active.id,
          activeProfileName: active.fullName,
          activeProfileBirthDate: active.birthDate,
          quotaLimit: entitlement?.chatbotMonthlyLimit ?? 0,
          remainingQuota: entitlement?.chatbotMonthlyLimit ?? 0,
          quotaExhausted: (entitlement?.chatbotMonthlyLimit ?? 0) <= 0,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          pageState: PageState.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> sendMessage(String text) async {
    final String message = text.trim();
    if (message.isEmpty || state.activeProfileId == null) {
      return;
    }
    if (state.quotaExhausted) return;
    final List<ChatMessageModel> appended = <ChatMessageModel>[
      ...state.messages,
      SoulMapper.toUserMessage(message),
    ];
    emit(
      state.copyWith(
        isSubmitting: true,
        messages: appended,
        errorMessage: null,
      ),
    );
    try {
      final response = await _chatRepository.chatWithGuide(
        ChatWithGuideRequest(
          profileId: state.activeProfileId!,
          message: message,
          sessionId: state.sessionId,
        ),
      );
      final List<ChatMessageModel> nextMessages = <ChatMessageModel>[
        ...appended,
        if ((response.reply ?? '').isNotEmpty)
          SoulMapper.toAssistantMessage(response.reply!),
      ];
      emit(
        state.copyWith(
          isSubmitting: false,
          messages: nextMessages,
          sessionId: response.sessionId,
          remainingQuota: response.remainingQuota,
          quotaLimit: response.quotaLimit,
          quotaExhausted: response.quotaExhausted,
          pageState: PageState.success,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isSubmitting: false,
          pageState: PageState.success,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
