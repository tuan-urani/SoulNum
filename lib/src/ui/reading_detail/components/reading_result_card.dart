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
