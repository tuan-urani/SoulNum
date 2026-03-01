import 'package:flutter/material.dart';
import 'package:soulnum/src/utils/app_colors.dart';
import 'package:soulnum/src/utils/app_styles.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.height = 48,
    this.backgroundColor,
    this.disabledBackgroundColor,
    this.foregroundColor,
    this.textStyle,
    this.borderRadius = 12,
    this.borderSide,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final double height;
  final Color? backgroundColor;
  final Color? disabledBackgroundColor;
  final Color? foregroundColor;
  final TextStyle? textStyle;
  final double borderRadius;
  final BorderSide? borderSide;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null && !isLoading && !isDisabled;
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primary,
          disabledBackgroundColor:
              disabledBackgroundColor ?? AppColors.colorB8BCC6,
          foregroundColor: foregroundColor ?? AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: borderSide ?? BorderSide.none,
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(label, style: textStyle ?? AppStyles.buttonMedium()),
      ),
    );
  }
}
