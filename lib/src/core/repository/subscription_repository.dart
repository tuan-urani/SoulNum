import 'package:soulnum/src/api/supabase/supabase_ai_data_source.dart';
import 'package:soulnum/src/core/model/request/sync_subscription_request.dart';
import 'package:soulnum/src/core/model/response/subscription_sync_response.dart';

class SubscriptionRepository {
  const SubscriptionRepository(this._dataSource);

  final SupabaseAiDataSource _dataSource;

  Future<SubscriptionSyncResponse> syncSubscription(SyncSubscriptionRequest request) async {
    final Map<String, dynamic> json = await _dataSource.syncSubscription(request);
    return SubscriptionSyncResponse.fromJson(json);
  }
}

