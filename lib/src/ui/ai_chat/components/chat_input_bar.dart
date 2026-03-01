import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:soulnum/src/extensions/int_extensions.dart';
import 'package:soulnum/src/locale/locale_key.dart';
import 'package:soulnum/src/ui/widgets/app_button.dart';
import 'package:soulnum/src/ui/widgets/app_input.dart';
import 'package:soulnum/src/utils/app_colors.dart';
import 'package:soulnum/src/utils/app_styles.dart';

class ChatInputBar extends StatelessWidget {
  const ChatInputBar({
    super.key,
    required this.controller,
    required this.onSend,
    required this.loading,
    required this.disabled,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final bool loading;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: AppInput(
            controller: controller,
            hint: LocaleKey.chatInputHint.tr,
            maxLines: 4,
            minLines: 1,
            isDisabledTyping: disabled,
            fillColor: AppColors.authInputBackground,
            borderColor: AppColors.authInputBorder,
            hintTextStyle: AppStyles.bodyMedium(color: AppColors.authTextMuted),
            textStyle: AppStyles.bodyMedium(color: AppColors.authText),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
          ),
        ),
        8.width,
        SizedBox(
          width: 116,
          child: AppButton(
            label: LocaleKey.chatSend.tr,
            onPressed: onSend,
            isLoading: loading,
            isDisabled: disabled,
            height: 56,
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.authButtonText,
          ),
        ),
      ],
    );
  }
}
