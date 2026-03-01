import 'package:flutter/material.dart';
import 'package:soulnum/src/extensions/int_extensions.dart';
import 'package:soulnum/src/utils/app_colors.dart';
import 'package:soulnum/src/utils/app_styles.dart';

class AppStatePlaceholder extends StatelessWidget {
  const AppStatePlaceholder({
    super.key,
    required this.title,
    required this.description,
    this.action,
  });

  final String title;
  final String description;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            title,
            style: AppStyles.h5(color: AppColors.white),
            textAlign: TextAlign.center,
          ),
          8.height,
          Text(
            description,
            style: AppStyles.bodyMedium(color: AppColors.colorFBFC9DE),
            textAlign: TextAlign.center,
          ),
          if (action != null) ...<Widget>[
            16.height,
            action!,
          ],
        ],
      ),
    );
  }
}

