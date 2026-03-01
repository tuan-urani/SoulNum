import 'package:soulnum/src/api/supabase/supabase_ai_data_source.dart';
import 'package:soulnum/src/core/model/request/delete_profile_request.dart';
import 'package:soulnum/src/core/model/response/delete_profile_response.dart';

class ProfileDeletionRepository {
  const ProfileDeletionRepository(this._dataSource);

  final SupabaseAiDataSource _dataSource;

  Future<DeleteProfileResponse> deleteProfilePermanently(DeleteProfileRequest request) async {
    final Map<String, dynamic> json = await _dataSource.deleteProfilePermanently(request);
    return DeleteProfileResponse.fromJson(json);
  }
}

