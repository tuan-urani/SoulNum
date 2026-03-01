import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:soulnum/src/extensions/int_extensions.dart';
import 'package:soulnum/src/locale/locale_key.dart';
import 'package:soulnum/src/ui/widgets/app_auth_panel.dart';
import 'package:soulnum/src/ui/widgets/app_button.dart';
import 'package:soulnum/src/ui/widgets/app_input.dart';
import 'package:soulnum/src/utils/app_colors.dart';
import 'package:soulnum/src/utils/app_styles.dart';

class RegisterFormPanel extends StatelessWidget {
  const RegisterFormPanel({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.isLoading,
    required this.onSubmit,
    required this.onNavigateLogin,
    required this.onInputChanged,
    this.errorMessage,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool isLoading;
  final VoidCallback onSubmit;
  final VoidCallback onNavigateLogin;
  final VoidCallback onInputChanged;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return AppAuthPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            LocaleKey.registerTitle.tr,
            style: AppStyles.h3(
              color: AppColors.authText,
              fontWeight: FontWeight.w700,
            ),
          ),
          8.height,
          Text(
            LocaleKey.registerSubtitle.tr,
            style: AppStyles.bodyMedium(
              color: AppColors.authTextMuted,
              height: 1.5,
            ),
          ),
          24.height,
          AppInput(
            label: LocaleKey.registerEmailLabel.tr,
            hint: LocaleKey.registerEmailHint.tr,
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            onChanged: (_) => onInputChanged(),
            fillColor: AppColors.authInputBackground,
            borderColor: AppColors.authInputBorder,
            labelStyle: AppStyles.bodySmall(color: AppColors.authInputLabel),
            hintTextStyle: AppStyles.bodyMedium(color: AppColors.authTextMuted),
            textStyle: AppStyles.bodyMedium(color: AppColors.authText),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 17,
            ),
          ),
          14.height,
          AppInput(
            label: LocaleKey.registerPasswordLabel.tr,
            controller: passwordController,
            isPassword: true,
            onChanged: (_) => onInputChanged(),
            fillColor: AppColors.authInputBackground,
            borderColor: AppColors.authInputBorder,
            obscureIconColor: AppColors.authTextMuted,
            labelStyle: AppStyles.bodySmall(color: AppColors.authInputLabel),
            hintTextStyle: AppStyles.bodyMedium(color: AppColors.authTextMuted),
            textStyle: AppStyles.bodyMedium(color: AppColors.authText),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 17,
            ),
          ),
          14.height,
          AppInput(
            label: LocaleKey.registerConfirmPasswordLabel.tr,
            controller: confirmPasswordController,
            isPassword: true,
            onChanged: (_) => onInputChanged(),
            fillColor: AppColors.authInputBackground,
            borderColor: AppColors.authInputBorder,
            obscureIconColor: AppColors.authTextMuted,
            labelStyle: AppStyles.bodySmall(color: AppColors.authInputLabel),
            hintTextStyle: AppStyles.bodyMedium(color: AppColors.authTextMuted),
            textStyle: AppStyles.bodyMedium(color: AppColors.authText),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 17,
            ),
          ),
          12.height,
          if (errorMessage != null && errorMessage!.isNotEmpty) ...<Widget>[
            Container(
              width: double.infinity,
              padding: 12.paddingAll,
              decoration: BoxDecoration(
                color: AppColors.color1AEF4056,
                border: Border.all(color: AppColors.colorEF4056),
                borderRadius: 10.borderRadiusAll,
              ),
              child: Text(
                errorMessage!,
                style: AppStyles.bodySmall(color: AppColors.authText),
              ),
            ),
            12.height,
          ],
          AppButton(
            label: LocaleKey.registerPrimaryAction.tr,
            onPressed: onSubmit,
            isLoading: isLoading,
            backgroundColor: AppColors.authAccentGold,
            foregroundColor: AppColors.authButtonText,
            textStyle: AppStyles.buttonMedium(
              color: AppColors.authButtonText,
              fontWeight: FontWeight.w700,
            ),
            borderRadius: 14,
            disabledBackgroundColor: AppColors.authSubButtonBorder,
          ),
          12.height,
          Container(
            width: double.infinity,
            padding: 10.paddingAll,
            decoration: BoxDecoration(
              color: AppColors.authHelperBackground,
              border: Border.all(color: AppColors.authHelperBorder),
              borderRadius: 10.borderRadiusAll,
            ),
            child: Text(
              LocaleKey.registerPasswordHelper.tr,
              style: AppStyles.bodySmall(
                color: AppColors.authHelperText,
                height: 1.45,
              ),
            ),
          ),
          12.height,
          Center(
            child: Wrap(
              spacing: 4,
              children: <Widget>[
                Text(
                  LocaleKey.registerHaveAccount.tr,
                  style: AppStyles.bodySmall(color: AppColors.authTextMuted),
                ),
                GestureDetector(
                  onTap: isLoading ? null : onNavigateLogin,
                  child: Text(
                    LocaleKey.registerBackToLoginAction.tr,
                    style: AppStyles.bodySmall(
                      color: AppColors.authAccentGold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
