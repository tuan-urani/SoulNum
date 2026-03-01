import 'package:soulnum/src/api/supabase/supabase_ai_data_source.dart';
import 'package:soulnum/src/core/mapper/soul_mapper.dart';
import 'package:soulnum/src/core/model/reading_model.dart';
import 'package:soulnum/src/core/model/request/get_reading_request.dart';
import 'package:soulnum/src/core/model/request/unlock_daily_biorhythm_request.dart';
import 'package:soulnum/src/core/model/response/daily_unlock_response.dart';
import 'package:soulnum/src/core/model/response/reading_response.dart';

class ReadingRepository {
  const ReadingRepository(this._dataSource);

  final SupabaseAiDataSource _dataSource;

  Future<ReadingModel> getOrGenerateReading(GetReadingRequest request) async {
    final Map<String, dynamic> json = await _dataSource.getOrGenerateReading(request);
    return SoulMapper.toReading(ReadingResponse.fromJson(json));
  }

  Future<DailyUnlockResponse> unlockDailyBiorhythm(UnlockDailyBiorhythmRequest request) async {
    final Map<String, dynamic> json = await _dataSource.unlockDailyBiorhythm(request);
    return DailyUnlockResponse.fromJson(json);
  }
}

