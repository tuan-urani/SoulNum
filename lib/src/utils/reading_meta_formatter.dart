import 'package:get/get.dart';
import 'package:soulnum/src/core/constants/feature_keys.dart';
import 'package:soulnum/src/core/model/reading_model.dart';
import 'package:soulnum/src/locale/locale_key.dart';

class ReadingScopeMeta {
  const ReadingScopeMeta({required this.label, required this.value});

  final String label;
  final String value;

  String get pillText => '$label: $value';
}

class ReadingMetaFormatter {
  const ReadingMetaFormatter._();

  static String formatGeneratedAt(DateTime value) {
    return '${_twoDigits(value.day)}/${_twoDigits(value.month)}/${value.year} • '
        '${_twoDigits(value.hour)}:${_twoDigits(value.minute)}';
  }

  static String sourceLabel(bool fromCache) {
    return fromCache
        ? LocaleKey.readingResultSourceCache.tr
        : LocaleKey.readingResultSourceGenerated.tr;
  }

  static ReadingScopeMeta? targetMeta(ReadingModel reading) {
    if (reading.targetDate != null) {
      return ReadingScopeMeta(
        label: LocaleKey.readingResultTargetDateLabel.tr,
        value: formatDateOnly(reading.targetDate!),
      );
    }

    final String normalizedPeriod = reading.targetPeriod?.trim() ?? '';
    if (normalizedPeriod.isEmpty) {
      return null;
    }

    if (reading.featureKey == FeatureKeys.forecastMonth) {
      return ReadingScopeMeta(
        label: LocaleKey.readingResultTargetMonthLabel.tr,
        value: formatMonthKey(normalizedPeriod),
      );
    }

    if (reading.featureKey == FeatureKeys.forecastYear) {
      return ReadingScopeMeta(
        label: LocaleKey.readingResultTargetYearLabel.tr,
        value: normalizedPeriod,
      );
    }

    return ReadingScopeMeta(
      label: LocaleKey.readingResultTargetLabel.tr,
      value: normalizedPeriod,
    );
  }

  static String formatDateOnly(DateTime value) {
    return '${_twoDigits(value.day)}/${_twoDigits(value.month)}/${value.year}';
  }

  static String formatMonthKey(String value) {
    final Match? match = RegExp(r'^(\d{4})-(\d{2})$').firstMatch(value.trim());
    if (match == null) {
      return value;
    }
    return '${match.group(2)}/${match.group(1)}';
  }

  static String? yearKeyFromMonthKey(String? value) {
    final String normalized = value?.trim() ?? '';
    final Match? match = RegExp(r'^(\d{4})-(\d{2})$').firstMatch(normalized);
    if (match == null) {
      return null;
    }
    return match.group(1);
  }

  static String toIsoDate(DateTime value) {
    return '${value.year}-${_twoDigits(value.month)}-${_twoDigits(value.day)}';
  }

  static String _twoDigits(int value) => value.toString().padLeft(2, '0');
}
