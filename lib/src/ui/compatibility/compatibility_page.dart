import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:soulnum/src/extensions/int_extensions.dart';
import 'package:soulnum/src/locale/locale_key.dart';
import 'package:soulnum/src/ui/base/interactor/page_states.dart';
import 'package:soulnum/src/ui/compatibility/components/profile_selector.dart';
import 'package:soulnum/src/ui/compatibility/interactor/compatibility_cubit.dart';
import 'package:soulnum/src/ui/compatibility/interactor/compatibility_state.dart';
import 'package:soulnum/src/ui/reading_detail/components/reading_result_card.dart';
import 'package:soulnum/src/ui/widgets/app_button.dart';
import 'package:soulnum/src/ui/widgets/app_screen_scaffold.dart';
import 'package:soulnum/src/ui/widgets/app_state_placeholder.dart';
import 'package:soulnum/src/ui/widgets/base/app_body.dart';

class CompatibilityPage extends StatelessWidget {
  const CompatibilityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final CompatibilityCubit cubit = Get.find<CompatibilityCubit>();
    if (cubit.state.pageState == PageState.initial) {
      cubit.loadProfiles();
    }
    return BlocProvider<CompatibilityCubit>.value(
      value: cubit,
      child: BlocBuilder<CompatibilityCubit, CompatibilityState>(
        builder: (BuildContext context, CompatibilityState state) {
          return AppScreenScaffold(
            title: LocaleKey.compatibilityTitle.tr,
            child: AppBody(
              pageState: state.pageState,
              loading: const Center(child: CircularProgressIndicator()),
              empty: AppStatePlaceholder(
                title: LocaleKey.commonEmpty.tr,
                description: LocaleKey.homeManageProfiles.tr,
                action: AppButton(
                  label: LocaleKey.homeManageProfiles.tr,
                  onPressed: () => Get.back<void>(),
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
              success: ListView(
                children: <Widget>[
                  ProfileSelector(
                    label: LocaleKey.compatibilitySelectFirst.tr,
                    value: state.firstProfileId,
                    profiles: state.profiles,
                    onChanged: cubit.selectFirst,
                  ),
                  12.height,
                  ProfileSelector(
                    label: LocaleKey.compatibilitySelectSecond.tr,
                    value: state.secondProfileId,
                    profiles: state.profiles,
                    onChanged: cubit.selectSecond,
                  ),
                  16.height,
                  AppButton(
                    label: LocaleKey.compatibilityRun.tr,
                    isLoading: state.isSubmitting,
                    onPressed: cubit.runCompatibility,
                  ),
                  16.height,
                  if (state.result != null) ReadingResultCard(reading: state.result!),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

