import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:soulnum/src/locale/locale_key.dart';
import 'package:soulnum/src/ui/widgets/app_button.dart';
import 'package:soulnum/src/ui/widgets/app_screen_scaffold.dart';
import 'package:soulnum/src/ui/widgets/app_state_placeholder.dart';
import 'package:soulnum/src/utils/app_pages.dart';

class AiChatLimitPage extends StatelessWidget {
  const AiChatLimitPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScreenScaffold(
      title: LocaleKey.chatTitle.tr,
      child: AppStatePlaceholder(
        title: LocaleKey.chatQuotaExhausted.tr,
        description: LocaleKey.vipTitle.tr,
        action: AppButton(
          label: LocaleKey.vipUpgradeAction.tr,
          onPressed: () => Get.toNamed(AppPages.subscriptionVip),
        ),
      ),
    );
  }
}

