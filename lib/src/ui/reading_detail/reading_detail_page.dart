import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:soulnum/src/extensions/int_extensions.dart';
import 'package:soulnum/src/locale/locale_key.dart';
import 'package:soulnum/src/ui/reading_detail/components/reading_result_card.dart';
import 'package:soulnum/src/ui/reading_detail/interactor/reading_detail_cubit.dart';
import 'package:soulnum/src/ui/reading_detail/interactor/reading_detail_state.dart';
import 'package:soulnum/src/ui/widgets/app_button.dart';
import 'package:soulnum/src/ui/widgets/app_screen_scaffold.dart';
import 'package:soulnum/src/ui/widgets/app_state_placeholder.dart';
import 'package:soulnum/src/ui/widgets/base/app_body.dart';
import 'package:soulnum/src/utils/app_pages.dart';

class ReadingDetailPage extends StatefulWidget {
  const ReadingDetailPage({super.key});

  @override
  State<ReadingDetailPage> createState() => _ReadingDetailPageState();
}

class _ReadingDetailPageState extends State<ReadingDetailPage> {
  late final String _featureKey;
  late final String _titleKey;
  String? _secondaryProfileId;
  late final ReadingDetailCubit _cubit;

  @override
  void initState() {
    super.initState();
    final Map<String, dynamic> args =
        (Get.arguments as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
    _featureKey = args['feature_key'] as String? ?? '';
    _titleKey = args['title_key'] as String? ?? LocaleKey.readingDetailTitle;
    _secondaryProfileId = args['secondary_profile_id'] as String?;
    _cubit = Get.find<ReadingDetailCubit>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadReading();
    });
  }

  Future<void> _loadReading() {
    return _cubit.load(
      featureKey: _featureKey,
      titleKey: _titleKey,
      secondaryProfileId: _secondaryProfileId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ReadingDetailCubit>.value(
      value: _cubit,
      child: BlocBuilder<ReadingDetailCubit, ReadingDetailState>(
        builder: (BuildContext context, ReadingDetailState state) {
          return AppScreenScaffold(
            title: (state.titleKey ?? _titleKey).tr,
            child: AppBody(
              pageState: state.pageState,
              loading: const Center(child: CircularProgressIndicator()),
              empty: AppStatePlaceholder(
                title: LocaleKey.commonEmpty.tr,
                description: LocaleKey.noActiveProfile.tr,
                action: AppButton(
                  label: LocaleKey.profileCreateAction.tr,
                  onPressed: () async {
                    await Get.toNamed(AppPages.profileCreate);
                    await _loadReading();
                  },
                ),
              ),
              failure: AppStatePlaceholder(
                title: LocaleKey.commonError.tr,
                description: state.errorMessage ?? LocaleKey.commonError.tr,
                action: AppButton(
                  label: LocaleKey.commonRetry.tr,
                  onPressed: _loadReading,
                ),
              ),
              unauthorized: AppStatePlaceholder(
                title: LocaleKey.unauthorizedTitle.tr,
                description: LocaleKey.unauthorizedDescription.tr,
                action: AppButton(
                  label: LocaleKey.loginPrimaryAction.tr,
                  onPressed: () => Get.offAllNamed(AppPages.login),
                ),
              ),
              success: ListView(
                children: <Widget>[
                  if (state.reading != null)
                    ReadingResultCard(reading: state.reading!),
                  12.height,
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
