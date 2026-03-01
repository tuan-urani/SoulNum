import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:soulnum/src/extensions/int_extensions.dart';
import 'package:soulnum/src/locale/locale_key.dart';
import 'package:soulnum/src/ui/ai_chat/components/chat_bubble.dart';
import 'package:soulnum/src/ui/ai_chat/components/chat_input_bar.dart';
import 'package:soulnum/src/ui/ai_chat/interactor/ai_chat_cubit.dart';
import 'package:soulnum/src/ui/ai_chat/interactor/ai_chat_state.dart';
import 'package:soulnum/src/ui/base/interactor/page_states.dart';
import 'package:soulnum/src/ui/widgets/app_button.dart';
import 'package:soulnum/src/ui/widgets/app_screen_scaffold.dart';
import 'package:soulnum/src/ui/widgets/app_state_placeholder.dart';
import 'package:soulnum/src/ui/widgets/base/app_body.dart';
import 'package:soulnum/src/utils/app_pages.dart';

class AiChatPage extends StatefulWidget {
  const AiChatPage({super.key});

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AiChatCubit cubit = Get.find<AiChatCubit>();
    if (cubit.state.pageState == PageState.initial) {
      cubit.bootstrap();
    }
    return BlocProvider<AiChatCubit>.value(
      value: cubit,
      child: BlocConsumer<AiChatCubit, AiChatState>(
        listener: (BuildContext context, AiChatState state) {
          if (state.quotaExhausted) {
            Get.offNamed(AppPages.aiChatLimit);
          }
        },
        builder: (BuildContext context, AiChatState state) {
          return AppScreenScaffold(
            title: LocaleKey.chatTitle.tr,
            child: AppBody(
              pageState: state.pageState,
              loading: const Center(child: CircularProgressIndicator()),
              unauthorized: AppStatePlaceholder(
                title: LocaleKey.unauthorizedTitle.tr,
                description: LocaleKey.unauthorizedDescription.tr,
                action: AppButton(
                  label: LocaleKey.vipUpgradeAction.tr,
                  onPressed: () => Get.toNamed(AppPages.subscriptionVip),
                ),
              ),
              empty: AppStatePlaceholder(
                title: LocaleKey.commonEmpty.tr,
                description: LocaleKey.noActiveProfile.tr,
              ),
              failure: AppStatePlaceholder(
                title: LocaleKey.commonError.tr,
                description: state.errorMessage ?? LocaleKey.commonError.tr,
                action: AppButton(
                  label: LocaleKey.commonRetry.tr,
                  onPressed: cubit.bootstrap,
                ),
              ),
              success: Column(
                children: <Widget>[
                  Text('${LocaleKey.quotaRemaining.tr}: ${state.remainingQuota}/${state.quotaLimit}'),
                  12.height,
                  Expanded(
                    child: ListView.separated(
                      itemCount: state.messages.length,
                      separatorBuilder: (BuildContext context, int index) => 8.height,
                      itemBuilder: (BuildContext context, int index) {
                        return ChatBubble(message: state.messages[index]);
                      },
                    ),
                  ),
                  8.height,
                  ChatInputBar(
                    controller: _messageController,
                    loading: state.isSubmitting,
                    disabled: state.quotaExhausted,
                    onSend: () async {
                      final text = _messageController.text;
                      _messageController.clear();
                      await cubit.sendMessage(text);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
