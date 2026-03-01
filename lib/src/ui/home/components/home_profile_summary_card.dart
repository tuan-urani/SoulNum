import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:soulnum/src/core/model/entitlement_model.dart';
import 'package:soulnum/src/core/model/user_profile_model.dart';
import 'package:soulnum/src/extensions/int_extensions.dart';
import 'package:soulnum/src/locale/locale_key.dart';
import 'package:soulnum/src/ui/widgets/app_card_section.dart';
import 'package:soulnum/src/utils/app_colors.dart';
import 'package:soulnum/src/utils/app_styles.dart';

class HomeProfileSummaryCard extends StatelessWidget {
  const HomeProfileSummaryCard({
    super.key,
    required this.profile,
    required this.entitlement,
    required this.onTap,
  });

  final UserProfileModel? profile;
  final EntitlementModel? entitlement;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AppCardSection(
        color: const Color(0xFF17172A),
        border: Border.all(color: AppColors.colorF586AA6.withValues(alpha: 0.3)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              LocaleKey.homeProfileSummary.tr,
              style: AppStyles.h5(color: AppColors.white),
            ),
            8.height,
            Text(
              profile?.fullName ?? LocaleKey.noActiveProfile.tr,
              style: AppStyles.bodyMedium(color: AppColors.colorFBFC9DE),
            ),
            6.height,
            Text(
              entitlement?.isVipPro == true ? LocaleKey.statusVip.tr : LocaleKey.statusFree.tr,
              style: AppStyles.bodySmall(color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
