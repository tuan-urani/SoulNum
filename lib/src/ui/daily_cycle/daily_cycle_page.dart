import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:soulnum/src/locale/locale_key.dart';
import 'package:soulnum/src/ui/base/interactor/page_states.dart';
import 'package:soulnum/src/ui/daily_cycle/components/daily_cycle_locked.dart';
import 'package:soulnum/src/ui/daily_cycle/components/daily_cycle_unlocked.dart';
import 'package:soulnum/src/ui/daily_cycle/interactor/daily_cycle_cubit.dart';
import 'package:soulnum/src/ui/daily_cycle/interactor/daily_cycle_state.dart';
import 'package:soulnum/src/ui/widgets/app_button.dart';
import 'package:soulnum/src/ui/widgets/app_screen_scaffold.dart';
import 'package:soulnum/src/ui/widgets/app_state_placeholder.dart';
import 'package:soulnum/src/ui/widgets/base/app_body.dart';

class DailyCyclePage extends StatelessWidget {
  const DailyCyclePage({super.key});

  @override
  Widget build(BuildContext context) {
    final DailyCycleCubit cubit = Get.find<DailyCycleCubit>();
    if (cubit.state.pageState == PageState.initial) {
      cubit.load();
    }
    return BlocProvider<DailyCycleCubit>.value(
      value: cubit,
      child: BlocBuilder<DailyCycleCubit, DailyCycleState>(
        builder: (BuildContext context, DailyCycleState state) {
          return AppScreenScaffold(
            title: LocaleKey.dailyCycleTitle.tr,
            child: AppBody(
              pageState: state.pageState,
              loading: const Center(child: CircularProgressIndicator()),
              empty: AppStatePlaceholder(
                title: LocaleKey.commonEmpty.tr,
                description: LocaleKey.noActiveProfile.tr,
              ),
              failure: AppStatePlaceholder(
                title: LocaleKey.commonError.tr,
                description: state.errorMessage ?? LocaleKey.commonError.tr,
                action: AppButton(
                  label: LocaleKey.commonRetry.tr,
                  onPressed: cubit.load,
                ),
              ),
              success: state.isLocked
                  ? DailyCycleLocked(
                      loading: state.isSubmitting,
                      onUnlockByAd: cubit.unlockWithRewardedAd,
                    )
                  : DailyCycleUnlocked(reading: state.reading!),
            ),
          );
        },
      ),
    );
  }
}

