import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:soulnum/src/core/constants/feature_keys.dart';
import 'package:soulnum/src/core/model/feature_tile_model.dart';
import 'package:soulnum/src/extensions/int_extensions.dart';
import 'package:soulnum/src/locale/locale_key.dart';
import 'package:soulnum/src/ui/widgets/app_card_section.dart';
import 'package:soulnum/src/utils/app_colors.dart';
import 'package:soulnum/src/utils/app_styles.dart';

class HomeFeatureGrid extends StatelessWidget {
  const HomeFeatureGrid({
    super.key,
    required this.tiles,
    required this.onTapTile,
    required this.isTileEnabled,
  });

  final List<FeatureTileModel> tiles;
  final ValueChanged<FeatureTileModel> onTapTile;
  final bool Function(FeatureTileModel tile) isTileEnabled;

  static const Map<String, _FeatureVisualMeta> _featureMeta =
      <String, _FeatureVisualMeta>{
        'profile_summary': _FeatureVisualMeta(
          icon: Icons.person_search_rounded,
          symbol: '00',
          subtitleKey: LocaleKey.homeFeatureProfileSummaryHint,
          accent: AppColors.authAccentGold,
        ),
        FeatureKeys.coreNumbers: _FeatureVisualMeta(
          icon: Icons.auto_awesome_rounded,
          symbol: '1',
          subtitleKey: LocaleKey.homeFeatureCoreNumbersHint,
          accent: AppColors.authAccentGold,
        ),
        FeatureKeys.psychMatrix: _FeatureVisualMeta(
          icon: Icons.grid_view_rounded,
          symbol: '3-6-9',
          subtitleKey: LocaleKey.homeFeaturePsychMatrixHint,
          accent: AppColors.authAccentViolet,
        ),
        FeatureKeys.birthChart: _FeatureVisualMeta(
          icon: Icons.stars_rounded,
          symbol: '1-9',
          subtitleKey: LocaleKey.homeFeatureBirthChartHint,
          accent: AppColors.colorF59AEF9,
        ),
        FeatureKeys.energyBoost: _FeatureVisualMeta(
          icon: Icons.bolt_rounded,
          symbol: '8',
          subtitleKey: LocaleKey.homeFeatureEnergyBoostHint,
          accent: AppColors.color88CF66,
        ),
        FeatureKeys.compatibility: _FeatureVisualMeta(
          icon: Icons.favorite_rounded,
          symbol: '2',
          subtitleKey: LocaleKey.homeFeatureCompatibilityHint,
          accent: AppColors.colorFF8C42,
        ),
        FeatureKeys.fourPeaks: _FeatureVisualMeta(
          icon: Icons.terrain_rounded,
          symbol: '4',
          subtitleKey: LocaleKey.homeFeatureFourPeaksHint,
          accent: AppColors.colorF39702,
        ),
        FeatureKeys.fourChallenges: _FeatureVisualMeta(
          icon: Icons.security_rounded,
          symbol: '4',
          subtitleKey: LocaleKey.homeFeatureFourChallengesHint,
          accent: AppColors.colorFEF4056,
        ),
        FeatureKeys.biorhythmDaily: _FeatureVisualMeta(
          icon: Icons.timelapse_rounded,
          symbol: '24H',
          subtitleKey: LocaleKey.homeFeatureDailyBiorhythmHint,
          accent: AppColors.color0095FF,
        ),
        FeatureKeys.forecastDay: _FeatureVisualMeta(
          icon: Icons.today_rounded,
          symbol: 'D',
          subtitleKey: LocaleKey.homeFeatureForecastDayHint,
          accent: AppColors.colorF59AEF9,
        ),
        FeatureKeys.forecastMonth: _FeatureVisualMeta(
          icon: Icons.calendar_month_rounded,
          symbol: 'M',
          subtitleKey: LocaleKey.homeFeatureForecastMonthHint,
          accent: AppColors.authAccentViolet,
        ),
        FeatureKeys.forecastYear: _FeatureVisualMeta(
          icon: Icons.event_repeat_rounded,
          symbol: 'Y',
          subtitleKey: LocaleKey.homeFeatureForecastYearHint,
          accent: AppColors.authAccentGold,
        ),
        FeatureKeys.chatAssistant: _FeatureVisualMeta(
          icon: Icons.forum_rounded,
          symbol: 'AI',
          subtitleKey: LocaleKey.homeFeatureVipChatHint,
          accent: AppColors.colorFFE53E,
        ),
      };

  _FeatureVisualMeta _resolveMeta(String featureKey) =>
      _featureMeta[featureKey] ??
      const _FeatureVisualMeta(
        icon: Icons.auto_awesome_rounded,
        symbol: 'SN',
        subtitleKey: LocaleKey.homeFeatureCoreNumbersHint,
        accent: AppColors.authAccentGold,
      );

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: tiles.length,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.94,
      ),
      itemBuilder: (BuildContext context, int index) {
        final FeatureTileModel tile = tiles[index];
        final bool enabled = isTileEnabled(tile);
        final _FeatureVisualMeta meta = _resolveMeta(tile.featureKey);

        final Color accentColor = meta.accent.withValues(
          alpha: enabled ? 1 : 0.65,
        );
        return Opacity(
          opacity: enabled ? 1 : 0.45,
          child: GestureDetector(
            onTap: enabled ? () => onTapTile(tile) : null,
            child: AppCardSection(
              color: AppColors.authBackgroundSurface,
              border: Border.all(color: accentColor.withValues(alpha: 0.28)),
              padding: 12.paddingAll,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.12),
                  blurRadius: 16,
                  spreadRadius: 0,
                  offset: const Offset(0, 6),
                ),
              ],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: accentColor.withValues(alpha: 0.42),
                          ),
                        ),
                        child: Icon(meta.icon, size: 17, color: accentColor),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: accentColor.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Text(
                          meta.symbol,
                          style: AppStyles.caption(
                            color: accentColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  10.height,
                  Text(
                    tile.titleKey.tr,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyles.bodyLarge(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  6.height,
                  Expanded(
                    child: Text(
                      meta.subtitleKey.tr,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: AppStyles.bodySmall(
                        color: AppColors.colorFBFC9DE,
                        fontWeight: FontWeight.w400,
                        height: 1.35,
                      ),
                    ),
                  ),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: <Widget>[
                      if (tile.requiresVip || tile.requiresAdGate)
                        _FeatureBadge(
                          label: tile.requiresVip
                              ? LocaleKey.statusVip.tr
                              : LocaleKey.badgeAd.tr,
                          color: accentColor,
                        ),
                      if (!enabled)
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: AppColors.colorF586AA6.withValues(
                              alpha: 0.28,
                            ),
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: Icon(
                            Icons.lock_rounded,
                            size: 12,
                            color: AppColors.colorFBFC9DE,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FeatureBadge extends StatelessWidget {
  const _FeatureBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: AppStyles.caption(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _FeatureVisualMeta {
  const _FeatureVisualMeta({
    required this.icon,
    required this.symbol,
    required this.subtitleKey,
    required this.accent,
  });

  final IconData icon;
  final String symbol;
  final String subtitleKey;
  final Color accent;
}
