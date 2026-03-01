import 'package:flutter/material.dart';
import 'package:soulnum/src/core/model/chat_message_model.dart';
import 'package:soulnum/src/extensions/int_extensions.dart';
import 'package:soulnum/src/ui/widgets/app_card_section.dart';
import 'package:soulnum/src/utils/app_colors.dart';
import 'package:soulnum/src/utils/app_styles.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
  });

  final ChatMessageModel message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 280),
        child: AppCardSection(
          color: message.isUser ? AppColors.primary : const Color(0xFF17172A),
          border: Border.all(color: AppColors.colorF586AA6.withValues(alpha: 0.2)),
          padding: 12.paddingAll,
          child: Text(
            message.content,
            style: AppStyles.bodyMedium(
              color: message.isUser ? AppColors.white : AppColors.colorFBFC9DE,
            ),
          ),
        ),
      ),
    );
  }
}
