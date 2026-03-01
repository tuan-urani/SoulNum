import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:soulnum/src/core/model/chat_message_model.dart';
import 'package:soulnum/src/extensions/int_extensions.dart';
import 'package:soulnum/src/locale/locale_key.dart';
import 'package:soulnum/src/ui/widgets/app_card_section.dart';
import 'package:soulnum/src/utils/app_colors.dart';
import 'package:soulnum/src/utils/app_styles.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.message});

  final ChatMessageModel message;

  @override
  Widget build(BuildContext context) {
    final Color bubbleColor = message.isUser
        ? AppColors.primary.withValues(alpha: 0.16)
        : AppColors.authBackgroundSurface;
    final Color textColor = message.isUser
        ? AppColors.authText
        : AppColors.colorFBFC9DE;

    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 310),
        child: AppCardSection(
          color: bubbleColor,
          borderRadius: 14.borderRadiusAll,
          border: Border.all(
            color: message.isUser
                ? AppColors.primary.withValues(alpha: 0.45)
                : AppColors.colorF586AA6.withValues(alpha: 0.28),
          ),
          padding: 12.paddingAll,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                message.isUser
                    ? LocaleKey.chatUserLabel.tr
                    : LocaleKey.chatAssistantLabel.tr,
                style: AppStyles.caption(
                  color: message.isUser
                      ? AppColors.authButtonText
                      : AppColors.authAccentGold,
                  fontWeight: FontWeight.w600,
                ),
              ),
              6.height,
              Text(
                message.content,
                style: AppStyles.bodyMedium(color: textColor, height: 1.4),
              ),
              6.height,
              Text(
                _formatTime(message.createdAt),
                style: AppStyles.caption(
                  color: AppColors.colorFBFC9DE.withValues(alpha: 0.75),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime value) {
    String twoDigits(int number) => number.toString().padLeft(2, '0');
    return '${twoDigits(value.hour)}:${twoDigits(value.minute)}';
  }
}
