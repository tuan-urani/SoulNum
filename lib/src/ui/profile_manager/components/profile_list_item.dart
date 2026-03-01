import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:soulnum/src/core/model/user_profile_model.dart';
import 'package:soulnum/src/extensions/int_extensions.dart';
import 'package:soulnum/src/locale/locale_key.dart';
import 'package:soulnum/src/ui/widgets/app_card_section.dart';
import 'package:soulnum/src/utils/app_colors.dart';
import 'package:soulnum/src/utils/app_styles.dart';

class ProfileListItem extends StatelessWidget {
  const ProfileListItem({
    super.key,
    required this.profile,
    required this.onTap,
  });

  final UserProfileModel profile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AppCardSection(
        color: const Color(0xFF17172A),
        border: Border.all(color: AppColors.colorF586AA6.withValues(alpha: 0.25)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              profile.fullName,
              style: AppStyles.h5(color: AppColors.white),
            ),
            6.height,
            Text(
              '${LocaleKey.profileBirthDateLabel.tr}: ${profile.birthDate.toIso8601String().split('T').first}',
              style: AppStyles.bodySmall(color: AppColors.colorFBFC9DE),
            ),
            if (profile.isActive) ...<Widget>[
              8.height,
              Text(
                LocaleKey.activeProfile.tr,
                style: AppStyles.caption(color: AppColors.primary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
