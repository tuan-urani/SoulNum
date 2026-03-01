import 'package:get/get.dart';
import 'package:soulnum/src/api/edge_functions/ai_gateway_api.dart';
import 'package:soulnum/src/api/supabase/supabase_ai_data_source.dart';
import 'package:soulnum/src/api/supabase/supabase_auth_data_source.dart';
import 'package:soulnum/src/api/supabase/supabase_client_factory.dart';
import 'package:soulnum/src/api/supabase/supabase_profile_data_source.dart';
import 'package:soulnum/src/core/repository/chat_repository.dart';
import 'package:soulnum/src/core/repository/history_repository.dart';
import 'package:soulnum/src/core/repository/profile_deletion_repository.dart';
import 'package:soulnum/src/core/repository/profile_repository.dart';
import 'package:soulnum/src/core/repository/reading_repository.dart';
import 'package:soulnum/src/core/repository/session_repository.dart';
import 'package:soulnum/src/core/repository/subscription_repository.dart';

Future<void> registerCoreModule() async {
  if (!Get.isRegistered<SupabaseClientFactory>()) {
    Get.put<SupabaseClientFactory>(const SupabaseClientFactory(), permanent: true);
  }

  if (!Get.isRegistered<SupabaseAuthDataSource>()) {
    Get.put<SupabaseAuthDataSource>(
      SupabaseAuthDataSource(Get.find<SupabaseClientFactory>().client),
      permanent: true,
    );
  }

  if (!Get.isRegistered<AiGatewayApi>()) {
    Get.put<AiGatewayApi>(
      AiGatewayApi(Get.find<SupabaseClientFactory>().client),
      permanent: true,
    );
  }

  if (!Get.isRegistered<SupabaseAiDataSource>()) {
    Get.put<SupabaseAiDataSource>(
      SupabaseAiDataSource(Get.find<AiGatewayApi>()),
      permanent: true,
    );
  }

  if (!Get.isRegistered<SupabaseProfileDataSource>()) {
    Get.put<SupabaseProfileDataSource>(
      SupabaseProfileDataSource(Get.find<SupabaseClientFactory>().client),
      permanent: true,
    );
  }

  if (!Get.isRegistered<SessionRepository>()) {
    Get.put<SessionRepository>(
      SessionRepository(Get.find<SupabaseAuthDataSource>()),
      permanent: true,
    );
  }
  if (!Get.isRegistered<ProfileRepository>()) {
    Get.put<ProfileRepository>(
      ProfileRepository(Get.find<SupabaseProfileDataSource>()),
      permanent: true,
    );
  }
  if (!Get.isRegistered<ReadingRepository>()) {
    Get.put<ReadingRepository>(
      ReadingRepository(Get.find<SupabaseAiDataSource>()),
      permanent: true,
    );
  }
  if (!Get.isRegistered<ChatRepository>()) {
    Get.put<ChatRepository>(
      ChatRepository(Get.find<SupabaseAiDataSource>()),
      permanent: true,
    );
  }
  if (!Get.isRegistered<SubscriptionRepository>()) {
    Get.put<SubscriptionRepository>(
      SubscriptionRepository(Get.find<SupabaseAiDataSource>()),
      permanent: true,
    );
  }
  if (!Get.isRegistered<HistoryRepository>()) {
    Get.put<HistoryRepository>(
      HistoryRepository(Get.find<SupabaseAiDataSource>()),
      permanent: true,
    );
  }
  if (!Get.isRegistered<ProfileDeletionRepository>()) {
    Get.put<ProfileDeletionRepository>(
      ProfileDeletionRepository(Get.find<SupabaseAiDataSource>()),
      permanent: true,
    );
  }
}
