import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:soulnum/src/extensions/int_extensions.dart';
import 'package:soulnum/src/locale/locale_key.dart';
import 'package:soulnum/src/ui/base/interactor/page_states.dart';
import 'package:soulnum/src/ui/profile_manager/components/profile_list_item.dart';
import 'package:soulnum/src/ui/profile_manager/interactor/profile_manager_cubit.dart';
import 'package:soulnum/src/ui/profile_manager/interactor/profile_manager_state.dart';
import 'package:soulnum/src/ui/widgets/app_button.dart';
import 'package:soulnum/src/ui/widgets/app_screen_scaffold.dart';
import 'package:soulnum/src/ui/widgets/app_state_placeholder.dart';
import 'package:soulnum/src/ui/widgets/base/app_body.dart';
import 'package:soulnum/src/utils/app_pages.dart';

class ProfileManagerPage extends StatelessWidget {
  const ProfileManagerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args =
        (Get.arguments as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
    final bool forceSelectActive = args['force_select_active'] == true;

    final ProfileManagerCubit cubit = Get.find<ProfileManagerCubit>();
    if (cubit.state.pageState == PageState.initial) {
      cubit.loadProfiles();
    }
    return BlocProvider<ProfileManagerCubit>.value(
      value: cubit,
      child: BlocBuilder<ProfileManagerCubit, ProfileManagerState>(
        builder: (BuildContext context, ProfileManagerState state) {
          if (forceSelectActive && state.activeProfile != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (Get.currentRoute == AppPages.profileManager) {
                Get.offAllNamed(AppPages.main);
              }
            });
          }

          return AppScreenScaffold(
            title: LocaleKey.profileManagerTitle.tr,
            child: AppBody(
              pageState: state.pageState,
              loading: const Center(child: CircularProgressIndicator()),
              empty: AppStatePlaceholder(
                title: LocaleKey.commonEmpty.tr,
                description: LocaleKey.noActiveProfile.tr,
                action: AppButton(
                  label: LocaleKey.profileCreateAction.tr,
                  onPressed: () async {
                    await Get.toNamed(
                      AppPages.profileCreate,
                      arguments: <String, dynamic>{
                        'force_select_active': forceSelectActive,
                      },
                    );
                    await cubit.loadProfiles();
                  },
                ),
              ),
              failure: AppStatePlaceholder(
                title: LocaleKey.commonError.tr,
                description: state.errorMessage ?? LocaleKey.commonError.tr,
                action: AppButton(
                  label: LocaleKey.commonRetry.tr,
                  onPressed: cubit.loadProfiles,
                ),
              ),
              success: ListView.separated(
                itemCount: state.profiles.length + 1,
                separatorBuilder: (BuildContext context, int index) =>
                    12.height,
                itemBuilder: (BuildContext context, int index) {
                  if (index == state.profiles.length) {
                    return AppButton(
                      label: LocaleKey.profileCreateAction.tr,
                      onPressed: () async {
                        await Get.toNamed(
                          AppPages.profileCreate,
                          arguments: <String, dynamic>{
                            'force_select_active': forceSelectActive,
                          },
                        );
                        await cubit.loadProfiles();
                      },
                    );
                  }
                  final profile = state.profiles[index];
                  return ProfileListItem(
                    profile: profile,
                    onTap: () =>
                        Get.toNamed(AppPages.profileDetail, arguments: profile),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
