import 'package:get/get.dart';
import 'package:soulnum/src/core/repository/chat_repository.dart';
import 'package:soulnum/src/core/repository/profile_repository.dart';
import 'package:soulnum/src/ui/ai_chat/interactor/ai_chat_cubit.dart';

class AiChatBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AiChatCubit>()) {
      Get.lazyPut<AiChatCubit>(
        () => AiChatCubit(
          Get.find<ChatRepository>(),
          Get.find<ProfileRepository>(),
        ),
      );
    }
  }
}

