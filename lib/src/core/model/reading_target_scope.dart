import 'package:soulnum/src/core/constants/feature_keys.dart';

class ReadingTargetScope {
  const ReadingTargetScope({this.targetDate, this.targetPeriod});

  final DateTime? targetDate;
  final String? targetPeriod;

  static ReadingTargetScope resolve({
    required String featureKey,
    DateTime? requestedTargetDate,
    String? requestedTargetPeriod,
    DateTime? referenceDate,
  }) {
    final DateTime baseDate =
        requestedTargetDate ?? referenceDate ?? DateTime.now();
    final DateTime normalizedDate = DateTime(
      baseDate.year,
      baseDate.month,
      baseDate.day,
    );

    if (featureKey == FeatureKeys.forecastDay ||
        featureKey == FeatureKeys.biorhythmDaily) {
      return ReadingTargetScope(targetDate: normalizedDate);
    }

    if (featureKey == FeatureKeys.forecastMonth) {
      return ReadingTargetScope(
        targetPeriod: _normalizeMonthKey(
          raw: requestedTargetPeriod,
          fallbackDate: normalizedDate,
        ),
      );
    }

    if (featureKey == FeatureKeys.forecastYear) {
      return ReadingTargetScope(
        targetPeriod: _normalizeYearKey(
          raw: requestedTargetPeriod,
          fallbackDate: normalizedDate,
        ),
      );
    }

    return const ReadingTargetScope();
  }

  static String _normalizeMonthKey({
    required String? raw,
    required DateTime fallbackDate,
  }) {
    final String normalized = raw?.trim() ?? '';
    if (RegExp(r'^\d{4}-\d{2}$').hasMatch(normalized)) {
      return normalized;
    }
    return '${fallbackDate.year}-${_twoDigits(fallbackDate.month)}';
  }

  static String _normalizeYearKey({
    required String? raw,
    required DateTime fallbackDate,
  }) {
    final String normalized = raw?.trim() ?? '';
    if (RegExp(r'^\d{4}$').hasMatch(normalized)) {
      return normalized;
    }
    return '${fallbackDate.year}';
  }

  static String _twoDigits(int value) => value.toString().padLeft(2, '0');
}
