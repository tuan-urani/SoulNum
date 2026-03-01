import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:soulnum/src/core/constants/feature_keys.dart';
import 'package:soulnum/src/core/model/feature_tile_model.dart';
import 'package:soulnum/src/extensions/int_extensions.dart';
import 'package:soulnum/src/ui/home/components/home_feature_grid.dart';
import 'package:soulnum/src/ui/home/components/home_profile_summary_card.dart';
import 'package:soulnum/src/ui/home/interactor/home_cubit.dart';
import 'package:soulnum/src/ui/home/interactor/home_state.dart';
import 'package:soulnum/src/ui/widgets/app_button.dart';
import 'package:soulnum/src/ui/widgets/app_card_section.dart';
import 'package:soulnum/src/ui/widgets/app_screen_scaffold.dart';
import 'package:soulnum/src/ui/widgets/app_state_placeholder.dart';
import 'package:soulnum/src/ui/widgets/base/app_body.dart';
import 'package:soulnum/src/utils/app_colors.dart';
import 'package:soulnum/src/utils/app_pages.dart';
import 'package:soulnum/src/utils/app_styles.dart';

import '../../locale/locale_key.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeCubit cubit = Get.find<HomeCubit>()..load();
    return BlocProvider<HomeCubit>.value(
      value: cubit,
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: (BuildContext context, HomeState state) {
          Future<void> openActiveProfileSelector() async {
            final bool hasAnyProfile = state.profiles.isNotEmpty;
            final String route = hasAnyProfile
                ? AppPages.profileManager
                : AppPages.profileCreate;
            await Get.toNamed(
              route,
              arguments: <String, dynamic>{'force_select_active': true},
            );
            await cubit.load();
          }

          void openProfileManager() {
            final Future<dynamic>? navigation = Get.toNamed(
              AppPages.profileManager,
            );
            navigation?.then((_) => cubit.load());
          }

          final bool hasActiveProfile = state.activeProfile != null;

          return AppScreenScaffold(
            title: LocaleKey.homeTitle.tr,
            actions: <Widget>[
              TextButton(
                onPressed: () => Get.toNamed(AppPages.history),
                child: Text(LocaleKey.homeHistory.tr),
              ),
            ],
            child: AppBody(
              pageState: state.pageState,
              loading: const Center(child: CircularProgressIndicator()),
              empty: AppStatePlaceholder(
                title: LocaleKey.commonEmpty.tr,
                description: LocaleKey.noActiveProfile.tr,
                action: AppButton(
                  label: LocaleKey.profileCreateAction.tr,
                  onPressed: openActiveProfileSelector,
                ),
              ),
              failure: AppStatePlaceholder(
                title: LocaleKey.commonError.tr,
                description: state.errorMessage ?? LocaleKey.commonError.tr,
                action: AppButton(
                  label: LocaleKey.commonRetry.tr,
                  onPressed: cubit.load,
                ),
              ),
              success: ListView(
                children: <Widget>[
                  if (!hasActiveProfile) ...<Widget>[
                    AppCardSection(
                      color: const Color(0xFF17172A),
                      border: Border.all(
                        color: AppColors.colorF586AA6.withValues(alpha: 0.3),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            LocaleKey.homeSelectActiveProfileRequired.tr,
                            style: AppStyles.h5(color: AppColors.white),
                          ),
                          8.height,
                          Text(
                            LocaleKey.homeSelectActiveProfileDescription.tr,
                            style: AppStyles.bodySmall(
                              color: AppColors.colorFBFC9DE,
                            ),
                          ),
                          12.height,
                          AppButton(
                            label: state.profiles.isEmpty
                                ? LocaleKey.profileCreateAction.tr
                                : LocaleKey.homeSelectActiveProfileAction.tr,
                            onPressed: openActiveProfileSelector,
                          ),
                        ],
                      ),
                    ),
                    12.height,
                  ],
                  HomeProfileSummaryCard(
                    profile: state.activeProfile,
                    entitlement: state.entitlement,
                    onTap: () {
                      openProfileManager();
                    },
                  ),
                  16.height,
                  HomeFeatureGrid(
                    tiles: state.tiles,
                    isTileEnabled: (FeatureTileModel tile) {
                      if (hasActiveProfile) {
                        return true;
                      }
                      return tile.featureKey == 'profile_summary';
                    },
                    onTapTile: (FeatureTileModel tile) {
                      if (tile.featureKey == 'profile_summary') {
                        openProfileManager();
                        return;
                      }
                      if (tile.featureKey == FeatureKeys.compatibility) {
                        Get.toNamed(AppPages.compatibility);
                        return;
                      }
                      if (tile.featureKey == FeatureKeys.biorhythmDaily) {
                        Get.toNamed(AppPages.dailyCycle);
                        return;
                      }
                      if (tile.featureKey == FeatureKeys.chatAssistant) {
                        Get.toNamed(AppPages.aiChat);
                        return;
                      }
                      Get.toNamed(
                        AppPages.readingDetail,
                        arguments: <String, dynamic>{
                          'feature_key': tile.featureKey,
                          'title_key': tile.titleKey,
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
