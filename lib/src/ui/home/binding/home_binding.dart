import 'package:get/get.dart';

import 'package:soulnum/src/core/repository/profile_repository.dart';
import 'package:soulnum/src/ui/home/interactor/home_cubit.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<HomeCubit>()) {
      Get.lazyPut<HomeCubit>(
        () => HomeCubit(Get.find<ProfileRepository>()),
      );
    }
  }
}
