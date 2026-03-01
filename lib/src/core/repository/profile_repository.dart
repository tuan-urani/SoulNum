import 'package:soulnum/src/api/supabase/supabase_profile_data_source.dart';
import 'package:soulnum/src/core/mapper/soul_mapper.dart';
import 'package:soulnum/src/core/model/entitlement_model.dart';
import 'package:soulnum/src/core/model/request/profile_upsert_request.dart';
import 'package:soulnum/src/core/model/response/entitlement_response.dart';
import 'package:soulnum/src/core/model/response/profile_row_response.dart';
import 'package:soulnum/src/core/model/user_profile_model.dart';

class ProfileRepository {
  const ProfileRepository(this._dataSource);

  final SupabaseProfileDataSource _dataSource;

  Future<List<UserProfileModel>> getProfiles() async {
    final List<Map<String, dynamic>> rows = await _dataSource.getProfiles();
    return rows.map((Map<String, dynamic> row) => SoulMapper.toProfile(ProfileRowResponse.fromJson(row))).toList();
  }

  Future<UserProfileModel> createProfile(ProfileUpsertRequest request) async {
    final Map<String, dynamic> row = await _dataSource.createProfile(
      fullName: request.fullName,
      birthDate: request.birthDate,
      gender: request.gender,
      relationLabel: request.relationLabel,
    );
    return SoulMapper.toProfile(ProfileRowResponse.fromJson(row));
  }

  Future<void> setActiveProfile(String profileId) => _dataSource.setActiveProfile(profileId);

  Future<EntitlementModel?> getEntitlement() async {
    final Map<String, dynamic>? row = await _dataSource.getEntitlement();
    if (row == null) return null;
    return SoulMapper.toEntitlement(EntitlementResponse.fromJson(row));
  }
}

