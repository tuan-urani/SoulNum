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
import 'package:soulnum/src/ui/widgets/app_card_section.dart';
import 'package:soulnum/src/ui/widgets/app_screen_scaffold.dart';
import 'package:soulnum/src/ui/widgets/app_state_placeholder.dart';
import 'package:soulnum/src/ui/widgets/base/app_body.dart';
import 'package:soulnum/src/utils/app_pages.dart';
import 'package:soulnum/src/utils/app_colors.dart';
import 'package:soulnum/src/utils/app_styles.dart';

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
          if (state.pageState == PageState.success &&
              (state.errorMessage ?? '').trim().isNotEmpty) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _ChatInfoCard(
                    title: LocaleKey.chatProfileContextTitle.tr,
                    value:
                        '${state.activeProfileName ?? LocaleKey.noActiveProfile.tr}\n'
                        '${LocaleKey.chatProfileBirthDateLabel.tr}: ${_formatDate(state.activeProfileBirthDate)}',
                  ),
                  8.height,
                  _ChatQuotaCard(
                    remainingQuota: state.remainingQuota,
                    quotaLimit: state.quotaLimit,
                    exhausted: state.quotaExhausted,
                  ),
                  8.height,
                  if (state.quotaExhausted) ...<Widget>[
                    _ChatInfoCard(
                      title: LocaleKey.chatHardLimitTitle.tr,
                      value: LocaleKey.chatQuotaExhausted.tr,
                      isWarning: true,
                    ),
                    8.height,
                  ],
                  Expanded(
                    child: AppCardSection(
                      color: AppColors.authBackgroundSurface,
                      borderRadius: 16.borderRadiusAll,
                      border: Border.all(
                        color: AppColors.colorFB1B8D1.withValues(alpha: 0.26),
                      ),
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                      child: state.messages.isEmpty
                          ? Center(
                              child: Text(
                                LocaleKey.chatEmptyConversation.tr,
                                style: AppStyles.bodyMedium(
                                  color: AppColors.authTextMuted,
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : ListView.separated(
                              itemCount: state.messages.length,
                              separatorBuilder:
                                  (BuildContext context, int index) => 8.height,
                              itemBuilder: (BuildContext context, int index) {
                                return ChatBubble(
                                  message: state.messages[index],
                                );
                              },
                            ),
                    ),
                  ),
                  if (state.quotaExhausted) ...<Widget>[
                    8.height,
                    _ChatInfoCard(
                      title: LocaleKey.chatReadOnlyHistoryTitle.tr,
                      value: LocaleKey.chatReadOnlyHistoryDescription.tr,
                    ),
                    8.height,
                    _ChatInfoCard(
                      title: LocaleKey.chatNextResetTitle.tr,
                      value: _nextResetText(),
                    ),
                  ],
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

class _ChatInfoCard extends StatelessWidget {
  const _ChatInfoCard({
    required this.title,
    required this.value,
    this.isWarning = false,
  });

  final String title;
  final String value;
  final bool isWarning;

  @override
  Widget build(BuildContext context) {
    final Color borderColor = isWarning
        ? AppColors.authAccentGold.withValues(alpha: 0.45)
        : AppColors.colorF586AA6.withValues(alpha: 0.3);
    return AppCardSection(
      color: AppColors.authBackgroundSurface,
      borderRadius: 14.borderRadiusAll,
      border: Border.all(color: borderColor),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: AppStyles.bodyMedium(
              color: AppColors.colorF2F4F7,
              fontWeight: FontWeight.w700,
            ),
          ),
          6.height,
          Text(
            value,
            style: AppStyles.bodyMedium(
              color: isWarning
                  ? AppColors.authAccentGold
                  : AppColors.colorFBFC9DE,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatQuotaCard extends StatelessWidget {
  const _ChatQuotaCard({
    required this.remainingQuota,
    required this.quotaLimit,
    required this.exhausted,
  });

  final int remainingQuota;
  final int quotaLimit;
  final bool exhausted;

  @override
  Widget build(BuildContext context) {
    final int safeLimit = quotaLimit <= 0 ? 1 : quotaLimit;
    final double progress = (remainingQuota / safeLimit).clamp(0, 1).toDouble();
    return AppCardSection(
      color: AppColors.authBackgroundSurface,
      borderRadius: 14.borderRadiusAll,
      border: Border.all(color: AppColors.colorF586AA6.withValues(alpha: 0.3)),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            LocaleKey.chatQuotaTitle.tr,
            style: AppStyles.bodyMedium(
              color: AppColors.colorF2F4F7,
              fontWeight: FontWeight.w700,
            ),
          ),
          6.height,
          Text(
            '${LocaleKey.quotaRemaining.tr}: $remainingQuota/$quotaLimit',
            style: AppStyles.bodyMedium(
              color: exhausted
                  ? AppColors.authAccentGold
                  : AppColors.colorFBFC9DE,
            ),
          ),
          8.height,
          ClipRRect(
            borderRadius: 999.borderRadiusAll,
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.colorF586AA6.withValues(alpha: 0.22),
              valueColor: AlwaysStoppedAnimation<Color>(
                exhausted ? AppColors.authAccentGold : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDate(DateTime? value) {
  if (value == null) return '--/--/----';
  String twoDigits(int number) => number.toString().padLeft(2, '0');
  return '${twoDigits(value.day)}/${twoDigits(value.month)}/${value.year}';
}

String _nextResetText() {
  final DateTime now = DateTime.now();
  final DateTime nextMonth = DateTime(now.year, now.month + 1, 1);
  String twoDigits(int number) => number.toString().padLeft(2, '0');
  return '${LocaleKey.chatNextResetDescription.tr}: '
      '${twoDigits(nextMonth.day)}/${twoDigits(nextMonth.month)}/${nextMonth.year}';
}
