import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:soulnum/src/extensions/int_extensions.dart';
import 'package:soulnum/src/locale/locale_key.dart';
import 'package:soulnum/src/ui/base/interactor/page_states.dart';
import 'package:soulnum/src/ui/history/components/history_item_card.dart';
import 'package:soulnum/src/ui/history/interactor/history_cubit.dart';
import 'package:soulnum/src/ui/history/interactor/history_state.dart';
import 'package:soulnum/src/ui/widgets/app_button.dart';
import 'package:soulnum/src/ui/widgets/app_screen_scaffold.dart';
import 'package:soulnum/src/ui/widgets/app_state_placeholder.dart';
import 'package:soulnum/src/ui/widgets/base/app_body.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final HistoryCubit cubit = Get.find<HistoryCubit>();
    if (cubit.state.pageState == PageState.initial) {
      cubit.loadInitial();
    }
    return BlocProvider<HistoryCubit>.value(
      value: cubit,
      child: BlocBuilder<HistoryCubit, HistoryState>(
        builder: (BuildContext context, HistoryState state) {
          return AppScreenScaffold(
            title: LocaleKey.historyTitle.tr,
            child: AppBody(
              pageState: state.pageState,
              loading: const Center(child: CircularProgressIndicator()),
              empty: AppStatePlaceholder(
                title: LocaleKey.commonEmpty.tr,
                description: LocaleKey.commonNoData.tr,
              ),
              failure: AppStatePlaceholder(
                title: LocaleKey.commonError.tr,
                description: state.errorMessage ?? LocaleKey.commonError.tr,
                action: AppButton(
                  label: LocaleKey.commonRetry.tr,
                  onPressed: cubit.loadInitial,
                ),
              ),
              success: ListView.separated(
                itemCount: state.items.length + 1,
                separatorBuilder: (BuildContext context, int index) => 12.height,
                itemBuilder: (BuildContext context, int index) {
                  if (index == state.items.length) {
                    if (state.nextCursor == null) {
                      return const SizedBox.shrink();
                    }
                    return AppButton(
                      label: LocaleKey.historyLoadMore.tr,
                      isLoading: state.isLoadingMore,
                      onPressed: cubit.loadMore,
                    );
                  }
                  return HistoryItemCard(item: state.items[index]);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
