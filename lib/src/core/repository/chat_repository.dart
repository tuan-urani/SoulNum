import 'package:soulnum/src/api/supabase/supabase_ai_data_source.dart';
import 'package:soulnum/src/core/model/request/chat_with_guide_request.dart';
import 'package:soulnum/src/core/model/response/chat_reply_response.dart';

class ChatRepository {
  const ChatRepository(this._dataSource);

  final SupabaseAiDataSource _dataSource;

  Future<ChatReplyResponse> chatWithGuide(ChatWithGuideRequest request) async {
    final Map<String, dynamic> json = await _dataSource.chatWithGuide(request);
    return ChatReplyResponse.fromJson(json);
  }
}

