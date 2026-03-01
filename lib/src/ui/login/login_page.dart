import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:soulnum/src/extensions/int_extensions.dart';
import 'package:soulnum/src/core/model/user_profile_model.dart';
import 'package:soulnum/src/core/repository/profile_repository.dart';
import 'package:soulnum/src/locale/locale_key.dart';
import 'package:soulnum/src/ui/base/interactor/page_states.dart';
import 'package:soulnum/src/ui/login/components/login_brand_section.dart';
import 'package:soulnum/src/ui/login/components/login_form_panel.dart';
import 'package:soulnum/src/ui/login/interactor/login_cubit.dart';
import 'package:soulnum/src/ui/login/interactor/login_state.dart';
import 'package:soulnum/src/ui/widgets/app_auth_scaffold.dart';
import 'package:soulnum/src/utils/app_colors.dart';
import 'package:soulnum/src/utils/app_pages.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberLogin = true;

  @override
  void initState() {
    super.initState();
    Get.find<LoginCubit>().reset();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit(LoginCubit cubit) async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

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

    await cubit.signIn(email: email, password: password);
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

  Future<void> _routeAfterLogin() async {
    try {
      final ProfileRepository profileRepository = Get.find<ProfileRepository>();
      final List<UserProfileModel> profiles = await profileRepository
          .getProfiles();
      final UserProfileModel? activeProfile = profiles
          .cast<UserProfileModel?>()
          .firstWhere(
            (UserProfileModel? p) => p?.isActive ?? false,
            orElse: () => null,
          );

      if (activeProfile != null) {
        Get.offAllNamed(AppPages.main);
        return;
      }

      if (profiles.isEmpty) {
        Get.offAllNamed(
          AppPages.profileCreate,
          arguments: <String, dynamic>{'force_select_active': true},
        );
        return;
      }

      Get.offAllNamed(
        AppPages.profileManager,
        arguments: <String, dynamic>{'force_select_active': true},
      );
    } catch (_) {
      Get.offAllNamed(AppPages.main);
    }
  }

  @override
  Widget build(BuildContext context) {
    final LoginCubit cubit = Get.find<LoginCubit>();
    final String? initialMessage = () {
      final dynamic args = Get.arguments;
      if (args is Map && args['message'] is String) {
        return args['message'] as String;
      }
      if (args is String) {
        return args;
      }
      return null;
    }();

    return BlocProvider<LoginCubit>.value(
      value: cubit,
      child: BlocConsumer<LoginCubit, LoginState>(
        listener: (BuildContext context, LoginState state) {
          if (state.pageState == PageState.success) {
            _routeAfterLogin();
          }
        },
        builder: (BuildContext context, LoginState state) {
          return AppAuthScaffold(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const LoginBrandSection(),
                24.height,
                LoginFormPanel(
                  emailController: _emailController,
                  passwordController: _passwordController,
                  rememberLogin: _rememberLogin,
                  onRememberChanged: (bool value) {
                    if (_rememberLogin == value) {
                      return;
                    }
                    setState(() {
                      _rememberLogin = value;
                    });
                  },
                  isLoading: state.pageState == PageState.loading,
                  errorMessage: state.errorMessage ?? initialMessage,
                  onSubmit: () => _submit(cubit),
                  onNavigateRegister: () => Get.toNamed(AppPages.register),
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
