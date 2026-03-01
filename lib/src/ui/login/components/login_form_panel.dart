import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:soulnum/src/extensions/int_extensions.dart';
import 'package:soulnum/src/locale/locale_key.dart';
import 'package:soulnum/src/ui/widgets/app_auth_panel.dart';
import 'package:soulnum/src/ui/widgets/app_button.dart';
import 'package:soulnum/src/ui/widgets/app_input.dart';
import 'package:soulnum/src/utils/app_colors.dart';
import 'package:soulnum/src/utils/app_styles.dart';

class LoginFormPanel extends StatelessWidget {
  const LoginFormPanel({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.isLoading,
    required this.rememberLogin,
    required this.onRememberChanged,
    required this.onSubmit,
    required this.onNavigateRegister,
    required this.onInputChanged,
    this.errorMessage,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isLoading;
  final bool rememberLogin;
  final ValueChanged<bool> onRememberChanged;
  final VoidCallback onSubmit;
  final VoidCallback onNavigateRegister;
  final VoidCallback onInputChanged;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return AppAuthPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            LocaleKey.loginTitle.tr,
            style: AppStyles.h3(
              color: AppColors.authText,
              fontWeight: FontWeight.w700,
            ),
          ),
          8.height,
          Text(
            LocaleKey.loginSubtitle.tr,
            style: AppStyles.bodyMedium(
              color: AppColors.authTextMuted,
              height: 1.5,
            ),
          ),
          24.height,
          AppInput(
            label: LocaleKey.loginEmailLabel.tr,
            hint: LocaleKey.loginEmailHint.tr,
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
            label: LocaleKey.loginPasswordLabel.tr,
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
          10.height,
          Row(
            children: <Widget>[
              SizedBox(
                width: 20,
                height: 20,
                child: Checkbox(
                  value: rememberLogin,
                  onChanged: (bool? value) => onRememberChanged(value ?? false),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  activeColor: AppColors.authAccentViolet,
                  checkColor: AppColors.authText,
                  side: const BorderSide(color: AppColors.authBorder),
                ),
              ),
              8.width,
              Expanded(
                child: Text(
                  LocaleKey.loginRememberMe.tr,
                  style: AppStyles.bodySmall(color: AppColors.authTextMuted),
                ),
              ),
              Text(
                LocaleKey.loginForgotPassword.tr,
                style: AppStyles.bodySmall(
                  color: AppColors.authAccentGold,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
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
            label: LocaleKey.loginPrimaryAction.tr,
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
          SizedBox(
            width: double.infinity,
            height: 46,
            child: OutlinedButton(
              onPressed: isLoading ? null : onNavigateRegister,
              style: OutlinedButton.styleFrom(
                backgroundColor: AppColors.authSubButtonBackground,
                foregroundColor: AppColors.authText,
                disabledForegroundColor: AppColors.authTextMuted,
                disabledBackgroundColor: AppColors.authSubButtonBackground,
                side: const BorderSide(color: AppColors.authSubButtonBorder),
                shape: RoundedRectangleBorder(borderRadius: 14.borderRadiusAll),
              ),
              child: Text(
                LocaleKey.loginCreateAccountAction.tr,
                style: AppStyles.bodyMedium(
                  color: AppColors.authText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          18.height,
          Center(
            child: Text(
              LocaleKey.loginTermsDescription.tr,
              textAlign: TextAlign.center,
              style: AppStyles.bodySmall(
                color: AppColors.authTextMuted,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
