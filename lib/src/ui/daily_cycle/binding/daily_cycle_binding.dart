import 'package:get/get.dart';
import 'package:soulnum/src/core/repository/profile_repository.dart';
import 'package:soulnum/src/core/repository/reading_repository.dart';
import 'package:soulnum/src/ui/daily_cycle/interactor/daily_cycle_cubit.dart';

class DailyCycleBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<DailyCycleCubit>()) {
      Get.lazyPut<DailyCycleCubit>(
        () => DailyCycleCubit(
          Get.find<ProfileRepository>(),
          Get.find<ReadingRepository>(),
        ),
      );
    }
  }
}

