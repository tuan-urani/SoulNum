import 'package:soulnum/src/api/supabase/supabase_ai_data_source.dart';
import 'package:soulnum/src/core/mapper/soul_mapper.dart';
import 'package:soulnum/src/core/model/history_item_model.dart';
import 'package:soulnum/src/core/model/request/get_history_feed_request.dart';
import 'package:soulnum/src/core/model/response/history_feed_response.dart';

class HistoryRepository {
  const HistoryRepository(this._dataSource);

  final SupabaseAiDataSource _dataSource;

  Future<(List<HistoryItemModel>, DateTime?)> getHistory(GetHistoryFeedRequest request) async {
    final Map<String, dynamic> json = await _dataSource.getHistoryFeed(request);
    final HistoryFeedResponse response = HistoryFeedResponse.fromJson(json);
    final List<HistoryItemModel> items = response.items.map(SoulMapper.toHistoryItem).toList();
    return (items, response.nextCursor);
  }
}

