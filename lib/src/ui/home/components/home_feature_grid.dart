import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
        childAspectRatio: 1.25,
      ),
      itemBuilder: (BuildContext context, int index) {
        final FeatureTileModel tile = tiles[index];
        final bool enabled = isTileEnabled(tile);
        return Opacity(
          opacity: enabled ? 1 : 0.45,
          child: GestureDetector(
            onTap: enabled ? () => onTapTile(tile) : null,
            child: AppCardSection(
              color: const Color(0xFF121226),
              border: Border.all(
                color: AppColors.colorF586AA6.withValues(alpha: 0.2),
              ),
              padding: 12.paddingAll,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      tile.titleKey.tr,
                      style: AppStyles.bodyLarge(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (tile.requiresVip || tile.requiresAdGate)
                    Text(
                      tile.requiresVip
                          ? LocaleKey.statusVip.tr
                          : LocaleKey.badgeAd.tr,
                      style: AppStyles.caption(color: AppColors.primary),
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
