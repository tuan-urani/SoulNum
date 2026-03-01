import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:soulnum/src/core/constants/feature_keys.dart';
import 'package:soulnum/src/core/model/reading_model.dart';
import 'package:soulnum/src/extensions/int_extensions.dart';
import 'package:soulnum/src/locale/locale_key.dart';
import 'package:soulnum/src/ui/widgets/app_card_section.dart';
import 'package:soulnum/src/utils/app_colors.dart';
import 'package:soulnum/src/utils/app_pages.dart';
import 'package:soulnum/src/utils/app_styles.dart';

class ReadingResultCard extends StatelessWidget {
  const ReadingResultCard({super.key, required this.reading});

  final ReadingModel reading;

  @override
  Widget build(BuildContext context) {
    final _ReadingContent content = _ReadingContent.fromJson(reading.result);
    if (reading.featureKey == FeatureKeys.coreNumbers) {
      return _CoreNumbersResultCard(content: content);
    }
    if (reading.featureKey == FeatureKeys.psychMatrix) {
      return _PsychMatrixResultCard(
        content: content,
        rawResult: reading.result,
      );
    }
    if (reading.featureKey == FeatureKeys.birthChart) {
      return _BirthChartResultCard(content: content, rawResult: reading.result);
    }
    if (reading.featureKey == FeatureKeys.energyBoost) {
      return _EnergyBoostResultCard(
        content: content,
        rawResult: reading.result,
      );
    }
    if (reading.featureKey == FeatureKeys.compatibility) {
      return _CompatibilityResultCard(
        content: content,
        rawResult: reading.result,
      );
    }
    if (reading.featureKey == FeatureKeys.fourPeaks) {
      return _FourPeaksResultCard(content: content, rawResult: reading.result);
    }
    if (reading.featureKey == FeatureKeys.fourChallenges) {
      return _FourChallengesResultCard(
        content: content,
        rawResult: reading.result,
      );
    }
    if (reading.featureKey == FeatureKeys.forecastDay) {
      return _ForecastResultCard(
        period: _ForecastPeriod.day,
        content: content,
        rawResult: reading.result,
      );
    }
    if (reading.featureKey == FeatureKeys.forecastMonth) {
      return _ForecastResultCard(
        period: _ForecastPeriod.month,
        content: content,
        rawResult: reading.result,
      );
    }
    if (reading.featureKey == FeatureKeys.forecastYear) {
      return _ForecastResultCard(
        period: _ForecastPeriod.year,
        content: content,
        rawResult: reading.result,
      );
    }

    final String generatedAt = _formatDateTime(reading.generatedAt);
    final String sourceLabel = reading.fromCache
        ? LocaleKey.readingResultSourceCache.tr
        : LocaleKey.readingResultSourceGenerated.tr;
    final String prettyJson = const JsonEncoder.withIndent(
      '  ',
    ).convert(reading.result);

    return AppCardSection(
      color: AppColors.authBackgroundSurface,
      border: Border.all(color: AppColors.colorF586AA6.withValues(alpha: 0.2)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _MetaPill(
                label: '${LocaleKey.readingResultGeneratedAt.tr}: $generatedAt',
              ),
              _MetaPill(
                label: '${LocaleKey.readingResultSourceLabel.tr}: $sourceLabel',
              ),
            ],
          ),
          12.height,
          if (content.title.isNotEmpty)
            Text(content.title, style: AppStyles.h4(color: AppColors.white)),
          if (content.summary.isNotEmpty) ...<Widget>[
            if (content.title.isNotEmpty) 10.height,
            _SectionCard(
              title: LocaleKey.readingResultSummaryTitle.tr,
              child: Text(
                content.summary,
                style: AppStyles.bodyMedium(color: AppColors.colorFBFC9DE),
              ),
            ),
          ],
          if (content.insights.isNotEmpty) ...<Widget>[
            12.height,
            Text(
              LocaleKey.readingResultInsightsTitle.tr,
              style: AppStyles.h5(color: AppColors.white),
            ),
            8.height,
            ...content.insights.map(
              (_InsightItem insight) => Padding(
                padding: 8.paddingBottom,
                child: _SectionCard(
                  title: insight.label,
                  child: Text(
                    insight.value,
                    style: AppStyles.bodyMedium(color: AppColors.colorFBFC9DE),
                  ),
                ),
              ),
            ),
          ],
          if (content.actions.isNotEmpty) ...<Widget>[
            8.height,
            Text(
              LocaleKey.readingResultActionsTitle.tr,
              style: AppStyles.h5(color: AppColors.white),
            ),
            8.height,
            ...content.actions.asMap().entries.map(
              (MapEntry<int, String> entry) => Padding(
                padding: 8.paddingBottom,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '${entry.key + 1}.',
                      style: AppStyles.bodyMedium(
                        color: AppColors.colorFBFC9DE,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    8.width,
                    Expanded(
                      child: Text(
                        entry.value,
                        style: AppStyles.bodyMedium(
                          color: AppColors.colorFBFC9DE,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (!content.hasStructuredData) ...<Widget>[
            if (content.title.isNotEmpty || content.summary.isNotEmpty)
              8.height,
            _SectionCard(
              title: LocaleKey.readingResultRawDataTitle.tr,
              child: SelectableText(
                prettyJson,
                style: AppStyles.bodySmall(color: AppColors.colorFBFC9DE),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDateTime(DateTime value) {
    String twoDigits(int number) => number.toString().padLeft(2, '0');
    return '${value.year}-${twoDigits(value.month)}-${twoDigits(value.day)} '
        '${twoDigits(value.hour)}:${twoDigits(value.minute)}';
  }
}

class _CoreNumbersResultCard extends StatelessWidget {
  const _CoreNumbersResultCard({required this.content});

  final _ReadingContent content;

  @override
  Widget build(BuildContext context) {
    final _InsightItem? highlight = content.insights.isNotEmpty
        ? content.insights.first
        : (content.summary.isNotEmpty
              ? _InsightItem(
                  label: LocaleKey.readingResultSummaryTitle.tr,
                  value: content.summary,
                )
              : null);

    final List<_InsightItem> detailInsights = content.insights.length > 1
        ? content.insights.sublist(1)
        : <_InsightItem>[];

    final String actionText = content.actions.isNotEmpty
        ? content.actions.join('\n')
        : (content.summary.isNotEmpty
              ? content.summary
              : LocaleKey.commonNoData.tr);

    return AppCardSection(
      color: AppColors.authBackgroundSurface,
      borderRadius: 28.borderRadiusAll,
      border: Border.all(color: AppColors.colorFB1B8D1.withValues(alpha: 0.2)),
      boxShadow: <BoxShadow>[
        BoxShadow(
          color: AppColors.black.withValues(alpha: 0.35),
          offset: const Offset(0, 10),
          blurRadius: 28,
        ),
      ],
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _CoreNumbersHeader(
            title: content.title.isNotEmpty
                ? content.title
                : LocaleKey.homeCoreNumbers.tr,
          ),
          12.height,
          if (highlight != null) ...<Widget>[
            _InsightCard(item: highlight, highlighted: true),
            10.height,
          ],
          ...detailInsights.map(
            (_InsightItem item) => Padding(
              padding: 10.paddingBottom,
              child: _InsightCard(item: item),
            ),
          ),
          if (detailInsights.isEmpty && highlight == null) ...<Widget>[
            _InsightCard(
              item: _InsightItem(
                label: LocaleKey.readingResultSummaryTitle.tr,
                value: content.summary.isNotEmpty
                    ? content.summary
                    : LocaleKey.commonNoData.tr,
              ),
            ),
            10.height,
          ],
          _ActionCard(
            title: LocaleKey.readingResultActionsTitle.tr,
            content: actionText,
          ),
          24.height,
          Row(
            children: <Widget>[
              Expanded(
                child: _ModuleNavButton(
                  label: LocaleKey.readingCoreNumbersPrevModule.tr,
                  onPressed: () {
                    if (Navigator.of(context).canPop()) {
                      Get.back<void>();
                      return;
                    }
                    Get.offAllNamed(AppPages.home);
                  },
                  isPrimary: false,
                ),
              ),
              10.width,
              Expanded(
                child: _ModuleNavButton(
                  label: LocaleKey.readingCoreNumbersNextModule.tr,
                  onPressed: () {
                    Get.offNamed(
                      AppPages.readingDetail,
                      arguments: <String, dynamic>{
                        'feature_key': FeatureKeys.psychMatrix,
                        'title_key': LocaleKey.homePsychMatrix,
                      },
                    );
                  },
                  isPrimary: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PsychMatrixResultCard extends StatelessWidget {
  const _PsychMatrixResultCard({
    required this.content,
    required this.rawResult,
  });

  final _ReadingContent content;
  final Map<String, dynamic> rawResult;

  @override
  Widget build(BuildContext context) {
    final _PsychMatrixViewModel viewModel = _PsychMatrixViewModel.fromResult(
      content: content,
      rawResult: rawResult,
    );

    return AppCardSection(
      color: AppColors.authBackgroundSurface,
      borderRadius: 28.borderRadiusAll,
      border: Border.all(color: AppColors.colorFB1B8D1.withValues(alpha: 0.2)),
      boxShadow: <BoxShadow>[
        BoxShadow(
          color: AppColors.black.withValues(alpha: 0.35),
          offset: const Offset(0, 10),
          blurRadius: 28,
        ),
      ],
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _PsychMatrixHeader(title: viewModel.title),
          12.height,
          _PsychOverviewCard(overview: viewModel.overview),
          10.height,
          _PsychMetricGrid(metrics: viewModel.metrics),
          10.height,
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _PsychClusterChip(
                label:
                    '${LocaleKey.readingPsychMatrixStrongClusterPrefix.tr}: ${viewModel.strongCluster}',
                isPositive: true,
              ),
              _PsychClusterChip(
                label:
                    '${LocaleKey.readingPsychMatrixWeakClusterPrefix.tr}: ${viewModel.weakCluster}',
                isPositive: false,
              ),
            ],
          ),
          10.height,
          _PsychDeepInterpretationCard(content: viewModel.deepInterpretation),
          24.height,
          Row(
            children: <Widget>[
              Expanded(
                child: _ModuleNavButton(
                  label: LocaleKey.readingPsychMatrixBackHome.tr,
                  onPressed: () => Get.offAllNamed(AppPages.home),
                  isPrimary: false,
                ),
              ),
              10.width,
              Expanded(
                child: _ModuleNavButton(
                  label: LocaleKey.readingPsychMatrixNextSuggestion.tr,
                  onPressed: () {
                    Get.offNamed(
                      AppPages.readingDetail,
                      arguments: <String, dynamic>{
                        'feature_key': FeatureKeys.birthChart,
                        'title_key': LocaleKey.homeBirthChart,
                      },
                    );
                  },
                  isPrimary: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PsychMatrixHeader extends StatelessWidget {
  const _PsychMatrixHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.colorF586AA6.withValues(alpha: 0.24),
        ),
        borderRadius: 14.borderRadiusAll,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            AppColors.color1C274C.withValues(alpha: 0.95),
            AppColors.color131A29.withValues(alpha: 0.9),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: AppStyles.bodyLarge(
                color: AppColors.colorF2F4F7,
                fontWeight: FontWeight.w600,
                height: 1.33,
              ),
            ),
            4.height,
            Text(
              LocaleKey.readingPsychMatrixEntryHint.tr,
              style: AppStyles.bodySmall(
                color: AppColors.colorFBFC9DE.withValues(alpha: 0.78),
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PsychOverviewCard extends StatelessWidget {
  const _PsychOverviewCard({required this.overview});

  final String overview;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.colorF586AA6.withValues(alpha: 0.38),
        ),
        borderRadius: 14.borderRadiusAll,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            AppColors.authAccentViolet.withValues(alpha: 0.22),
            AppColors.colorF59AEF9.withValues(alpha: 0.15),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              LocaleKey.readingPsychMatrixOverviewTitle.tr,
              style: AppStyles.bodyLarge(
                color: AppColors.colorDFE4F5,
                fontWeight: FontWeight.w700,
                height: 1.33,
              ),
            ),
            2.height,
            _ExpandableText(
              text: overview,
              style: AppStyles.bodyLarge(
                color: AppColors.colorFBFC9DE,
                height: 1.35,
              ),
              collapsedMaxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}

class _PsychMetricGrid extends StatelessWidget {
  const _PsychMetricGrid({required this.metrics});

  final List<_PsychMetric> metrics;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: metrics.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        mainAxisExtent: 72,
      ),
      itemBuilder: (BuildContext context, int index) {
        final _PsychMetric metric = metrics[index];
        final String score = metric.scoreText.isEmpty ? '--' : metric.scoreText;
        return DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.color131A29.withValues(alpha: 0.95),
            border: Border.all(
              color: AppColors.colorFB1B8D1.withValues(alpha: 0.28),
            ),
            borderRadius: 10.borderRadiusAll,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 9),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    metric.label,
                    style: AppStyles.bodySmall(
                      color: AppColors.colorFBFC9DE,
                      height: 1.28,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                8.width,
                DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.colorF586AA6.withValues(alpha: 0.35),
                    ),
                    borderRadius: 8.borderRadiusAll,
                    color: AppColors.color1C274C.withValues(alpha: 0.9),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Text(
                      score,
                      style: AppStyles.bodyMedium(
                        color: AppColors.colorF2F4F7,
                        fontWeight: FontWeight.w700,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PsychClusterChip extends StatelessWidget {
  const _PsychClusterChip({required this.label, required this.isPositive});

  final String label;
  final bool isPositive;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          color: isPositive
              ? AppColors.color88CF66.withValues(alpha: 0.45)
              : AppColors.authAccentGold.withValues(alpha: 0.45),
        ),
        borderRadius: 999.borderRadiusAll,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        child: Text(
          label,
          style: AppStyles.bodySmall(
            color: isPositive
                ? AppColors.color88CF66
                : AppColors.authAccentGold,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}

class _PsychDeepInterpretationCard extends StatelessWidget {
  const _PsychDeepInterpretationCard({required this.content});

  final String content;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.color131A29.withValues(alpha: 0.88),
        border: Border.all(
          color: AppColors.colorFB1B8D1.withValues(alpha: 0.22),
        ),
        borderRadius: 14.borderRadiusAll,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              LocaleKey.readingPsychMatrixDeepTitle.tr,
              style: AppStyles.bodyLarge(
                color: AppColors.colorDFE4F5,
                fontWeight: FontWeight.w700,
                height: 1.33,
              ),
            ),
            2.height,
            _ExpandableText(
              text: content,
              style: AppStyles.bodySmall(
                color: AppColors.colorFBFC9DE.withValues(alpha: 0.9),
                height: 1.3,
              ),
              collapsedMaxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}

class _BirthChartResultCard extends StatelessWidget {
  const _BirthChartResultCard({required this.content, required this.rawResult});

  final _ReadingContent content;
  final Map<String, dynamic> rawResult;

  @override
  Widget build(BuildContext context) {
    final _BirthChartViewModel viewModel = _BirthChartViewModel.fromResult(
      content: content,
      rawResult: rawResult,
    );

    return AppCardSection(
      color: AppColors.authBackgroundSurface,
      borderRadius: 28.borderRadiusAll,
      border: Border.all(color: AppColors.colorFB1B8D1.withValues(alpha: 0.2)),
      boxShadow: <BoxShadow>[
        BoxShadow(
          color: AppColors.black.withValues(alpha: 0.35),
          offset: const Offset(0, 10),
          blurRadius: 28,
        ),
      ],
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _BirthChartHeader(title: viewModel.title),
          12.height,
          _BirthOverviewCard(overview: viewModel.overview),
          10.height,
          _BirthVisualCard(content: viewModel.visualDescription),
          10.height,
          Row(
            children: <Widget>[
              Expanded(child: _BirthAxisCard(axis: viewModel.axes[0])),
              10.width,
              Expanded(child: _BirthAxisCard(axis: viewModel.axes[1])),
              10.width,
              Expanded(child: _BirthAxisCard(axis: viewModel.axes[2])),
            ],
          ),
          10.height,
          _BirthMissingCard(content: viewModel.missingHighlight),
          24.height,
          Row(
            children: <Widget>[
              Expanded(
                child: _ModuleNavButton(
                  label: LocaleKey.readingBirthChartBackHome.tr,
                  onPressed: () => Get.offAllNamed(AppPages.home),
                  isPrimary: false,
                ),
              ),
              10.width,
              Expanded(
                child: _ModuleNavButton(
                  label: LocaleKey.readingBirthChartNextEnergy.tr,
                  onPressed: () {
                    Get.offNamed(
                      AppPages.readingDetail,
                      arguments: <String, dynamic>{
                        'feature_key': FeatureKeys.energyBoost,
                        'title_key': LocaleKey.homeEnergyBoost,
                      },
                    );
                  },
                  isPrimary: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BirthChartHeader extends StatelessWidget {
  const _BirthChartHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.colorF586AA6.withValues(alpha: 0.24),
        ),
        borderRadius: 14.borderRadiusAll,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            AppColors.color1C274C.withValues(alpha: 0.95),
            AppColors.color131A29.withValues(alpha: 0.9),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: AppStyles.bodyLarge(
                color: AppColors.colorF2F4F7,
                fontWeight: FontWeight.w600,
                height: 1.33,
              ),
            ),
            4.height,
            Text(
              LocaleKey.readingBirthChartEntryHint.tr,
              style: AppStyles.bodySmall(
                color: AppColors.colorFBFC9DE.withValues(alpha: 0.78),
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BirthOverviewCard extends StatelessWidget {
  const _BirthOverviewCard({required this.overview});

  final String overview;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.colorF586AA6.withValues(alpha: 0.38),
        ),
        borderRadius: 14.borderRadiusAll,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            AppColors.authAccentViolet.withValues(alpha: 0.22),
            AppColors.colorF59AEF9.withValues(alpha: 0.15),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              LocaleKey.readingBirthChartOverviewTitle.tr,
              style: AppStyles.bodyLarge(
                color: AppColors.colorDFE4F5,
                fontWeight: FontWeight.w700,
                height: 1.33,
              ),
            ),
            2.height,
            _ExpandableText(
              text: overview,
              style: AppStyles.bodyLarge(
                color: AppColors.colorFBFC9DE,
                height: 1.35,
              ),
              collapsedMaxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}

class _BirthVisualCard extends StatelessWidget {
  const _BirthVisualCard({required this.content});

  final String content;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.color131A29.withValues(alpha: 0.88),
        border: Border.all(
          color: AppColors.colorFB1B8D1.withValues(alpha: 0.22),
        ),
        borderRadius: 14.borderRadiusAll,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.authGlowViolet.withValues(alpha: 0.16),
            blurRadius: 24,
          ),
        ],
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 170),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: _ExpandableText(
            text: content,
            style: AppStyles.bodyLarge(
              color: AppColors.colorFBFC9DE,
              height: 1.35,
            ),
            collapsedMaxLines: 4,
          ),
        ),
      ),
    );
  }
}

class _BirthAxisCard extends StatelessWidget {
  const _BirthAxisCard({required this.axis});

  final _BirthAxis axis;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.color1C274C.withValues(alpha: 0.92),
        border: Border.all(
          color: AppColors.colorFB1B8D1.withValues(alpha: 0.3),
        ),
        borderRadius: 12.borderRadiusAll,
      ),
      child: SizedBox(
        height: 84,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(11, 11, 11, 11),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Text(
                  '${LocaleKey.readingBirthChartAxisPrefix.tr}\n${axis.code}',
                  style: AppStyles.h4(
                    color: AppColors.colorF2F4F7,
                    fontWeight: FontWeight.w700,
                    height: 1.12,
                  ),
                ),
              ),
              Text(
                axis.subtitle,
                style: AppStyles.bodySmall(
                  color: AppColors.colorFBFC9DE.withValues(alpha: 0.82),
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BirthMissingCard extends StatelessWidget {
  const _BirthMissingCard({required this.content});

  final String content;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.authAccentGold.withValues(alpha: 0.45),
        ),
        borderRadius: 14.borderRadiusAll,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            AppColors.authAccentGold.withValues(alpha: 0.16),
            AppColors.authAccentGold.withValues(alpha: 0.08),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              LocaleKey.readingBirthChartMissingTitle.tr,
              style: AppStyles.bodyLarge(
                color: AppColors.colorDFE4F5,
                fontWeight: FontWeight.w700,
                height: 1.33,
              ),
            ),
            2.height,
            _ExpandableText(
              text: content,
              style: AppStyles.bodySmall(
                color: AppColors.colorFBFC9DE.withValues(alpha: 0.9),
                height: 1.3,
              ),
              collapsedMaxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}

class _EnergyBoostResultCard extends StatelessWidget {
  const _EnergyBoostResultCard({
    required this.content,
    required this.rawResult,
  });

  final _ReadingContent content;
  final Map<String, dynamic> rawResult;

  @override
  Widget build(BuildContext context) {
    final _EnergyBoostViewModel viewModel = _EnergyBoostViewModel.fromResult(
      content: content,
      rawResult: rawResult,
    );

    return AppCardSection(
      color: AppColors.authBackgroundSurface,
      borderRadius: 28.borderRadiusAll,
      border: Border.all(color: AppColors.colorFB1B8D1.withValues(alpha: 0.2)),
      boxShadow: <BoxShadow>[
        BoxShadow(
          color: AppColors.black.withValues(alpha: 0.35),
          offset: const Offset(0, 10),
          blurRadius: 28,
        ),
      ],
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _FeatureHeaderCard(
            title: viewModel.title,
            entryHint: LocaleKey.readingEnergyBoostEntryHint.tr,
          ),
          12.height,
          _FeatureHighlightCard(
            title: viewModel.dominantTitle,
            description: viewModel.dominantDescription,
          ),
          10.height,
          _FeatureTagsCard(
            title: LocaleKey.readingEnergyBoostTalentTitle.tr,
            tags: viewModel.talentTags,
            isPositive: true,
          ),
          10.height,
          _FeatureTagsCard(
            title: LocaleKey.readingEnergyBoostWeaknessTitle.tr,
            tags: viewModel.weaknessTags,
            isPositive: false,
          ),
          10.height,
          _FeatureLongTextCard(
            title: LocaleKey.readingEnergyBoostActionTitle.tr,
            content: viewModel.dailyAction,
            collapsedMaxLines: 3,
          ),
          24.height,
          Row(
            children: <Widget>[
              Expanded(
                child: _ModuleNavButton(
                  label: LocaleKey.readingEnergyBoostBackHome.tr,
                  onPressed: () => Get.offAllNamed(AppPages.home),
                  isPrimary: false,
                ),
              ),
              10.width,
              Expanded(
                child: _ModuleNavButton(
                  label: LocaleKey.readingEnergyBoostApplyNow.tr,
                  onPressed: () {},
                  isPrimary: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompatibilityResultCard extends StatelessWidget {
  const _CompatibilityResultCard({
    required this.content,
    required this.rawResult,
  });

  final _ReadingContent content;
  final Map<String, dynamic> rawResult;

  @override
  Widget build(BuildContext context) {
    final _CompatibilityViewModel viewModel =
        _CompatibilityViewModel.fromResult(
          content: content,
          rawResult: rawResult,
        );

    return AppCardSection(
      color: AppColors.authBackgroundSurface,
      borderRadius: 20.borderRadiusAll,
      border: Border.all(color: AppColors.colorFB1B8D1.withValues(alpha: 0.2)),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _FeatureHeaderCard(
            title: viewModel.title,
            entryHint: LocaleKey.readingCompatibilityEntryHint.tr,
          ),
          12.height,
          _FeatureHighlightCard(
            title: LocaleKey.readingCompatibilityOverviewTitle.tr,
            description: viewModel.overview,
          ),
          10.height,
          _FeatureLongTextCard(
            title: LocaleKey.readingCompatibilityHarmonyTitle.tr,
            content: viewModel.harmony,
            collapsedMaxLines: 3,
          ),
          10.height,
          _FeatureLongTextCard(
            title: LocaleKey.readingCompatibilityCautionTitle.tr,
            content: viewModel.caution,
            collapsedMaxLines: 3,
          ),
          10.height,
          _FeatureLongTextCard(
            title: LocaleKey.readingCompatibilityPrinciplesTitle.tr,
            content: viewModel.principles,
            collapsedMaxLines: 4,
          ),
        ],
      ),
    );
  }
}

class _FourPeaksResultCard extends StatelessWidget {
  const _FourPeaksResultCard({required this.content, required this.rawResult});

  final _ReadingContent content;
  final Map<String, dynamic> rawResult;

  @override
  Widget build(BuildContext context) {
    final _FourPeaksViewModel viewModel = _FourPeaksViewModel.fromResult(
      content: content,
      rawResult: rawResult,
    );

    return AppCardSection(
      color: AppColors.authBackgroundSurface,
      borderRadius: 28.borderRadiusAll,
      border: Border.all(color: AppColors.colorFB1B8D1.withValues(alpha: 0.2)),
      boxShadow: <BoxShadow>[
        BoxShadow(
          color: AppColors.black.withValues(alpha: 0.35),
          offset: const Offset(0, 10),
          blurRadius: 28,
        ),
      ],
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _FeatureHeaderCard(
            title: viewModel.title,
            entryHint: LocaleKey.readingFourPeaksEntryHint.tr,
          ),
          12.height,
          _FeatureHighlightCard(
            title: LocaleKey.readingFourPeaksOverviewTitle.tr,
            description: viewModel.overview,
          ),
          10.height,
          ...viewModel.stages.map(
            (_StageItem stage) => Padding(
              padding: 10.paddingBottom,
              child: _StageCard(item: stage),
            ),
          ),
          14.height,
          Row(
            children: <Widget>[
              Expanded(
                child: _ModuleNavButton(
                  label: LocaleKey.readingFourPeaksBackHome.tr,
                  onPressed: () => Get.offAllNamed(AppPages.home),
                  isPrimary: false,
                ),
              ),
              10.width,
              Expanded(
                child: _ModuleNavButton(
                  label: LocaleKey.readingFourPeaksNextChallenges.tr,
                  onPressed: () {
                    Get.offNamed(
                      AppPages.readingDetail,
                      arguments: <String, dynamic>{
                        'feature_key': FeatureKeys.fourChallenges,
                        'title_key': LocaleKey.homeFourChallenges,
                      },
                    );
                  },
                  isPrimary: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FourChallengesResultCard extends StatelessWidget {
  const _FourChallengesResultCard({
    required this.content,
    required this.rawResult,
  });

  final _ReadingContent content;
  final Map<String, dynamic> rawResult;

  @override
  Widget build(BuildContext context) {
    final _FourChallengesViewModel viewModel =
        _FourChallengesViewModel.fromResult(
          content: content,
          rawResult: rawResult,
        );

    return AppCardSection(
      color: AppColors.authBackgroundSurface,
      borderRadius: 28.borderRadiusAll,
      border: Border.all(color: AppColors.colorFB1B8D1.withValues(alpha: 0.2)),
      boxShadow: <BoxShadow>[
        BoxShadow(
          color: AppColors.black.withValues(alpha: 0.35),
          offset: const Offset(0, 10),
          blurRadius: 28,
        ),
      ],
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _FeatureHeaderCard(
            title: viewModel.title,
            entryHint: LocaleKey.readingFourChallengesEntryHint.tr,
          ),
          12.height,
          _FeatureGoldHighlightCard(
            title: LocaleKey.readingFourChallengesOverviewTitle.tr,
            description: viewModel.overview,
          ),
          10.height,
          ...viewModel.stages.map(
            (_StageItem stage) => Padding(
              padding: 10.paddingBottom,
              child: _StageCard(item: stage),
            ),
          ),
          10.height,
          _FeatureLongTextCard(
            title: LocaleKey.readingFourChallengesStrategyTitle.tr,
            content: viewModel.strategy,
            collapsedMaxLines: 3,
          ),
          24.height,
          Row(
            children: <Widget>[
              Expanded(
                child: _ModuleNavButton(
                  label: LocaleKey.readingFourChallengesBackHome.tr,
                  onPressed: () => Get.offAllNamed(AppPages.home),
                  isPrimary: false,
                ),
              ),
              10.width,
              Expanded(
                child: _ModuleNavButton(
                  label: LocaleKey.readingFourChallengesToChatbot.tr,
                  onPressed: () => Get.toNamed(AppPages.aiChat),
                  isPrimary: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum _ForecastPeriod { day, month, year }

class _ForecastResultCard extends StatelessWidget {
  const _ForecastResultCard({
    required this.period,
    required this.content,
    required this.rawResult,
  });

  final _ForecastPeriod period;
  final _ReadingContent content;
  final Map<String, dynamic> rawResult;

  @override
  Widget build(BuildContext context) {
    final _ForecastViewModel viewModel = _ForecastViewModel.fromResult(
      period: period,
      content: content,
      rawResult: rawResult,
    );

    return AppCardSection(
      color: AppColors.authBackgroundSurface,
      borderRadius: 28.borderRadiusAll,
      border: Border.all(color: AppColors.colorFB1B8D1.withValues(alpha: 0.2)),
      boxShadow: <BoxShadow>[
        BoxShadow(
          color: AppColors.black.withValues(alpha: 0.35),
          offset: const Offset(0, 10),
          blurRadius: 28,
        ),
      ],
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _FeatureHeaderCard(
            title: viewModel.title,
            entryHint: viewModel.entryHint,
          ),
          12.height,
          _FeatureHighlightCard(
            title: LocaleKey.readingForecastOverviewTitle.tr,
            description: viewModel.overview,
          ),
          10.height,
          _FeatureTagsCard(
            title: LocaleKey.readingForecastThemesTitle.tr,
            tags: viewModel.themeTags,
            isPositive: true,
          ),
          10.height,
          _FeatureLongTextCard(
            title: LocaleKey.readingForecastFocusTitle.tr,
            content: viewModel.focus,
            collapsedMaxLines: 3,
          ),
          10.height,
          _FeatureLongTextCard(
            title: LocaleKey.readingForecastOpportunityTitle.tr,
            content: viewModel.opportunity,
            collapsedMaxLines: 3,
          ),
          10.height,
          _FeatureLongTextCard(
            title: LocaleKey.readingForecastCautionTitle.tr,
            content: viewModel.caution,
            collapsedMaxLines: 3,
          ),
          10.height,
          _ForecastActionsCard(actions: viewModel.actions),
          24.height,
          Row(
            children: <Widget>[
              Expanded(
                child: _ModuleNavButton(
                  label: LocaleKey.readingForecastBackHome.tr,
                  onPressed: () => Get.offAllNamed(AppPages.home),
                  isPrimary: false,
                ),
              ),
              10.width,
              Expanded(
                child: _ModuleNavButton(
                  label: viewModel.nextCtaLabel,
                  onPressed: viewModel.onNext,
                  isPrimary: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ForecastActionsCard extends StatelessWidget {
  const _ForecastActionsCard({required this.actions});

  final List<String> actions;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.authAccentGold.withValues(alpha: 0.45),
        ),
        borderRadius: 14.borderRadiusAll,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            AppColors.authAccentGold.withValues(alpha: 0.16),
            AppColors.authAccentGold.withValues(alpha: 0.08),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              LocaleKey.readingResultActionsTitle.tr,
              style: AppStyles.bodyLarge(
                color: AppColors.colorDFE4F5,
                fontWeight: FontWeight.w700,
                height: 1.33,
              ),
            ),
            8.height,
            ...actions.asMap().entries.map(
              (MapEntry<int, String> entry) => Padding(
                padding: 6.paddingBottom,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '${entry.key + 1}.',
                      style: AppStyles.bodySmall(
                        color: AppColors.colorFBFC9DE.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                    8.width,
                    Expanded(
                      child: _ExpandableText(
                        text: entry.value,
                        style: AppStyles.bodySmall(
                          color: AppColors.colorFBFC9DE.withValues(alpha: 0.9),
                          height: 1.3,
                        ),
                        collapsedMaxLines: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureHeaderCard extends StatelessWidget {
  const _FeatureHeaderCard({required this.title, required this.entryHint});

  final String title;
  final String entryHint;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.colorF586AA6.withValues(alpha: 0.24),
        ),
        borderRadius: 14.borderRadiusAll,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            AppColors.color1C274C.withValues(alpha: 0.95),
            AppColors.color131A29.withValues(alpha: 0.9),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: AppStyles.bodyLarge(
                color: AppColors.colorF2F4F7,
                fontWeight: FontWeight.w600,
                height: 1.33,
              ),
            ),
            4.height,
            Text(
              entryHint,
              style: AppStyles.bodySmall(
                color: AppColors.colorFBFC9DE.withValues(alpha: 0.78),
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureHighlightCard extends StatelessWidget {
  const _FeatureHighlightCard({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.colorF586AA6.withValues(alpha: 0.38),
        ),
        borderRadius: 14.borderRadiusAll,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            AppColors.authAccentViolet.withValues(alpha: 0.22),
            AppColors.colorF59AEF9.withValues(alpha: 0.15),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: AppStyles.bodyLarge(
                color: AppColors.colorDFE4F5,
                fontWeight: FontWeight.w700,
                height: 1.33,
              ),
            ),
            2.height,
            _ExpandableText(
              text: description,
              style: AppStyles.bodyLarge(
                color: AppColors.colorFBFC9DE,
                height: 1.35,
              ),
              collapsedMaxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureGoldHighlightCard extends StatelessWidget {
  const _FeatureGoldHighlightCard({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.authAccentGold.withValues(alpha: 0.45),
        ),
        borderRadius: 14.borderRadiusAll,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            AppColors.authAccentGold.withValues(alpha: 0.16),
            AppColors.authAccentGold.withValues(alpha: 0.08),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: AppStyles.bodyLarge(
                color: AppColors.colorDFE4F5,
                fontWeight: FontWeight.w700,
                height: 1.33,
              ),
            ),
            2.height,
            _ExpandableText(
              text: description,
              style: AppStyles.bodyLarge(
                color: AppColors.colorFBFC9DE,
                height: 1.35,
              ),
              collapsedMaxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureTagsCard extends StatelessWidget {
  const _FeatureTagsCard({
    required this.title,
    required this.tags,
    required this.isPositive,
  });

  final String title;
  final List<String> tags;
  final bool isPositive;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.color131A29.withValues(alpha: 0.88),
        border: Border.all(
          color: AppColors.colorFB1B8D1.withValues(alpha: 0.22),
        ),
        borderRadius: 14.borderRadiusAll,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: AppStyles.bodyLarge(
                color: AppColors.colorDFE4F5,
                fontWeight: FontWeight.w700,
                height: 1.33,
              ),
            ),
            8.height,
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tags
                  .map(
                    (String tag) =>
                        _TagChip(label: tag, isPositive: isPositive),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label, required this.isPositive});

  final String label;
  final bool isPositive;

  @override
  Widget build(BuildContext context) {
    final Color borderColor = isPositive
        ? AppColors.color88CF66.withValues(alpha: 0.45)
        : AppColors.authAccentGold.withValues(alpha: 0.45);
    final Color textColor = isPositive
        ? AppColors.color88CF66
        : AppColors.authAccentGold;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: 999.borderRadiusAll,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        child: Text(
          label,
          style: AppStyles.bodySmall(color: textColor, height: 1.0),
        ),
      ),
    );
  }
}

class _FeatureLongTextCard extends StatelessWidget {
  const _FeatureLongTextCard({
    required this.title,
    required this.content,
    this.collapsedMaxLines = 3,
  });

  final String title;
  final String content;
  final int collapsedMaxLines;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.color131A29.withValues(alpha: 0.88),
        border: Border.all(
          color: AppColors.colorFB1B8D1.withValues(alpha: 0.22),
        ),
        borderRadius: 14.borderRadiusAll,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: AppStyles.bodyLarge(
                color: AppColors.colorDFE4F5,
                fontWeight: FontWeight.w700,
                height: 1.33,
              ),
            ),
            2.height,
            _ExpandableText(
              text: content,
              style: AppStyles.bodySmall(
                color: AppColors.colorFBFC9DE.withValues(alpha: 0.9),
                height: 1.3,
              ),
              collapsedMaxLines: collapsedMaxLines,
            ),
          ],
        ),
      ),
    );
  }
}

class _StageCard extends StatelessWidget {
  const _StageCard({required this.item});

  final _StageItem item;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.color1C274C.withValues(alpha: 0.88),
        border: Border.all(
          color: AppColors.colorFB1B8D1.withValues(alpha: 0.24),
        ),
        borderRadius: 12.borderRadiusAll,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(11, 11, 11, 11),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              item.title,
              style: AppStyles.bodySmall(
                color: AppColors.colorF2F4F7,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
            5.height,
            _ExpandableText(
              text: item.description,
              style: AppStyles.bodySmall(
                color: AppColors.colorFBFC9DE.withValues(alpha: 0.92),
                height: 1.2,
              ),
              collapsedMaxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}

class _StageItem {
  const _StageItem({required this.title, required this.description});

  final String title;
  final String description;
}

class _CoreNumbersHeader extends StatelessWidget {
  const _CoreNumbersHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.colorF586AA6.withValues(alpha: 0.24),
        ),
        borderRadius: 14.borderRadiusAll,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            AppColors.color1C274C.withValues(alpha: 0.95),
            AppColors.color131A29.withValues(alpha: 0.9),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: AppStyles.bodyLarge(
                color: AppColors.colorF2F4F7,
                fontWeight: FontWeight.w600,
                height: 1.33,
              ),
            ),
            4.height,
            Text(
              LocaleKey.readingCoreNumbersEntryHint.tr,
              style: AppStyles.bodySmall(
                color: AppColors.colorFBFC9DE.withValues(alpha: 0.78),
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.item, this.highlighted = false});

  final _InsightItem item;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final BoxDecoration decoration = highlighted
        ? BoxDecoration(
            border: Border.all(
              color: AppColors.colorF586AA6.withValues(alpha: 0.38),
            ),
            borderRadius: 14.borderRadiusAll,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                AppColors.authAccentViolet.withValues(alpha: 0.22),
                AppColors.colorF59AEF9.withValues(alpha: 0.15),
              ],
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.authGlowViolet.withValues(alpha: 0.3),
                blurRadius: 24,
              ),
            ],
          )
        : BoxDecoration(
            color: AppColors.color131A29.withValues(alpha: 0.88),
            border: Border.all(
              color: AppColors.colorF586AA6.withValues(alpha: 0.22),
            ),
            borderRadius: 14.borderRadiusAll,
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.authGlowViolet.withValues(alpha: 0.16),
                blurRadius: 24,
              ),
            ],
          );

    return DecoratedBox(
      decoration: decoration,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: RichText(
          text: TextSpan(
            style: AppStyles.bodyLarge(
              color: AppColors.colorFBFC9DE,
              height: 1.35,
            ),
            children: <TextSpan>[
              TextSpan(
                text: item.label.isNotEmpty ? '${item.label} ' : '',
                style: AppStyles.bodyLarge(
                  color: AppColors.colorDFE4F5,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
              TextSpan(text: item.value),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.title, required this.content});

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.authAccentGold.withValues(alpha: 0.45),
        ),
        borderRadius: 14.borderRadiusAll,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            AppColors.authAccentGold.withValues(alpha: 0.16),
            AppColors.authAccentGold.withValues(alpha: 0.08),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: AppStyles.bodyLarge(
                color: AppColors.colorDFE4F5,
                fontWeight: FontWeight.w700,
                height: 1.33,
              ),
            ),
            8.height,
            Text(
              content,
              style: AppStyles.bodySmall(
                color: AppColors.colorFBFC9DE.withValues(alpha: 0.9),
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModuleNavButton extends StatelessWidget {
  const _ModuleNavButton({
    required this.label,
    required this.onPressed,
    required this.isPrimary,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: 12.borderRadiusAll,
          child: Ink(
            decoration: BoxDecoration(
              border: Border.all(
                color: isPrimary
                    ? AppColors.colorF586AA6.withValues(alpha: 0.35)
                    : AppColors.authAccentGold.withValues(alpha: 0.4),
              ),
              borderRadius: 12.borderRadiusAll,
              gradient: isPrimary
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[
                        AppColors.authAccentViolet.withValues(alpha: 0.28),
                        AppColors.colorF59AEF9.withValues(alpha: 0.22),
                      ],
                    )
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[
                        AppColors.authAccentGold.withValues(alpha: 0.1),
                        AppColors.authAccentGold.withValues(alpha: 0.06),
                      ],
                    ),
            ),
            child: Center(
              child: Text(
                label,
                style: AppStyles.bodyMedium(
                  color: isPrimary
                      ? AppColors.colorF2F4F7
                      : AppColors.authAccentGold,
                  height: 1.25,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ExpandableText extends StatefulWidget {
  const _ExpandableText({
    required this.text,
    required this.style,
    this.collapsedMaxLines = 3,
  });

  final String text;
  final TextStyle style;
  final int collapsedMaxLines;

  @override
  State<_ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<_ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final TextPainter textPainter = TextPainter(
          text: TextSpan(text: widget.text, style: widget.style),
          maxLines: widget.collapsedMaxLines,
          textDirection: Directionality.of(context),
        )..layout(maxWidth: constraints.maxWidth);
        final bool hasOverflow = textPainter.didExceedMaxLines;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              widget.text,
              style: widget.style,
              maxLines: _expanded ? null : widget.collapsedMaxLines,
              overflow: _expanded
                  ? TextOverflow.visible
                  : TextOverflow.ellipsis,
            ),
            if (hasOverflow) ...<Widget>[
              4.height,
              GestureDetector(
                onTap: () => setState(() => _expanded = !_expanded),
                behavior: HitTestBehavior.opaque,
                child: Text(
                  _expanded
                      ? LocaleKey.commonCollapse.tr
                      : LocaleKey.commonExpand.tr,
                  style: AppStyles.bodySmall(
                    color: AppColors.authAccentGold,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.colorF586AA6.withValues(alpha: 0.16),
        borderRadius: 10.borderRadiusAll,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: AppStyles.caption(color: AppColors.colorFBFC9DE),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AppCardSection(
      color: AppColors.color131A29,
      border: Border.all(color: AppColors.colorF586AA6.withValues(alpha: 0.2)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: AppStyles.bodyMedium(
              color: AppColors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          6.height,
          child,
        ],
      ),
    );
  }
}

class _PsychMatrixViewModel {
  const _PsychMatrixViewModel({
    required this.title,
    required this.overview,
    required this.metrics,
    required this.strongCluster,
    required this.weakCluster,
    required this.deepInterpretation,
  });

  final String title;
  final String overview;
  final List<_PsychMetric> metrics;
  final String strongCluster;
  final String weakCluster;
  final String deepInterpretation;

  factory _PsychMatrixViewModel.fromResult({
    required _ReadingContent content,
    required Map<String, dynamic> rawResult,
  }) {
    final List<_PsychMetric> metrics = _extractMetrics(
      rawResult: rawResult,
      content: content,
    );

    final String strongCluster = _extractCluster(
      rawResult: rawResult,
      insights: content.insights,
      metricFallback: metrics.isNotEmpty ? metrics.first.label : '',
      keyCandidates: <String>[
        'strong_cluster',
        'strongest_cluster',
        'dominant_cluster',
      ],
      insightKeywords: <String>['mạnh', 'trội', 'vượt trội', 'nổi bật'],
      fallback: LocaleKey.commonNoData.tr,
    );

    final String weakCluster = _extractCluster(
      rawResult: rawResult,
      insights: content.insights,
      metricFallback: metrics.length > 1
          ? metrics.last.label
          : (metrics.isNotEmpty ? metrics.first.label : ''),
      keyCandidates: <String>[
        'weak_cluster',
        'weaker_cluster',
        'missing_cluster',
      ],
      insightKeywords: <String>[
        'thiếu',
        'cần bù',
        'yếu',
        'cân bằng',
        'bồi đắp',
      ],
      fallback: LocaleKey.commonNoData.tr,
    );

    final String deepInterpretation = _getString(rawResult, <String>[
      'deep_interpretation',
      'interpretation',
    ]).trim();
    final String actionInterpretation = content.actions.isNotEmpty
        ? content.actions.first
        : '';
    final String insightInterpretation = content.insights.length > 1
        ? content.insights[1].value
        : '';
    final String fallbackInterpretation = content.summary.isNotEmpty
        ? content.summary
        : LocaleKey.commonNoData.tr;

    return _PsychMatrixViewModel(
      title: content.title.isNotEmpty
          ? content.title
          : LocaleKey.homePsychMatrix.tr,
      overview: content.summary.isNotEmpty
          ? content.summary
          : LocaleKey.commonNoData.tr,
      metrics: metrics,
      strongCluster: strongCluster,
      weakCluster: weakCluster,
      deepInterpretation: deepInterpretation.isNotEmpty
          ? deepInterpretation
          : (actionInterpretation.isNotEmpty
                ? actionInterpretation
                : (insightInterpretation.isNotEmpty
                      ? insightInterpretation
                      : fallbackInterpretation)),
    );
  }

  static List<_PsychMetric> _extractMetrics({
    required Map<String, dynamic> rawResult,
    required _ReadingContent content,
  }) {
    final List<_PsychMetric> parsed = <_PsychMetric>[];
    const List<String> candidateKeys = <String>[
      'matrix_scores',
      'scores',
      'aspects',
      'matrix_grid',
      'dimensions',
    ];

    for (final String key in candidateKeys) {
      final dynamic value = rawResult[key];
      if (value is! List) continue;
      for (final dynamic item in value) {
        final _PsychMetric? metric = _PsychMetric.fromDynamic(item);
        if (metric != null) parsed.add(metric);
      }
      if (parsed.isNotEmpty) break;
    }

    if (parsed.isEmpty) {
      for (final _InsightItem insight in content.insights.take(9)) {
        final String label = _compactMetricLabel(
          _normalizeClusterText(insight.label),
        );
        if (label.isEmpty) continue;
        final String scoreText = _extractScoreText(
          insight.label,
          insight.value,
        );
        parsed.add(_PsychMetric(label: label, scoreText: scoreText));
      }
    }

    if (parsed.isEmpty) {
      parsed.add(
        _PsychMetric(
          label: LocaleKey.readingPsychMatrixMetricFallback.tr,
          scoreText: '',
        ),
      );
    }

    return parsed.take(9).toList();
  }

  static String _extractCluster({
    required Map<String, dynamic> rawResult,
    required List<_InsightItem> insights,
    required String metricFallback,
    required List<String> keyCandidates,
    required List<String> insightKeywords,
    required String fallback,
  }) {
    final String fromKey = _getString(rawResult, keyCandidates).trim();
    if (fromKey.isNotEmpty) {
      return _normalizeClusterText(fromKey, maxLength: 18);
    }

    for (final _InsightItem insight in insights) {
      final String normalizedLabel = insight.label.toLowerCase();
      final bool matched = insightKeywords.any(normalizedLabel.contains);
      if (!matched) continue;
      final String cluster = _normalizeClusterText(
        insight.label,
        maxLength: 18,
      );
      if (cluster.isNotEmpty) return cluster;
    }

    if (metricFallback.trim().isNotEmpty) {
      return _normalizeClusterText(metricFallback, maxLength: 18);
    }

    return fallback;
  }

  static String _getString(Map<String, dynamic> json, List<String> keys) {
    for (final String key in keys) {
      final dynamic value = json[key];
      if (value is String && value.trim().isNotEmpty) {
        return value;
      }
    }
    return '';
  }

  static String _normalizeClusterText(String input, {int? maxLength}) {
    String text = input.trim();
    if (text.isEmpty) return '';
    if (text.contains(':')) {
      final String afterColon = text.split(':').last.trim();
      if (afterColon.isNotEmpty) {
        text = afterColon;
      }
    }
    text = text.replaceAll(RegExp(r'\s*\(.*?\)\s*'), ' ').trim();
    if (maxLength != null && text.length > maxLength) {
      return '${text.substring(0, maxLength).trim()}...';
    }
    return text;
  }

  static String _extractScoreText(String primary, String secondary) {
    final RegExp scorePattern = RegExp(r'(\d{1,2})\s*/\s*(\d{1,2})');
    final RegExpMatch? first = scorePattern.firstMatch(primary);
    if (first != null) return '${first.group(1)}/${first.group(2)}';
    final RegExpMatch? second = scorePattern.firstMatch(secondary);
    if (second != null) return '${second.group(1)}/${second.group(2)}';

    final RegExp numberedPattern = RegExp(
      r's[ốo]\s*(\d{1,2})',
      caseSensitive: false,
      unicode: true,
    );
    final RegExpMatch? numberedInPrimary = numberedPattern.firstMatch(primary);
    if (numberedInPrimary != null) {
      return 'Số ${numberedInPrimary.group(1)}';
    }
    final RegExpMatch? numberedInSecondary = numberedPattern.firstMatch(
      secondary,
    );
    if (numberedInSecondary != null) {
      return 'Số ${numberedInSecondary.group(1)}';
    }

    return '';
  }

  static String _compactMetricLabel(String input) {
    String text = input.trim();
    if (text.isEmpty) return text;

    const List<String> removablePrefixes = <String>[
      'Năng lượng ',
      'Tiềm năng phát triển sự ',
      'Khao khát ',
      'Hành trình phát triển ',
      'Nhu cầu bồi đắp tính ',
      'Nhu cầu bồi đắp ',
      'Sự phát triển ',
    ];
    for (final String prefix in removablePrefixes) {
      if (text.startsWith(prefix)) {
        text = text.substring(prefix.length).trim();
        break;
      }
    }

    text = text.replaceAll(' và ', ' · ');
    if (text.length > 30) {
      text = '${text.substring(0, 30).trim()}...';
    }
    return text;
  }
}

class _PsychMetric {
  const _PsychMetric({required this.label, required this.scoreText});

  final String label;
  final String scoreText;

  static _PsychMetric? fromDynamic(dynamic item) {
    if (item is String) {
      final String text = item.trim();
      if (text.isEmpty) return null;
      if (text.contains(':')) {
        final List<String> parts = text.split(':');
        final String label = _PsychMatrixViewModel._compactMetricLabel(
          parts.first.trim(),
        );
        final String score = parts.sublist(1).join(':').trim();
        return _PsychMetric(label: label, scoreText: score);
      }
      return _PsychMetric(
        label: _PsychMatrixViewModel._compactMetricLabel(text),
        scoreText: _PsychMatrixViewModel._extractScoreText(text, ''),
      );
    }

    if (item is! Map) return null;
    final Map<String, dynamic> map = item.cast<String, dynamic>();
    final String label =
        (map['label'] as String? ??
                map['name'] as String? ??
                map['title'] as String? ??
                '')
            .trim();
    if (label.isEmpty) return null;

    final dynamic score = map['score'] ?? map['value'] ?? map['point'];
    final dynamic max = map['max'] ?? map['total'] ?? 10;
    String scoreText = '';
    if (score is num && max is num && max > 0) {
      scoreText = '${score.round()}/${max.round()}';
    } else if (score is String) {
      scoreText = score.trim();
    }
    return _PsychMetric(
      label: _PsychMatrixViewModel._compactMetricLabel(
        _PsychMatrixViewModel._normalizeClusterText(label),
      ),
      scoreText: scoreText.isNotEmpty
          ? scoreText
          : _PsychMatrixViewModel._extractScoreText(label, ''),
    );
  }
}

class _BirthChartViewModel {
  const _BirthChartViewModel({
    required this.title,
    required this.overview,
    required this.visualDescription,
    required this.axes,
    required this.missingHighlight,
  });

  final String title;
  final String overview;
  final String visualDescription;
  final List<_BirthAxis> axes;
  final String missingHighlight;

  factory _BirthChartViewModel.fromResult({
    required _ReadingContent content,
    required Map<String, dynamic> rawResult,
  }) {
    final String visualFromPayload = _getString(rawResult, <String>[
      'chart_visual_note',
      'birth_chart_visual',
      'grid_note',
    ]).trim();
    final String visualFromInsight = content.insights.isNotEmpty
        ? content.insights.first.value
        : '';
    final String visualFallback = LocaleKey.readingBirthChartVisualFallback.tr;

    final String missingFromPayload = _getString(rawResult, <String>[
      'missing_highlight',
      'missing_point',
      'weak_spot',
    ]).trim();
    final String missingFromInsight = _pickMissingInsight(content.insights);
    final String missingFromAction = content.actions.isNotEmpty
        ? content.actions.last
        : '';
    final String missingFallback = content.summary.isNotEmpty
        ? content.summary
        : LocaleKey.commonNoData.tr;

    return _BirthChartViewModel(
      title: content.title.isNotEmpty
          ? content.title
          : LocaleKey.homeBirthChart.tr,
      overview: content.summary.isNotEmpty
          ? content.summary
          : LocaleKey.commonNoData.tr,
      visualDescription: visualFromPayload.isNotEmpty
          ? visualFromPayload
          : (visualFromInsight.isNotEmpty ? visualFromInsight : visualFallback),
      axes: _extractAxes(rawResult),
      missingHighlight: missingFromPayload.isNotEmpty
          ? missingFromPayload
          : (missingFromInsight.isNotEmpty
                ? missingFromInsight
                : (missingFromAction.isNotEmpty
                      ? missingFromAction
                      : missingFallback)),
    );
  }

  static List<_BirthAxis> _extractAxes(Map<String, dynamic> rawResult) {
    final List<_BirthAxis> defaults = <_BirthAxis>[
      _BirthAxis(
        code: '1-4-7',
        subtitle: LocaleKey.readingBirthChartAxisAction.tr,
      ),
      _BirthAxis(
        code: '2-5-8',
        subtitle: LocaleKey.readingBirthChartAxisEmotion.tr,
      ),
      _BirthAxis(
        code: '3-6-9',
        subtitle: LocaleKey.readingBirthChartAxisMind.tr,
      ),
    ];

    final dynamic rawAxes = rawResult['axes'];
    if (rawAxes is! List || rawAxes.isEmpty) return defaults;

    final Map<String, _BirthAxis> parsedByCode = <String, _BirthAxis>{};
    for (final dynamic item in rawAxes) {
      if (item is! Map) continue;
      final Map<String, dynamic> map = item.cast<String, dynamic>();
      final String code = (map['code'] as String? ?? '').trim();
      if (code.isEmpty) continue;
      final String subtitle =
          (map['label'] as String? ??
                  map['subtitle'] as String? ??
                  map['domain'] as String? ??
                  '')
              .trim();
      if (subtitle.isEmpty) continue;
      parsedByCode[code] = _BirthAxis(code: code, subtitle: subtitle);
    }

    return defaults
        .map((_BirthAxis axis) => parsedByCode[axis.code] ?? axis)
        .toList();
  }

  static String _pickMissingInsight(List<_InsightItem> insights) {
    const List<String> missingHints = <String>[
      'thiếu',
      'thách thức',
      'cần bù',
      'cần rèn',
      'cân bằng',
      'ổn định',
    ];
    for (final _InsightItem insight in insights) {
      final String mixed =
          '${insight.label.toLowerCase()} ${insight.value.toLowerCase()}';
      final bool isMatch = missingHints.any(mixed.contains);
      if (!isMatch) continue;
      if (insight.value.trim().isNotEmpty) {
        return insight.value.trim();
      }
      if (insight.label.trim().isNotEmpty) {
        return insight.label.trim();
      }
    }
    return '';
  }

  static String _getString(Map<String, dynamic> json, List<String> keys) {
    for (final String key in keys) {
      final dynamic value = json[key];
      if (value is String && value.trim().isNotEmpty) {
        return value;
      }
    }
    return '';
  }
}

class _BirthAxis {
  const _BirthAxis({required this.code, required this.subtitle});

  final String code;
  final String subtitle;
}

class _EnergyBoostViewModel {
  const _EnergyBoostViewModel({
    required this.title,
    required this.dominantTitle,
    required this.dominantDescription,
    required this.talentTags,
    required this.weaknessTags,
    required this.dailyAction,
  });

  final String title;
  final String dominantTitle;
  final String dominantDescription;
  final List<String> talentTags;
  final List<String> weaknessTags;
  final String dailyAction;

  factory _EnergyBoostViewModel.fromResult({
    required _ReadingContent content,
    required Map<String, dynamic> rawResult,
  }) {
    final String dominantTitle = _ReadingParseUtils.firstNonEmpty(<String>[
      _ReadingParseUtils.getString(rawResult, <String>[
        'dominant_title',
        'dominant_energy',
        'highlight_title',
      ]),
      _ReadingParseUtils.findInsightLabelByKeywords(
        insights: content.insights,
        keywords: <String>['mạnh', 'trội', 'ưu thế', 'điểm sáng', 'nổi bật'],
      ),
    ], LocaleKey.readingEnergyBoostDominantTitle.tr);

    final String dominantDescription = _ReadingParseUtils.firstNonEmpty(
      <String>[
        _ReadingParseUtils.getString(rawResult, <String>[
          'dominant_description',
          'dominant_analysis',
          'highlight',
          'overview',
        ]),
        _ReadingParseUtils.findInsightValueByKeywords(
          insights: content.insights,
          keywords: <String>['mạnh', 'trội', 'ưu thế', 'tài năng', 'điểm sáng'],
        ),
        content.insights.isNotEmpty ? content.insights.first.value : '',
        content.summary,
      ],
      LocaleKey.commonNoData.tr,
    );

    final List<String> talentTags = _ReadingParseUtils.extractTags(
      rawResult: rawResult,
      keyCandidates: <String>[
        'talent_tags',
        'strength_tags',
        'talents',
        'strengths',
        'positive_traits',
      ],
      insights: content.insights,
      keywordCandidates: <String>[
        'tài năng',
        'điểm mạnh',
        'thế mạnh',
        'ưu thế',
        'mạnh',
        'nổi bật',
      ],
      fallbackText: content.summary,
    );

    final List<String> weaknessTags = _ReadingParseUtils.extractTags(
      rawResult: rawResult,
      keyCandidates: <String>[
        'weakness_tags',
        'weaknesses',
        'risks',
        'improve_tags',
        'bottlenecks',
      ],
      insights: content.insights,
      keywordCandidates: <String>[
        'yếu',
        'cần bù',
        'thử thách',
        'cản trở',
        'hao hụt',
        'điểm mù',
      ],
      fallbackText: content.actions.join('; '),
    );

    final String dailyAction = _ReadingParseUtils.firstNonEmpty(<String>[
      _ReadingParseUtils.getString(rawResult, <String>[
        'daily_action',
        'action_plan',
        'recommendation',
        'guidance',
      ]),
      content.actions.join('\n'),
      _ReadingParseUtils.findInsightValueByKeywords(
        insights: content.insights,
        keywords: <String>['hành động', 'thói quen', 'gợi ý', 'ứng dụng'],
      ),
    ], LocaleKey.commonNoData.tr);

    return _EnergyBoostViewModel(
      title: content.title.isNotEmpty
          ? content.title
          : LocaleKey.homeEnergyBoost.tr,
      dominantTitle: dominantTitle,
      dominantDescription: dominantDescription,
      talentTags: talentTags,
      weaknessTags: weaknessTags,
      dailyAction: dailyAction,
    );
  }
}

class _CompatibilityViewModel {
  const _CompatibilityViewModel({
    required this.title,
    required this.overview,
    required this.harmony,
    required this.caution,
    required this.principles,
  });

  final String title;
  final String overview;
  final String harmony;
  final String caution;
  final String principles;

  factory _CompatibilityViewModel.fromResult({
    required _ReadingContent content,
    required Map<String, dynamic> rawResult,
  }) {
    final String overview = _ReadingParseUtils.firstNonEmpty(<String>[
      content.summary,
      _ReadingParseUtils.getString(rawResult, <String>[
        'overview',
        'summary_text',
      ]),
      _ReadingParseUtils.findInsightValueByKeywords(
        insights: content.insights,
        keywords: <String>['tổng quan', 'đánh giá', 'mức độ'],
      ),
    ], LocaleKey.commonNoData.tr);

    final String harmony = _ReadingParseUtils.firstNonEmpty(<String>[
      _ReadingParseUtils.getString(rawResult, <String>[
        'harmony',
        'harmony_zone',
        'strength_zone',
      ]),
      _ReadingParseUtils.findInsightValueByKeywords(
        insights: content.insights,
        keywords: <String>[
          'hòa hợp',
          'điểm hợp',
          'đồng điệu',
          'hỗ trợ',
          'thuận lợi',
        ],
      ),
      content.insights.isNotEmpty ? content.insights.first.value : '',
    ], LocaleKey.commonNoData.tr);

    final String caution = _ReadingParseUtils.firstNonEmpty(<String>[
      _ReadingParseUtils.getString(rawResult, <String>[
        'caution',
        'conflict_zone',
        'risk_zone',
      ]),
      _ReadingParseUtils.findInsightValueByKeywords(
        insights: content.insights,
        keywords: <String>[
          'xung đột',
          'khác biệt',
          'lưu ý',
          'thử thách',
          'rủi ro',
        ],
      ),
      content.insights.length > 1 ? content.insights[1].value : '',
    ], LocaleKey.commonNoData.tr);

    final String principles = _ReadingParseUtils.firstNonEmpty(<String>[
      _ReadingParseUtils.getString(rawResult, <String>[
        'principles',
        'communication_principles',
        'guidelines',
      ]),
      content.actions.join('\n'),
      _ReadingParseUtils.findInsightValueByKeywords(
        insights: content.insights,
        keywords: <String>['nguyên tắc', 'giao tiếp', 'thỏa thuận', 'ứng xử'],
      ),
    ], LocaleKey.commonNoData.tr);

    return _CompatibilityViewModel(
      title: content.title.isNotEmpty
          ? content.title
          : LocaleKey.homeCompatibility.tr,
      overview: overview,
      harmony: harmony,
      caution: caution,
      principles: principles,
    );
  }
}

class _FourPeaksViewModel {
  const _FourPeaksViewModel({
    required this.title,
    required this.overview,
    required this.stages,
  });

  final String title;
  final String overview;
  final List<_StageItem> stages;

  factory _FourPeaksViewModel.fromResult({
    required _ReadingContent content,
    required Map<String, dynamic> rawResult,
  }) {
    return _FourPeaksViewModel(
      title: content.title.isNotEmpty
          ? content.title
          : LocaleKey.homeFourPeaks.tr,
      overview: _ReadingParseUtils.firstNonEmpty(<String>[
        content.summary,
        _ReadingParseUtils.getString(rawResult, <String>[
          'overview',
          'summary_text',
        ]),
      ], LocaleKey.commonNoData.tr),
      stages: _ReadingParseUtils.extractStages(
        rawResult: rawResult,
        keys: <String>['stages', 'peaks'],
        fallbackInsights: content.insights,
        stageTitlePrefix: LocaleKey.readingFourPeaksStagePrefix.tr,
      ),
    );
  }
}

class _FourChallengesViewModel {
  const _FourChallengesViewModel({
    required this.title,
    required this.overview,
    required this.stages,
    required this.strategy,
  });

  final String title;
  final String overview;
  final List<_StageItem> stages;
  final String strategy;

  factory _FourChallengesViewModel.fromResult({
    required _ReadingContent content,
    required Map<String, dynamic> rawResult,
  }) {
    return _FourChallengesViewModel(
      title: content.title.isNotEmpty
          ? content.title
          : LocaleKey.homeFourChallenges.tr,
      overview: _ReadingParseUtils.firstNonEmpty(<String>[
        content.summary,
        _ReadingParseUtils.getString(rawResult, <String>[
          'overview',
          'summary_text',
        ]),
      ], LocaleKey.commonNoData.tr),
      stages: _ReadingParseUtils.extractStages(
        rawResult: rawResult,
        keys: <String>['stages', 'challenges', 'challenge_stages'],
        fallbackInsights: content.insights,
        stageTitlePrefix: LocaleKey.readingFourChallengesStagePrefix.tr,
      ),
      strategy: _ReadingParseUtils.firstNonEmpty(<String>[
        _ReadingParseUtils.getString(rawResult, <String>[
          'strategy',
          'action_strategy',
          'coping_strategy',
        ]),
        content.actions.join('\n'),
        content.insights.length > 3 ? content.insights[3].value : '',
      ], LocaleKey.commonNoData.tr),
    );
  }
}

class _ForecastViewModel {
  const _ForecastViewModel({
    required this.title,
    required this.entryHint,
    required this.overview,
    required this.themeTags,
    required this.focus,
    required this.opportunity,
    required this.caution,
    required this.actions,
    required this.nextCtaLabel,
    required this.onNext,
  });

  final String title;
  final String entryHint;
  final String overview;
  final List<String> themeTags;
  final String focus;
  final String opportunity;
  final String caution;
  final List<String> actions;
  final String nextCtaLabel;
  final VoidCallback onNext;

  factory _ForecastViewModel.fromResult({
    required _ForecastPeriod period,
    required _ReadingContent content,
    required Map<String, dynamic> rawResult,
  }) {
    final String overview = _ReadingParseUtils.firstNonEmpty(<String>[
      content.summary,
      _ReadingParseUtils.getString(rawResult, <String>[
        'overview',
        'summary_text',
      ]),
    ], LocaleKey.commonNoData.tr);

    final List<String> themeTags = content.insights
        .map(
          (_InsightItem e) =>
              _ReadingParseUtils.cleanInsightLabel(e.label, maxLength: 26),
        )
        .where((String value) => value.isNotEmpty)
        .take(4)
        .toList();

    final String focus = _ReadingParseUtils.firstNonEmpty(<String>[
      _ReadingParseUtils.findInsightValueByKeywords(
        insights: content.insights,
        keywords: <String>[
          'chủ đề',
          'trọng tâm',
          'năng lượng',
          'kích hoạt',
          'chính',
        ],
      ),
      content.insights.isNotEmpty ? content.insights.first.value : '',
      overview,
    ], LocaleKey.commonNoData.tr);

    final String opportunity = _ReadingParseUtils.firstNonEmpty(<String>[
      _ReadingParseUtils.findInsightValueByKeywords(
        insights: content.insights,
        keywords: <String>[
          'cơ hội',
          'bứt phá',
          'phát triển',
          'nâng tầm',
          'tối ưu',
          'hài hòa',
        ],
      ),
      content.insights.length > 1 ? content.insights[1].value : '',
      focus,
    ], LocaleKey.commonNoData.tr);

    final String caution = _ReadingParseUtils.firstNonEmpty(<String>[
      _ReadingParseUtils.findInsightValueByKeywords(
        insights: content.insights,
        keywords: <String>[
          'rủi ro',
          'lưu ý',
          'thử thách',
          'cân bằng',
          'quản trị',
          'cẩn trọng',
        ],
      ),
      content.insights.length > 2 ? content.insights[2].value : '',
      content.actions.isNotEmpty ? content.actions.first : '',
    ], LocaleKey.commonNoData.tr);

    final List<String> actions = content.actions.isNotEmpty
        ? content.actions
        : content.insights.map((_InsightItem e) => e.value).take(3).toList();

    return _ForecastViewModel(
      title: content.title.isNotEmpty
          ? content.title
          : _defaultTitleByPeriod(period),
      entryHint: _entryHintByPeriod(period),
      overview: overview,
      themeTags: themeTags.isNotEmpty
          ? themeTags
          : <String>[LocaleKey.readingForecastThemeFallback.tr],
      focus: focus,
      opportunity: opportunity,
      caution: caution,
      actions: actions.isNotEmpty
          ? actions
          : <String>[LocaleKey.commonNoData.tr],
      nextCtaLabel: _nextLabelByPeriod(period),
      onNext: _nextActionByPeriod(period),
    );
  }

  static String _defaultTitleByPeriod(_ForecastPeriod period) {
    switch (period) {
      case _ForecastPeriod.day:
        return LocaleKey.homeForecastDay.tr;
      case _ForecastPeriod.month:
        return LocaleKey.homeForecastMonth.tr;
      case _ForecastPeriod.year:
        return LocaleKey.homeForecastYear.tr;
    }
  }

  static String _entryHintByPeriod(_ForecastPeriod period) {
    switch (period) {
      case _ForecastPeriod.day:
        return LocaleKey.readingForecastDayEntryHint.tr;
      case _ForecastPeriod.month:
        return LocaleKey.readingForecastMonthEntryHint.tr;
      case _ForecastPeriod.year:
        return LocaleKey.readingForecastYearEntryHint.tr;
    }
  }

  static String _nextLabelByPeriod(_ForecastPeriod period) {
    switch (period) {
      case _ForecastPeriod.day:
        return LocaleKey.readingForecastDayNextMonth.tr;
      case _ForecastPeriod.month:
        return LocaleKey.readingForecastMonthNextYear.tr;
      case _ForecastPeriod.year:
        return LocaleKey.readingForecastYearToChatbot.tr;
    }
  }

  static VoidCallback _nextActionByPeriod(_ForecastPeriod period) {
    switch (period) {
      case _ForecastPeriod.day:
        return () {
          Get.offNamed(
            AppPages.readingDetail,
            arguments: <String, dynamic>{
              'feature_key': FeatureKeys.forecastMonth,
              'title_key': LocaleKey.homeForecastMonth,
            },
          );
        };
      case _ForecastPeriod.month:
        return () {
          Get.offNamed(
            AppPages.readingDetail,
            arguments: <String, dynamic>{
              'feature_key': FeatureKeys.forecastYear,
              'title_key': LocaleKey.homeForecastYear,
            },
          );
        };
      case _ForecastPeriod.year:
        return () => Get.toNamed(AppPages.aiChat);
    }
  }
}

class _ReadingParseUtils {
  const _ReadingParseUtils._();

  static String firstNonEmpty(List<String> values, String fallback) {
    for (final String value in values) {
      final String normalized = value.trim();
      if (normalized.isNotEmpty) {
        return normalized;
      }
    }
    return fallback;
  }

  static String getString(Map<String, dynamic> json, List<String> keys) {
    for (final String key in keys) {
      final dynamic value = json[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return '';
  }

  static String findInsightLabelByKeywords({
    required List<_InsightItem> insights,
    required List<String> keywords,
  }) {
    for (final _InsightItem insight in insights) {
      final String target = insight.label.toLowerCase();
      if (!keywords.any(target.contains)) continue;
      if (insight.label.trim().isNotEmpty) {
        return insight.label.trim();
      }
    }
    return '';
  }

  static String findInsightValueByKeywords({
    required List<_InsightItem> insights,
    required List<String> keywords,
  }) {
    for (final _InsightItem insight in insights) {
      final String target =
          '${insight.label.toLowerCase()} ${insight.value.toLowerCase()}';
      if (!keywords.any(target.contains)) continue;
      if (insight.value.trim().isNotEmpty) {
        return insight.value.trim();
      }
      if (insight.label.trim().isNotEmpty) {
        return insight.label.trim();
      }
    }
    return '';
  }

  static String cleanInsightLabel(String input, {int maxLength = 24}) {
    String text = input.trim();
    if (text.isEmpty) return '';
    if (text.contains(':')) {
      text = text.split(':').first.trim();
    }
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (text.length > maxLength) {
      text = '${text.substring(0, maxLength).trim()}...';
    }
    return text;
  }

  static List<String> extractTags({
    required Map<String, dynamic> rawResult,
    required List<String> keyCandidates,
    required List<_InsightItem> insights,
    required List<String> keywordCandidates,
    required String fallbackText,
  }) {
    final List<String> fromPayload = getStringList(rawResult, keyCandidates);
    if (fromPayload.isNotEmpty) return fromPayload;

    final List<String> fromInsights = <String>[];
    for (final _InsightItem insight in insights) {
      final String haystack =
          '${insight.label.toLowerCase()} ${insight.value.toLowerCase()}';
      if (!keywordCandidates.any(haystack.contains)) continue;
      fromInsights.addAll(splitTags('${insight.label};${insight.value}'));
    }
    if (fromInsights.isNotEmpty) {
      return _unique(fromInsights).take(6).toList();
    }

    final List<String> fallbackTags = splitTags(fallbackText);
    if (fallbackTags.isNotEmpty) {
      return fallbackTags.take(6).toList();
    }

    return <String>[LocaleKey.commonNoData.tr];
  }

  static List<String> getStringList(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    for (final String key in keys) {
      final dynamic value = json[key];
      if (value is List) {
        final List<String> parsed = <String>[];
        for (final dynamic item in value) {
          if (item is String) {
            parsed.addAll(splitTags(item));
            continue;
          }
          if (item is Map) {
            final Map<String, dynamic> map = item.cast<String, dynamic>();
            parsed.addAll(
              splitTags(
                (map['name'] as String? ??
                        map['label'] as String? ??
                        map['title'] as String? ??
                        map['value']?.toString() ??
                        '')
                    .trim(),
              ),
            );
          }
        }
        final List<String> cleaned = _unique(parsed);
        if (cleaned.isNotEmpty) return cleaned;
      }

      if (value is String && value.trim().isNotEmpty) {
        final List<String> parsed = splitTags(value);
        if (parsed.isNotEmpty) return parsed;
      }
    }
    return <String>[];
  }

  static List<String> splitTags(String raw) {
    final List<String> parts = raw
        .split(RegExp(r'[\n;,|•]+'))
        .map((String e) => e.trim())
        .where((String e) => e.isNotEmpty)
        .toList();

    final List<String> tags = <String>[];
    for (final String part in parts) {
      String text = part;
      text = text.replaceFirst(RegExp(r'^\d+[\)\.\-\s]+'), '');
      if (text.contains(':')) {
        text = text.split(':').last.trim();
      }
      text = text.replaceAll(RegExp(r'\s+'), ' ').trim();
      if (text.isEmpty || text.length > 36) continue;
      tags.add(text);
    }
    return _unique(tags);
  }

  static List<_StageItem> extractStages({
    required Map<String, dynamic> rawResult,
    required List<String> keys,
    required List<_InsightItem> fallbackInsights,
    required String stageTitlePrefix,
  }) {
    final List<_StageItem> parsedFromPayload = <_StageItem>[];
    for (final String key in keys) {
      final dynamic value = rawResult[key];
      if (value is! List) continue;
      for (int index = 0; index < value.length; index++) {
        final dynamic item = value[index];
        if (item is! Map) continue;
        final Map<String, dynamic> map = item.cast<String, dynamic>();
        final String title = firstNonEmpty(<String>[
          (map['title'] as String? ?? '').trim(),
          (map['label'] as String? ?? '').trim(),
          (map['name'] as String? ?? '').trim(),
          '$stageTitlePrefix ${index + 1}',
        ], '$stageTitlePrefix ${index + 1}');
        final String description = firstNonEmpty(<String>[
          (map['description'] as String? ?? '').trim(),
          (map['value'] as String? ?? '').trim(),
          (map['insight'] as String? ?? '').trim(),
        ], LocaleKey.commonNoData.tr);
        parsedFromPayload.add(
          _StageItem(title: title, description: description),
        );
      }
      if (parsedFromPayload.isNotEmpty) break;
    }

    if (parsedFromPayload.isNotEmpty) {
      return _fillStageSlots(parsedFromPayload, stageTitlePrefix);
    }

    final List<_StageItem> parsedFromInsights = <_StageItem>[];
    for (int index = 0; index < fallbackInsights.length && index < 4; index++) {
      final _InsightItem insight = fallbackInsights[index];
      final String title = insight.label.trim().isNotEmpty
          ? insight.label.trim()
          : '$stageTitlePrefix ${index + 1}';
      final String description = firstNonEmpty(<String>[
        insight.value,
        insight.label,
      ], LocaleKey.commonNoData.tr);
      parsedFromInsights.add(
        _StageItem(title: title, description: description),
      );
    }

    return _fillStageSlots(parsedFromInsights, stageTitlePrefix);
  }

  static List<_StageItem> _fillStageSlots(
    List<_StageItem> stages,
    String stageTitlePrefix,
  ) {
    final List<_StageItem> filled = stages.take(4).toList();
    while (filled.length < 4) {
      final int position = filled.length + 1;
      filled.add(
        _StageItem(
          title: '$stageTitlePrefix $position',
          description: LocaleKey.commonNoData.tr,
        ),
      );
    }
    return filled;
  }

  static List<String> _unique(List<String> values) {
    final Set<String> visited = <String>{};
    final List<String> output = <String>[];
    for (final String value in values) {
      final String normalized = value.trim();
      if (normalized.isEmpty) continue;
      final String key = normalized.toLowerCase();
      if (visited.contains(key)) continue;
      visited.add(key);
      output.add(normalized);
    }
    return output;
  }
}

class _ReadingContent {
  const _ReadingContent({
    required this.title,
    required this.summary,
    required this.insights,
    required this.actions,
  });

  final String title;
  final String summary;
  final List<_InsightItem> insights;
  final List<String> actions;

  bool get hasStructuredData =>
      title.isNotEmpty ||
      summary.isNotEmpty ||
      insights.isNotEmpty ||
      actions.isNotEmpty;

  factory _ReadingContent.fromJson(Map<String, dynamic> json) {
    final dynamic rawInsights = json['insights'];
    final dynamic rawActions = json['actions'];

    final List<_InsightItem> parsedInsights = <_InsightItem>[];
    if (rawInsights is List) {
      for (final dynamic item in rawInsights) {
        if (item is! Map) continue;
        final String label = (item['label'] as String? ?? '').trim();
        final String value = (item['value'] as String? ?? '').trim();
        if (label.isEmpty && value.isEmpty) continue;
        parsedInsights.add(
          _InsightItem(label: label.isEmpty ? '-' : label, value: value),
        );
      }
    }

    final List<String> parsedActions = <String>[];
    if (rawActions is List) {
      for (final dynamic item in rawActions) {
        final String text = (item as String? ?? '').trim();
        if (text.isEmpty) continue;
        parsedActions.add(text);
      }
    }

    return _ReadingContent(
      title: (json['title'] as String? ?? '').trim(),
      summary: (json['summary'] as String? ?? '').trim(),
      insights: parsedInsights,
      actions: parsedActions,
    );
  }
}

class _InsightItem {
  const _InsightItem({required this.label, required this.value});

  final String label;
  final String value;
}
