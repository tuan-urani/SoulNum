import 'package:get/get.dart';
import 'package:soulnum/src/core/repository/profile_repository.dart';
import 'package:soulnum/src/core/repository/reading_repository.dart';
import 'package:soulnum/src/ui/compatibility/interactor/compatibility_cubit.dart';

class CompatibilityBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<CompatibilityCubit>()) {
      Get.lazyPut<CompatibilityCubit>(
        () => CompatibilityCubit(
          Get.find<ProfileRepository>(),
          Get.find<ReadingRepository>(),
        ),
      );
    }
  }
}

