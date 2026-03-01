import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:soulnum/src/extensions/int_extensions.dart';
import 'package:soulnum/src/locale/locale_key.dart';
import 'package:soulnum/src/ui/subscription/interactor/subscription_cubit.dart';
import 'package:soulnum/src/ui/subscription/interactor/subscription_state.dart';
import 'package:soulnum/src/ui/widgets/app_button.dart';
import 'package:soulnum/src/ui/widgets/app_screen_scaffold.dart';
import 'package:soulnum/src/ui/widgets/app_state_placeholder.dart';
import 'package:soulnum/src/ui/widgets/base/app_body.dart';
import 'package:soulnum/src/utils/app_colors.dart';
import 'package:soulnum/src/utils/app_styles.dart';

class SubscriptionPage extends StatelessWidget {
  const SubscriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final SubscriptionCubit cubit = Get.find<SubscriptionCubit>();
    return BlocProvider<SubscriptionCubit>.value(
      value: cubit,
      child: BlocBuilder<SubscriptionCubit, SubscriptionState>(
        builder: (BuildContext context, SubscriptionState state) {
          return AppScreenScaffold(
            title: LocaleKey.vipTitle.tr,
            child: AppBody(
              pageState: state.pageState,
              failure: AppStatePlaceholder(
                title: LocaleKey.commonError.tr,
                description: state.errorMessage ?? LocaleKey.commonError.tr,
                action: AppButton(
                  label: LocaleKey.commonRetry.tr,
                  onPressed: () => cubit.activatePlan(
                    provider: 'google',
                    planCode: 'vip_pro_monthly',
                  ),
                ),
              ),
              success: ListView(
                children: <Widget>[
                  Text(
                    LocaleKey.vipTitle.tr,
                    style: AppStyles.h5(color: AppColors.white),
                  ),
                  12.height,
                  AppButton(
                    label: LocaleKey.vipMonthly.tr,
                    isLoading: state.isSubmitting,
                    onPressed: () => cubit.activatePlan(
                      provider: 'google',
                      planCode: 'vip_pro_monthly',
                    ),
                  ),
                  12.height,
                  AppButton(
                    label: LocaleKey.vipYearly.tr,
                    isDisabled: state.isSubmitting,
                    onPressed: () => cubit.activatePlan(
                      provider: 'google',
                      planCode: 'vip_pro_yearly',
                    ),
                  ),
                  if (state.syncResult != null) ...<Widget>[
                    16.height,
                    Text(
                      '${LocaleKey.statusVip.tr}: ${state.syncResult!.isVipPro}',
                      style: AppStyles.bodyMedium(color: AppColors.primary),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
