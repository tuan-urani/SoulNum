import 'package:soulnum/src/helper/app_logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseProfileDataSource {
  const SupabaseProfileDataSource(this._client);

  final SupabaseClient _client;

  String? _resolveUserIdOrNull() {
    final String? currentUserId = _client.auth.currentUser?.id;
    if (currentUserId != null && currentUserId.isNotEmpty) {
      return currentUserId;
    }
    final String? sessionUserId = _client.auth.currentSession?.user.id;
    if (sessionUserId != null && sessionUserId.isNotEmpty) {
      return sessionUserId;
    }
    return null;
  }

  String _resolveUserIdRequired() {
    final String? userId = _resolveUserIdOrNull();
    if (userId != null && userId.isNotEmpty) {
      return userId;
    }
    throw AuthException('Unauthorized');
  }

  Future<List<Map<String, dynamic>>> getProfiles() async {
    final String? userId = _resolveUserIdOrNull();
    if (userId == null || userId.isEmpty) {
      return const <Map<String, dynamic>>[];
    }

    return AppLogger.trace<List<Map<String, dynamic>>>(
      action: 'SupabaseTable.user_profiles.select',
      request: <String, dynamic>{
        'select':
            'id,owner_user_id,full_name,birth_date,gender,relation_label,is_active,created_at',
        'owner_user_id': userId,
        'deleted_at': null,
        'order': 'created_at.desc',
      },
      run: () async {
        final List<dynamic> rows = await _client
            .from('user_profiles')
            .select(
              'id,owner_user_id,full_name,birth_date,gender,relation_label,is_active,created_at',
            )
            .eq('owner_user_id', userId)
            .isFilter('deleted_at', null)
            .order('created_at', ascending: false);
        return rows
            .map((dynamic e) => (e as Map).cast<String, dynamic>())
            .toList(growable: false);
      },
      responseMapper: (List<Map<String, dynamic>> result) => <String, dynamic>{
        'count': result.length,
      },
    );
  }

  Future<Map<String, dynamic>> createProfile({
    required String fullName,
    required DateTime birthDate,
    String? gender,
    String? relationLabel,
  }) async {
    final String userId = _resolveUserIdRequired();

    final List<dynamic> existingProfiles = await _client
        .from('user_profiles')
        .select('id')
        .eq('owner_user_id', userId)
        .isFilter('deleted_at', null)
        .limit(1);

    final bool shouldSetActive = existingProfiles.isEmpty;

    final Map<String, dynamic> payload = <String, dynamic>{
      'owner_user_id': userId,
      'full_name': fullName,
      'birth_date': birthDate.toIso8601String().split('T').first,
      'gender': gender,
      'relation_label': relationLabel,
      'is_active': shouldSetActive,
    };

    return AppLogger.trace<Map<String, dynamic>>(
      action: 'SupabaseTable.user_profiles.insert',
      request: payload,
      run: () async {
        final Map<String, dynamic> row = await _client
            .from('user_profiles')
            .insert(payload)
            .select(
              'id,owner_user_id,full_name,birth_date,gender,relation_label,is_active',
            )
            .single();
        return row;
      },
      responseMapper: (Map<String, dynamic> result) => <String, dynamic>{
        'id': result['id'],
      },
    );
  }

  Future<void> setActiveProfile(String profileId) async {
    final String userId = _resolveUserIdRequired();

    await AppLogger.trace<void>(
      action: 'SupabaseTable.user_profiles.setActive',
      request: <String, dynamic>{'user_id': userId, 'profile_id': profileId},
      run: () async {
        await _client
            .from('user_profiles')
            .update(<String, dynamic>{'is_active': false})
            .eq('owner_user_id', userId)
            .isFilter('deleted_at', null);
        await _client
            .from('user_profiles')
            .update(<String, dynamic>{'is_active': true})
            .eq('id', profileId)
            .eq('owner_user_id', userId)
            .isFilter('deleted_at', null);
      },
      responseMapper: (_) => <String, dynamic>{'updated': true},
    );
  }

  Future<Map<String, dynamic>?> getEntitlement() async {
    return AppLogger.trace<Map<String, dynamic>?>(
      action: 'SupabaseTable.subscription_entitlements.select',
      request: <String, dynamic>{'select': '*', 'limit': 1},
      run: () async {
        final dynamic result = await _client
            .from('subscription_entitlements')
            .select('*')
            .maybeSingle();
        if (result == null) {
          return null;
        }
        return (result as Map).cast<String, dynamic>();
      },
      responseMapper: (Map<String, dynamic>? result) => <String, dynamic>{
        'found': result != null,
        'is_vip_pro': result?['is_vip_pro'],
      },
    );
  }
}
