import 'package:soulnum/src/core/model/chat_message_model.dart';
import 'package:soulnum/src/core/model/entitlement_model.dart';
import 'package:soulnum/src/core/model/history_item_model.dart';
import 'package:soulnum/src/core/model/reading_model.dart';
import 'package:soulnum/src/core/model/response/entitlement_response.dart';
import 'package:soulnum/src/core/model/response/profile_row_response.dart';
import 'package:soulnum/src/core/model/response/reading_response.dart';
import 'package:soulnum/src/core/model/user_profile_model.dart';

class SoulMapper {
  const SoulMapper._();

  static UserProfileModel toProfile(ProfileRowResponse response) {
    return UserProfileModel(
      id: response.id,
      ownerUserId: response.ownerUserId,
      fullName: response.fullName,
      birthDate: response.birthDate,
      isActive: response.isActive,
      gender: response.gender,
      relationLabel: response.relationLabel,
    );
  }

  static EntitlementModel toEntitlement(EntitlementResponse response) {
    return EntitlementModel(
      isVipPro: response.isVipPro,
      planCode: response.planCode,
      profileLimit: response.profileLimit,
      chatbotMonthlyLimit: response.chatbotMonthlyLimit,
      adFreeDailyCycle: response.adFreeDailyCycle,
      entitleStartAt: response.entitleStartAt,
      entitleEndAt: response.entitleEndAt,
    );
  }

  static ReadingModel toReading(ReadingResponse response) {
    return ReadingModel(
      readingId: response.readingId,
      featureKey: response.featureKey,
      result: response.result,
      generatedAt: response.generatedAt,
      fromCache: response.fromCache,
    );
  }

  static HistoryItemModel toHistoryItem(Map<String, dynamic> row) {
    return HistoryItemModel(
      id: row['id'] as String? ?? '',
      featureKey: row['feature_key'] as String? ?? '',
      createdAt: DateTime.tryParse(row['created_at'] as String? ?? '') ?? DateTime.now(),
      resultSnapshot: (row['result_snapshot'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{},
      targetDate: DateTime.tryParse(row['target_date'] as String? ?? ''),
      periodKey: row['period_key'] as String?,
    );
  }

  static ChatMessageModel toAssistantMessage(String content) {
    return ChatMessageModel(
      role: 'assistant',
      content: content,
      createdAt: DateTime.now(),
    );
  }

  static ChatMessageModel toUserMessage(String content) {
    return ChatMessageModel(
      role: 'user',
      content: content,
      createdAt: DateTime.now(),
    );
  }
}

