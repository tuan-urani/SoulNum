import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:soulnum/src/extensions/int_extensions.dart';
import 'package:soulnum/src/locale/locale_key.dart';
import 'package:soulnum/src/ui/base/interactor/page_states.dart';
import 'package:soulnum/src/ui/register/components/register_brand_section.dart';
import 'package:soulnum/src/ui/register/components/register_form_panel.dart';
import 'package:soulnum/src/ui/register/interactor/register_cubit.dart';
import 'package:soulnum/src/ui/register/interactor/register_state.dart';
import 'package:soulnum/src/ui/widgets/app_auth_scaffold.dart';
import 'package:soulnum/src/utils/app_colors.dart';
import 'package:soulnum/src/utils/app_pages.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    Get.find<RegisterCubit>().reset();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit(RegisterCubit cubit) async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    final String confirmPassword = _confirmPasswordController.text.trim();

    if (email.isEmpty) {
      _showValidationError(LocaleKey.authValidationEmailRequired.tr);
      return;
    }
    if (!_looksLikeEmail(email)) {
      _showValidationError(LocaleKey.authValidationEmailInvalid.tr);
      return;
    }
    if (password.isEmpty) {
      _showValidationError(LocaleKey.authValidationPasswordRequired.tr);
      return;
    }
    if (password.length < 8) {
      _showValidationError(LocaleKey.authValidationPasswordMinLength.tr);
      return;
    }
    if (confirmPassword.isEmpty) {
      _showValidationError(LocaleKey.authValidationConfirmPasswordRequired.tr);
      return;
    }
    if (password != confirmPassword) {
      _showValidationError(LocaleKey.authValidationPasswordMismatch.tr);
      return;
    }

    await cubit.signUp(email: email, password: password);
  }

  void _showValidationError(String message) {
    Get.snackbar(
      LocaleKey.error.tr,
      message,
      backgroundColor: AppColors.error,
      colorText: AppColors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: 16.paddingAll,
    );
  }

  bool _looksLikeEmail(String value) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
  }

  @override
  Widget build(BuildContext context) {
    final RegisterCubit cubit = Get.find<RegisterCubit>();
    return BlocProvider<RegisterCubit>.value(
      value: cubit,
      child: BlocConsumer<RegisterCubit, RegisterState>(
        listener: (BuildContext context, RegisterState state) {
          if (state.pageState == PageState.success) {
            Get.offAllNamed(AppPages.main);
          }
        },
        builder: (BuildContext context, RegisterState state) {
          return AppAuthScaffold(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const RegisterBrandSection(),
                24.height,
                RegisterFormPanel(
                  emailController: _emailController,
                  passwordController: _passwordController,
                  confirmPasswordController: _confirmPasswordController,
                  isLoading: state.pageState == PageState.loading,
                  errorMessage: state.errorMessage,
                  onSubmit: () => _submit(cubit),
                  onNavigateLogin: () => Get.offNamed(AppPages.login),
                  onInputChanged: cubit.clearError,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
