import 'package:soulnum/src/api/edge_functions/ai_gateway_api.dart';
import 'package:soulnum/src/core/constants/feature_keys.dart';
import 'package:soulnum/src/core/model/request/chat_with_guide_request.dart';
import 'package:soulnum/src/core/model/request/delete_profile_request.dart';
import 'package:soulnum/src/core/model/request/get_history_feed_request.dart';
import 'package:soulnum/src/core/model/request/get_reading_request.dart';
import 'package:soulnum/src/core/model/request/sync_subscription_request.dart';
import 'package:soulnum/src/core/model/request/unlock_daily_biorhythm_request.dart';

class SupabaseAiDataSource {
  const SupabaseAiDataSource(this._gatewayApi);

  final AiGatewayApi _gatewayApi;

  Future<Map<String, dynamic>> getOrGenerateReading(GetReadingRequest request) {
    return _gatewayApi.invoke(
      functionName: EdgeFunctionNames.getOrGenerateReading,
      body: request.toJson(),
    );
  }

  Future<Map<String, dynamic>> chatWithGuide(ChatWithGuideRequest request) {
    return _gatewayApi.invoke(
      functionName: EdgeFunctionNames.chatWithGuide,
      body: request.toJson(),
    );
  }

  Future<Map<String, dynamic>> unlockDailyBiorhythm(UnlockDailyBiorhythmRequest request) {
    return _gatewayApi.invoke(
      functionName: EdgeFunctionNames.unlockDailyBiorhythm,
      body: request.toJson(),
    );
  }

  Future<Map<String, dynamic>> syncSubscription(SyncSubscriptionRequest request) {
    return _gatewayApi.invoke(
      functionName: EdgeFunctionNames.syncSubscription,
      body: request.toJson(),
    );
  }

  Future<Map<String, dynamic>> deleteProfilePermanently(DeleteProfileRequest request) {
    return _gatewayApi.invoke(
      functionName: EdgeFunctionNames.deleteProfilePermanently,
      body: request.toJson(),
    );
  }

  Future<Map<String, dynamic>> getHistoryFeed(GetHistoryFeedRequest request) {
    return _gatewayApi.invoke(
      functionName: EdgeFunctionNames.getHistoryFeed,
      body: request.toJson(),
    );
  }
}

