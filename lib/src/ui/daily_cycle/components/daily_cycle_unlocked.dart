import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:soulnum/src/core/model/reading_model.dart';
import 'package:soulnum/src/extensions/int_extensions.dart';
import 'package:soulnum/src/locale/locale_key.dart';
import 'package:soulnum/src/ui/reading_detail/components/reading_result_card.dart';
import 'package:soulnum/src/utils/app_colors.dart';
import 'package:soulnum/src/utils/app_styles.dart';

class DailyCycleUnlocked extends StatelessWidget {
  const DailyCycleUnlocked({
    super.key,
    required this.reading,
  });

  final ReadingModel reading;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Text(
          LocaleKey.dailyCycleUnlocked.tr,
          style: AppStyles.bodyLarge(color: AppColors.primary, fontWeight: FontWeight.w600),
        ),
        12.height,
        ReadingResultCard(reading: reading),
      ],
    );
  }
}

