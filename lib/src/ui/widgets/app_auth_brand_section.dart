import 'package:flutter/material.dart';
import 'package:soulnum/src/extensions/int_extensions.dart';
import 'package:soulnum/src/utils/app_colors.dart';
import 'package:soulnum/src/utils/app_styles.dart';

class AppAuthBrandSection extends StatelessWidget {
  const AppAuthBrandSection({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: 14.borderRadiusAll,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                AppColors.authAccentGold,
                AppColors.authAccentViolet,
              ],
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            'SN',
            style: AppStyles.bodyLarge(
              color: AppColors.authButtonText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        12.width,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: AppStyles.h5(
                  color: AppColors.authText,
                  fontWeight: FontWeight.w700,
                ),
              ),
              3.height,
              Text(
                subtitle,
                style: AppStyles.bodySmall(color: AppColors.authTextMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
