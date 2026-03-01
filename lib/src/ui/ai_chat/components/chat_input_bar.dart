import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:soulnum/src/locale/locale_key.dart';
import 'package:soulnum/src/ui/widgets/app_button.dart';
import 'package:soulnum/src/ui/widgets/app_input.dart';

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
    return Column(
      children: <Widget>[
        AppInput(
          controller: controller,
          hint: LocaleKey.chatInputHint.tr,
          maxLines: 4,
          minLines: 1,
          isDisabledTyping: disabled,
        ),
        AppButton(
          label: LocaleKey.chatSend.tr,
          onPressed: onSend,
          isLoading: loading,
          isDisabled: disabled,
        ),
      ],
    );
  }
}

