import 'package:flutter/material.dart';
import 'package:soulnum/src/extensions/int_extensions.dart';
import 'package:soulnum/src/utils/app_colors.dart';

class AppAuthPanel extends StatelessWidget {
  const AppAuthPanel({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.authPanel,
        borderRadius: 22.borderRadiusAll,
        border: Border.all(color: AppColors.authBorder),
      ),
      padding: 20.paddingAll,
      child: child,
    );
  }
}
