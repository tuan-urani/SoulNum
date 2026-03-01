import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:soulnum/src/core/model/reading_model.dart';
import 'package:soulnum/src/extensions/int_extensions.dart';
import 'package:soulnum/src/locale/locale_key.dart';
import 'package:soulnum/src/ui/widgets/app_card_section.dart';
import 'package:soulnum/src/utils/app_colors.dart';
import 'package:soulnum/src/utils/app_styles.dart';

class DailyCycleUnlocked extends StatelessWidget {
  const DailyCycleUnlocked({super.key, required this.reading});

  final ReadingModel reading;

  @override
  Widget build(BuildContext context) {
    final _DailyCycleViewModel viewModel = _DailyCycleViewModel.fromReading(
      reading,
    );

    return ListView(
      children: <Widget>[
        Text(
          LocaleKey.dailyCycleUnlocked.tr,
          style: AppStyles.bodyLarge(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        12.height,
        _DailyCycleTitleCard(
          title: viewModel.title,
          generatedAt: viewModel.generatedAt,
        ),
        10.height,
        _DailyCycleSectionCard(
          title: LocaleKey.dailyCycleOverviewTitle.tr,
          content: viewModel.summary,
          accent: AppColors.authAccentViolet,
        ),
        10.height,
        _DailyCycleSectionCard(
          title: LocaleKey.dailyCyclePhysicalTitle.tr,
          content: viewModel.physical.description,
          accent: AppColors.color88CF66,
          scoreText: viewModel.physical.scoreText,
          badgeText: viewModel.physical.badgeText,
        ),
        10.height,
        _DailyCycleSectionCard(
          title: LocaleKey.dailyCycleEmotionalTitle.tr,
          content: viewModel.emotional.description,
          accent: AppColors.authAccentGold,
          scoreText: viewModel.emotional.scoreText,
          badgeText: viewModel.emotional.badgeText,
        ),
        10.height,
        _DailyCycleSectionCard(
          title: LocaleKey.dailyCycleIntellectualTitle.tr,
          content: viewModel.intellectual.description,
          accent: AppColors.colorF59AEF9,
          scoreText: viewModel.intellectual.scoreText,
          badgeText: viewModel.intellectual.badgeText,
        ),
        10.height,
        _DailyCycleActionsCard(
          title: LocaleKey.dailyCycleSuggestionsTitle.tr,
          actions: viewModel.actions,
        ),
        if (viewModel.extraInsights.isNotEmpty) ...<Widget>[
          10.height,
          _DailyCycleInsightsCard(insights: viewModel.extraInsights),
        ],
      ],
    );
  }
}

class _DailyCycleTitleCard extends StatelessWidget {
  const _DailyCycleTitleCard({required this.title, required this.generatedAt});

  final String title;
  final DateTime generatedAt;

  @override
  Widget build(BuildContext context) {
    return AppCardSection(
      color: AppColors.authBackgroundSurface,
      borderRadius: 16.borderRadiusAll,
      border: Border.all(color: AppColors.colorFB1B8D1.withValues(alpha: 0.3)),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: AppStyles.bodyLarge(
              color: AppColors.colorF2F4F7,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
          8.height,
          Text(
            _formatGeneratedAt(generatedAt),
            style: AppStyles.bodySmall(
              color: AppColors.colorFBFC9DE.withValues(alpha: 0.78),
            ),
          ),
        ],
      ),
    );
  }

  String _formatGeneratedAt(DateTime value) {
    String twoDigits(int number) => number.toString().padLeft(2, '0');
    return '${twoDigits(value.day)}/${twoDigits(value.month)}/${value.year} • '
        '${twoDigits(value.hour)}:${twoDigits(value.minute)}';
  }
}

class _DailyCycleSectionCard extends StatelessWidget {
  const _DailyCycleSectionCard({
    required this.title,
    required this.content,
    required this.accent,
    this.scoreText,
    this.badgeText,
  });

  final String title;
  final String content;
  final Color accent;
  final String? scoreText;
  final String? badgeText;

  @override
  Widget build(BuildContext context) {
    return AppCardSection(
      color: AppColors.authBackgroundSurface,
      borderRadius: 16.borderRadiusAll,
      border: Border.all(color: accent.withValues(alpha: 0.34)),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Text(
                  title,
                  style: AppStyles.bodyLarge(
                    color: AppColors.colorF2F4F7,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if ((scoreText ?? '').trim().isNotEmpty)
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.15),
                    borderRadius: 8.borderRadiusAll,
                    border: Border.all(color: accent.withValues(alpha: 0.5)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Text(
                      scoreText!,
                      style: AppStyles.bodyMedium(
                        color: accent,
                        fontWeight: FontWeight.w700,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if ((badgeText ?? '').trim().isNotEmpty) ...<Widget>[
            8.height,
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: 999.borderRadiusAll,
                color: AppColors.colorF586AA6.withValues(alpha: 0.14),
                border: Border.all(
                  color: AppColors.colorF586AA6.withValues(alpha: 0.28),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                child: Text(
                  badgeText!,
                  style: AppStyles.bodySmall(
                    color: AppColors.colorFBFC9DE,
                    fontWeight: FontWeight.w500,
                    height: 1.0,
                  ),
                ),
              ),
            ),
          ],
          8.height,
          Text(
            content,
            style: AppStyles.bodyMedium(
              color: AppColors.colorFBFC9DE,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyCycleActionsCard extends StatelessWidget {
  const _DailyCycleActionsCard({required this.title, required this.actions});

  final String title;
  final List<String> actions;

  @override
  Widget build(BuildContext context) {
    return AppCardSection(
      color: AppColors.authBackgroundSurface,
      borderRadius: 16.borderRadiusAll,
      border: Border.all(color: AppColors.colorF586AA6.withValues(alpha: 0.32)),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: AppStyles.bodyLarge(
              color: AppColors.colorF2F4F7,
              fontWeight: FontWeight.w700,
            ),
          ),
          8.height,
          ...actions.asMap().entries.map(
            (MapEntry<int, String> entry) => Padding(
              padding: 8.paddingBottom,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '${entry.key + 1}.',
                    style: AppStyles.bodyMedium(
                      color: AppColors.authAccentGold,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  8.width,
                  Expanded(
                    child: Text(
                      entry.value,
                      style: AppStyles.bodyMedium(
                        color: AppColors.colorFBFC9DE,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyCycleInsightsCard extends StatelessWidget {
  const _DailyCycleInsightsCard({required this.insights});

  final List<_InsightItem> insights;

  @override
  Widget build(BuildContext context) {
    return AppCardSection(
      color: AppColors.authBackgroundSurface,
      borderRadius: 16.borderRadiusAll,
      border: Border.all(color: AppColors.colorFB1B8D1.withValues(alpha: 0.22)),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            LocaleKey.dailyCycleMoreInsightsTitle.tr,
            style: AppStyles.bodyLarge(
              color: AppColors.colorF2F4F7,
              fontWeight: FontWeight.w700,
            ),
          ),
          8.height,
          ...insights.map(
            (_InsightItem item) => Padding(
              padding: 8.paddingBottom,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    item.label,
                    style: AppStyles.bodyMedium(
                      color: AppColors.authAccentViolet,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                  4.height,
                  Text(
                    item.value,
                    style: AppStyles.bodyMedium(
                      color: AppColors.colorFBFC9DE,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyCycleViewModel {
  const _DailyCycleViewModel({
    required this.title,
    required this.summary,
    required this.physical,
    required this.emotional,
    required this.intellectual,
    required this.actions,
    required this.extraInsights,
    required this.generatedAt,
  });

  final String title;
  final String summary;
  final _CycleBlock physical;
  final _CycleBlock emotional;
  final _CycleBlock intellectual;
  final List<String> actions;
  final List<_InsightItem> extraInsights;
  final DateTime generatedAt;

  factory _DailyCycleViewModel.fromReading(ReadingModel reading) {
    final Map<String, dynamic> raw = reading.result;
    final List<_InsightItem> insights = _parseInsights(raw['insights']);
    final List<String> actions = _parseActions(raw['actions']);

    final _CycleBlock physical = _resolveCycleBlock(
      raw: raw,
      insights: insights,
      fallbackIndex: 0,
      keyCandidates: <String>[
        'physical_cycle',
        'physical',
        'cycle_physical',
        'body_cycle',
      ],
    );
    final _CycleBlock emotional = _resolveCycleBlock(
      raw: raw,
      insights: insights,
      fallbackIndex: 1,
      keyCandidates: <String>[
        'emotional_cycle',
        'emotional',
        'cycle_emotional',
        'feeling_cycle',
      ],
    );
    final _CycleBlock intellectual = _resolveCycleBlock(
      raw: raw,
      insights: insights,
      fallbackIndex: 2,
      keyCandidates: <String>[
        'intellectual_cycle',
        'intellectual',
        'cycle_intellectual',
        'mental_cycle',
      ],
    );

    final String summary = _readString(raw, <String>['summary']).trim();

    return _DailyCycleViewModel(
      title: _readString(raw, <String>['title']).trim().isNotEmpty
          ? _readString(raw, <String>['title']).trim()
          : LocaleKey.dailyCycleTitle.tr,
      summary: summary.isNotEmpty ? summary : LocaleKey.commonNoData.tr,
      physical: physical,
      emotional: emotional,
      intellectual: intellectual,
      actions: actions.isNotEmpty
          ? actions
          : <String>[LocaleKey.commonNoData.tr],
      extraInsights: insights.length > 3
          ? insights.sublist(3)
          : <_InsightItem>[],
      generatedAt: reading.generatedAt,
    );
  }

  static _CycleBlock _resolveCycleBlock({
    required Map<String, dynamic> raw,
    required List<_InsightItem> insights,
    required int fallbackIndex,
    required List<String> keyCandidates,
  }) {
    final dynamic payload = _firstValue(raw, keyCandidates);
    String description = '';
    String scoreText = '';
    String badgeText = '';

    if (payload is Map) {
      final Map<String, dynamic> map = payload.cast<String, dynamic>();
      description = _readString(map, <String>[
        'description',
        'summary',
        'detail',
        'insight',
        'value',
        'message',
      ]).trim();
      scoreText = _extractScoreTextFromAny(
        _firstValue(map, <String>['score', 'percent', 'index', 'energy']),
      );
      badgeText = _readString(map, <String>[
        'trend',
        'status',
        'state',
        'label',
      ]).trim();
    } else if (payload is String) {
      description = payload.trim();
      scoreText = _extractScoreTextFromText(payload);
    } else if (payload is num) {
      scoreText = _extractScoreTextFromAny(payload);
    }

    final _InsightItem? fallbackInsight =
        fallbackIndex >= 0 && fallbackIndex < insights.length
        ? insights[fallbackIndex]
        : null;

    if (description.isEmpty && fallbackInsight != null) {
      description = fallbackInsight.value;
    }
    if (badgeText.isEmpty && fallbackInsight != null) {
      badgeText = fallbackInsight.label;
    }
    if (scoreText.isEmpty && fallbackInsight != null) {
      scoreText = _extractScoreTextFromText(
        '${fallbackInsight.label} ${fallbackInsight.value}',
      );
    }

    return _CycleBlock(
      description: description.isNotEmpty
          ? description
          : LocaleKey.commonNoData.tr,
      scoreText: scoreText,
      badgeText: badgeText,
    );
  }

  static List<_InsightItem> _parseInsights(dynamic rawInsights) {
    final List<_InsightItem> output = <_InsightItem>[];
    if (rawInsights is! List) return output;
    for (final dynamic item in rawInsights) {
      if (item is! Map) continue;
      final Map<String, dynamic> map = item.cast<String, dynamic>();
      final String label = (map['label'] as String? ?? '').trim();
      final String value = (map['value'] as String? ?? '').trim();
      if (label.isEmpty && value.isEmpty) continue;
      output.add(
        _InsightItem(
          label: label.isNotEmpty ? label : LocaleKey.commonNoData.tr,
          value: value.isNotEmpty ? value : LocaleKey.commonNoData.tr,
        ),
      );
    }
    return output;
  }

  static List<String> _parseActions(dynamic rawActions) {
    final List<String> output = <String>[];
    if (rawActions is! List) return output;
    for (final dynamic item in rawActions) {
      if (item is! String) continue;
      final String text = item.trim();
      if (text.isEmpty) continue;
      output.add(text);
    }
    return output;
  }

  static String _readString(Map<String, dynamic> map, List<String> keys) {
    for (final String key in keys) {
      final dynamic value = map[key];
      if (value is! String) continue;
      final String text = value.trim();
      if (text.isNotEmpty) return text;
    }
    return '';
  }

  static dynamic _firstValue(Map<String, dynamic> map, List<String> keys) {
    for (final String key in keys) {
      if (!map.containsKey(key)) continue;
      final dynamic value = map[key];
      if (value == null) continue;
      if (value is String && value.trim().isEmpty) continue;
      return value;
    }
    return null;
  }

  static String _extractScoreTextFromAny(dynamic value) {
    if (value is num) {
      if (value >= 0 && value <= 1) {
        return '${(value * 100).round()}%';
      }
      if (value > 1 && value <= 10) {
        final String asText = value % 1 == 0
            ? value.toInt().toString()
            : value.toStringAsFixed(1);
        return '$asText/10';
      }
      if (value > 10 && value <= 100) {
        return '${value.round()}%';
      }
      return value.toString();
    }
    if (value is String) {
      return _extractScoreTextFromText(value);
    }
    return '';
  }

  static String _extractScoreTextFromText(String text) {
    final RegExp percent = RegExp(r'(-?\d+(?:[.,]\d+)?)\s*%');
    final RegExp slashTen = RegExp(r'(-?\d+(?:[.,]\d+)?)\s*/\s*10');
    final RegExp plainTen = RegExp(r'(-?\d+(?:[.,]\d+)?)\s*trên\s*10');

    final RegExpMatch? percentMatch = percent.firstMatch(text);
    if (percentMatch != null) {
      return '${percentMatch.group(1)}%';
    }
    final RegExpMatch? slashTenMatch = slashTen.firstMatch(text);
    if (slashTenMatch != null) {
      return '${slashTenMatch.group(1)}/10';
    }
    final RegExpMatch? plainTenMatch = plainTen.firstMatch(text);
    if (plainTenMatch != null) {
      return '${plainTenMatch.group(1)}/10';
    }
    return '';
  }
}

class _CycleBlock {
  const _CycleBlock({
    required this.description,
    required this.scoreText,
    required this.badgeText,
  });

  final String description;
  final String scoreText;
  final String badgeText;
}

class _InsightItem {
  const _InsightItem({required this.label, required this.value});

  final String label;
  final String value;
}
