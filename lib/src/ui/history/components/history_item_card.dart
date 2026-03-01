import 'package:flutter/material.dart';
import 'package:soulnum/src/core/model/history_item_model.dart';
import 'package:soulnum/src/extensions/int_extensions.dart';
import 'package:soulnum/src/ui/widgets/app_card_section.dart';
import 'package:soulnum/src/utils/app_colors.dart';
import 'package:soulnum/src/utils/app_styles.dart';

class HistoryItemCard extends StatelessWidget {
  const HistoryItemCard({
    super.key,
    required this.item,
  });

  final HistoryItemModel item;

  @override
  Widget build(BuildContext context) {
    return AppCardSection(
      color: const Color(0xFF17172A),
      border: Border.all(color: AppColors.colorF586AA6.withValues(alpha: 0.2)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(item.featureKey, style: AppStyles.bodyLarge(color: AppColors.white, fontWeight: FontWeight.w600)),
          6.height,
          Text(
            item.createdAt.toIso8601String(),
            style: AppStyles.bodySmall(color: AppColors.colorFBFC9DE),
          ),
        ],
      ),
    );
  }
}
