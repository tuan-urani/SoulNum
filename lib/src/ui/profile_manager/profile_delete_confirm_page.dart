import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:soulnum/src/core/model/user_profile_model.dart';
import 'package:soulnum/src/extensions/int_extensions.dart';
import 'package:soulnum/src/locale/locale_key.dart';
import 'package:soulnum/src/ui/profile_manager/interactor/profile_manager_cubit.dart';
import 'package:soulnum/src/ui/profile_manager/interactor/profile_manager_state.dart';
import 'package:soulnum/src/ui/widgets/app_button.dart';
import 'package:soulnum/src/ui/widgets/app_screen_scaffold.dart';
import 'package:soulnum/src/utils/app_colors.dart';
import 'package:soulnum/src/utils/app_styles.dart';

class ProfileDeleteConfirmPage extends StatelessWidget {
  const ProfileDeleteConfirmPage({super.key});

  @override
  Widget build(BuildContext context) {
    final UserProfileModel? profile = Get.arguments as UserProfileModel?;
    final ProfileManagerCubit cubit = Get.find<ProfileManagerCubit>();
    if (profile == null) {
      return AppScreenScaffold(
        title: LocaleKey.profileDeleteTitle.tr,
        child: Center(
          child: Text(
            LocaleKey.commonNoData.tr,
            style: AppStyles.bodyMedium(color: AppColors.white),
          ),
        ),
      );
    }
    return BlocProvider<ProfileManagerCubit>.value(
      value: cubit,
      child: BlocBuilder<ProfileManagerCubit, ProfileManagerState>(
        builder: (BuildContext context, ProfileManagerState state) {
          return AppScreenScaffold(
            title: LocaleKey.profileDeleteTitle.tr,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  LocaleKey.profileDeleteDescription.tr,
                  style: AppStyles.bodyMedium(color: AppColors.colorFBFC9DE),
                ),
                12.height,
                Text(
                  profile.fullName,
                  style: AppStyles.h5(color: AppColors.white),
                ),
                24.height,
                AppButton(
                  label: LocaleKey.profileDeleteConfirm.tr,
                  isLoading: state.isSubmitting,
                  onPressed: () async {
                    try {
                      await cubit.deleteProfile(profile.id);
                    } catch (_) {
                      if (!context.mounted) return;
                      Get.snackbar(
                        LocaleKey.error.tr,
                        cubit.state.errorMessage ?? LocaleKey.commonError.tr,
                        backgroundColor: AppColors.error,
                        colorText: AppColors.white,
                      );
                      return;
                    }
                    if (context.mounted) {
                      Get.until((Route<dynamic> route) => route.isFirst);
                    }
                  },
                ),
                12.height,
                AppButton(
                  label: LocaleKey.commonCancel.tr,
                  onPressed: () => Get.back<void>(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
