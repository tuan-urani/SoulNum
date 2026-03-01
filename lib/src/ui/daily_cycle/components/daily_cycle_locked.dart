import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:soulnum/src/extensions/int_extensions.dart';
import 'package:soulnum/src/locale/locale_key.dart';
import 'package:soulnum/src/ui/widgets/app_button.dart';
import 'package:soulnum/src/ui/widgets/app_state_placeholder.dart';

class DailyCycleLocked extends StatelessWidget {
  const DailyCycleLocked({
    super.key,
    required this.onUnlockByAd,
    required this.loading,
  });

  final VoidCallback onUnlockByAd;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return AppStatePlaceholder(
      title: LocaleKey.dailyCycleTitle.tr,
      description: LocaleKey.dailyCycleLockedDescription.tr,
      action: Column(
        children: <Widget>[
          AppButton(
            label: LocaleKey.dailyCycleUnlockByAd.tr,
            onPressed: onUnlockByAd,
            isLoading: loading,
          ),
          8.height,
        ],
      ),
    );
  }
}

